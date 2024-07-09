// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
extension Date {
    var shortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
    var shortDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd hh:mm:ssa"
        return dateFormatter.string(from: self)
    }
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        return dateFormatter.string(from: self)
    }
    var relativeTime: String {
        let interval = Int(Date().timeIntervalSince(self))
        
        if interval < 180 {
            return "just now"
        } else if interval < 3600 {
            return "\(interval / 60)m ago"
        } else if interval < 86400 {
            return "\(interval / 3600)h ago"
        } else if interval < 31536000 {
            return "\(interval / 86400)d ago"
        } else {
            return "ages ago"
        }
    }

}
