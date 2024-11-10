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
            if let angelEntity = try? await Entity(named: "Angel.usdz", in: realityKitContentBundle) {
                content.add(angelEntity)
                
                // Scale down the model
                angelEntity.scale = SIMD3<Float>(0.1, 0.1, 0.1) // Adjust scale as needed
                
                // Move the model to a new position
                angelEntity.position = SIMD3<Float>(x: 75, y: 20, z: -150) // Adjust position as needed
                
                if let animation = angelEntity.availableAnimations.first {
                    angelEntity.playAnimation(animation.repeat())
                }
            }
            
            if let devilEntity = try? await Entity(named: "Devil.usdz", in: realityKitContentBundle) {
                content.add(devilEntity)
                
                // Scale down the model
                devilEntity.scale = SIMD3<Float>(0.2, 0.2, 0.2) // Adjust scale as needed
                
                // Move the model to a new position
                devilEntity.position = SIMD3<Float>(x: -75.0, y: 20, z: -150.0) // Adjust position as needed
                
                if let animation = devilEntity.availableAnimations.first {
                    devilEntity.playAnimation(animation.repeat())
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
