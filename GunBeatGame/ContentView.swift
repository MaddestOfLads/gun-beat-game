import SwiftUI
import SwiftData

// Simple theme (tweak later or move to Asset colors)
struct Theme {
  static let bg   = Color(red: 0.32, green: 0.12, blue: 0.12)     // deep maroon
  static let card = Color(red: 0.97, green: 0.86, blue: 0.88)     // soft pink
  static let play = Color.yellow
}

struct RootView: View {
  var body: some View {
    NavigationStack {
      TitleView()
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

        VStack(spacing: 12) {
          Text("Lock on to the beat, time your shots, and climb the leaderboard.")
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.9))

          NavigationLink {
            LevelSelectView()
          } label: {
            Label("Play", systemImage: "play.fill")
              .padding(.horizontal, 28).padding(.vertical, 14)
              .background(Theme.play, in: Capsule())
              .foregroundStyle(.black)
          }

          HStack(spacing: 12) {
            NavigationLink {
              HowToPlayView()
            } label: {
              Label("How to Play", systemImage: "questionmark.circle")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.2))

            NavigationLink {
              CreditsView()
            } label: {
              Label("Credits", systemImage: "person.3.fill")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.2))
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Quick Tips")
            .font(.headline)
            .foregroundStyle(.white)

          HStack(spacing: 12) {
            Label("Shoot on the marker", systemImage: "scope")
              .frame(maxWidth: .infinity, alignment: .leading)
            Label("Perfect hits boost stars", systemImage: "star.fill")
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .font(.subheadline)
          .foregroundStyle(.white.opacity(0.85))
        }
        .padding(16)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))

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

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Gun Beat Game")
                            .font(.title2.bold())
                        Text("A rhythm shooter built for fast, satisfying runs.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Aleksander Muszyński", systemImage: "pencil.and.outline")
                            Label("Nicola Secci", systemImage: "hammer.fill")
                            Label("Efran Fernandez ", systemImage: "waveform")
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Music")
                            .font(.headline)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.2))
                            .frame(height: 160)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "music.note.list")
                                        .font(.system(size: 32))
                                    Text("Music is built with open-source tracks and samples.")
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))

                    //Text that shows how many times Credits was opened
                    Text("You have opened this screen \(openCount) times")
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer(minLength: 12)
                }
                .padding(24)
            }
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
  @Query(sort: \LevelResultRecord.created_at, order: .reverse) private var levelResults: [LevelResultRecord]

  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Choose your track")
              .font(.title3.bold())
              .foregroundStyle(.white)
            Text("Each level syncs bubbles to the song BPM. Find your rhythm and aim for perfect hits.")
              .font(.subheadline)
              .foregroundStyle(.white.opacity(0.8))
          }

          LazyVStack(spacing: 16) {
            // Loop over the REAL levels from the JSON
            ForEach(viewModel.levels) { level in
              LevelCard(level: level, rating: bestStars(for: level.id))
            }
          }
        }
        .padding(16)
      }
      .navigationTitle("Level select")
    }
  }

  private func bestStars(for levelId: String) -> Int {
    levelResults
      .filter { $0.level_id == levelId }
      .map { $0.total_stars }
      .max() ?? 0
  }
}

struct LevelCard: View {
  let level: LevelData
  let rating: Int
    
  var body: some View {
    HStack(spacing: 12) {
      // Thumbnail
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(.white.opacity(0.7))
          .frame(width: 120, height: 80)
        Image(systemName: "waveform.path.ecg")
          .font(.system(size: 28, weight: .bold))
          .foregroundStyle(.pink.opacity(0.9))
      }
        

      VStack(alignment: .leading, spacing: 6) {
        Text(level.title)
              .font(.headline)
              .foregroundStyle(.black)
          
        Text(level.description)
              .font(.subheadline)
              .opacity(0.7)
              .foregroundStyle(.black)
          
        
        Stars(rating: rating)
      }
      Spacer()

        NavigationLink {
          GameView(levelData: level)
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

// ========== 3.5) HOW TO PLAY ==========
struct HowToPlayView: View {
  var body: some View {
    ZStack {
      Theme.bg.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("How to Play")
            .font(.title2.bold())
            .foregroundStyle(.white)

          InstructionCard(
            title: "Hit the beat",
            systemImage: "scope",
            description: "Wait for bubbles to cross the marker, then fire to score. Timing is everything."
          )
          InstructionCard(
            title: "Watch your ammo",
            systemImage: "rectangle.stack.fill",
            description: "The ammo meter shows loaded shots. Missing drains score—stay sharp."
          )
          InstructionCard(
            title: "Chase stars",
            systemImage: "star.circle.fill",
            description: "Perfect hits build your streak. Higher scores unlock more stars per level."
          )

          VStack(alignment: .leading, spacing: 8) {
            Text("Controls")
              .font(.headline)
              .foregroundStyle(.white)
            Text("Tap the gun button to fire. Use the pause icon to stop and the restart icon to reset the song.")
              .font(.subheadline)
              .foregroundStyle(.white.opacity(0.8))
          }
          .padding(16)
          .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(24)
      }
    }
    .navigationTitle("How to Play")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct InstructionCard: View {
  let title: String
  let systemImage: String
  let description: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemImage)
        .font(.system(size: 28))
        .frame(width: 44, height: 44)
        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(.white)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.white)
        Text(description)
          .font(.subheadline)
          .foregroundStyle(.white.opacity(0.85))
      }
    }
    .padding(16)
    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
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
