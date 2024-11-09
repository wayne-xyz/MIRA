//
//  TextToSpeechTestView.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

import SwiftUI

struct TextToSpeechTestView: View {
    
//    add Flag to check the test function
    let  isDevelopement: Bool = true
    @StateObject private var textSpeaker = TextSpeaker()
    
    func viewDidAppear() {
        if isDevelopement{
            textSpeaker.speakText("Hello, welcome to SwiftUI text-to-speech!")
        }
    }
    
     var body: some View{
         VStack{
             Text("Playing,Hello, welcome to SwiftUI text-to-speech!")
                 
             
         }
         .onAppear(){
             viewDidAppear()
         }
    }
    
}

#Preview {
    TextToSpeechTestView()
}
