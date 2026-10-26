import SwiftUI

@main
struct MirageApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
    }
}
