# OpenAI-Wrapper-SwiftUI

An OpenAI Wrapper built in SwiftUI

## Overview

AIWrapper-SwiftUI is a SwiftUI-based wrapper designed to leverage AI for vision-related tasks. This wrapper interacts with an OpenAI proxy script to secure API communications and protect your API key

## Features

* SwiftUI Integration: Seamlessly integrates with SwiftUI projects
* AI Vision Capabilities: Utilize AI to perform various vision-related tasks
* Secure API Communication: Protect your OpenAI API key using a proxy script
* Customizable Settings: Easily configure proxy script location and shared secret key

## Usage

1. **Open the code in XCode**
2. **Update the Proxy Script Location:** In the ChatModel class, update the location property with the URL of your OpenAI proxy script. The source code for the openai_proxy.php script used in the demo is available at: [https://github.com/adamlyttleapps/OpenAI-Proxy-PHP](https://github.com/adamlyttleapps/OpenAI-Proxy-PHP).

```
//customize the location of the openai_proxy.php script
private let location = "https://adamlyttleapps.com/demo/OpenAIProxy-PHP/openai_proxy.php"
    
//create a shared secret key, requests to the server use an md5 hash with the shared secret
private let sharedSecretKey = "secret_key"
```

3. **Configure Privacy Settings**: If you are adding this wrapper to an existing project, ensure that you add the following keys to your Info.plist:

```
Privacy - Photo Library Usage Description
Privacy - Camera Usage Description
```

These entries are necessary to request user permissions for accessing the photo library and camera.

## Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/adamlyttleapps/OpenAI-Wrapper-SwiftUI).

## MIT License

This project is licensed under the MIT License. See the LICENSE file for more details.

This README provides a clear overview of the project, detailed usage instructions, and additional sections like examples, contributions, and licensing, making it more comprehensive and user-friendly.
