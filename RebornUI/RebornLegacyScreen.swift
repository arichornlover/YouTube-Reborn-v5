//
//  RebornLegacyScreen.swift
//  YouTube Reborn
//
//  Bridges the legacy Objective-C settings controllers into the new SwiftUI
//  menu. Each case knows how to construct its controller so the SwiftUI layer
//  can push it via a UIViewControllerRepresentable.
//

import UIKit

enum RebornLegacyScreen: String, Identifiable, CaseIterable {
    case video
    case overlay
    case tabBar
    case colour
    case pictureInPicture
    case shorts
    case other
    case rebornSettings
    case downloads
    case credits
    case startupPage
    case reorderPivotBar

    var id: String { rawValue }

    var title: String {
        switch self {
        case .video: return "Video Options"
        case .overlay: return "Overlay Options"
        case .tabBar: return "Tab Bar Options"
        case .colour: return "Colour Options"
        case .pictureInPicture: return "Picture In Picture"
        case .shorts: return "Shorts Options"
        case .other: return "Other Options"
        case .rebornSettings: return "Reborn Settings"
        case .downloads: return "Downloads"
        case .credits: return "Credits"
        case .startupPage: return "Startup Page"
        case .reorderPivotBar: return "Reorder Tab Bar"
        }
    }

    func makeViewController() -> UIViewController {
        switch self {
        case .video:
            return VideoOptionsController(style: .grouped)
        case .overlay:
            return OverlayOptionsController(style: .grouped)
        case .tabBar:
            return TabBarOptionsController(style: .grouped)
        case .colour:
            return ColourOptionsController()
        case .pictureInPicture:
            return PictureInPictureOptionsController(style: .grouped)
        case .shorts:
            return ShortsOptionsController(style: .grouped)
        case .other:
            return OtherOptionsController(style: .grouped)
        case .rebornSettings:
            return RebornSettingsController(style: .grouped)
        case .downloads:
            return DownloadsController()
        case .credits:
            return CreditsController(style: .grouped)
        case .startupPage:
            return StartupPageOptionsController(style: .grouped)
        case .reorderPivotBar:
            return ReorderPivotBarController(style: .grouped)
        }
    }
}
