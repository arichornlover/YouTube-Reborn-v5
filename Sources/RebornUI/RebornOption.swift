//
//  RebornOption.swift
//  YouTube Reborn
//
//  Data model for the reimagined menu. The whole interface is driven from this
//  registry, which removes the duplicated controllers/cells that the old
//  table-view menu relied on and gives us one place to add or reorder options.
//

import Foundation

enum RebornAction: String, Identifiable {
    case viewDownloads
    case viewDownloadsInFilza
    case clearCache
    case restartYouTube
    case resetSettings
    case reportIssue
    case supportDevelopers

    var id: String { rawValue }
}

/// Screens that live entirely in the new SwiftUI layer.
enum RebornModernScreen: String, Identifiable, Hashable, CaseIterable {
    case notifications
    case tabOrder
    case startupPage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .tabOrder: return "Reorder Tabs"
        case .startupPage: return "Startup Tab"
        }
    }

    var subtitle: String {
        switch self {
        case .notifications: return "Custom notifications tab, icon & badge"
        case .tabOrder: return "Drag to reorder every tab"
        case .startupPage: return "Choose the tab the app opens on"
        }
    }

    var symbol: String {
        switch self {
        case .notifications: return "bell.badge.fill"
        case .tabOrder: return "rectangle.3.group"
        case .startupPage: return "house.fill"
        }
    }
}

/// Either a legacy Objective-C controller or a new SwiftUI screen.
enum RebornDestination: Hashable {
    case legacy(RebornLegacyScreen)
    case modern(RebornModernScreen)
}

enum RebornControl {
    case toggle(key: String, default: Bool)
    case navigation(RebornDestination)
    case action(RebornAction)
}

struct RebornOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let symbol: String
    let control: RebornControl

    init(id: String,
         title: String,
         subtitle: String? = nil,
         symbol: String,
         control: RebornControl) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.control = control
    }
}

/// Visual accent used to theme a section card. Kept abstract so the SwiftUI
/// layer owns the actual colours.
enum RebornTint {
    case red, pink, purple, blue, teal, green, orange, gray
}

struct RebornSection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: RebornTint
    let destination: RebornDestination
}

enum RebornOptionRegistry {

    // MARK: Featured toggles (front of the menu)

    static func featured() -> [RebornOption] {
        [
            RebornOption(id: "featured.adblock",
                         title: "Block Video Ads",
                         subtitle: "Remove video ads, banners and promos",
                         symbol: "hand.raised.fill",
                         control: .toggle(key: "kEnableNoVideoAds", default: true)),
            RebornOption(id: "featured.pip",
                         title: "Picture in Picture",
                         subtitle: "Keep videos playing in a floating window",
                         symbol: "pip.fill",
                         control: .toggle(key: "kEnablePictureInPictureVTwo", default: true)),
            RebornOption(id: "featured.redbar",
                         title: "Red Progress Bar",
                         subtitle: "Restore Reborn's classic red scrubber",
                         symbol: "arrow.left.and.right",
                         control: .toggle(key: "kRedProgressBar", default: false)),
            RebornOption(id: "featured.lowcontrast",
                         title: "Low Contrast Mode",
                         subtitle: "Softer labels closer to YouTube's old design",
                         symbol: "circle.lefthalf.filled",
                         control: .toggle(key: "kLowContrastMode", default: false)),
            RebornOption(id: "featured.hideop",
                         title: "Hide Reborn Overlay Button",
                         subtitle: "Hide the OP button inside the player",
                         symbol: "eye.slash.fill",
                         control: .toggle(key: "kHideRebornOPButtonVTwo", default: false))
        ]
    }

    // MARK: Quick actions

    static func quickActions() -> [RebornOption] {
        [
            RebornOption(id: "quick.downloads",
                         title: "Downloads",
                         symbol: "arrow.down.circle.fill",
                         control: .navigation(.legacy(.downloads))),
            RebornOption(id: "quick.colour",
                         title: "Colour",
                         symbol: "paintpalette.fill",
                         control: .navigation(.legacy(.colour))),
            RebornOption(id: "quick.restart",
                         title: "Restart",
                         symbol: "arrow.clockwise",
                         control: .action(.restartYouTube)),
            RebornOption(id: "quick.reset",
                         title: "Reset",
                         symbol: "trash.fill",
                         control: .action(.resetSettings))
        ]
    }

