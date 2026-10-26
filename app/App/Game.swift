import SwiftUI
import CoreGraphics

/// The game: joshuatree's user/mirage.c running here unchanged. It draws a 960 by 540 picture; this class turns it
/// into a CGImage whenever the game says a new frame is ready.
@MainActor
final class Game: ObservableObject {
    static let width = 960, height = 540
    @Published private(set) var frame: CGImage?
    private let pixels: UnsafeMutablePointer<UInt32>
    private let start = Date()

    init() {
        pixels = mirage_start(Int32(Game.width), Int32(Game.height))
        render()
    }

    /// Ticks since launch, 100 a second: the OS clock the game expects.
    var tick: UInt32 { UInt32(Date().timeIntervalSince(start) * 100) }

    func press(_ code: Int32) {
        mirage_key(code, tick)
        render()
    }

    func advance() {
        if mirage_tick(tick) != 0 { render() }
    }

    /// 0x00RRGGBB in memory is little-endian xRGB, which Core Graphics reads directly.
    private func render() {
        let bytes = Game.width * Game.height * 4
        let data = Data(bytes: pixels, count: bytes) as CFData
        guard let provider = CGDataProvider(data: data) else { return }
        frame = CGImage(width: Game.width, height: Game.height, bitsPerComponent: 8, bitsPerPixel: 32,
                        bytesPerRow: Game.width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue),
                        provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}

/// Key codes from joshuatree's user/jtsys.h.
enum Key {
    static let up: Int32 = 256, down: Int32 = 257, enter: Int32 = 258, left: Int32 = 261, right: Int32 = 262
    static func letter(_ c: Character) -> Int32 { Int32(c.asciiValue ?? 0) }
}
