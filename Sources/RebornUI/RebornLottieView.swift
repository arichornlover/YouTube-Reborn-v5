//
//  RebornLottieView.swift
//  YouTube Reborn
//
//  Optional Lottie hook for the hero header and section icons. Lottie is a
//  Swift-only dependency, so it is compiled in only when the module is present
//  (`canImport`). Until the framework is vendored in the build, the menu falls
//  back to a lightweight SwiftUI animation with the exact same API.
//

import SwiftUI
import UIKit

struct RebornHeroAnimation: View {
    var size: CGFloat = 96

    var body: some View {
        #if canImport(Lottie)
        RebornLottiePlayer(name: "reborn_hero")
            .frame(width: size, height: size)
        #else
        ZStack {
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

            Image(systemName: "play.rectangle.on.rectangle.fill")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: RebornTheme.accent.opacity(0.8), radius: 12, x: 0, y: 4)
        }
        #endif
    }
}

#if canImport(Lottie)
import Lottie

/// Thin wrapper around Lottie's SwiftUI view (Lottie 4.x).
struct RebornLottiePlayer: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.play()
        return view
    }

    func updateUIViewController(_ uiView: LottieAnimationView, context: Context) {}
}
#endif
