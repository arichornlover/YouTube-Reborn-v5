//
//  RebornHomeView.swift
//  YouTube Reborn
//
//  The reimagined root menu. A card-based, glassy layout that deliberately
//  avoids the stock settings look: gradient hero header, a quick-action rail,
//  featured toggles and reorganised section cards.
//

import SwiftUI
import UIKit

// MARK: - View model

final class RebornHomeModel: ObservableObject {

    @Published private(set) var values: [String: Bool] = [:]

    private let store = RebornSettingsStore.shared

    let rebornVersion = "5.0.0"

    var youtubeVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
    }

    init() {
        var seeded: [String: Bool] = [:]
        for option in RebornOptionRegistry.featured() + RebornOptionRegistry.modernToggles() {
            if case let .toggle(key, fallback) = option.control {
                seeded[key] = store.bool(key, default: fallback)
            }
        }
        values = seeded
    }

    func binding(for option: RebornOption) -> Binding<Bool> {
        guard case let .toggle(key, fallback) = option.control else {
            return .constant(false)
        }
        return Binding(
            get: { [weak self] in self?.values[key] ?? fallback },
            set: { [weak self] newValue in
                self?.values[key] = newValue
                self?.store.set(newValue, forKey: key)
            }
        )
    }
}

// MARK: - Root view

struct RebornHomeView: View {

    @StateObject private var model = RebornHomeModel()

