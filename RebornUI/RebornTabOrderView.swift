//
//  RebornTabOrderView.swift
//  YouTube Reborn
//
//  Reimagined tab reordering. Covers every pivot bar item — Home, Shorts,
//  Create, Subscriptions, You, Explore and the custom Notifications tab — and
//  persists the arrangement as Reborn's kTabOrder key, which both Tweak.xm and
//  NotificationsTab.xm apply.
//

import SwiftUI

struct RebornTabOrderView: View {

    private struct RebornTabItem: Identifiable, Equatable {
        let id: String
        let title: String
        let symbol: String
    }

    private let store = RebornSettingsStore.shared

    @State private var items: [RebornTabItem]
    @State private var editMode: EditMode = .inactive

    init() {
        _items = State(initialValue: Self.load())
    }

    private static func defaultTabs() -> [RebornTabItem] {
        [
            RebornTabItem(id: "FEwhat_to_watch", title: "Home", symbol: "house.fill"),
            RebornTabItem(id: "FEshorts", title: "Shorts", symbol: "play.square.stack.fill"),
            RebornTabItem(id: "FEuploads", title: "Create", symbol: "plus.circle.fill"),
            RebornTabItem(id: "FEsubscriptions", title: "Subscriptions", symbol: "rectangle.stack.badge.play.fill"),
            RebornTabItem(id: "FElibrary", title: "You", symbol: "person.fill"),
            RebornTabItem(id: "FEexplore", title: "Explore", symbol: "safari.fill"),
            RebornTabItem(id: "FEnotifications_inbox", title: "Notifications", symbol: "bell.fill")
        ]
    }

    private static func load() -> [RebornTabItem] {
        var tabs = defaultTabs()
        guard let stored = RebornSettingsStore.shared.object("kTabOrder") as? [String], !stored.isEmpty else {
            return tabs
        }
        var result: [RebornTabItem] = []
        var remaining = tabs
        for identifier in stored {
            if let index = remaining.firstIndex(where: { $0.id == identifier }) {
                result.append(remaining[index])
                remaining.remove(at: index)
            }
        }
        result.append(contentsOf: remaining)
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    ForEach(items) { item in
                        HStack(spacing: 14) {
                            RebornIconBubble(symbol: item.symbol, tint: RebornTheme.accent)
                            Text(item.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer(minLength: 8)
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(RebornCardBackground(cornerRadius: 16))
                    }
                    .onMove(perform: move)
                } header: {
                    Text("Drag to arrange every tab")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.45))
                        .textCase(nil)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)

            resetRow
        }
        .background(RebornBackground())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(editMode == .active ? "Done" : "Edit") {
                    withAnimation { editMode = editMode == .active ? .inactive : .active }
                }
                .fontWeight(.semibold)
                .tint(RebornTheme.accent)
            }
        }
    }

    private var resetRow: some View {
        Button {
            store.remove("kTabOrder")
            items = Self.defaultTabs()
            withAnimation { editMode = .inactive }
        } label: {
            HStack(spacing: 10) {
                Spacer()
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold))
                Text("Reset to Default")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .rebornCard()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 30)
    }

    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        store.set(items.map { $0.id }, for: "kTabOrder")
    }
}