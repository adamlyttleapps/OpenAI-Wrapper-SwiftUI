// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
import SwiftUI

class ChatModel: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var messages: [ChatMessage] = []
    @Published var isSending: Bool = false
    @Published var title: String? = nil
    @Published var date: Date
    
    //customize the location of the openai_proxy.php script
    //source code for openai_proxy.php available here: https://github.com/adamlyttleapps/OpenAIProxy-PHP
    
    private let location = "https://adamlyttleapps.com/demo/OpenAIProxy-PHP/openai_proxy.php"
    
    //create a shared secret key, requests to the server use an md5 hash with the shared secret
    private let sharedSecretKey = "secret_key"
    
    enum CodingKeys: String, CodingKey {
        case id
        case messages
        case isSending
        case title
        case date
    }

    init(id: UUID = UUID(), messages: [ChatMessage] = [], isSending: Bool = false, title: String? = nil, date: Date = Date()) {
        self.id = id
        self.messages = messages
        self.isSending = isSending
        self.title = title
        self.date = date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        isSending = try container.decode(Bool.self, forKey: .isSending)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(messages, forKey: .messages)
        try container.encode(isSending, forKey: .isSending)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
    }
    
    var messageData: String? {
        // Convert ChatModel instance to JSON
        do {
            let jsonData = try JSONEncoder().encode(self.messages)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                return jsonString
            }
        } catch {
            print("Failed to encode ChatModel to JSON: \(error)")
        }
        return nil
    }
        
    
    func sendMessage(role: MessageRole = .user, message: String? = nil, image: UIImage? = nil) {
        
        appendMessage(role: role, message: message, image: image)
        self.isSending = true
        
        let parameters: [String: String] = [
            "messages": self.messageData!,
            "hash": "\(self.messageData!)\(sharedSecretKey)".hash()
        ]
        
        let connectionRequest = ConnectionRequest()
        connectionRequest.fetchData(location, parameters: parameters) { [weak self] data,error in
            
            if let self = self {
                
                if let error = error, !error.isEmpty {
                    print("ERROR")
                }
                else if let data = data {
                    print("received data = \(data)")
                    if let message = String(data: data, encoding: .utf8) {
                        
                        DispatchQueue.main.async {
                            self.appendMessage(role: .system, message: message)
                            self.isSending = false
                        }
                    }
                }

                if self.isSending {
                    DispatchQueue.main.async {
                        self.isSending = false
                    }
                }

            }
            
        }
        
        
        
    }
    
    func appendMessage(role: MessageRole, message: String? = nil, image: UIImage? = nil) {
        self.date = Date()
        messages.append(ChatMessage(
            role: role,
            message: message,
            image: image
        ))
    }
    
}

enum MessageRole: String, Codable {
    case user
    case system
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    var message: String?
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case message
        case image
    }

    init(id: UUID = UUID(), role: MessageRole, message: String?, image: UIImage? = nil) {
        self.id = id
        self.role = role
        self.message = message
        self.image = image //?.jpegData(compressionQuality: 1.0)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        role = try container.decode(MessageRole.self, forKey: .role)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        /*if let imageData = try container.decodeIfPresent(Data.self, forKey: .image) ?? nil {
            image = UIImage(data: imageData)
        }*/
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(message, forKey: .message)
        //try container.encode(image?.jpegData(compressionQuality: 1.0), forKey: .image)
        
        if let image = self.image,
           let resizedImage = self.resizedImage(image),
           let resizedImageData = resizedImage.jpegData(compressionQuality: 0.4) {
            let imageData = self.encodeToPercentEncodedString(resizedImageData)
            try container.encode(imageData, forKey: .image)
        }
        
    }

    private func resizedImage(_ image: UIImage) -> UIImage? {
        //increase size of image here:
        if image.size.height > 1000 {
            return image.resized(toHeight: 1000)
        }
        else {
            return image
        }
    }
    
    
    private func encodeToPercentEncodedString(_ data: Data) -> String {
        return data.map { String(format: "%%%02hhX", $0) }.joined()
    }

    


}
