// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI

struct PhotoView: View {
    
    let image: UIImage
    
    var body: some View {
        
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
        }
        
    }
    
}
