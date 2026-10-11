//
//  RebornLottieView.swift
//  YouTube Reborn
//
//  Optional Lottie hook for the hero header and section icons. Lottie is a
//  Swift-only dependency, so it is compiled in only when the module is present
//  (`canImport`). Stage it with `Tools/fetch-lottie.sh` to activate; until then
//  the menu falls back to a lightweight SwiftUI animation with the same energy.
//

import SwiftUI
import UIKit

/// Reborn's signature hero: a glowing pink emblem with a rotating orbit ring.
/// Uses the real Lottie animation when the framework is present, otherwise a
/// SwiftUI stand-in that pulses, spins and breathes just like the logo.
struct RebornHeroAnimation: View {
    var size: CGFloat = 96
    @State private var spin = false
    @State private var pulse = 1.0

    var body: some View {
        Group {
            #if canImport(Lottie)
            RebornLottiePlayer(name: "reborn_hero")
                .frame(width: size, height: size)
            #else
            fallback
            #endif
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                spin = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = 1.06
            }
        }
    }

    @ViewBuilder
    private var fallback: some View {
        ZStack {
            // soft glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [RebornTheme.accent.opacity(0.55), RebornTheme.accent.opacity(0.05)],
                        center: .center,
                        startRadius: 2,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)
                .blur(radius: 6)

            // spinning dashed orbit
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [RebornTheme.accent, RebornTheme.accent.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [5, 8])
                )
                .frame(width: size * 0.86, height: size * 0.86)
                .rotationEffect(.degrees(spin ? 360 : 0))

            // glow ring
            Circle()
                .stroke(RebornTheme.accent.opacity(0.5), lineWidth: 1)
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(pulse)

            // emblem badge
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [RebornTheme.accent, RebornTheme.accent.opacity(0.75)],
                        center: .center,
                        startRadius: 2,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.62, height: size * 0.62)
                .scaleEffect(pulse)
                .shadow(color: RebornTheme.accent.opacity(0.7), radius: 12, x: 0, y: 4)

            // play glyph
            Image(systemName: "play.fill")
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
                .scaleEffect(pulse * 1.02)
        }
    }
}

#if canImport(Lottie)
import Lottie

private func rebornAnimBundle() -> Bundle? {
    if let path = Bundle.main.path(forResource: "YouTubeReborn", ofType: "bundle") {
        return Bundle(path: path)
    }
    return nil
}

/// Thin wrapper around Lottie's SwiftUI view (Lottie 4.x).
struct RebornLottiePlayer: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let view: LottieAnimationView
        if let bundle = rebornAnimBundle(),
           let path = bundle.path(forResource: name, ofType: "json", inDirectory: "Lottie") {
            view = LottieAnimationView(filePath: path)
        } else {
            view = LottieAnimationView(name: name)
        }
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
#endif