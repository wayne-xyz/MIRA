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
            let cubeLoader=CubemapLoader()
            let cubeentity=cubeLoader.createSkyboxEntity()
            content.add(cubeentity!)
            
            
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
