//
//  RebornDebugLogView.swift
//  YouTube Reborn
//
//  Live view of the tweak's diagnostic log (see Sources/UYTLog.xm). This mirrors
//  the logging surface uYouEnhanced exposes, adapted for Reborn: users can watch
//  what breaks when a future YouTube version changes behaviour and copy/share the
//  report straight into a bug report.
//

import SwiftUI
import Combine
import UIKit

struct RebornDebugLogView: View {

    @State private var report: String = ""
    @State private var live: Bool = true

    private let ticker = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RebornBackground()

            ScrollView(showsIndicators: true) {
                Text(report.isEmpty ? "Collecting diagnostics…" : report)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.85))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
        }
        .onAppear { refresh() }
        .onReceive(ticker) { _ in if live { refresh() } }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Toggle(isOn: $live) {
                    Image(systemName: live ? "pause.circle" : "play.circle")
                }
                .labelsHidden()
                .toggleStyle(.button)
                .tint(RebornTheme.accent)

                Button { refresh() } label: {
                    Image(systemName: "arrow.clockwise")
                }

                Button { UIPasteboard.general.string = report } label: {
                    Image(systemName: "doc.on.doc")
                }

                ShareLink(item: report) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func refresh() {
        report = UYTDebugFullReport()
    }
}
