import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Combine

struct ImmersiveView: View {
    let handTracking = HandTrackingProvider()
    let session = ARKitSession()
    @State var box = ModelEntity()
    @State var sphere = ModelEntity()
    @State var robotModelEntity: ModelEntity?
    
    // State variables for pinch detection
    @State private var isPinching = false
    @State private var pinchCounter = 0

    var body: some View {
        VStack {
            // Display the pinch status
            Text("Pinching: \(isPinching ? "true" : "false")")
                .font(.largeTitle)
                .foregroundColor(isPinching ? .green : .red)
                .padding()
            
            RealityView { content in
                // Define a no-bounce material for physical interactions
                let noBounceMaterial = PhysicsMaterialResource.generate(
                    friction: 1.0, restitution: 0.0
                )
                
                // Ground Plane (Static Physics)
                let groundPlane = ModelEntity()
                let groundShape = ShapeResource.generateBox(size: SIMD3<Float>(10.0, 0.01, 10.0))
                groundPlane.components[CollisionComponent.self] = CollisionComponent(shapes: [groundShape])
                groundPlane.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                    shapes: [groundShape], mass: 0.0, material: noBounceMaterial, mode: .static
                )
                groundPlane.position = SIMD3<Float>(x: 0, y: 0, z: 0)
                content.add(groundPlane)

                // Robot Entity (Dynamic Physics Body)
                if let robotEntity = try? await Entity(named: "Robot.usdz", in: realityKitContentBundle) {
                    let robotModelEntity = ModelEntity()
                    robotModelEntity.addChild(robotEntity)
                    content.add(robotModelEntity)
                    
                    // Position robot and add physics body with no bounce
                    robotModelEntity.position = SIMD3<Float>(x: 0, y: 1.5, z: -2.0)
                    robotModelEntity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
                    self.robotModelEntity = robotModelEntity
                    
                    let boxShape = ShapeResource.generateBox(size: SIMD3<Float>(0.5, 0.5, 0.5))
                    
                    robotModelEntity.components.set(PhysicsBodyComponent(
                        shapes: [boxShape], mass: 2.0, material: noBounceMaterial, mode: .dynamic
                    ))
                    
                    robotModelEntity.collision = CollisionComponent(
                        shapes: [boxShape],
                        mode: .default,
                        filter: CollisionFilter(group: .default, mask: .all)
                    )
                    
                    if let animation = robotEntity.availableAnimations.first {
                        robotEntity.playAnimation(animation.repeat())
                    }
                }
                
                // Sphere for left hand tracking
                let material = SimpleMaterial(color: .red, isMetallic: false)
                self.sphere = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [material])
                content.add(sphere)
                
                // Box for right hand tracking
                self.box = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(0.1, 0.1, 0.1)), materials: [material])
                content.add(box)

            } update: { content in
                Task {
                    // Loop through all anchors provided by the handTracking provider
                    for await anchorUpdate in handTracking.anchorUpdates {
                        let anchor = anchorUpdate.anchor
                        
                        // Detect a pinch gesture
                        if let handSkeleton = anchor.handSkeleton {
                            // Get the positions of the thumb and index finger tips
                            let thumbTipTransform = handSkeleton.joint(.thumbTip).anchorFromJointTransform
                            let indexFingerTipTransform = handSkeleton.joint(.indexFingerTip).anchorFromJointTransform
                            
                            // Calculate the distance between thumb tip and index finger tip
                            let distance = simd_distance(
                                SIMD3<Float>(thumbTipTransform.columns.3.x, thumbTipTransform.columns.3.y, thumbTipTransform.columns.3.z),
                                SIMD3<Float>(indexFingerTipTransform.columns.3.x, indexFingerTipTransform.columns.3.y, indexFingerTipTransform.columns.3.z)
                            )
                            
                            // Fine-tuned threshold for pinch detection
                            if distance < 0.03 { // Adjusted threshold for more precision
                                if !isPinching {
                                    // New pinch detected
                                    isPinching = true
                                    pinchCounter += 1
                                    print("Pinch number: \(pinchCounter)")
                                }
                            } else {
                                // Reset the pinch state when fingers are apart
                                isPinching = false
                            }
                        }
                    }
                }
            }
            // Run ARKit session asynchronously (off the main thread)
            .task {
                await runHandTrackingSession()
            }
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
