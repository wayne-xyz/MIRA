//
//  ContentView.swift
//  MIRAv2
//
//  Created by Mehrad Faridan on 2024-11-09.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")

            Toggle("Show Immersive Space", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding(.top, 50)
        }
        .onAppear() {
            performGenerator()
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
    
    
    
    
    
    func performGenerator(){
        let skyApi=Key.init(keyfilename: ".env2").apiKey
        let Skybox=SkyboxGenerator(apiKey: skyApi)
        let TEST_PROMPT="Stanford Campus in california an sunny day with building and trees"
        // print time as log 
        let startTime = Date()
        print("Starting skybox generation at \(startTime)")
        
        Skybox.generateSkybox(skyboxStyleId: 35, prompt: TEST_PROMPT) { result in
            switch result {
            case .success(let skyboxResponse):
                print("Skybox generated with ID: \(skyboxResponse.id), Status: \(skyboxResponse.status)")
                if let fileUrl = skyboxResponse.fileUrl {
                    print("File URL: \(fileUrl)")
                }
            case .failure(let error):
                print("Failed to generate skybox: \(error)")
            }
        }
        
        
        
        print("Loding from the skybox")
    }
}



#Preview(windowStyle: .automatic) {
    ContentView()
}
