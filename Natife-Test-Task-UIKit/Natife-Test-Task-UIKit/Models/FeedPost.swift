//
//  FeedPost.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 11.10.2023.
//

import Foundation

struct FeedPost: Decodable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let previewText: String
    let likesCount: Int
}
