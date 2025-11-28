import SwiftUI

struct PassCardView: View {
    let pass: SecurePassItem
    var onOpen: () -> Void
    var onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: pass.kind.icon)
                    .font(.title2.weight(.semibold))
                VStack(alignment: .leading) {
                    Text(pass.kind.label.uppercased())
                        .font(.caption).bold()
                        .opacity(0.7)
                    Text(pass.title)
                        .font(.title3).bold()
                }
                Spacer()
                if pass.requiresBiometric {
                    Image(systemName: "lock.fill")
                        .imageScale(.medium)
                        .transition(.opacity)
                }
            }

            Text(pass.detail)
                .font(.subheadline)
                .lineLimit(2)
                .opacity(0.9)

            HStack {
                Label("Preview", systemImage: "viewfinder")
                    .font(.footnote.bold())
                Spacer()
                Button(action: onToggle) {
                    Label(pass.requiresBiometric ? "Protected" : "Quick open", systemImage: pass.requiresBiometric ? "hand.raised.fill" : "hand.tap")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThickMaterial, in: Capsule())
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(pass.tint.swiftUIColor.gradient)
                .shadow(color: pass.tint.swiftUIColor.opacity(0.35), radius: 16, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.2))
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: pass.requiresBiometric)
    }
}

struct PassDetailSheet: View {
    let pass: SecurePassItem
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 8)

            VStack(spacing: 12) {
                Label(pass.kind.label, systemImage: pass.kind.icon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(pass.tint.swiftUIColor)
                Text(pass.title)
                    .font(.largeTitle.bold())
                Text(pass.detail)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text("Secure code")
                    .font(.caption.bold())
                    .opacity(0.6)
                Text(pass.code)
                    .font(.title3.monospaced())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            }

            Spacer()
            Button(role: .destructive, action: onDelete) {
                Label("Remove pass", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .presentationDetents([.fraction(0.5), .large])
    }
}
