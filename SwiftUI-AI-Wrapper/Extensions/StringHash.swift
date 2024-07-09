// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import CryptoKit
import Foundation

extension String {
    func hash() -> String {
        let data = Data(self.utf8)
        let hash = Insecure.MD5.hash(data: data)
        let hashValue = hash.compactMap { String(format: "%02x", $0) }.joined()
        return hashValue
    }
}
