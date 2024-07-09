// AI Wrapper SwiftUI
// Created by Adam Lyttle on 7/9/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @Binding var isActive: Bool
    
    @State var screen: GeometryProxy?
    
    @State private var captureSession: AVCaptureSession? = AVCaptureSession()
    @State private var photoOutput: AVCapturePhotoOutput? = AVCapturePhotoOutput()
    private let photoCaptureDelegate = PhotoCaptureDelegate()
    
    @State private var isProcessing: Bool = false
    @State private var shutterFlash: Bool = false
    //let onShutterFlash: () -> Void
    
    let onCaptureImage: (UIImage) -> Void

    
    
    //image picker stuff
    @State private var showImagePicker: Bool = false
    //@State private var imagePickerOpacity: CGFloat = 0
    @State private var selectedImage: UIImage? = nil
    @State private var filename: String? = nil
    
    @Binding var showHistory: Bool
    
    @State private var flashOn: Bool = false
    
    @Environment(\.colorScheme) var colorScheme //colorScheme == .dark ? Color.white : Color.black
    
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        flashOn = !flashOn
        
        do {
            try device.lockForConfiguration()
            device.torchMode = flashOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flashlight could not be used")
        }
    }
    
    //let processedImage: (UIImage, String) -> Void
    
    private var screenWidth: CGFloat {
        if let screen = screen {
            return screen.size.width
        }
        else {
            return 0
        }
    }
    
    private var screenHeight: CGFloat {
        if let screen = screen {
            return screen.size.width
        }
        else {
            return 0
        }
    }
    

    var body: some View {
        ZStack (alignment: .topLeading) {
            
            VStack {
                if let captureSession = captureSession, let photoOutput = photoOutput {
                    CameraPreviewView(captureSession: captureSession, photoOutput: photoOutput, photoCaptureDelegate: photoCaptureDelegate)
                    .frame(width: screen?.size.width, height: screen?.size.height, alignment: .center)
                    .onAppear {
                        checkCameraPermission()
                    }
                }
            }
            .opacity(isActive ? 1 : (1 - 0.66))
            
            if isProcessing {
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.bottom, 80)
                        Spacer()
                    }
                    Spacer()
                }
                .background(shutterFlash ? Color.white : Color.black.opacity(0.66))
                .onAppear {
                    withAnimation {
                        shutterFlash = false
                    }
                }
                
            }
            else {
                
                HStack {
                    Spacer()
                    Button(action: {
                        //show image selection
                        self.toggleFlashlight()
                    }) {
                        if flashOn {
                            Image(systemName: "bolt")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                                .clipped()
                                .padding(.top)
                        }
                        else {
                            Image(systemName: "bolt.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22, alignment: .center)
                                .clipped()
                                .padding(.top)
                        }
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            //show image selection
                            showImagePicker = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30, alignment: .center)
                                .clipped()
                                .padding(25)
                        }
                        .foregroundColor(.white)
                        .sheet(isPresented: $showImagePicker) {
                            PhotoPicker(isPresented: $showImagePicker, selectedImage: $selectedImage, filename: $filename)
                                .accentColor(.blue)
                        }
                        
                        Spacer()
                        Button(action: {
                            if let photoOutput = photoOutput {
                                print("==> capturePhoto")
                                isProcessing = true
                                let settings = AVCapturePhotoSettings()
                                photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
                                //self.onShutterFlash()
                            }
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, alignment: .center)
                                .clipped()
                                .padding(25)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                        //
                        
                        
                        
                        Button(action: {
                            showHistory.toggle()
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, alignment: .center)
                                .clipped()
                                .padding(25)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 2.5)
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                
                //white flash shows that the photo has been taken but also hides the transition from live to still
                
                
                //}
                
            }
            
        }
        .onChange(of: isProcessing) { value in
            if value {
                shutterFlash = true
            }
        }
        .onChange(of: showHistory) { value in
            if value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isActive = false
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isActive = true
                }
            }
        }
        .onChange(of: isActive) { value in
            if isActive {
                self.startCameraSession()
            }
            else {
                self.stopCameraSession()
            }
        }
        .onChange(of: selectedImage) { selectedImage in
            DispatchQueue.main.async {
                if let selectedImage = selectedImage {
                    self.selectedImage = selectedImage
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isProcessing = false
                    }
                    onCaptureImage(selectedImage)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    
    private func stopCameraSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                print("==> captureSession.stopRunning()")
                captureSession.stopRunning()
                self.captureSession = nil
                self.photoOutput = nil
            }
        }
    }
    
    private func startCameraSession() {
        print("==> startCameraSession")
        if let _ = captureSession {} else {
            captureSession = AVCaptureSession()
        }
        if let _ = photoOutput {} else {
            photoOutput = AVCapturePhotoOutput()
        }
        print("==> 1")
        if let captureSession = captureSession, !captureSession.isRunning {
            print("==> 2")
            DispatchQueue.global(qos: .userInitiated).async {
                print("==> captureSession.startRunning()")
                captureSession.startRunning()
            }
        }
    }
    
    private func setupCamera() {
        // Initialize and configure the capture session
        photoCaptureDelegate.onPhotoCapture = { image in
            //sets maximum height of image to 1000px (update here)
            if let resizedImage = image.resized(toHeight: max(1000, image.size.height)) {
                self.selectedImage = resizedImage
            }
            
        }
    }
    
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already authorized
            setupCamera()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    setupCamera()
                }
                // Handle if not granted
            }
        case .denied, .restricted:
            // Permission denied or restricted, handle accordingly
            break
        @unknown default:
            break
        }
    }
    
    
}


struct CameraPreviewView: UIViewRepresentable {
    var captureSession: AVCaptureSession
    var photoOutput: AVCapturePhotoOutput
    var photoCaptureDelegate: AVCapturePhotoCaptureDelegate

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        // Setup capture session
        captureSession.sessionPreset = .photo
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  captureSession.canAddInput(videoDeviceInput) else { return view }
            captureSession.addInput(videoDeviceInput)
            
            // Add photo output
            guard captureSession.canAddOutput(photoOutput) else { return view }
            captureSession.addOutput(photoOutput)
            
            // Add preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            //previewLayer.videoGravity = .resizeAspect // Change this line
            view.layer.addSublayer(previewLayer)
            
            // Start session
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
            
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var onPhotoCapture: ((UIImage) -> Void)?

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        if let image = UIImage(data: imageData) {
            onPhotoCapture?(image)
        }
    }
}
