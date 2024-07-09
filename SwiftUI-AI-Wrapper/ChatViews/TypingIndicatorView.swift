// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI

struct TypingIndicatorView: View {
    let animationDelay: Double = 0.2
    @State private var shouldAnimate = false

    var body: some View {
        HStack (spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.black)
                    .scaleEffect(shouldAnimate ? 1 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(animationDelay * Double(index)),
                        value: shouldAnimate
                    )
            }
        }
        .onAppear {
            shouldAnimate = true
        }
    }
}
