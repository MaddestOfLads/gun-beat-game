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
    // This is saved on the device and remembered between launches
    @AppStorage("creditsOpenCount") private var openCount = 0

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 24) {
                

                VStack(spacing: 6) {
                    Text("Aleksander Muszyński")
                    Text("Nicola Secci")
                    Text("Efran Fernandez")
                }
                .foregroundStyle(.white.opacity(0.9))

                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.2))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "play.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.8))
                    )

                //Text that shows how many times Credits was opened
                Text("You have opened this screen \(openCount) times")
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                //increase the counter every time the screen appears
                openCount += 1
            }
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
  // Connect the View Model
  @StateObject var viewModel = LevelViewModel()

  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()
      
      ScrollView {
        LazyVStack(spacing: 16) {
          
          // Loop over the REAL levels from the JSON
          ForEach(viewModel.levels) { level in
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
  let level: LevelData
    
  var body: some View {
    HStack(spacing: 12) {
      // Thumbnail
      RoundedRectangle(cornerRadius: 12)
        .fill(.white.opacity(0.7))
        .frame(width: 120, height: 80)
        

      VStack(alignment: .leading, spacing: 6) {
        Text(level.title)
              .font(.headline)
              .foregroundStyle(.black)
          
        Text(level.description)
              .font(.subheadline)
              .opacity(0.7)
              .foregroundStyle(.black)
          
        
        Stars(rating: 3)
      }
      Spacer()

        NavigationLink {
          GameplayView()
        } label: {
          Image(systemName: "play.fill")
            .padding(14)
            .background(Color.green, in: Circle())
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

// ========== 4) GAMEPLAY SCREEN ==========

struct GameplayView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ZStack {
                Color.blue                      // blue play area

                // LEFT: bubbles + RIGHT: time bar
                HStack {
                    BubbleColumn()
                    Spacer()
                    TimeBar()
                }
                .padding(.horizontal, 32)

                // TOP: pause button  /  BOTTOM-RIGHT: gun + ammo
                VStack {
                    HStack {
                        Spacer()
                        PauseButton()
                    }

                    Spacer()

                    HStack {
                        Spacer()
                        AmmoAndGun()
                    }
                }
                .padding(24)
            }
            .cornerRadius(24)
            .padding()
        }
        .navigationTitle("Gameplay")
    }
}

// Bubbles column
struct BubbleColumn: View {
    @State private var offset: CGFloat = -200

    var body: some View {
        VStack(spacing: 32) {
            ForEach(0..<7, id: \.self) { _ in
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 40, height: 80)
                    .shadow(radius: 6)
            }
        }
        .offset(y: offset)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                offset = 200
            }
        }
    }
}

struct TimeBar: View {
    // mock value: 70% filled
    let progress: CGFloat = 0.7

    var body: some View {
        ZStack(alignment: .bottom) {
            // background track
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.25))
                .frame(width: 14, height: 260)

            // red filled part
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red)
                .frame(width: 10, height: 260 * progress)
                .padding(.bottom, 4)
        }
        .shadow(radius: 3)
    }
}

// Pause button
struct PauseButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 60, height: 60)

            HStack(spacing: 6) {
                Capsule()
                    .fill(Color.white)
                    .frame(width: 10, height: 24)
                Capsule()
                    .fill(Color.white)
                    .frame(width: 10, height: 24)
            }
        }
    }
}

// Gun, ammo & bullet
struct AmmoAndGun: View {
    // mock data
    let maxBullets = 5
    let currentBullets = 3

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            
            HStack(spacing: 0) {
                Text("\(currentBullets)")
                    .frame(width: 40, height: 32)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)

                Text("\(maxBullets)")
                    .frame(width: 40, height: 32)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
            }

            // AMMO COUNTER + GUN
            HStack(spacing: 16) {
                // ammo counter "3 5"
                // ROW OF BULLETS (ABOVE THE GUN)
                HStack(spacing: 4) {
                    ForEach(0..<maxBullets, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(index < currentBullets
                                  ? Color.gray.opacity(0.9)   // loaded bullet
                                  : Color.gray.opacity(0.3))  // empty slot
                            .frame(width: 18, height: 8)
                    }
                }
                // gun icon card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .frame(width: 140, height: 140)

                    // use your real gun asset here (name it "gun" in Assets)
                    if let _ = UIImage(named: "gun") {
                        Image("gun")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "target")
                            .font(.system(size: 40))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}
