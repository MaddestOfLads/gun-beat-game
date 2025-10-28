import SwiftUI
import SwiftData

@Model
class Score {
    var value: Int = 0
    init(value: Int) {
        self.value = value
    }
}

//@main
struct SimpleDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Score.self)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var scores: [Score]
    
    var topScore: Int {
        scores.map(\.value).max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Top score: \(topScore)")
                .font(.title)
            
            Button("Add random score") {
                let new = Score(value: Int.random(in: 0...100))
                context.insert(new)
                try? context.save()
            }
        }
        .padding()
    }
}
