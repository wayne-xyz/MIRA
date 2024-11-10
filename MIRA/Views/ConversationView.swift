import SwiftUI
import RealityKit

struct ConversationView: View {
    @StateObject private var conversationManager = ConversationManager.shared
    @State private var isListening = false
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isImmersive = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Toggle Button
                Button(action: toggleListening) {
                    HStack {
                        Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                            .foregroundColor(isListening ? .green : .red)
                        Text(isListening ? "Listening" : "Not Listening")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding()
                
                // Keywords List
                List {
                    ForEach(conversationManager.keywords, id: \.self) { keyword in
                        HStack {
                            Text(keyword)
                                .font(.body)
                            Spacer()
                            Image(systemName: "text.bubble")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Conversation Keys")
        }
        .onAppear(){
            // writign a delay 30s to add the entity
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // turn on the immersive mode
                toggleImmersiveMode()
            }
        }
        .frame(maxWidth: 500)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private func toggleListening() {
        isListening.toggle()
        
        if isListening {
            do {
                try conversationManager.startRecording()
            } catch {
                print("Failed to start recording: \(error)")
                isListening = false  // Reset toggle if failed
            }
        } else {
            conversationManager.stopRecording()
        }
    }
    

    
    private func toggleImmersiveMode() {
        Task {
            if isImmersive {
                await dismissImmersiveSpace()
            } else {
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
            isImmersive.toggle()
        }
    }



    // rewrite a function which could dynamically add entity based on the string word
    private func addEntity(word: String) {
        let cube = CubemapLoader()
        
        let cubeentity = cube.createSkyboxEntityByName(city: word)
        
    }


}

#Preview {
    ConversationView()
} 
