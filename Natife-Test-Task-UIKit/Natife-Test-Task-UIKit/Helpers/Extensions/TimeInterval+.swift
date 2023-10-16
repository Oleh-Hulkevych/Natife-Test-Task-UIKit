//
//  TimeInterval+.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import Foundation

extension TimeInterval {
    
    var timeAgoToString: String {
        switch intervalSinceNow {
        case ..<60: "\(Int(intervalSinceNow)) seconds ago"
        case ..<3600: "\(Int(intervalSinceNow / 60)) minutes ago"
        case ..<86400: "\(Int(intervalSinceNow / 3600)) hours ago"
        case ..<2592000: "\(Int(intervalSinceNow / 86400)) days ago"
        default:
            formatted
        }
    }
}

private extension TimeInterval {
    
    var intervalSinceNow: TimeInterval {
        Date().timeIntervalSince1970 - self
    }
    
    var formatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let date = Date(timeIntervalSince1970: self)
        return dateFormatter.string(from: date)
    }
}
