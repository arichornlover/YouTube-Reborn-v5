import SwiftUI
import Combine
import UIKit

// MARK: - Objective-C sheet presenter

public final class RebornDownloadSheet: NSObject {
    @objc public static func present(payload: RebornDownloadPayload, from presenter: UIViewController) {
        let hosting = UIHostingController(rootView: RebornDownloadRoot(payload: payload))
        hosting.modalPresentationStyle = .pageSheet
        if let sheet = hosting.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            if sheet.responds(to: NSSelectorFromString("setPreferredCornerRadius:")) {
                sheet.setValue(RebornTheme.cardCornerRadius, forKey: "preferredCornerRadius")
            }
        }
        presenter.present(hosting, animated: true)
    }
}

// MARK: - Model

enum RebornDownloadMode {
    case video
    case audio
}

struct RebornFormatTier: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let codec: String
    let size: String
    let hasDirectURL: Bool
    let isHDR: Bool
    let format: RebornStreamFormat
}

enum RebornDownloadStatus: Equatable {
    case ready
    case running(phase: String, fraction: Double, bytes: UInt64)
    case succeeded(path: String)
    case failed(String)
}

final class RebornDownloadModel: ObservableObject {
    let payload: RebornDownloadPayload

    @Published var mode: RebornDownloadMode = .video
    @Published var selectedVideoID = 0
    @Published var selectedAudioID = 0
    @Published var status: RebornDownloadStatus = .ready
    @Published var speedBytesPerSecond: Double = 0

    var videoTiers: [RebornFormatTier] = []
    var audioTiers: [RebornFormatTier] = []

    var selectedVideo: RebornStreamFormat? {
        videoTiers.first { $0.id == selectedVideoID }?.format
    }

    var selectedAudio: RebornStreamFormat? {
        audioTiers.first { $0.id == selectedAudioID }?.format
    }

    var canDownload: Bool {
        payload.canUseSABR || (selectedVideo?.directURL != nil) || (selectedAudio?.directURL != nil && mode == .audio)
    }

    var isRunning: Bool {
        if case .running = status { return true }
        return false
    }

    private var speedTimer: Timer?
    private var lastBytes: UInt64 = 0
    private var lastSampleTime = Date()

    init(payload: RebornDownloadPayload) {
        self.payload = payload
        buildTiers()
        if !payload.videoFormats.isEmpty { selectedVideoID = videoTiers.first?.id ?? 0 }
        if !payload.audioFormats.isEmpty { selectedAudioID = audioTiers.first?.id ?? 0 }
    }

    private func codecBadge(_ format: RebornStreamFormat) -> String {
        guard let codecs = format.codecs else { return format.mimeType?.hasPrefix("audio/") == true ? "AAC" : "MP4" }
        if codecs.contains("av01") { return "AV1" }
        if codecs.contains("vp09") { return "VP9" }
        if codecs.contains("avc1") { return "AVC" }
        if codecs.contains("mp4a") { return "AAC" }
        if codecs.contains("opus") { return "OPUS" }
        if codecs.contains("ec-3") || codecs.contains("ac-3") { return "AC-3" }
        return format.mimeType?.hasPrefix("audio/") == true ? "AAC" : "MP4"
    }

