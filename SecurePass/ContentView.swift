//
//  ContentView.swift
//  SecurePass
//
//  Created by Aditi More on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PassViewModel()
    @Namespace private var animation

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, Color.gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    header
                    if viewModel.isUnlocked {
                        walletStack
                        actionButtons
                    } else {
                        lockedState
                    }
                }
                .padding()
            }
            .navigationTitle("SecurePass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { privacyBadge }
            .sheet(isPresented: $viewModel.showScanner) { scannerSheet }
            .sheet(item: $viewModel.selectedPass) { pass in
                PassDetailSheet(pass: pass) {
                    viewModel.remove(pass)
                }
                .presentationBackground(.thinMaterial)
            }
            .alert("Authentication", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Encrypted on-device Wallet")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            Text("Passes, loyalty cards, and keys stay locally in your AES-encrypted vault. No sync, no network, just you and your device.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var walletStack: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: -70) {
                ForEach(Array(zip(viewModel.passes.indices, viewModel.passes)), id: \.1.id) { index, pass in
                    PassCardView(pass: pass) {
                        Task { await viewModel.open(pass) }
                    } onToggle: {
                        viewModel.toggleProtection(for: pass)
                    }
                    .padding(.horizontal)
                    .offset(y: CGFloat(index) * -10)
                    .rotationEffect(.degrees(Double(index) * -2), anchor: .center)
                    .matchedGeometryEffect(id: pass.id, in: animation)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.remove(pass)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 120)
        }
    }

    private var lockedState: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("Wallet Locked")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("Use Face ID / Touch ID to decrypt your pass vault. Data never leaves this device.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
            Button {
                Task { await viewModel.unlock() }
            } label: {
                Label("Unlock with Biometrics", systemImage: "faceid")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.mint)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                withAnimation(.spring) { viewModel.showScanner = true }
            } label: {
                Label("Scan to import", systemImage: "barcode.viewfinder")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            Text("Tap a pass to preview. Enable pass-level Face ID for keys or sensitive passes. Swiping down removes a pass.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var privacyBadge: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Label("On-device", systemImage: "bolt.shield")
                .padding(8)
                .background(.ultraThinMaterial, in: Capsule())
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var scannerSheet: some View {
        if #available(iOS 17.0, *) {
            VisionScannerView { code in
                viewModel.add(code: code)
                viewModel.showScanner = false
            }
            .edgesIgnoringSafeArea(.all)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "barcode")
                    .font(.largeTitle)
                Text("Vision scanning requires iOS 17. Add passes manually via pasted codes.")
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
