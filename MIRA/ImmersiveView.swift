//
//  ImmersiveView.swift
//  MIRAv2
//
//  Created by Mehrad Faridan on 2024-11-09.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    var body: some View {
        RealityView { content in
            
            let cubemapLoader = CubemapLoader()
            if let cubeEnvironment = cubemapLoader.createSkyboxEntity(){
                content.add(cubeEnvironment )
            }
            
            
            
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
