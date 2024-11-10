import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Combine

class ImmersiveViewModel: ObservableObject {
    @Published var buttonText = "MIRA"  // Default button text
    @Published var transcribedText = ""  // Holds transcribed speech text
    @Published var isListening = false   // Track if listening
    @Published var responseText = "Waiting for response..." // Display ChatGPT response
}

struct ImmersiveView: View {
    let handTracking = HandTrackingProvider()
    let session = ARKitSession()
    @State var robotModelEntity: ModelEntity?
    @StateObject private var viewModel = ImmersiveViewModel()  // ViewModel to handle button text
    @StateObject private var speechRecognizer = SpeechRecognizer()  // Speech recognizer

    @State private var isPinching = false
    @State private var textEntity: ModelEntity?  // Store reference to text entity
    @State var textResponse = ""
    

    var body: some View {
        ZStack {
            RealityView { content in
                let cubemap = CubemapLoader()
                let cubemapEntity = cubemap.createSkyboxEntityByname(citynmae: "newyork")
                content.add(cubemapEntity!)
                
                await setupScene(content: content)
            }
            .task {
                await runHandTrackingSession()
                detectPinchGesture()
            }
   

            

            // Centered response text display
            VStack {
                Spacer()
                Text(speechRecognizer.transcribedText)
                    .font(.headline)
                    .padding()
                    .frame(width: 300) // Adjust width as needed
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .onAppear() {
                if speechRecognizer.isRecording == false {
                    speechRecognizer.startRecording()
                }
              
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // Center the text in the ZStack
        }
    }

    private func setupScene(content: RealityKit.RealityViewContent) async {
        let noBounceMaterial = PhysicsMaterialResource.generate(
            friction: 1.0, restitution: 0.0
        )
        
        let groundPlane = ModelEntity()
        let groundShape = ShapeResource.generateBox(size: SIMD3<Float>(10.0, 0.01, 10.0))
        groundPlane.components[CollisionComponent.self] = CollisionComponent(shapes: [groundShape])
        groundPlane.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            shapes: [groundShape], mass: 0.0, material: noBounceMaterial, mode: .static
        )
        groundPlane.position = SIMD3<Float>(x: 0, y: 0, z: 0)
        content.add(groundPlane)

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
            
            textEntity.position = SIMD3<Float>(x: -0.15, y: 2.2, z: 0)
            textEntity.name = "DynamicText"
            robotModelEntity.addChild(textEntity)
            
            self.textEntity = textEntity  // Store reference to text entity for updating
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
                    
                    
                    if speechRecognizer.isRecording{
                        print("distacne < 0.02")
                        print(speechRecognizer.transcribedText)
                        if !self.isPinching && distance<0.02 {
                            self.isPinching = true
                            
                            speechRecognizer.stopRecording()
                            print("stop recording")
                            
                            
                        }
                    }else if self.isPinching && distance<0.02 {
                        print("start recording")
                        speechRecognizer.startRecording()
                        print("Task started after delay")
                    }

                    }
                }
            }
        }
    }



#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