    // MARK: Modern (ported from uYouEnhanced)

    static func modernToggles() -> [RebornOption] {
        [
            RebornOption(id: "modern.adblock.full",
                         title: "AdBlock Workaround",
                         subtitle: "Strip playback, feed, shelf and Shorts ads",
                         symbol: "shield.fill",
                         control: .toggle(key: "kAdBlockWorkaround", default: false)),
            RebornOption(id: "modern.notifications",
                         title: "Show Notifications Tab",
                         subtitle: "Add a custom notifications tab to the bar",
                         symbol: "bell.badge.fill",
                         control: .toggle(key: "kShowNotificationsTab", default: false))
        ]
    }

    static func modernSections() -> [RebornSection] {
        [
            RebornSection(id: "s.modern.notifications",
                          title: "Notifications Tab",
                          subtitle: "Icon style, badge & bar position",
                          symbol: "bell.badge.fill",
                          tint: .pink,
                          destination: .modern(.notifications)),
            RebornSection(id: "s.modern.taborder",
                          title: "Reorder Tabs",
                          subtitle: "Arrange Home, Shorts, Notifications & more",
                          symbol: "arrow.up.arrow.down",
                          tint: .blue,
                          destination: .modern(.tabOrder)),
            RebornSection(id: "s.modern.startup",
                          title: "Startup Tab",
                          subtitle: "Open straight to Notifications or another tab",
                          symbol: "house.fill",
                          tint: .green,
                          destination: .modern(.startupPage))
        ]
    }

    // MARK: Reorganized sections

    static func sections() -> [RebornSection] {
        [
            RebornSection(id: "s.video",
                          title: "Playback & Player",
                          subtitle: "Fullscreen, gestures, speeds & more",
                          symbol: "play.rectangle.fill",
                          tint: .red,
                          destination: .legacy(.video)),
            RebornSection(id: "s.overlay",
                          title: "Video Overlay",
                          subtitle: "Buttons, progress bar & player chrome",
                          symbol: "square.grid.3x2.fill",
                          tint: .purple,
                          destination: .legacy(.overlay)),
            RebornSection(id: "s.shorts",
                          title: "Shorts",
                          subtitle: "Buttons and behaviour in the Shorts feed",
                          symbol: "play.square.stack.fill",
                          tint: .pink,
                          destination: .legacy(.shorts)),
            RebornSection(id: "s.tabbar",
                          title: "Tab Bar & Navigation",
                          subtitle: "Tabs, labels, Explore, Upload & more",
                          symbol: "rectangle.3.group.fill",
                          tint: .blue,
                          destination: .legacy(.tabBar)),
            RebornSection(id: "s.appearance",
                          title: "Appearance & Colour",
                          subtitle: "Recolour the entire app",
                          symbol: "paintbrush.fill",
                          tint: .teal,
                          destination: .legacy(.colour)),
            RebornSection(id: "s.pip",
                          title: "Picture in Picture",
                          subtitle: "Badges and PiP behaviour",
                          symbol: "pip.fill",
                          tint: .orange,
                          destination: .legacy(.pictureInPicture)),
            RebornSection(id: "s.other",
                          title: "Other Options",
                          subtitle: "Branding, hints, ads, kids & more",
                          symbol: "ellipsis.circle.fill",
                          tint: .purple,
                          destination: .legacy(.other)),
            RebornSection(id: "s.settings",
                          title: "Reborn Settings",
                          subtitle: "Global switches, reset & credits",
                          symbol: "switch.2",
                          tint: .red,
                          destination: .legacy(.rebornSettings))
        ]
    }

    // MARK: About rows

    static func about() -> [RebornOption] {
        [
            RebornOption(id: "about.credits",
                         title: "Credits",
                         symbol: "star.fill",
                         control: .navigation(.legacy(.credits))),
            RebornOption(id: "about.report",
                         title: "Report an Issue",
                         symbol: "exclamationmark.bubble.fill",
                         control: .action(.reportIssue)),
            RebornOption(id: "about.support",
                         title: "Support the Developers",
                         symbol: "heart.fill",
                         control: .action(.supportDevelopers))
        ]
    }
}