    private func sizeString(_ bytes: UInt64) -> String {
        guard bytes > 0 else { return "—" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    private func audioLabel(_ format: RebornStreamFormat) -> String {
        if let bitrate = format.bitrateLabel, !bitrate.isEmpty { return bitrate }
        if format.bitrate > 0 { return "\(Int(format.bitrate / 1000)) kbps" }
        return "Best audio"
    }

    private func buildTiers() {
        let engine = RebornDownloadEngine.shared()

        var videoByHeight: [Int: RebornStreamFormat] = [:]
        for format in payload.videoFormats {
            let height = Int(format.height)
            guard height > 0 else { continue }
            if let existing = videoByHeight[height], existing.bitrate >= format.bitrate { continue }
            videoByHeight[height] = format
        }
        videoTiers = videoByHeight.sorted { $0.key > $1.key }.compactMap { item in
            let format = item.value
            let height = Int(format.height)
            let highFPS = Int(format.fps) >= 50
            let title = highFPS ? "\(height)p\(Int(format.fps))" : "\(height)p"
            let direct = format.directURL?.isEmpty == false
            let package = (engine.isActive(payload.videoID) || payload.canUseSABR) ? "On-device" : (direct ? "Direct link" : "Capture required")
            let subtitle = format.isHDR ? "HDR • \(package)" : package
            return RebornFormatTier(
                id: height,
                title: title,
                subtitle: subtitle,
                codec: codecBadge(format),
                size: sizeString(format.contentLength),
                hasDirectURL: direct,
                isHDR: format.isHDR,
                format: format
            )
        }

        let sortedAudio = payload.audioFormats.sorted { $0.bitrate > $1.bitrate }
        var seenIDs = Set<Int>()
        audioTiers = sortedAudio.compactMap { format in
            let bitrate = Int(format.bitrate)
            let id = bitrate > 0 ? bitrate : Int(format.itag)
            guard !seenIDs.contains(id) else { return nil }
            seenIDs.insert(id)
            let direct = format.directURL?.isEmpty == false
            let package = (engine.isActive(payload.videoID) || payload.canUseSABR) ? "On-device" : (direct ? "Direct link" : "Capture required")
            return RebornFormatTier(
                id: id,
                title: audioLabel(format),
                subtitle: package,
                codec: codecBadge(format),
                size: sizeString(format.contentLength),
                hasDirectURL: direct,
                isHDR: false,
                format: format
            )
        }
    }

    func startDownload() {
        guard canDownload, !isRunning else { return }
        runSpeedTimer()

        let engine = RebornDownloadEngine.shared()
        let progressHandler: RebornDownloadProgress = { phase, fraction, bytes in
            DispatchQueue.main.async {
                self.consumeProgress(phase: phase, fraction: fraction, bytes: bytes)
            }
        }

        switch mode {
        case .video:
            guard let video = selectedVideo else { return }
            engine.startVideo(payload, videoFormat: video, audioFormat: selectedAudio, progress: progressHandler) { success, path, error in
                self.complete(success: success, path: path, error: error)
            }
        case .audio:
            guard let audio = selectedAudio else { return }
            engine.startAudio(payload, audioFormat: audio, progress: progressHandler) { success, path, error in
                self.complete(success: success, path: path, error: error)
            }
        }
    }

    func cancel() {
        stopSpeedTimer()
        speedBytesPerSecond = 0
        RebornDownloadEngine.shared().cancelCurrent()
        status = .ready
    }

    private func consumeProgress(phase: String, fraction: Double, bytes: UInt64) {
        let now = Date()
        if bytes >= lastBytes, bytes > 0 {
            let interval = now.timeIntervalSince(lastSampleTime)
            let delta = Double(bytes - lastBytes)
            if interval > 0 {
                speedBytesPerSecond = delta / interval
            }
        }
        lastBytes = bytes
        lastSampleTime = now
        status = .running(phase: phase, fraction: fraction, bytes: bytes)
    }

    private func complete(success: Bool, path: String?, error: String?) {
        stopSpeedTimer()
        speedBytesPerSecond = 0
        if success, let path = path {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            status = .succeeded(path: path)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            status = .failed(error ?? "Download failed.")
        }
    }

    private func runSpeedTimer() {
        stopSpeedTimer()
        speedTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            DispatchQueue.main.async {
                self.speedBytesPerSecond *= 0.35
            }
        }
    }

    private func stopSpeedTimer() {
        speedTimer?.invalidate()
        speedTimer = nil
    }
}

// MARK: - Root

struct RebornDownloadRoot: View {
    @ObservedObject var model: RebornDownloadModel
    @Environment(\.dismiss) private var dismiss

    init(payload: RebornDownloadPayload) {
        _model = ObservedObject(wrappedValue: RebornDownloadModel(payload: payload))
    }

