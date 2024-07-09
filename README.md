# AIWrapper-SwiftUI

An AI Vision Wrapper built in SwiftUI

**Usage:**

Open the code in XCode

Update 'location' in ChatModel with the URL of the the OpenAI proxy script. Source code for the openai_proxy.php script used in the demo available at: [https://github.com/adamlyttleapps/OpenAIProxy-PHP](https://github.com/adamlyttleapps/OpenAIProxy-PHP)

```
//customize the location of the openai_proxy.php script
private let location = "https://adamlyttleapps.com/demo/OpenAIProxy-PHP/openai_proxy.php"
    
//create a shared secret key, requests to the server use an md5 hash with the shared secret
private let sharedSecretKey = "secret_key"
```
Note: If adding to an existing project make sure values for "Privacy - Photo Library Usage Description" and "Privacy - Camera Usage Description" are added to Info.plist
