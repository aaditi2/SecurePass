import Foundation
import SwiftUI
import UIKit

struct SecurePassItem: Identifiable, Codable, Equatable {
    enum Kind: String, Codable, CaseIterable {
        case event
        case loyalty
        case key
        case transit
        case generic

        var icon: String {
            switch self {
            case .event: return "ticket"
            case .loyalty: return "giftcard"
            case .key: return "key.fill"
            case .transit: return "tram.fill"
            case .generic: return "wallet.pass"
            }
        }

        var label: String {
            switch self {
            case .event: return "Event"
            case .loyalty: return "Loyalty"
            case .key: return "Key"
            case .transit: return "Transit"
            case .generic: return "Pass"
            }
        }
    }

    let id: UUID
    var title: String
    var detail: String
    var kind: Kind
    var tint: ColorRepresentation
    var code: String
    var requiresBiometric: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        kind: Kind,
        tint: Color = .blue,
        code: String,
        requiresBiometric: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.kind = kind
        self.tint = ColorRepresentation(color: tint)
        self.code = code
        self.requiresBiometric = requiresBiometric
    }
}

struct ColorRepresentation: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(color: Color) {
        let resolved = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Array where Element == SecurePassItem {
    static var demo: [SecurePassItem] {
        [
            SecurePassItem(
                title: "Concert Night",
                detail: "Floor 1 • Row B • Seat 12",
                kind: .event,
                tint: .purple,
                code: "EVT-8291-2345",
                requiresBiometric: true
            ),
            SecurePassItem(
                title: "Coffee Club",
                detail: "Rewards #8844  • 10/12 punches",
                kind: .loyalty,
                tint: .orange,
                code: "LTT-2210-3399"
            ),
            SecurePassItem(
                title: "Smart Lock",
                detail: "Front Door • Home",
                kind: .key,
                tint: .teal,
                code: "HOME-LOCK-KEY",
                requiresBiometric: true
            ),
            SecurePassItem(
                title: "Metro Card",
                detail: "3 rides remaining",
                kind: .transit,
                tint: .indigo,
                code: "MTR-5511-9921"
            )
        ]
    }
}
