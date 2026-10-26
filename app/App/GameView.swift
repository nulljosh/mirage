import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            screen
            #if os(iOS)
            Pad(game: game)
            #endif
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0x14 / 255, green: 0x13 / 255, blue: 0x11 / 255))
        #if os(macOS)
        .frame(minWidth: 640, idealWidth: 992, minHeight: 360, idealHeight: 572)
        #endif
    }

    private var screen: some View {
        TimelineView(.animation) { _ in
            Group {
                if let frame = game.frame {
                    Image(decorative: frame, scale: 1).resizable().interpolation(.none)
                } else {
                    Color.black
                }
            }
            .aspectRatio(CGFloat(Game.width) / CGFloat(Game.height), contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onChange(of: Date().timeIntervalSinceReferenceDate) { _, _ in game.advance() }
        }
        .focusable()
        .focusEffectDisabled()
        .focused($focused)
        .onAppear { focused = true }
        .onKeyPress(phases: [.down, .repeat]) { press in
            guard let code = code(for: press) else { return .ignored }
            game.press(code)
            return .handled
        }
        .accessibilityLabel("Mirage")
        .accessibilityHint("A and D walk, W jumps, space swings, S talks")
    }

    private func code(for press: KeyPress) -> Int32? {
        switch press.key {
        case .upArrow: return Key.up
        case .downArrow: return Key.down
        case .leftArrow: return Key.left
        case .rightArrow: return Key.right
        case .return: return Key.enter
        case .space: return 32
        default:
            guard let c = press.characters.lowercased().first, c.isASCII, c.isLetter || c == "." else { return nil }
            return Key.letter(c)
        }
    }
}

#if os(iOS)
/// Touch controls: a held walk button repeats like a held key.
struct Pad: View {
    @ObservedObject var game: Game

    var body: some View {
        HStack(spacing: 8) {
            Hold(title: "Left", code: Key.letter("a"), game: game)
            Hold(title: "Right", code: Key.letter("d"), game: game)
            Spacer(minLength: 8)
            Tap(title: "Talk", code: Key.letter("s"), game: game)
            Tap(title: "Jump", code: Key.letter("w"), game: game)
            Tap(title: "Swing", code: 32, game: game, accent: true)
        }
    }
}

private struct Tap: View {
    let title: String, code: Int32
    @ObservedObject var game: Game
    var accent = false
    var body: some View {
        Button(title) { game.press(code) }
            .font(.headline)
            .frame(minWidth: 64, minHeight: 48)
            .background(Capsule().fill(accent ? Color(red: 0xB5 / 255, green: 0x50 / 255, blue: 0x2C / 255) : Color.white.opacity(0.12)))
            .foregroundStyle(.white)
            .buttonStyle(.plain)
    }
}

private struct Hold: View {
    let title: String, code: Int32
    @ObservedObject var game: Game
    @State private var timer: Timer?
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(minWidth: 72, minHeight: 48)
            .background(Capsule().fill(Color.white.opacity(0.12)))
            .foregroundStyle(.white)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard timer == nil else { return }
                    game.press(code)
                    timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in Task { @MainActor in game.press(code) } }
                }
                .onEnded { _ in timer?.invalidate(); timer = nil })
            .accessibilityAddTraits(.isButton)
    }
}
#endif
