//
//  EnvTest.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/10/24.
//

import SwiftUI
import RealityKit

struct EnvTest: View {
    // Sample entity properties
 
    
    var body: some View {
        VStack {
            // 3D View container
            RealityView { content in
                // Create and configure the cube environment
                
                let cubemapLoader = CubemapLoader()
                if let cubeEnvironment = cubemapLoader.createSkyboxEntity(){
                    content.add(cubeEnvironment )
                }
               
                
            
            }
            
            
        }
    }
}

// Preview provider for SwiftUI canvas
#Preview {
    EnvTest()
}
