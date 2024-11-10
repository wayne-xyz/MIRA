import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    
    var body: some View {
        RealityView { content in
            
            // Add angel
            if let angelEntity = try? await Entity(named: "Angel.usdz", in: realityKitContentBundle) {
                content.add(angelEntity)
                angelEntity.scale = SIMD3<Float>(0.1, 0.1, 0.1)
                angelEntity.position = SIMD3<Float>(x: 75, y: 20, z: -150)
                
                if let animation = angelEntity.availableAnimations.first {
                    angelEntity.playAnimation(animation.repeat())
                }
            }
            
            // Add devil
            if let devilEntity = try? await Entity(named: "Devil.usdz", in: realityKitContentBundle) {
                content.add(devilEntity)
                devilEntity.scale = SIMD3<Float>(0.2, 0.2, 0.2)
                devilEntity.position = SIMD3<Float>(x: -75.0, y: 20, z: -150.0)
                
                if let animation = devilEntity.availableAnimations.first {
                    devilEntity.playAnimation(animation.repeat())
                }
            }
            
            // Add robot with gravity
            if let robotEntity = try? await Entity(named: "Robot.usdz", in: realityKitContentBundle) {
                
                // Create a ModelEntity wrapper
                let robotModelEntity = ModelEntity()
                robotModelEntity.addChild(robotEntity)
                
                content.add(robotModelEntity)
                
                // Position the robot in front of the user
                robotModelEntity.position = SIMD3<Float>(x: 0, y: 1.5, z: -2.0)
                robotModelEntity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
                
                // Add gravity to the robot
                let boxShape = ShapeResource.generateBox(size: SIMD3<Float>(0.5, 0.5, 0.5))
                robotModelEntity.components.set(PhysicsBodyComponent(
                    shapes: [boxShape],
                    mass: 2.0,
                    material: .generate(friction: 0.5, restitution: 0.2),
                    mode: .dynamic
                ))
                
                // Add collision component to robot
                robotModelEntity.collision = CollisionComponent(
                    shapes: [boxShape],
                    mode: .default,
                    filter: .default
                )
                
                // Add animation to the child entity (original robot)
                if let animation = robotEntity.availableAnimations.first {
                    robotEntity.playAnimation(animation.repeat())
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
