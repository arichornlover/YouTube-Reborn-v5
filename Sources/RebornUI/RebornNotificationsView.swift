//
//  RebornNotificationsView.swift
//  YouTube Reborn
//
//  Reimagined configuration for the custom notifications tab. Writes the same
//  keys the NotificationsTab.xm hooks read (kNotificationIconStyle,
//  kNotificationsTabIndex, kShowNotificationsTab).
//

import SwiftUI

struct RebornNotificationsView: View {

    private let store = RebornSettingsStore.shared

    @State private var iconStyle: Int
    @State private var position: Int

    private let iconStyles: [(value: Int, title: String, subtitle: String)] = [
        (0, "Modern", "Outlined 2025-style bell"),
        (1, "Classic", "Filled and unfilled bell pairs"),
        (2, "Filled", "Solid 24pt bell"),
        (3, "Inbox", "Inbox bell, gray when idle"),
        (4, "Classic Inbox", "Classic inbox icon treatments")
    ]

    init() {
        _iconStyle = State(initialValue: RebornSettingsStore.shared.integer("kNotificationIconStyle"))
        _position = State(initialValue: RebornSettingsStore.shared.integer("kNotificationsTabIndex"))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                iconCard
                positionCard
                hintCard
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
        .background(RebornBackground())
    }

    // MARK: Icon style

    private var iconCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Icon Style", symbol: "paintpalette.fill")

            ForEach(iconStyles, id: \.value) { style in
                if style.value != iconStyles.first?.value {
                    Divider().overlay(Color.white.opacity(0.08))
                }
                Button {
                    iconStyle = style.value
                    store.setInteger(style.value, for: "kNotificationIconStyle")
                } label: {
                    HStack(spacing: 14) {
                        RebornIconBubble(symbol: "bell\(style.value == 2 ? ".fill" : "")",
                                         tint: style.value == iconStyle ? RebornTheme.accent : Color.white.opacity(0.35))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(style.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(style.subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer(minLength: 8)
                        if style.value == iconStyle {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(RebornTheme.accent)
                        }
                    }
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .rebornCard()
    }

    // MARK: Position

    private var positionCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Bar Position", symbol: "slider.horizontal.3")

            HStack(spacing: 14) {
                RebornIconBubble(symbol: "list.number", tint: RebornTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications tab index")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Where the tab sits when it is added")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer(minLength: 8)
                Stepper("", value: $position, in: 0...7)
                    .labelsHidden()
                    .onChange(of: position) { newValue in
                        store.setInteger(max(0, newValue), for: "kNotificationsTabIndex")
                    }
                Text("\(position)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(minWidth: 28)
            }
            .padding(.vertical, 11)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .rebornCard()
    }

    // MARK: Hint

    private var hintCard: some View {
        HStack(alignment: .top, spacing: 12) {
            RebornIconBubble(symbol: "wand.and.rays", tint: RebornTheme.accent)
            Text("Tip: use Reorder Tabs to place Notifications anywhere, and set it as the Startup Tab to open straight here.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(16)
        .rebornCard()
    }

    private func cardHeader(title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(RebornTheme.accent)
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
        }
        .padding(.top, 14)
        .padding(.bottom, 6)
    }
}