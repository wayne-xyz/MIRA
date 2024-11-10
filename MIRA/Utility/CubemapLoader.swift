//
//  CubemapLoader.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//
import RealityKit
import SwiftUI
import simd



class CubemapLoader {

    
    func createCubemapEntity() -> ModelEntity {
        // Create a large cube to act as the environment container
        let cubeSize: Float = 1000 // Adjust size as needed for immersion
        let cubeMesh = MeshResource.generateBox(size: cubeSize)
        
        // Create the material for each face
        let imageNames = [
            "cube_front",
            "cube_back",
            "cube_left",
            "cube_right",
            "cube_up",
            "cube_down"
        ]
        
        // Create new materials for each face
        var materials: [UnlitMaterial] = []
        
        for imageName in imageNames {
            let material = createMaterialWithTexture(imageName: imageName)
            materials.append(material)
        }
        
        
        let material1 = SimpleMaterial(color: .green, isMetallic: false)
        let material2 = SimpleMaterial(color: .red, isMetallic: false)
        let material3 = SimpleMaterial(color: .blue, isMetallic: false)
        let material4 = SimpleMaterial(color: .yellow, isMetallic: false)
        let material5 = SimpleMaterial(color: .orange, isMetallic: false)
        let material6 = SimpleMaterial(color: .purple, isMetallic: false)

        let materialsArray = [material1, material2, material3, material4, material5, material6]
        

        let parentEntity = ModelEntity()
        
        // Create cube faces as ModelEntities
        let face1 = ModelEntity(mesh: cubeMesh, materials: [material1]) // Front face
        let face2 = ModelEntity(mesh: cubeMesh, materials: [material2]) // Back face
        let face3 = ModelEntity(mesh: cubeMesh, materials: [material3]) // Left face
        let face4 = ModelEntity(mesh: cubeMesh, materials: [material4]) // Right face
        let face5 = ModelEntity(mesh: cubeMesh, materials: [material5]) // Top face
        let face6 = ModelEntity(mesh: cubeMesh, materials: [material6]) // Bottom face

        // Position faces to form a cube

        // Front face (z = 0)
        face1.position = SIMD3<Float>(0, 0, 0.5)  // Move it half the size forward

  // Create and position each face
        let faces = [
            createFace(mesh: cubeMesh, material: materials[0], position: SIMD3(0, 0, 0.5),
                    orientation: simd_quatf(angle: 0, axis: SIMD3(0, 0, 0))),         // Front
            
            createFace(mesh: cubeMesh, material: materials[1], position: SIMD3(0, 0, -0.5),
                    orientation: simd_quatf(angle: .pi, axis: SIMD3(1, 0, 0))),       // Back
            
            createFace(mesh: cubeMesh, material: materials[2], position: SIMD3(-0.5, 0, 0),
                    orientation: simd_quatf(angle: .pi/2, axis: SIMD3(0, 1, 0))),     // Left
            
            createFace(mesh: cubeMesh, material: materials[3], position: SIMD3(0.5, 0, 0),
                    orientation: simd_quatf(angle: -.pi/2, axis: SIMD3(0, 1, 0))),    // Right
            
            createFace(mesh: cubeMesh, material: materials[4], position: SIMD3(0, 0.5, 0),
                    orientation: simd_quatf(angle: .pi/2, axis: SIMD3(1, 0, 0))),     // Top
            
            createFace(mesh: cubeMesh, material: materials[5], position: SIMD3(0, -0.5, 0),
                    orientation: simd_quatf(angle: -.pi/2, axis: SIMD3(1, 0, 0)))     // Bottom
        ]
        
        // Add all faces to parent
        faces.forEach { parentEntity.addChild($0) }
        
        parentEntity.scale = SIMD3(x: cubeSize ,y:cubeSize, z:cubeSize)
        
        // Print entity size and position
        print("Parent Entity Scale: \(parentEntity.scale)")
        print("Parent Entity Position: \(parentEntity.position)")
        // Create the model entity for the cube
        let cubeEntity = ModelEntity(mesh: cubeMesh, materials: materialsArray)
        
        // Set the scale to -1 on the X-axis to make textures visible from the inside
        cubeEntity.scale = SIMD3(x: -1, y: 1, z: 1)
        
        return parentEntity
    }
    
    
    private func createFace(mesh: MeshResource, material: UnlitMaterial, position: SIMD3<Float>, orientation: simd_quatf) -> ModelEntity {
        let face = ModelEntity(mesh: mesh, materials: [material])
        face.position = position
        face.orientation = orientation
        return face
    }
    
    private func createMaterialWithTexture(imageName: String) -> UnlitMaterial {
        // Load image
        guard let image = UIImage(named: imageName) else {
            fatalError("Unable to load image \(imageName) from assets.")
        }
        
        var material = UnlitMaterial()
        
        // Convert image to texture and set material color
        if let cgImage = image.cgImage?.copy() {
            do {
                let textureResource = try TextureResource(image: cgImage, options: .init(semantic: .normal))
                let texture = MaterialParameters.Texture(textureResource)
                material.color = .init(tint: .white, texture: texture)
            } catch {
                print("Error converting UIImage to MaterialParameters.Texture: \(error)")
            }
        } else {
            print("⚠️ Failed to create texture for: \(imageName)")
        }
        
        return material
    }
}

