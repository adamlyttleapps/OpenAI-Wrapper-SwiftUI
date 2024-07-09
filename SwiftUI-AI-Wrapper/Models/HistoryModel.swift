// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation

class History: ObservableObject {
    @Published var chats: [ChatModel]
    init() {
        if let data = UserDefaults.standard.data(forKey: "chats"),
           let savedChats = try? JSONDecoder().decode([ChatModel].self, from: data) {
            chats = savedChats
        } else {
            chats = []
        }
    }
    func appendChat(_ chat: ChatModel) {
        removeChat(chat, skipImageDeletion: true)
        chats.append(chat)
        
        DispatchQueue.global().async {
            if let firstMessage = chat.messages.first, let image = firstMessage.image {
                
                // Get the path to the documents directory
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileName = "\(firstMessage.id).jpg"
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    
                    
                    // Check if the file already exists
                    if !FileManager.default.fileExists(atPath: fileURL.path) {
                        if let imageData = image.resized(toHeight: 300)?.jpegData(compressionQuality: 0.6) {
                            // Write the data to the file
                            do {
                                try imageData.write(to: fileURL)
                                print("Image saved successfully to \(fileURL)")
                            } catch {
                                print("Error saving image: \(error)")
                            }
                        }
                    } else {
                        print("File already exists at \(fileURL)")
                    }
                    
                }
                
            }
        }
        
        save()
    }
    func removeChat(_ chat: ChatModel, skipImageDeletion: Bool = false) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            
            if !skipImageDeletion {
                if let firstMessage = chat.messages.first {
                    //delete file
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileName = "\(firstMessage.id).jpg"
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        
                        do {
                            // Check if the file exists before attempting to delete it
                            if FileManager.default.fileExists(atPath: fileURL.path) {
                                try FileManager.default.removeItem(at: fileURL)
                                print("File successfully deleted.")
                            } else {
                                print("File does not exist.")
                            }
                        } catch {
                            print("Error deleting file: \(error)")
                        }
                    }
                }
            }
            
            chats.remove(at: index)
            save()
        }
    }
    
    func save() {
        DispatchQueue.global().async {
            if let data = try? JSONEncoder().encode(self.chats) {
                UserDefaults.standard.set(data, forKey: "chats")
            }
        }
    }
    
}
