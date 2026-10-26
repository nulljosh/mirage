import SwiftUI
import CoreGraphics

/// The game: joshuatree's user/mirage.c running here unchanged. It draws a picture the shape of the view it fills
/// (960 by 540 to start); this class turns it into a CGImage whenever the game says a new frame is ready.
@MainActor
final class Game: ObservableObject {
    @Published private(set) var frame: CGImage?
    private(set) var width = 960, height = 540
    private let pixels: UnsafeMutablePointer<UInt32>
    private let start = Date()

    init() {
        pixels = mirage_start(Int32(width), Int32(height))
        #if os(iOS)
        mirage_touch()
        #endif
        render()
    }

    /// Ticks since launch, 100 a second: the OS clock the game expects.
    var tick: UInt32 { UInt32(Date().timeIntervalSince(start) * 100) }

    /// The picture's size in pixels for a view of this shape: 540 on the short side, the long side to match.
    func fit(_ size: CGSize) {
        guard size.width > 1, size.height > 1 else { return }
        let aspect = size.width / size.height
        var w = aspect >= 1 ? Int(540 * aspect) : 540, h = aspect >= 1 ? 540 : Int(540 / aspect)
        if w * h > 1280 * 720 { let k = (Double(1280 * 720) / Double(w * h)).squareRoot(); w = Int(Double(w) * k); h = Int(Double(h) * k) }
        guard w != width || h != height else { return }
        width = w; height = h
        mirage_resize(Int32(w), Int32(h))
        render()
    }

    func press(_ code: Int32) {
        mirage_key(code, tick)
        render()
    }

    func advance() {
        if mirage_tick(tick) != 0 { render() }
    }

    /// 0x00RRGGBB in memory is little-endian xRGB, which Core Graphics reads directly.
    private func render() {
        let data = Data(bytes: pixels, count: width * height * 4) as CFData
        guard let provider = CGDataProvider(data: data) else { return }
        frame = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                        bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue),
                        provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}

/// Key codes from joshuatree's user/jtsys.h.
enum Key {
    static let up: Int32 = 256, down: Int32 = 257, enter: Int32 = 258, left: Int32 = 261, right: Int32 = 262
    static func letter(_ c: Character) -> Int32 { Int32(c.asciiValue ?? 0) }
}
