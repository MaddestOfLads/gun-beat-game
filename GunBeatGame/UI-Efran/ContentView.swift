import SwiftUI

// Simple theme (tweak later or move to Asset colors)
struct Theme {
  static let bg   = Color(red: 0.32, green: 0.12, blue: 0.12)     // deep maroon
  static let card = Color(red: 0.97, green: 0.86, blue: 0.88)     // soft pink
  static let play = Color.yellow
}

struct RootView: View {
  var body: some View {
    NavigationStack {
      GameView()
        .navigationBarHidden(true)
    }
  }
}

// ========== 1) TITLE ==========
struct TitleView: View {
  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()
      VStack(spacing: 24) {
        // Your logo
        if let _ = UIImage(named: "logo") {
          Image("logo").resizable().scaledToFit().frame(height: 260)
        } else {
          // fallback if you haven't added the asset yet
          RoundedRectangle(cornerRadius: 24).fill(.gray.opacity(0.3))
            .overlay(Text("Add Asset named 'logo'")).frame(height: 260)
        }

        NavigationLink {
          LevelSelectView()
        } label: {
          Label("Play", systemImage: "play.fill")
            .padding(.horizontal, 28).padding(.vertical, 14)
            .background(Theme.play, in: Capsule())
            .foregroundStyle(.black)
        }

        NavigationLink("Credits") { CreditsView() }
          .buttonStyle(.bordered)
          .tint(.gray)

        Spacer()
      }
      .padding(24)
    }
  }
}

// ========== 2) CREDITS ==========
struct CreditsView: View {
  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()
      VStack(spacing: 24) {
        Text("CREDITS").font(.headline).foregroundStyle(.white)

        VStack(spacing: 6) {
          Text("Aleksander Muszyński")
          Text("Nicola Secci")
          Text("Efran Fernandez")
        }
        .foregroundStyle(.white.opacity(0.9))

        // video placeholder
        RoundedRectangle(cornerRadius: 16)
          .fill(.white.opacity(0.2))
          .frame(height: 180)
          .overlay(Image(systemName: "play.circle").font(.system(size: 48)).foregroundStyle(.white.opacity(0.8)))

        Spacer()
      }
      .padding(24)
      .navigationTitle("Credits")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

// ========== 3) LEVEL SELECT ==========
struct Level: Identifiable {
  let id = UUID()
  let title: String
  let description: String
  let rating: Int
}

let demoLevels: [Level] = [
  .init(title: "The great adventure", description: "This is level description", rating: 1),
  .init(title: "The even greater adventure", description: "This is level description", rating: 3),
  .init(title: "The ultimate adventure", description: "This is level description", rating: 2),
]

struct LevelSelectView: View {
  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(demoLevels) { level in
            LevelCard(level: level)
          }
        }
        .padding(16)
      }
      .navigationTitle("Level select")
    }
  }
}

struct LevelCard: View {
  let level: Level
  var body: some View {
    HStack(spacing: 12) {
      // thumbnail placeholder
      RoundedRectangle(cornerRadius: 12)
        .fill(.white.opacity(0.7))
        .frame(width: 120, height: 80)

      VStack(alignment: .leading, spacing: 6) {
        Text(level.title).font(.headline)
        Text(level.description).font(.subheadline).opacity(0.7)
        Stars(rating: level.rating)
      }
      Spacer()

      Button {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // start level here
      } label: {
        Image(systemName: "play.fill")
          .padding(14)
          .background(.green, in: Circle())
          .foregroundStyle(.white)
      }
    }
    .padding(12)
    .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
  }
}

struct Stars: View {
  let rating: Int
  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<3, id: \.self) { i in
        Image(systemName: i < rating ? "star.fill" : "star")
      }
    }
    .foregroundStyle(.orange)
    .font(.footnote)
  }
}
