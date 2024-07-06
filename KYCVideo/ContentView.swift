//
//  ContentView.swift
//  KYCVideo
//
//  Created by Faisal Kabir Galib on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var cameraAuthorized = false
        
        var body: some View {
            VStack {
                Button("Take Photo") {
                    checkCameraPermission { authorized in
                        if authorized {
                            self.showingCamera = true
                        } else {
                            // Handle the case where permission is denied
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView()
            }
        }
}

#Preview {
    ContentView()
}