    var body: some View {
        ZStack {
            RebornTheme.background.ignoresSafeArea()
            RebornDownloadAurora()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    RebornDownloadHeader(payload: model.payload)
                    if model.videoTiers.isEmpty && model.audioTiers.isEmpty {
                        RebornDownloadEmptyState()
                    } else if case .succeeded(let path) = model.status {
                        RebornDownloadSuccessCard(path: path, onDone: { dismiss() })
                    } else {
                        content
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .onDisappear {
            if model.isRunning {
                model.cancel()
            }
        }
    }

    @ViewBuilder private var content: some View {
        RebornDownloadModePicker(model: model)
            .padding(.top, 2)
        groupPicker
        RebornDownloadMethodStrip(model: model)
        switch model.status {
        case .ready, .running, .failed:
            RebornDownloadActionArea(model: model)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private var groupPicker: some View {
        switch model.mode {
        case .video:
            RebornFormatGrid(tiers: model.videoTiers, selectedID: $model.selectedVideoID)
        case .audio:
            RebornFormatGrid(tiers: model.audioTiers, selectedID: $model.selectedAudioID)
        }
    }
}

// MARK: - Aurora background

struct RebornDownloadAurora: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(
                    colors: [RebornTheme.accent.opacity(0.22), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: geo.size.width * 0.9
                )
                RadialGradient(
                    colors: [Color.purple.opacity(0.14), .clear],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: geo.size.width * 0.85
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Header

struct RebornDownloadHeader: View {
    let payload: RebornDownloadPayload

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            artwork
            VStack(alignment: .leading, spacing: 5) {
                Text(payload.title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                if let channel = payload.channel, !channel.isEmpty {
                    Label(channel, systemImage: "checkmark.seal.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var artwork: some View {
        ZStack(alignment: .bottomTrailing) {
            RebornCardBackground(cornerRadius: 22)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [RebornTheme.accent.opacity(0.45), Color.purple.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    if let string = payload.artworkURLString, let url = URL(string: string) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                ZStack {
                                    Color.clear
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 54))
                                        .foregroundStyle(LinearGradient(colors: [.white.opacity(0.95), .white.opacity(0.55)], startPoint: .top, endPoint: .bottom))
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )
                .overlay(alignment: .bottomTrailing) {
                    if let duration = payload.duration, !duration.isEmpty {
                        Text(duration)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .monospacedDigit()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.55), in: Capsule())
                            .padding(8)
                    }
                }
                .frame(height: 176)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Mode picker

struct RebornDownloadModePicker: View {
    @ObservedObject var model: RebornDownloadModel

    var body: some View {
        HStack(spacing: 10) {
            modeCard(.video, icon: "film.stack", label: "Video", summary: summaryVideo)
            modeCard(.audio, icon: "waveform", label: "Audio", summary: summaryAudio)
        }
    }

    private var summaryVideo: String {
        if let first = model.videoTiers.first { return first.title }
        return "Unavailable"
    }

    private var summaryAudio: String {
        if let first = model.audioTiers.first { return first.title }
        return "Unavailable"
    }

    private func modeCard(_ mode: RebornDownloadMode, icon: String, label: String, summary: String) -> some View {
        let selected = model.mode == mode
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                model.mode = mode
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(colors: selected ? [RebornTheme.accent, RebornTheme.accent.opacity(0.7)] : [Color.white.opacity(0.08), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                    Text(summary)
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .opacity(0.65)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? RebornTheme.accent.opacity(0.9) : Color.white.opacity(0.08), lineWidth: selected ? 1.5 : 1)
            )
            .shadow(color: selected ? RebornTheme.accent.opacity(0.35) : .clear, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Format grid

struct RebornFormatGrid: View {
    let tiers: [RebornFormatTier]
    @Binding var selectedID: Int

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(tiers) { tier in
                RebornFormatCard(tier: tier, isSelected: selectedID == tier.id) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedID = tier.id
                    }
                }
            }
        }
    }
}

struct RebornFormatCard: View {
    let tier: RebornFormatTier
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(tier.title)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RebornTheme.accent)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.22))
                    }
                }
                HStack(spacing: 5) {
                    Text(tier.codec)
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tier.isHDR ? RebornTheme.accent.opacity(0.85) : Color.white.opacity(0.1), in: Capsule())
                    if tier.isHDR {
                        Text("HDR")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(RebornTheme.accent.opacity(0.85), in: Capsule())
                    }
                }
                Spacer(minLength: 0)
                HStack {
                    Label(tier.subtitle, systemImage: "iphone")
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .opacity(0.7)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    Text(tier.size)
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .monospacedDigit()
                        .opacity(0.7)
                }
            }
            .padding(11)
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? RebornTheme.accent.opacity(0.14) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? RebornTheme.accent.opacity(0.95) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Method strip

struct RebornDownloadMethodStrip: View {
    @ObservedObject var model: RebornDownloadModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: model.payload.canUseSABR ? "bolt.fill" : "arrow.down.circle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(model.payload.canUseSABR ? RebornTheme.accent : .secondary)
            Text(model.payload.canUseSABR
                 ? "On-device capture ready — downloads replay your signed player session."
                 : "No player capture yet. Play the video for a few seconds so on-device downloads unlock.")
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(RebornTheme.accent.opacity(model.payload.canUseSABR ? 0.12 : 0.05)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(RebornTheme.accent.opacity(model.payload.canUseSABR ? 0.35 : 0.08), lineWidth: 1))
    }
}

// MARK: - Action area

struct RebornDownloadActionArea: View {
    @ObservedObject var model: RebornDownloadModel

