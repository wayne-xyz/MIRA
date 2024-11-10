// write a test view to when the swiftUi file onAppear, it will print the key

import SwiftUI

struct KeyTestView: View {
    var body: some View {
        Text("Key: \(Key.shared.apiKey)")
    }
}


#Preview {
    KeyTestView()
}
