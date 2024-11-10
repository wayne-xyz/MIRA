//
//  ImmersiveView.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            // Directly add the cube to the content
            // Add the environment cube to the content
            
            
            
            
            }
        }
    }

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
