//
//  Reborn-Bridging-Header.h
//  YouTube Reborn — Swift/ObjC bridging header
//
//  Exposes the existing Objective-C controllers to the modern SwiftUI layer so
//  the reimagined menu can present and navigate to them without a rewrite of
//  every screen. Paths are relative to this file (RebornUI/).
//

#ifndef REBORN_BRIDGING_HEADER_H
#define REBORN_BRIDGING_HEADER_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "../Controllers/VideoOptionsController.h"
#import "../Controllers/OverlayOptionsController.h"
#import "../Controllers/TabBarOptionsController.h"
#import "../Controllers/ColourOptionsController.h"
#import "../Controllers/PictureInPictureOptionsController.h"
#import "../Controllers/ShortsOptionsController.h"
#import "../Controllers/OtherOptionsController.h"
#import "../Controllers/RebornSettingsController.h"
#import "../Controllers/DownloadsController.h"
#import "../Controllers/CreditsController.h"
#import "../Controllers/StartupPageOptionsController.h"
#import "../Controllers/ReorderPivotBarController.h"
#import "../Modern/RebornDownloadPanel.h"

#endif /* REBORN_BRIDGING_HEADER_H */
