import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Combine

class ImmersiveViewModel: ObservableObject {
    @Published var buttonText = "MIRA"  // Default button text
}

struct ImmersiveView: View {
    let handTracking = HandTrackingProvider()
    let session = ARKitSession()
    @State var robotModelEntity: ModelEntity?
    @StateObject private var viewModel = ImmersiveViewModel()  // ViewModel to handle button text

    @State private var isPinching = false
    @State private var textEntity: ModelEntity?  // Store reference to text entity

    var body: some View {
        RealityView { content in
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
                
                // Text Entity for toggling text above the robot
                let textMesh = MeshResource.generateText(
                    viewModel.buttonText,
                    extrusionDepth: 0.02,
                    font: .systemFont(ofSize: 0.1),
                    containerFrame: CGRect.zero,
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
                let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
                let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
                
                // Adjust text position above the robot
                textEntity.position = SIMD3<Float>(x: -0.15, y: 2.1, z: 0)
                textEntity.name = "DynamicText"
                robotModelEntity.addChild(textEntity)
                
                // Store a reference to the text entity
                self.textEntity = textEntity
            }
            
        }
        .task {
            await runHandTrackingSession()
            detectPinchGesture()  // Run pinch detection in a separate task
        }
    }

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

    private func detectPinchGesture() {
        Task {
            for await anchorUpdate in handTracking.anchorUpdates {
                let anchor = anchorUpdate.anchor
                
                if let handSkeleton = anchor.handSkeleton {
                    let thumbTip = handSkeleton.joint(.thumbTip).anchorFromJointTransform
                    let indexTip = handSkeleton.joint(.indexFingerTip).anchorFromJointTransform
                    
                    let thumbPosition = SIMD3<Float>(thumbTip.columns.3.x, thumbTip.columns.3.y, thumbTip.columns.3.z)
                    let indexPosition = SIMD3<Float>(indexTip.columns.3.x, indexTip.columns.3.y, indexTip.columns.3.z)
                    
                    let distance = simd_distance(thumbPosition, indexPosition)
                    
                    DispatchQueue.main.async {
                        if distance < 0.02 {  // Adjusted sensitivity for easier pinch detection
                            if !self.isPinching {
                                self.isPinching = true
                                // Toggle the button text on each pinch
                                self.viewModel.buttonText = (self.viewModel.buttonText == "MIRA") ? "Listening..." : "MIRA"
                                self.updateTextEntity()
                            }
                        } else if self.isPinching {
                            self.isPinching = false
                        }
                    }
                }
            }
        }
    }

    private func updateTextEntity() {
        guard let textEntity = textEntity else { return }
        
        // Update the text on the 3D text entity
        let newTextMesh = MeshResource.generateText(
            viewModel.buttonText,
            extrusionDepth: 0.02,
            font: .systemFont(ofSize: 0.1),
            containerFrame: CGRect.zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        textEntity.model?.mesh = newTextMesh
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
