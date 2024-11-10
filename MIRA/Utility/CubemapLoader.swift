//
//  CubemapLoader.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//
import RealityKit
import SwiftUI



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
        
        // Create the model entity for the cube
        let cubeEntity = ModelEntity(mesh: cubeMesh, materials: materials)
        
        // Set the scale to -1 on the X-axis to make textures visible from the inside
        cubeEntity.scale = SIMD3(x: -1, y: 1, z: 1)
        
        return cubeEntity
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

