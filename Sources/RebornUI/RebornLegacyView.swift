//
//  RebornLegacyView.swift
//  YouTube Reborn
//
//  Wraps a legacy Objective-C settings controller so it can be pushed from the
//  SwiftUI navigation stack while the individual screens are migrated one by
//  one to the new design.
//

import SwiftUI
import UIKit

struct RebornLegacyView: UIViewControllerRepresentable {
    let screen: RebornLegacyScreen

    func makeUIViewController(context: Context) -> UIViewController {
        screen.makeViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Legacy controllers manage themselves; nothing to update.
    }
}
