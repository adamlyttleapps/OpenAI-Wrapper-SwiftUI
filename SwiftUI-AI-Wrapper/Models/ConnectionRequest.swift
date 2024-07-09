// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
import Combine

class ConnectionRequest: ObservableObject {
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    func fetchData(_ url: String?, parameters: [String: String], completion: @escaping (Data?,String?) -> Void) {
        guard let urlString = url, let requestUrl = URL(string: urlString) else {
            //onError?("Invalid URL")
            completion(nil, "Invalid URL")
            return
        }

        //Setup connection
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 60
        request.setValue("close", forHTTPHeaderField: "Connection")

        // Prepare a POST request
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let postString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        isLoading = true
        
        print("==> fetching \(requestUrl.absoluteString)")
        
        let customQueue = DispatchQueue(label: "com.adamlyttleapps.ConnectionRequest")
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .timeout(60, scheduler: customQueue) // 60 seconds timeout
            .receive(on: customQueue)
            .sink { completionStatus in
                self.isLoading = false
                switch completionStatus {
                case .failure(let error):
                    completion(nil,error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { data, _ in
                DispatchQueue.global().async {
                    completion(data,nil)
                }
            }
    }

    deinit {
        cancellable?.cancel()
    }
    
}
