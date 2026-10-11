//
//  RebornRootViewController.swift
//  YouTube Reborn
//
//  Entry point used by the Logos hooks. It hosts the SwiftUI menu inside a
//  plain UIViewController so the tweak can present it exactly like the old
//  RootOptionsController while keeping the modern navigation stack.
//

import SwiftUI
import UIKit

@objc(RebornRootViewController)
public final class RebornRootViewController: UIViewController {

    @objc public static func make() -> UIViewController {
        RebornRootViewController()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let host = UIHostingController(rootView: RebornHomeView())
        addChild(host)

        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        host.didMove(toParent: self)
    }
}
