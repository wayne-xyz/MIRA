//
//  CubemapLoader.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

import RealityKit
import SwiftUI
import simd

/// A utility class responsible for loading and creating spherical skybox environments
/// for immersive experiences.
class CubemapLoader {
    
let cityList=["tokyo","stanford","sanfrancisco","newyork","london","paris"]
    
    /// Creates a spherical skybox environment entity
    /// - Returns: An Entity configured as an inside-viewable skybox
    /// - Throws: SkyboxError if texture loading fails
    func createSkyboxEntity()->  Entity? {
        // Generate a large sphere mesh for the skybox
        let sphereMesh = MeshResource.generateSphere(radius: 1000)
        
        // Create the skybox material
        var skyboxMaterial = UnlitMaterial()
        
        do {
            // Load the 360-degree texture
            let texture = try TextureResource.load(named: "newyork")
            skyboxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Failed to create skybox material: \(error)")
            return nil
        }
        
        // Create and configure the skybox entity
        let skyboxEntity = Entity()
        skyboxEntity.components.set(ModelComponent(
            mesh: sphereMesh,
            materials: [skyboxMaterial]
        ))
        
        // Invert the X scale to make the texture visible from inside
        skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
        
        return skyboxEntity
    }
    
    
    func createSkyboxEntityByName(city:String)->  Entity? {
        // Generate a large sphere mesh for the skybox
        let sphereMesh = MeshResource.generateSphere(radius: 1000)
        
        // Create the skybox material
        var skyboxMaterial = UnlitMaterial()
        
        do {
            // Load the 360-degree texture
            let texture = try TextureResource.load(named: city)
            skyboxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Failed to create skybox material: \(error)")
            return nil
        }
        
        // Create and configure the skybox entity
        let skyboxEntity = Entity()
        skyboxEntity.components.set(ModelComponent(
            mesh: sphereMesh,
            materials: [skyboxMaterial]
        ))
        
        // Invert the X scale to make the texture visible from inside
        skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
        
        return skyboxEntity
    }
}