    var body: some View {
        NavigationStack {
            ZStack {
                RebornBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        header
                        quickActions
                        featuredCard
                        modernCard
                        sectionsList
                        aboutCard
                        footer
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 48)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: RebornDestination.self) { destination in
                destinationView(destination)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func destinationView(_ destination: RebornDestination) -> some View {
        switch destination {
        case .legacy(let screen):
            RebornLegacyView(screen: screen)
                .navigationTitle(screen.title)
                .navigationBarTitleDisplayMode(.inline)
        case .modern(let screen):
            modernView(screen)
                .navigationTitle(screen.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func modernView(_ screen: RebornModernScreen) -> some View {
        switch screen {
        case .notifications:
            RebornNotificationsView()
        case .tabOrder:
            RebornTabOrderView()
        case .startupPage:
            RebornStartupPageView()
        case .debugLog:
            RebornDebugLogView()
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 12) {
            RebornHeroAnimation(size: 92)

            Text("YouTube Reborn")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("REIMAGINED · v\(model.rebornVersion)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(RebornTheme.accent)

            Text("YouTube \(model.youtubeVersion)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 8) {
                versionPill(symbol: "play.rectangle.fill", text: "YouTube \(model.youtubeVersion)")
                versionPill(symbol: "wand.and.stars", text: "Reborn \(model.rebornVersion)")
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private func versionPill(symbol: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.85))
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule().fill(.ultraThinMaterial)
        )
    }

    // MARK: Quick actions

    private var quickActions: some View {
        HStack(spacing: 12) {
            ForEach(RebornOptionRegistry.quickActions()) { option in
                quickAction(option)
            }
        }
    }

    @ViewBuilder
    private func quickAction(_ option: RebornOption) -> some View {
        switch option.control {
        case .navigation(let destination):
            NavigationLink(value: destination) { quickActionLabel(option) }
                .buttonStyle(.plain)
        case .action(let action):
            Button { RebornActions.perform(action) } label: { quickActionLabel(option) }
                .buttonStyle(.plain)
        case .toggle:
            quickActionLabel(option)
        }
    }

    private func quickActionLabel(_ option: RebornOption) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(.ultraThinMaterial)
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                Image(systemName: option.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(RebornTheme.accent)
            }
            .frame(width: 54, height: 54)

            Text(option.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Featured toggles

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Essentials", symbol: "sparkles", tint: RebornTheme.accent)

            ForEach(Array(RebornOptionRegistry.featured().enumerated()), id: \.element.id) { index, option in
                if index > 0 {
                    Divider().overlay(Color.white.opacity(0.08))
                }
                RebornToggleRow(option: option, isOn: model.binding(for: option))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .rebornCard()
    }

    // MARK: Modern (ported from uYouEnhanced)

    private var modernCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Modern", symbol: "wand.and.rays", tint: RebornTheme.accent)

            ForEach(Array(RebornOptionRegistry.modernToggles().enumerated()), id: \.element.id) { index, option in
                if index > 0 {
                    Divider().overlay(Color.white.opacity(0.08))
                }
                RebornToggleRow(option: option, isOn: model.binding(for: option))
            }

            Divider().overlay(Color.white.opacity(0.08))

            ForEach(RebornOptionRegistry.modernSections()) { section in
                NavigationLink(value: section.destination) {
                    HStack(spacing: 14) {
                        RebornIconBubble(symbol: section.symbol, tint: RebornTheme.tint(section.tint))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(section.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(section.subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .rebornCard()
    }

    // MARK: Section cards

    private var sectionsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SECTIONS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.45))
                .padding(.leading, 6)

            ForEach(RebornOptionRegistry.sections()) { section in
                NavigationLink(value: section.destination) {
                    RebornSectionCard(section: section)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: About

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "About", symbol: "info.circle.fill", tint: RebornTheme.accent)

            ForEach(Array(RebornOptionRegistry.about().enumerated()), id: \.element.id) { index, option in
                if index > 0 {
                    Divider().overlay(Color.white.opacity(0.08))
                }
                aboutRow(option)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .rebornCard()
    }

    @ViewBuilder
    private func aboutRow(_ option: RebornOption) -> some View {
        switch option.control {
        case .navigation(let destination):
            NavigationLink(value: destination) { aboutLabel(option, chevron: true) }
                .buttonStyle(.plain)
        case .action(let action):
            Button { RebornActions.perform(action) } label: { aboutLabel(option, chevron: true) }
                .buttonStyle(.plain)
        case .toggle:
            aboutLabel(option, chevron: false)
        }
    }

    private func aboutLabel(_ option: RebornOption, chevron: Bool) -> some View {
        HStack(spacing: 14) {
            RebornIconBubble(symbol: option.symbol, tint: RebornTheme.accent)
            Text(option.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer(minLength: 8)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func cardHeader(title: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
        }
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 4) {
            Text("YouTube Reborn v\(model.rebornVersion)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
            Text("Reimagined menu · iOS 16+")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Components

struct RebornToggleRow: View {
    let option: RebornOption
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            RebornIconBubble(symbol: option.symbol, tint: RebornTheme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                if let subtitle = option.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(RebornTheme.accent)
        }
        .padding(.vertical, 11)
    }
}

struct RebornSectionCard: View {
    let section: RebornSection

    var body: some View {
        let tint = RebornTheme.tint(section.tint)

        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.95), tint.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: section.symbol)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(section.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Text(section.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(16)
        .rebornCard()
    }
}

struct RebornIconBubble: View {
    let symbol: String
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(tint.opacity(0.18))
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 38, height: 38)
    }
}

struct RebornBackground: View {
    var body: some View {
        ZStack {
            RebornTheme.background

            RadialGradient(
                colors: [RebornTheme.accent.opacity(0.30), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 420
            )
            .blur(radius: 20)

            RadialGradient(
                colors: [Color.purple.opacity(0.22), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 360
            )
            .blur(radius: 30)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Actions

enum RebornActions {

    static func perform(_ action: RebornAction) {
        switch action {
        case .restartYouTube:
            restart()
        case .resetSettings:
            RebornSettingsStore.shared.resetAll()
            restart()
        case .reportIssue:
            open("https://github.com/arichornlover/YouTube-Reborn-v5/issues")
        case .supportDevelopers:
            open("https://github.com/sponsors/LillieH1000")
        case .clearCache:
            clearCache()
        case .viewDownloads, .viewDownloadsInFilza:
            break
        }
    }

    static func restart() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exit(0)
        }
    }

    static func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    static func clearCache() {
        let fm = FileManager.default
        var freed: UInt64 = 0
        if let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
            if let items = try? fm.contentsOfDirectory(at: caches, includingPropertiesForKeys: nil) {
                for item in items {
                    if let attrs = try? fm.attributesOfItem(atPath: item.path),
                       let size = attrs[.size] as? UInt64 {
                        freed += size
                    }
                    try? fm.removeItem(at: item)
                }
            }
        }
        let mb = Double(freed) / 1_048_576.0
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Cache Cleared",
                message: String(format: "Freed %.1f MB.", mb),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topViewController()?.present(alert, animated: true)
        }
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
        guard let windowScene = scene as? UIWindowScene else { return nil }
        var top = windowScene.windows.first { $0.isKeyWindow }?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
