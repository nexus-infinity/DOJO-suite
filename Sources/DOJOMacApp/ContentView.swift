import SwiftUI
import DOJOShared

struct ContentView: View {
    @State private var message = "Welcome to DOJO macOS App"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.largeTitle)
                .padding()
            
            Button("Test AI Service") {
                let aiService = AIService()
                let input = TextInput(data: "macOS test data")
                let result = aiService.runModel(input: input)
                message = "AI Result: \(result.output)"
            }
            .buttonStyle(.borderedProminent)
            
            Button("Test Communication") {
                let msg = TextMessage(payload: "Hello from macOS")
                Communication.sendMessage(to: "DOJOShared", message: msg)
                message = "Message sent!"
            }
            .buttonStyle(.bordered)
            
            Text("DOJO Shared version: \(DOJOShared.version)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}

#Preview {
    ContentView()
}
