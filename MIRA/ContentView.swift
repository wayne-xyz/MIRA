import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        ZStack {
            // Full-window green background
            Color.green
                .ignoresSafeArea() // Ensures the background fills the entire screen

            VStack(spacing: 20) {
                Text("Welcome! Press Begin Simulation to Start!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .shadow(radius: 3)

                ToggleImmersiveSpaceButton()
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 10)
            )
            .padding(.horizontal)
        }
        .onChange(of: appModel.immersiveSpaceState) { newState in
            // Dismiss ContentView immediately when immersive space is opened
            if newState == .open {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


