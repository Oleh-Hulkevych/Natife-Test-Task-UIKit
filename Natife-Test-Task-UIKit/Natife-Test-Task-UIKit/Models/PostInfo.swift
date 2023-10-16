//
//  PostInfo.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 11.10.2023.
//

import Foundation

struct PostInfo: Decodable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let text: String
    let postImage: URL
    let likesCount: Int
}
