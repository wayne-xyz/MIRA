//
//  MIRAApp.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

import SwiftUI

@main
struct MIRAApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ChatGPTSpeechView() // Change to starting view (useful for testing)
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ContentView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
