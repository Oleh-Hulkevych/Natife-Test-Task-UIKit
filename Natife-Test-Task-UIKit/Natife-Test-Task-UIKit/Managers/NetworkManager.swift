//
//  NetworkManager.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import Foundation
import Network

final class NetworkManager {

    private let networkMonitor = NWPathMonitor()
    private let networkMonitorQueue = DispatchQueue(label: "NetworkMonitor", attributes: .concurrent)

    private let decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    var isNetworkConnected: Bool {
        return networkMonitor.currentPath.status == .satisfied
    }
    
    init() {
        startMonitoringNetwork()
    }
    
    private func startMonitoringNetwork() {
        networkMonitor.start(queue: networkMonitorQueue)
    }
    
    private func stopMonitoringNetwork() {
        networkMonitor.cancel()
    }
    
    func wrapOnBackground<T, E: Error>(_ function: @escaping (@escaping (Result<T, E>) -> Void) -> Void, completionOnMain completion: @escaping (Result<T, E>) -> Void) {
        DispatchQueue.global().async {
            function { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[FeedPost], NetworkError>) -> Void) {
        
        guard isNetworkConnected else {
            completion(.failure(.noInternetConnection))
            return
        }
        
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(.networkError(underlyingError: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidHTTPStatusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataReceived))
                return
            }
            
            do {
                let result = try self.decoder.decode([String: [FeedPost]].self, from: data)
                if let posts = result["posts"] {
                    completion(.success(posts))
                } else {
                    completion(.failure(.noPostsKeyFound))
                }
            } catch let decodingError {
                completion(.failure(.decodingError(underlyingError: decodingError)))
            }
        }
        task.resume()
    }
    
    func fetchPostById(postId: Int, completion: @escaping (Result<PostInfo, NetworkError>) -> Void) {
        
        guard isNetworkConnected else {
            completion(.failure(.noInternetConnection))
            return
        }
        let urlString = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/posts/\(postId).json"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(.networkError(underlyingError: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidHTTPStatusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataReceived))
                return
            }
            
            do {
                let result = try self.decoder.decode([String: PostInfo].self, from: data)
                if let posts = result["post"] {
                    completion(.success(posts))
                } else {
                    completion(.failure(.noPostsKeyFound))
                }
            } catch let decodingError {
                completion(.failure(.decodingError(underlyingError: decodingError)))
            }
        }
        task.resume()
    }
}

extension NetworkManager {
    
    enum NetworkError: LocalizedError {
        case invalidURL
        case noDataReceived
        case noPostsKeyFound
        case networkError(underlyingError: Error)
        case noInternetConnection
        case invalidHTTPStatusCode
        case decodingError(underlyingError: Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .noDataReceived:
                return "No data received."
            case .noPostsKeyFound:
                return "No 'posts' key found."
            case .networkError(let underlyingError):
                return "Network error: \(underlyingError.localizedDescription)"
            case .noInternetConnection:
                return "No internet connection."
            case .invalidHTTPStatusCode:
                return "Invalid HTTP status code."
            case .decodingError(let underlyingError):
                return "Decoding error: \(underlyingError.localizedDescription)"
            }
        }
    }
}
