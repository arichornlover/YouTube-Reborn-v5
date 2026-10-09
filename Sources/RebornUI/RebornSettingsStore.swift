//
//  RebornSettingsStore.swift
//  YouTube Reborn
//
//  Thin Swift wrapper around NSUserDefaults so the modern menu can read and
//  write the exact same preference keys the tweak hooks already consume. This
//  keeps the SwiftUI layer and the Logos hooks in sync with a single source of
//  truth (the raw k… keys).
//

import Foundation

final class RebornSettingsStore {

    static let shared = RebornSettingsStore()

    private let defaults = UserDefaults.standard

    private init() {}

    func bool(_ key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func bool(_ key: String, default fallback: Bool) -> Bool {
        if defaults.object(forKey: key) == nil { return fallback }
        return defaults.bool(forKey: key)
    }

    func set(_ value: Bool, for key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func integer(_ key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func setInteger(_ value: Int, for key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func object(_ key: String) -> Any? {
        defaults.object(forKey: key)
    }

    func set(_ value: Any, for key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func remove(_ key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }

    /// Every preference key owned by YouTube Reborn. Used by "Reset Settings"
    /// so we only clear our own keys and never touch other tweaks' defaults.
    static let knownKeys: [String] = [
        "kAdBlockWorkaround",
        "kAllowHDOnCellularData",
        "kAlwaysShowPlayerBarVTwo",
        "kAlwaysShowShortsPlayerBar",
        "kAutoFullScreen",
        "kAutoHideHomeBar",
        "kCustomDoubleTapToSkipDuration",
        "kNotificationIconStyle",
        "kNotificationsTabIndex",
        "kShowNotificationsTab",
        "kDisableDoubleTapToSkip",
        "kDisableHints",
        "kDisableRelatedVideosInOverlay",
        "kDisableResumeToShorts",
        "kDisableVideoAutoPlay",
        "kDisableVideoEndscreenPopups",
        "kDisableVideoInfoCards",
        "kDisableYouTubeKidsPopup",
        "kEnableBackgroundPlayback",
        "kEnableCustomDoubleTapToSkipDuration",
        "kEnableExtraSpeedOptions",
        "kEnableiPadStyleOniPhone",
        "kEnableiPhoneStyleOniPad",
        "kEnableNoVideoAds",
        "kEnablePictureInPicture",
        "kEnablePictureInPictureVTwo",
        "kGrayBufferProgress",
        "kHideAutoPlaySwitchInOverlay",
        "kHideCaptionsSubtitlesButtonInOverlay",
        "kHideChannelWatermark",
        "kHideCollapseButton",
        "kHideCurrentTime",
        "kHideDuration",
        "kHideExploreTab",
        "kHideFullscreenButton",
        "kHideLibraryTab",
        "kHideNextButtonInOverlay",
        "kHideNextButtonShadowInOverlay",
        "kHideOverlayDarkBackground",
        "kHideOverlayQuickActions",
        "kHidePictureInPictureAdsBadge",
        "kHidePictureInPictureSponsorBadge",
        "kHidePlayerBarHeatwave",
        "kHidePlayNextInQueue",
        "kHidePlayPauseButtonShadowInOverlay",
        "kHidePreviousButtonInOverlay",
        "kHidePreviousButtonShadowInOverlay",
        "kHideRebornOPButtonVTwo",
        "kHideRebornShortsOPButton",
        "kHideSeekBackwardButtonShadowInOverlay",
        "kHideSeekForwardButtonShadowInOverlay",
        "kHideShortsBuySuperThanks",
        "kHideShortsChannelAvatarButton",
        "kHideShortsCommentsButton",
        "kHideShortsDislikeButton",
        "kHideShortsLikeButton",
        "kHideShortsMoreActionsButton",
        "kHideShortsRemixButton",
        "kHideShortsSearchButton",
        "kHideShortsShareButton",
        "kHideShortsSubscriptionsButton",
        "kHideShortsTab",
        "kHideSubscriptionsTab",
        "kHideTabBarLabels",
        "kHideUploadTab",
        "kHideYouTab",
        "kHideYouTubeLogo",
        "kInteractionSegmentedInt",
        "kIntroSegmentedInt",
        "kLowContrastMode",
        "kMusicOffTopicSegmentedInt",
        "kNoCastButton",
        "kNoNotificationButton",
        "kNoSearchButton",
        "kOutroSegmentedInt",
        "kPortraitFullscreen",
        "kPremiumYouTubeLogo",
        "kPreviewSegmentedInt",
        "kRebornIHaveYouTubePremium",
        "kRedProgressBar",
        "kSelfPromoSegmentedInt",
        "kShowStatusBarInOverlay",
        "kSourceSegmentedInt",
        "kSponsorSegmentedInt",
        "kStartupPageIntVTwo",
        "kStickNavigationBar",
        "kTabOrder",
        "kYTRebornColourOptionsVFour"
    ]

    /// Removes every YouTube Reborn preference key. Returns how many existed.
    @discardableResult
    func resetAll() -> Int {
        var removed = 0
        for key in RebornSettingsStore.knownKeys where defaults.object(forKey: key) != nil {
            defaults.removeObject(forKey: key)
            removed += 1
        }
        defaults.synchronize()
        return removed
    }
}
