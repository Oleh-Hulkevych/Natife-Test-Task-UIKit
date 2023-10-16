//
//  LikesManager.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 11.10.2023.
//

import Foundation

final class LikesManager {

    private var likedPostIDs: Set<Int> = []

    func isLikedPost(id: Int) -> Bool {
        likedPostIDs.contains(id)
    }
    
    func togglePostLike(id: Int) {
        if isLikedPost(id: id) {
            likedPostIDs.remove(id)
            print("📙: Post unliked! / ID: \(id)")
        } else {
            likedPostIDs.insert(id)
            print("📗: Post liked! / ID: \(id)")
        }
    }
}
