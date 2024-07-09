// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI

struct ChatView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @ObservedObject var chat: ChatModel
    @State var chatTitle: String = "New Chat"
    
    @State private var showMenuButtons: Bool = false
    
    var removeChat: ((ChatModel)->Void)?
    
    var body: some View {

        VStack (spacing: 10) {
            
            ScrollViewReader { proxy in
                
                ScrollView {
                    
                    VStack (spacing: 10) {
                        ForEach(chat.messages) { message in
                            MessageView(message: message).id(message.id)
                        }
                        if chat.isSending {
                            MessageView(message: ChatMessage(
                                role: .system,
                                message: "..."
                            ))
                            .id("typing")
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: chat.messages.count) { _ in
                        if let lastMessage = chat.messages.last {
                            if chat.messages.count > 2 || lastMessage.role == .user || lastMessage.message == "..." {
                                withAnimation {
                                    proxy.scrollTo("eof", anchor: .bottom)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        proxy.scrollTo("eof", anchor: .bottom)
                                    }
                                }
                            }
                            if lastMessage.role == .system && lastMessage.message != "..." {
                                DispatchQueue.global().async {
                                    let history = History()
                                    history.appendChat(chat)
                                }
                            }
                        }
                    }
                    .onChange(of: chat.title) { value in
                        if let chatTitle = chat.title, self.chatTitle == "New Chat" {
                            self.chatTitle = chatTitle
                        }
                    }
                    
                    Rectangle()
                        .id("eof")
                        .frame(height: 10)
                        .foregroundColor(.clear)
                    
                }
                .navigationTitle(chatTitle)
                .navigationBarTitleDisplayMode(.inline)
                //
            }
            .onAppear {
                chatTitle = chat.title ?? "New Chat"
            }
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    //trailing buttons
                    if let _ = removeChat {
                        Button(action: {
                            //action
                            showMenuButtons = true
                        }) {
                            Image(systemName: "ellipsis.circle")
                        }
                        .actionSheet(isPresented: $showMenuButtons) {
                            
                            var buttons: [ActionSheet.Button] = []
                            
                            if let removeChat = removeChat {
                                buttons.append(.destructive(Text("Delete Chat"), action: {
                                    removeChat(chat)
                                    presentationMode.wrappedValue.dismiss()
                                }))
                            }
                            
                            buttons.append(.cancel())
                            
                            return ActionSheet(title: Text("Chat Actions"), message: nil,
                                               buttons: buttons)
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    //leading buttons
                    if let _ = removeChat {} else {
                        Button(action: {
                            //action
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            //Image(systenName: "multiply")
                            Text("Close")
                        }
                    }
                }
            }
            
            VStack (spacing: 0) {
                MessageInputView(message: { message in
                    chat.sendMessage(message: message)
                })
            }
            .opacity(hasSystemMessage() ? 1 : 0)
            .disabled(hasSystemMessage() ? false : true)
            
        }
        .onAppear {
            if let _ = removeChat, let firstMessage = chat.messages.first {
                //this is loaded from history -- load the image from view
                if let _ = firstMessage.image {} //already loaded
                else {
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileName = "\(firstMessage.id).jpg"
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        
                        if FileManager.default.fileExists(atPath: fileURL.path),
                           let imageData = try? Data(contentsOf: fileURL),
                           let image = UIImage(data: imageData) {
                            chat.messages[0].image = image
                        }
                    }
                }
                
            }
        }
    }
    
    func hasSystemMessage() -> Bool {
    
        if let firstSystemMessage = chat.messages.first(where: {$0.role == .system})?.message { //firstSystemMessage.contains("=") || firstSystemMessage.contains("equal") {
            return true
        }
        else {
            return false
        }
        
    }
    
}
