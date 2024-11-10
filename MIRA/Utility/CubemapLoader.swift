//
//  CubemapLoader.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//
import RealityKit
import SwiftUI


extension UIImage {
    func toMaterialParametersTexture() -> MaterialParameters.Texture? {
        guard let cgImage = self.cgImage else {
            print("Failed to get CGImage from UIImage")
            return nil
        }
        
        do {
            // Create a texture resource from the CGImage
            let textureResource = try TextureResource(image: cgImage, options: .init(semantic: .normal))
            
            // Convert the TextureResource to MaterialParameters.Texture
            let texture = MaterialParameters.Texture(textureResource)
            
            return texture
        } catch {
            print("Error converting UIImage to MaterialParameters.Texture: \(error)")
            return nil
        }
    }
}

class CubemapLoader {
    // Load images from assets and apply them to a cubemap
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
        
        // Create the materials for each face and log which image is being used
        let materials = imageNames.map { imageName in
            print("Assigning material to \(imageName) face")  // Log face assignment
            return createMaterial(imageName: imageName)
        }
        
        // Create the model entity for the cube
        let cubeEntity = ModelEntity(mesh: cubeMesh, materials: materials)
        
        // Set the scale to -1 on the X-axis to make textures visible from the inside
        cubeEntity.scale = SIMD3(x: -1, y: 1, z: 1)
        
        return cubeEntity
    }
    
    // Helper function to create a material with a given texture image
    private func createMaterial(imageName: String) -> UnlitMaterial {
        guard let textureImage = UIImage(named: imageName) else {
            fatalError("Unable to load image \(imageName) from assets.")
        }
        
        // Use an unlit material so the images are clearly visible without lighting
        var material = UnlitMaterial()
        if let texture = textureImage.toMaterialParametersTexture() {
            material.color = .init(tint: .white, texture: texture)
        } else {
            print("⚠️ Failed to create texture for: \(imageName)")
        }
        
        return material
    }
}

