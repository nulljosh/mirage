import SwiftUI

struct GameView: View {
    @StateObject private var game = Game()
    @FocusState private var focused: Bool

    var body: some View {
        #if os(iOS)
        GeometryReader { geo in
            let landscape = geo.size.width > geo.size.height
            ZStack(alignment: .top) {
                backdrop.frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                               height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom).clipped()
                    .ignoresSafeArea()
                if landscape {   /* the game fills the screen; the controls float over its lower corners */
                    screen(CGSize(width: geo.size.width, height: geo.size.height))
                    Pad(game: game).padding(.horizontal, 24).padding(.bottom, 20)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                } else {         /* upright: the game takes the top 60 percent edge to edge, the controls the rest */
                    let top = (geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom) * 0.6 - geo.safeAreaInsets.top
                    VStack(spacing: 0) {
                        screen(CGSize(width: geo.size.width, height: top))
                        Pad(game: game).padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        #else
        screen(nil)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0x14 / 255, green: 0x13 / 255, blue: 0x11 / 255))
            .frame(minWidth: 640, idealWidth: 992, minHeight: 360, idealHeight: 572)
        #endif
    }

    /// The game itself, blurred and dimmed, behind everything: the controls float over the world, not a black panel.
    private var backdrop: some View {
        Group {
            if let frame = game.frame {
                Image(decorative: frame, scale: 1).resizable().aspectRatio(contentMode: .fill)
                    .blur(radius: 36).overlay(Color.black.opacity(0.35))
            } else {
                Color.black
            }
        }
    }

    /// The game's picture, drawn the shape of `size` when one is given (the phone), else 960 by 540 fitted (the Mac).
    private func screen(_ size: CGSize?) -> some View {
        TimelineView(.animation) { _ in
            Group {
                if let frame = game.frame {
                    Image(decorative: frame, scale: 1).resizable().interpolation(.none)
                } else {
                    Color.black
                }
            }
            .aspectRatio(CGFloat(game.width) / CGFloat(game.height), contentMode: .fit)
            .frame(width: size?.width, height: size?.height)
            .onChange(of: Date().timeIntervalSinceReferenceDate) { _, _ in game.advance() }
        }
        .onAppear { if let size { game.fit(size) } }
        .onChange(of: size?.width) { _, _ in if let size { game.fit(size) } }
        .onChange(of: size?.height) { _, _ in if let size { game.fit(size) } }
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
let terra = Color(red: 0xB5 / 255, green: 0x50 / 255, blue: 0x2C / 255)

extension View {
    /// The functional layer over the game: clear Liquid Glass on iOS 26 (it floats over rich media), an ultra-thin
    /// material before it.
    @ViewBuilder func controlGlass<S: Shape>(_ shape: S, tint: Color? = nil) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(tint.map { Glass.clear.tint($0.opacity(0.85)).interactive() } ?? Glass.clear.interactive(), in: shape)
        } else {
            self.background(tint.map { AnyShapeStyle($0.opacity(0.9)) } ?? AnyShapeStyle(.ultraThinMaterial), in: shape)
        }
    }
}

/// Touch controls the way a handheld has them: a D-pad on the left (Down talks and turns the page), A to jump and B to
/// swing on the right. A held direction repeats like a held key.
struct Pad: View {
    @ObservedObject var game: Game

    var body: some View {
        group {
            HStack(alignment: .center) {
                DPad(game: game)
                Spacer(minLength: 16)
                HStack(alignment: .bottom, spacing: 16) {
                    RoundButton(label: "B", code: 32, game: game).offset(y: 18)
                    RoundButton(label: "A", code: Key.letter("w"), game: game, accent: true).offset(y: -18)
                }
            }
        }
        .frame(maxHeight: 176)
    }

    @ViewBuilder private func group<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        if #available(iOS 26, *) { GlassEffectContainer(spacing: 24) { content() } } else { content() }
    }
}

private struct DPad: View {
    @ObservedObject var game: Game
    private let arm: CGFloat = 50
    var body: some View {
        VStack(spacing: 0) {
            Arrow(symbol: "arrowtriangle.up.fill", code: Key.letter("w"), game: game, repeats: false)
            HStack(spacing: arm) {
                Arrow(symbol: "arrowtriangle.left.fill", code: Key.letter("a"), game: game, repeats: true)
                Arrow(symbol: "arrowtriangle.right.fill", code: Key.letter("d"), game: game, repeats: true)
            }
            Arrow(symbol: "arrowtriangle.down.fill", code: Key.letter("s"), game: game, repeats: false)
        }
        .frame(width: arm * 3 + 12, height: arm * 3 + 12)
        .controlGlass(Circle())
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
            .foregroundStyle(.white.opacity(down ? 1 : 0.8))
            .frame(width: 50, height: 50)
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
            .contentShape(Circle())
            .controlGlass(Circle(), tint: accent ? terra : nil)
            .scaleEffect(down ? 0.92 : 1)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in if !down { down = true; game.press(code) } }
                .onEnded { _ in down = false })
            .accessibilityLabel(label == "A" ? "A, jump" : "B, swing")
            .accessibilityAddTraits(.isButton)
    }
}
#endif
