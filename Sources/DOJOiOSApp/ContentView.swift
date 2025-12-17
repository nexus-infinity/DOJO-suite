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
                let input = TextInput(data: "iOS test data")
                let result = aiService.runModel(input: input)
                message = "AI Result: \(result.output)"
            }
            .buttonStyle(.borderedProminent)
            
            Button("Test Communication") {
                let msg = TextMessage(payload: "Hello from iOS")
                Communication.sendMessage(to: "DOJOShared", message: msg)
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
