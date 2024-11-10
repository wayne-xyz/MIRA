//
//  ImmersiveView.swift
//  MIRAv2
//
//  Created by Mehrad Faridan on 2024-11-09.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    let handTracking = HandTrackingProvider()
    let session = ARKitSession()
    @State var box = ModelEntity()
    @State var sphere = ModelEntity()

    var body: some View {
        RealityView { content in
            if let robotEntity = try? await Entity(named: "Robot.usdz", in: realityKitContentBundle) {
                content.add(robotEntity)
                
                // Scale down the model
                robotEntity.scale = SIMD3<Float>(0.2, 0.2, 0.2) // Adjust scale as needed
                
                // Move the model to a new position
                robotEntity.position = SIMD3<Float>(x: 0, y: -10, z: -100.0) // Adjust position as needed
                
                if let animation = robotEntity.availableAnimations.first {
                    robotEntity.playAnimation(animation.repeat())
                }
            }
            
            // Add the initial RealityKit content
            let material = SimpleMaterial(color: .red, isMetallic: false)
            self.sphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [material])
            self.box = ModelEntity(mesh: .generateBox(size: 0.05), materials: [material])

            content.add(box)
            content.add(sphere)

        } update: { content in

            Task {
                // Loop through all anchors provided by the handTracking provider
                for await anchorUpdate in handTracking.anchorUpdates {
                    let anchor = anchorUpdate.anchor
                    
                    // Switch statement to differentiate between left and right hands
                    switch anchor.chirality {
                    case .left:
                        if let handSkeleton = anchor.handSkeleton {
                            let palm = handSkeleton.joint(.middleFingerKnuckle)
                            // Get position of palm relative to origin
                            let originFromWrist = anchor.originFromAnchorTransform
                            let wristFromPalm = palm.anchorFromJointTransform
                            let originFromTip = originFromWrist * wristFromPalm
                            
                            // Set the transformation matrix relative to the scene's origin
                            sphere.setTransformMatrix(originFromTip, relativeTo: nil)
                        }

                    case .right:
                        if let handSkeleton = anchor.handSkeleton {
                            let palm = handSkeleton.joint(.middleFingerKnuckle)
                            // Get position of palm relative to origin
                            let originFromWrist = anchor.originFromAnchorTransform
                            let wristFromPalm = palm.anchorFromJointTransform
                            let originFromTip = originFromWrist * wristFromPalm
                            
                            // Set the transformation matrix relative to the scene's origin
                            box.setTransformMatrix(originFromTip, relativeTo: nil)
                            
                            // Print the transformed position for debugging
                            print("Box position:", box.transform.translation)
                        }

                    @unknown default:
                        print("Unknown error")
                    }
                }
            }
        }
        // Run ARKit session asynchronously (off the main thread)
        .task {
            await runHandTrackingSession()
        }
    }

    // Function to initialize hand tracking session
    func runHandTrackingSession() async {
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
                print("Hand tracking initializing in progress.")
            } else {
                print("Hand tracking is not supported.")
            }
        } catch {
            print("Error during initialization of hand tracking: \(error)")
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
