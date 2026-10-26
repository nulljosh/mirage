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
/// Touch controls the way a handheld has them: a D-pad on the left (Down talks and turns the page), A to jump and B to
/// swing on the right. A held direction repeats like a held key.
struct Pad: View {
    @ObservedObject var game: Game

    var body: some View {
        HStack(alignment: .center) {
            DPad(game: game)
            Spacer(minLength: 16)
            HStack(alignment: .bottom, spacing: 16) {
                RoundButton(label: "B", code: 32, game: game).offset(y: 18)
                RoundButton(label: "A", code: Key.letter("w"), game: game, accent: true).offset(y: -18)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: 176)
    }
}

private struct DPad: View {
    @ObservedObject var game: Game
    private let arm: CGFloat = 52
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.10)).frame(width: arm, height: arm * 3)
            RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.10)).frame(width: arm * 3, height: arm)
            VStack(spacing: 0) {
                Arrow(symbol: "arrowtriangle.up.fill", code: Key.letter("w"), game: game, repeats: false)
                HStack(spacing: arm) {
                    Arrow(symbol: "arrowtriangle.left.fill", code: Key.letter("a"), game: game, repeats: true)
                    Arrow(symbol: "arrowtriangle.right.fill", code: Key.letter("d"), game: game, repeats: true)
                }
                Arrow(symbol: "arrowtriangle.down.fill", code: Key.letter("s"), game: game, repeats: false)
            }
        }
        .frame(width: arm * 3, height: arm * 3)
    }
}

private struct Arrow: View {
    let symbol: String, code: Int32
    @ObservedObject var game: Game
    let repeats: Bool
    @State private var timer: Timer?
    @State private var down = false
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white.opacity(down ? 1 : 0.75))
            .frame(width: 52, height: 52)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !down else { return }
                    down = true
                    game.press(code)
                    if repeats { timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in Task { @MainActor in game.press(code) } } }
                }
                .onEnded { _ in down = false; timer?.invalidate(); timer = nil })
            .accessibilityLabel(symbol.contains("left") ? "Left" : symbol.contains("right") ? "Right" : symbol.contains("up") ? "Jump" : "Talk")
            .accessibilityAddTraits(.isButton)
    }
}

private struct RoundButton: View {
    let label: String, code: Int32
    @ObservedObject var game: Game
    var accent = false
    @State private var down = false
    var body: some View {
        Text(label)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 68, height: 68)
            .background(Circle().fill(accent ? Color(red: 0xB5 / 255, green: 0x50 / 255, blue: 0x2C / 255) : Color.white.opacity(0.16)))
            .scaleEffect(down ? 0.92 : 1)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in if !down { down = true; game.press(code) } }
                .onEnded { _ in down = false })
            .accessibilityLabel(label == "A" ? "A, jump" : "B, swing")
            .accessibilityAddTraits(.isButton)
    }
}
#endif
