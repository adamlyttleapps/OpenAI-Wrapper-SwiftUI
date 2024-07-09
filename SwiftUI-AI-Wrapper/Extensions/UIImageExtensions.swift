// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
import SwiftUI

func loadUIImage(_ imageName: String) -> UIImage? {
    if let uiImage = UIImage(named: imageName) {
        if let cgImage = uiImage.cgImage {
            return UIImage(cgImage: cgImage)
        }
    }
    return nil
}

extension UIImage {
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    func aspectHeight(width: CGFloat) -> CGFloat {
        return (size.height / size.width) * width
    }
    func aspectWidth(height: CGFloat) -> CGFloat {
        return (size.width / size.height) * height
    }
    
    func getPixelColor(x: Int, y: Int) -> UIColor? {
        
        guard let cgImage = self.cgImage else { return nil }
    
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        if let context = CGContext(data: &pixelData,
                                   width: 1,
                                   height: 1,
                                   bitsPerComponent: 8,
                                   bytesPerRow: 4,
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
           let croppedImage = cgImage.cropping(to: CGRect(x: x, y: y, width: 1, height: 1)) {
            
            context.draw(croppedImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            let red = CGFloat(pixelData[0]) / 255.0
            let green = CGFloat(pixelData[1]) / 255.0
            let blue = CGFloat(pixelData[2]) / 255.0
            let alpha = CGFloat(pixelData[3]) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return nil
    }
    
    
    var height: CGFloat {
        guard let cgImage = self.cgImage else { return 0 }
        return CGFloat(cgImage.height)
    }
    
    var width: CGFloat {
        guard let cgImage = self.cgImage else { return 0 }
        return CGFloat(cgImage.width)
    }

    func resized(toHeight height: CGFloat) -> UIImage? {
        let scale = height / self.size.height
        let newWidth = self.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}

