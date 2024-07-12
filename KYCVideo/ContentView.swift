//
//  ContentView.swift
//  KYCVideo
//
//  Created by Faisal Kabir Galib on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            CameraView(isRecording: $isRecording)
                .edgesIgnoringSafeArea(.all)
            Button(action: {
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .font(.title)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
