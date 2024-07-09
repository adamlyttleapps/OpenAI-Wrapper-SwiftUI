// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI

struct MessageInputView: View {

    @Environment(\.colorScheme) var colorScheme

    @State var value: String = ""
    //@State private var showingSearchField: Bool = false //triggers when search textbox is to be displayed
    @FocusState private var isFocused: Bool
    @State var focusOnView: Bool = false
    
    @State private var hideSearchValue: Bool = false
    
    var onChange: ((String) -> Void)?
    
    var message: (String) -> Void
    
    @State var height: CGFloat = 30
    
    var body: some View {
        
        VStack {
            HStack {
                HStack {
                    //Image(systemName: "magnifyingglass")
                    if(!hideSearchValue) {
                        ZStack (alignment: .leading) {
                            TextEditor(text: $value)
                                .frame(height: height)
                                .focused($isFocused)
                                .onAppear {
                                    if focusOnView {
                                        isFocused = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            focusOnView = false
                                        }
                                    }
                                }
                                .onChange(of: value) { newValue in
                                    if newValue.last == "\n" {
                                        value = String(newValue.dropLast())
                                        sendMessage()
                                    }
                                }
                            
                                Text(value.isEmpty ? "Enter message..." : value)
                                    .opacity(value.isEmpty ? 0.5 : 0)
                                    .multilineTextAlignment(.center)
                                    .padding(.leading, 5)
                                    .padding(.top, 4)
                                    .background {
                                        GeometryReader { proxy in
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .onChange(of: value) { _ in
                                                    height = min(120, max(30, proxy.size.height))
                                                }
                                        }
                                    }
                                    .onTapGesture {
                                        isFocused = true
                                    }
                        }
                        .offset(y: -3)
                    }
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane")
                    }
                    .accentColor(colorScheme == .dark ? .white : .black)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        /*.toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button(action: {
                        isFocused = false
                        //search = ""
                    }) {
                        Text("Close")
                    }
                    Spacer()
                }
            }
        }*/
        .accentColor(.black)
        
    }
    
    func sendMessage() {
        if !value.isEmpty {
            message(value)
            value = ""
        }
    }
    
}
