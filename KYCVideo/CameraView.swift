//
//  CameraView.swift
//  KYCVideo
//
//  Created by Faisal Kabir Galib on 7/5/24.
//

import SwiftUI
import AVFoundation

func checkCameraPermission(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        completion(true)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    case .denied, .restricted:
        completion(false)
    @unknown default:
        completion(false)
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoMaximumDuration = 3
        picker.allowsEditing = false
        picker.showsCameraControls = false // Hide default camera controls
        picker.cameraCaptureMode = .video
        
        // Adding custom overlay
        let overlay = UIHostingController(rootView: CameraOverlayView {
            context.coordinator.startCapture(picker)
        })
        overlay.view.backgroundColor = .clear
        overlay.view.frame = picker.view.frame
        picker.cameraOverlayView = overlay.view
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        if isRecording {
            context.coordinator.startCapture(uiViewController)
        }
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func startCapture(_ picker: UIImagePickerController) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.startVideoCapture()
            }
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                print(videoURL)
                uploadVideoToServer(fileURL: videoURL)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func uploadVideoToServer(fileURL: URL) {
            let url = URL(string: "https://ekycapi.bitanon.xyz/api/face/liveness")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer eyJhbGciOiJSUzI1NiIsInppcCI6IkRFRiJ9.eJxVzDELwjAQhuH_cnMHLWpsN0WHgiYgdcuS2isEr40kDQil_90z2MHxnuN7J8D3C8q1yPO9KHabIoMQGyhh0mBbDWW-EmKbaYgB_WB6ZNLgnRs1sHaRSC56WxR7Y4lp4C-f5B5P_LY6QwEZWhtMQ__keDOkzLGqD1LJVPKOfm2l6iSjRZ_kLi_VtarPJw0zzB879D5m.uFu05q_zVCVcNUK7VJ8IMFSluy0k09QjDvfhq_VXDHqzeIyQ6oU2b4OR9_etslXy63fUUvWNMDqDOoROVmT2Wd7fclzSM750qMJUm8ETigYzJkQowpeikjy9FlBgzGGMRCBiijpqgBMclLt1qkbyG4nCk_j2u25zTweDxnSCWz2Ns1pyjt8aeHnqUYo9iLcZY0XLlYM-xBkbGPbfKhygVRh65OPvNVLV2cN6Biyp5bwWPnpKzhagyndsAoiIRRRJ7Pe9xcbYVcXoxB0iqLhKzfULZBbRUAAlIvf5WCPb0kXV1lR8Qhv4qv-rAd7eghoa70bzSwKd6YbFJ4yP8ou0bA", forHTTPHeaderField: "Authorization")
            
            var data = Data()
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"face\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
            data.append(try! Data(contentsOf: fileURL))
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                        print("Response Received: \(httpResponse)")
                        // To print status code
                        print("Status Code: \(httpResponse.statusCode)")
                        // To print all headers
                        print("Headers: \(httpResponse.allHeaderFields)")
                    }
                    
                    // Optionally, if you want to print the body of the response
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("Body: \(body)")
                    }
            }.resume()
        }
    }
}

struct CameraOverlayView: View {
    var captureAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: captureAction) {
                    Text("Capture")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.bottom, 20)
                Spacer()
            }
        }
    }
}
