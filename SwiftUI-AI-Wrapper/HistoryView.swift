// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI

struct HistoryView: View {
    @Binding var isPresented: Bool
    @State private var history: History?// = History()
    @State private var incrementId: Int = 0
    var body: some View {
        NavigationView {
            List {
                if let history = history {
                    if history.chats.count > 0 {
                        ForEach(history.chats.sorted { $0.date > $1.date }, id: \.id) { chat in
                            NavigationLink(destination: ChatView(isPresented: .constant(false), chat: chat, chatTitle: chat.title ?? "New Chat", removeChat: { chat in
                                history.removeChat(chat)
                                incrementId += 1
                            })) {
                                HStack {
                                    if let image = chat.messages.first?.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: ContentMode.fill)
                                            .frame(width: 60, height: 60, alignment: .center)
                                            .mask {
                                                RoundedRectangle(cornerRadius: 6)
                                            }
                                    }
                                    VStack (alignment: .leading) {
                                        Text(chat.title ?? "New Chat")
                                        Text(chat.date.shortDateTime)
                                            .opacity(0.7)
                                            .font(.footnote)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        HStack {
                            Spacer()
                            Text("There's no history to display yet")
                            Spacer()
                        }
                        .padding(.top, 80)
                        .listRowSeparator(.hidden)
                    }
                }
                else {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding(.vertical, 100)
                            .onAppear {
                                DispatchQueue.global().async {
                                    let history = History()
                                    DispatchQueue.main.async {
                                        self.history = history
                                    }
                                }
                            }
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .id(incrementId)
            .listStyle(PlainListStyle())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //ToolbarItem(placement: .primaryAction) {
                    //trailing buttons
                    /*Button(action: {
                        //action
                    }) {
                        Image(systemName: "magnifyingglass")
                    }*/
                //}
                ToolbarItem(placement: .cancellationAction) {
                    //leading buttons
                    Button(action: {
                        //action
                        isPresented = false
                    }) {
                        Text("Close")
                    }
                    .accentColor(.blue)
                }
            }
        }
    }
}
