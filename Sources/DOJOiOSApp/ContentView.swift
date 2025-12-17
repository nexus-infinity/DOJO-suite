import SwiftUI
import DOJOShared

struct ContentView: View {
    @State private var message = "Welcome to DOJO iOS App"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.title)
                .padding()
            
            Button("Test AI Service") {
                let aiService = AIService()
                aiService.runModel(input: "iOS test data")
                message = "AI Service called!"
            }
            .buttonStyle(.borderedProminent)
            
            Button("Test Communication") {
                Communication.sendMessage(to: "DOJOShared", message: "Hello from iOS")
                message = "Message sent!"
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