    var body: some View {
        switch model.status {
        case .ready:
            readyArea
        case .running(let phase, let fraction, let bytes):
            RebornDownloadProgressCard(model: model, phase: phase, fraction: fraction, bytes: bytes)
        case .failed(let message):
            RebornDownloadFailureCard(model: model, message: message)
        default:
            EmptyView()
        }
    }

    private var readyArea: some View {
        VStack(spacing: 10) {
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                model.startDownload()
            }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text(model.mode == .video ? "Download Video" : "Download Audio")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(colors: [RebornTheme.accent, RebornTheme.accent.opacity(0.75)], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .foregroundStyle(.white)
                .shadow(color: RebornTheme.accent.opacity(model.canDownload ? 0.45 : 0.0), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(!model.canDownload)
            .opacity(model.canDownload ? 1 : 0.4)

            if !model.canDownload {
                Label("Downloading is unavailable until a player capture or direct link exists.", systemImage: "info.circle")
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Saves to the Downloads tab as an MP4")
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Progress

struct RebornDownloadProgressCard: View {
    @ObservedObject var model: RebornDownloadModel
    let phase: String
    let fraction: Double
    let bytes: UInt64

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 9)
                if fraction >= 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(fraction, 0.0), 1.0)))
                        .stroke(
                            AngularGradient(colors: [RebornTheme.accent, RebornTheme.accent.opacity(0.4), RebornTheme.accent], center: .center),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.25), value: fraction)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(RebornTheme.accent)
                        .scaleEffect(1.2)
                }
                VStack(spacing: 2) {
                    if fraction >= 0 {
                        Text("\(Int(min(max(fraction, 0.0), 1.0) * 100))%")
                            .font(.system(.title2, design: .rounded).weight(.heavy))
                            .monospacedDigit()
                    } else {
                        Text("•••")
                            .font(.system(.title3, design: .rounded).weight(.heavy))
                    }
                    Text(ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file))
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .monospacedDigit()
                        .opacity(0.7)
                }
            }
            .frame(width: 104, height: 104)

            Text(phase)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RebornTheme.accent)
                Text("\(ByteCountFormatter.string(fromByteCount: Int64(model.speedBytesPerSecond), countStyle: .file))/s")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") {
                    model.cancel()
                }
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(LinearGradient(colors: [Color.red.opacity(0.9), RebornTheme.accent], startPoint: .leading, endPoint: .trailing))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(RebornTheme.accent.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Success

struct RebornDownloadSuccessCard: View {
    let path: String
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [RebornTheme.accent, RebornTheme.accent.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                    .shadow(color: RebornTheme.accent.opacity(0.5), radius: 18, x: 0, y: 8)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(.white)
            }
            Text("Saved")
                .font(.system(.title2, design: .rounded).weight(.heavy))
            Text("Downloads")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(RebornTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(RebornTheme.accent.opacity(0.15), in: Capsule())
            Button(action: onDone) {
                Text("Done")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(RebornTheme.accent.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Failure

struct RebornDownloadFailureCard: View {
    @ObservedObject var model: RebornDownloadModel
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .multilineTextAlignment(.center)
            Button("Try Again") {
                model.status = .ready
            }
            .font(.system(.subheadline, design: .rounded).weight(.bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 9)
            .background(RebornTheme.accent, in: Capsule())
            .foregroundStyle(.white)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.orange.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.orange.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Empty state

struct RebornDownloadEmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No download formats available for this video.")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}