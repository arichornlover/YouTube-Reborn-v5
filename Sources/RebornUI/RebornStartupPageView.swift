//
//  RebornStartupPageView.swift
//  YouTube Reborn
//
//  Reimagined startup tab picker. Writes Reborn's kStartupPageIntVTwo key so
//  the YTPivotBarViewController hook in Tweak.xm selects the tab on launch —
//  including the custom Notifications tab (value 5).
//

import SwiftUI

struct RebornStartupPageView: View {

    private struct StartupOption: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let symbol: String
    }

    private let store = RebornSettingsStore.shared

    @State private var selected: Int

    private let options: [StartupOption] = [
        StartupOption(id: 0, title: "Home", subtitle: "The standard home feed", symbol: "house.fill"),
        StartupOption(id: 1, title: "Explore", subtitle: "Search and trending", symbol: "safari.fill"),
        StartupOption(id: 2, title: "Shorts", subtitle: "Jump straight to Shorts", symbol: "play.square.stack.fill"),
        StartupOption(id: 3, title: "Subscriptions", subtitle: "Your latest uploads", symbol: "rectangle.stack.badge.play.fill"),
        StartupOption(id: 4, title: "You", subtitle: "Library and history", symbol: "person.fill"),
        StartupOption(id: 5, title: "Notifications", subtitle: "Open straight to the custom notifications tab", symbol: "bell.fill")
    ]

    init() {
        _selected = State(initialValue: RebornSettingsStore.shared.integer("kStartupPageIntVTwo"))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("CHOOSE A STARTUP TAB")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.leading, 6)

                VStack(spacing: 0) {
                    ForEach(options) { option in
                        if option.id != options.first?.id {
                            Divider().overlay(Color.white.opacity(0.08))
                        }
                        Button {
                            selected = option.id
                            store.setInteger(option.id, for: "kStartupPageIntVTwo")
                        } label: {
                            HStack(spacing: 14) {
                                RebornIconBubble(symbol: option.symbol, tint: RebornTheme.accent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(option.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                                Spacer(minLength: 8)
                                if option.id == selected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(RebornTheme.accent)
                                }
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

                HStack(alignment: .top, spacing: 12) {
                    RebornIconBubble(symbol: "lightswitch.on", tint: RebornTheme.accent)
                    Text("Reborn will switch to this tab every time YouTube launches. Requires the matching tab to be visible in the bar.")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(16)
                .rebornCard()
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
        .background(RebornBackground())
    }
}