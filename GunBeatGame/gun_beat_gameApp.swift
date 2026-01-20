//
//  gun_beat_gameApp.swift
//  gun-beat-game
//
//  Created by Efran Fernández Fernández on 24/10/25.
//

import SwiftUI
import SwiftData

@main
struct gun_beat_gameApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: LevelResultRecord.self)
    }
}
