import Foundation
import SwiftUI

@MainActor
final class PassViewModel: ObservableObject {
    @Published private(set) var passes: [SecurePassItem] = []
    @Published var isUnlocked = false
    @Published var showScanner = false
    @Published var selectedPass: SecurePassItem?
    @Published var errorMessage: String?

    private let storage = SecurePassStorage()

    init() {
        passes = storage.loadPasses()
    }

    func unlock() async {
        do {
            let success = try await BiometricAuthenticator.authenticate(reason: "Unlock your vault")
            isUnlocked = success
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func open(_ pass: SecurePassItem) async {
        guard pass.requiresBiometric else {
            selectedPass = pass
            return
        }

        do {
            let success = try await BiometricAuthenticator.authenticate(reason: "Unlock \(pass.title)")
            if success { selectedPass = pass }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func add(code: String) {
        var normalized = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty { return }

        let kind: SecurePassItem.Kind
        if normalized.uppercased().contains("EVT") { kind = .event }
        else if normalized.uppercased().contains("KEY") { kind = .key }
        else if normalized.uppercased().contains("MET") { kind = .transit }
        else { kind = .generic }

        let newPass = SecurePassItem(
            title: "Imported Pass",
            detail: "Scanned via Vision",
            kind: kind,
            tint: .mint,
            code: normalized,
            requiresBiometric: kind == .key
        )

        withAnimation(.spring(duration: 0.25)) {
            passes.insert(newPass, at: 0)
        }
        persist()
    }

    func toggleProtection(for pass: SecurePassItem) {
        guard let index = passes.firstIndex(of: pass) else { return }
        passes[index].requiresBiometric.toggle()
        persist()
    }

    func remove(_ pass: SecurePassItem) {
        passes.removeAll { $0.id == pass.id }
        persist()
    }

    private func persist() {
        storage.save(passes)
    }
}
