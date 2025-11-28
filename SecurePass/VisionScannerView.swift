import SwiftUI
import VisionKit

@available(iOS 17.0, *)
struct VisionScannerView: UIViewControllerRepresentable {
    var onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(), .text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        guard uiViewController.isScanning == false else { return }
        do {
            try uiViewController.startScanning()
        } catch {
            print("Unable to start scanning: \(error.localizedDescription)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeFound: onCodeFound)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onCodeFound: (String) -> Void

        init(onCodeFound: @escaping (String) -> Void) {
            self.onCodeFound = onCodeFound
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            handle(item: item)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = items.first else { return }
            handle(item: item)
        }

        private func handle(item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                onCodeFound(barcode.payloadStringValue ?? "")
            case .text(let text):
                let best = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                guard best.isEmpty == false else { return }
                onCodeFound(best)
            default:
                break
            }
        }
    }
}
