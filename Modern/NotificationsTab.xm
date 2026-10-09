//
//  NotificationsTab.xm
//  YouTube Reborn
//
//  Custom notifications tab ported from uYouEnhanced so it "just works" with
//  Reborn's tab-bar systems. Adds a FEnotifications_inbox pivot item, an
//  optional unread badge, selectable icon styles and reunifies tab ordering:
//  every tab (incl. Notifications) can be reordered through the kTabOrder
//  array that the reimagined SwiftUI menu writes.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HBLog.h>

#import "Tweak.h"

#ifndef YT_NOTIFICATIONS
#define YT_NOTIFICATIONS 264
#endif

static inline BOOL RebornNotificationsEnabled(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowNotificationsTab"];
}

static NSBundle *RebornTweakBundle(void) {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"YouTubeReborn" ofType:@"bundle"];
    if (!bundlePath) {
        bundlePath = ROOT_PATH_NS(@"/Library/Application Support/YouTubeReborn.bundle");
    }
    return bundlePath ? [NSBundle bundleWithPath:bundlePath] : nil;
}

static UIImage *RebornNotificationIconImage(NSString *imageName) {
    NSString *path = [RebornTweakBundle() pathForResource:imageName ofType:@"png" inDirectory:@"UI"];
    UIImage *image = path ? [UIImage imageWithContentsOfFile:path] : nil;
    if (!image) return nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(24, 24), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 24, 24)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

static int RebornNotificationIconStyle(void) {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"kNotificationIconStyle"];
}

static NSString *RebornItemIdentifier(YTIPivotBarSupportedRenderers *item) {
    YTIPivotBarItemRenderer *barItem = item.pivotBarItemRenderer;
    if ([barItem respondsToSelector:@selector(pivotIdentifier)])
        return barItem.pivotIdentifier;
    YTIPivotBarIconOnlyItemRenderer *iconOnlyItem = item.pivotBarIconOnlyItemRenderer;
    if ([iconOnlyItem respondsToSelector:@selector(pivotIdentifier)])
        return iconOnlyItem.pivotIdentifier;
    return nil;
}

static void RebornApplyTabOrder(NSMutableArray *items) {
    NSArray *stored = [[NSUserDefaults standardUserDefaults] objectForKey:@"kTabOrder"];
    if (![stored isKindOfClass:[NSArray class]] || stored.count == 0) return;

    NSMutableArray *reordered = [NSMutableArray array];
    for (NSString *identifier in stored) {
        if (![identifier isKindOfClass:[NSString class]]) continue;
        NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *obj, NSUInteger idx, BOOL *stop) {
            return [RebornItemIdentifier(obj) isEqualToString:identifier];
        }];
        if (index != NSNotFound) {
            [reordered addObject:items[index]];
            [items removeObjectAtIndex:index];
        }
    }
    [reordered addObjectsFromArray:items];
    [items setArray:reordered];
}

static NSInteger _notificationsBadgeCount = 0;

%group gRebornTabs

%hook YTAppPivotBarItemStyle
- (UIImage *)pivotBarItemIconImageWithIconType:(int)type color:(UIColor *)color useNewIcons:(BOOL)isNew selected:(BOOL)isSelected {
    if (!RebornNotificationsEnabled() || type != YT_NOTIFICATIONS) return %orig;

    NSString *imageName;
    UIColor *iconColor;
    switch (RebornNotificationIconStyle()) {
        case 1:
            imageName = isSelected ? @"notifications_selected" : @"notifications_unselected";
            iconColor = [%c(YTColor) white1];
            break;
        case 2:
            imageName = isSelected ? @"notifications_selected" : @"notifications_24pt";
            iconColor = [%c(YTColor) white1];
            break;
        case 3:
            imageName = @"notifications_selected";
            iconColor = isSelected ? [%c(YTColor) white1] : [UIColor grayColor];
            break;
        case 4:
            imageName = @"inbox_selected";
            iconColor = isSelected ? [%c(YTColor) white1] : [UIColor grayColor];
            break;
        default:
            imageName = isSelected ? @"notifications_selected_2025" : @"notifications_unselected_2025";
            iconColor = [%c(YTColor) white1];
            break;
    }
    UIImage *image = RebornNotificationIconImage(imageName);
    if (!image) return %orig;

    return [%c(QTMIcon) tintImage:image color:iconColor];
}
%end

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    @try {
        if (RebornNotificationsEnabled()) {
            NSMutableArray <YTIPivotBarSupportedRenderers *> *items = renderer.itemsArray;
            if (items) {
                @try {
                    for (YTIPivotBarSupportedRenderers *item in items) {
                        if (item.pivotBarItemRenderer) {
                            @try {
                                id badgeData = [item.pivotBarItemRenderer valueForKey:@"notificationCount"];
                                if (badgeData && [badgeData respondsToSelector:@selector(integerValue)]) {
                                    NSInteger count = [badgeData integerValue];
                                    if (count > _notificationsBadgeCount) {
                                        _notificationsBadgeCount = count;
                                    }
                                }
                            } @catch (NSException *e2) {}
                        }
                    }
                } @catch (NSException *e1) {}

                BOOL alreadyPresent = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *obj, NSUInteger idx, BOOL *stop) {
                    return [RebornItemIdentifier(obj) isEqualToString:@"FEnotifications_inbox"];
                }] != NSNotFound;

                if (!alreadyPresent) {
                    @try {
                        id endPoint = [[%c(YTIBrowseEndpoint) alloc] init];
                        [endPoint setBrowseId:@"FEnotifications_inbox"];
                        id command = [[%c(YTICommand) alloc] init];
                        [command setBrowseEndpoint:endPoint];

                        id itemBar = [[%c(YTIPivotBarItemRenderer) alloc] init];
                        [itemBar setPivotIdentifier:@"FEnotifications_inbox"];
                        id icon = [itemBar icon];
                        @try { [icon setIconType:YT_NOTIFICATIONS]; } @catch (NSException *e) {}
                        [itemBar setNavigationEndpoint:command];

                        NSString *title = RebornNotificationIconStyle() == 3 ? @"Inbox" : @"Notifications";
                        [itemBar setTitle:[%c(YTIFormattedString) formattedStringWithString:title]];

                        id barSupport = [[%c(YTIPivotBarSupportedRenderers) alloc] init];
                        [barSupport setPivotBarItemRenderer:itemBar];

                        NSInteger preferred = [[NSUserDefaults standardUserDefaults] integerForKey:@"kNotificationsTabIndex"];
                        NSUInteger insertIndex = items.count;
                        if (preferred >= 0 && (NSUInteger)preferred < items.count) {
                            insertIndex = (NSUInteger)preferred;
                        }
                        [items insertObject:barSupport atIndex:insertIndex];
                    } @catch (NSException *e) {}
                }
            }
        }
        RebornApplyTabOrder(renderer.itemsArray);
    } @catch (NSException *exception) {
        HBLogError(@"NotificationsTab error setting renderer: %@", exception.reason);
    }
    %orig;
}
%end

%hook YTBrowseViewController
- (void)viewDidLoad {
    %orig;
    id navEndpoint = nil;
    for (NSString *key in @[@"navigationEndpoint", @"navEndpoint", @"_navEndpoint"]) {
        @try {
            id value = [self valueForKey:key];
            if ([value isKindOfClass:[%c(YTICommand) class]]) { navEndpoint = value; break; }
        } @catch (NSException *e) {}
    }
    if ([navEndpoint.browseEndpoint.browseId isEqualToString:@"FEnotifications_inbox"]) {
        @try {
            UIViewController *notificationsViewController = [[UIViewController alloc] init];
            [self addChildViewController:notificationsViewController];
            [notificationsViewController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
            [self.view addSubview:notificationsViewController.view];
            [self.view endEditing:YES];
            [notificationsViewController didMoveToParentViewController:self];
        } @catch (NSException *exception) {
            HBLogError(@"NotificationsTab cannot show notifications view controller: %@", exception.reason);
        }
    }
}
%end

%hook YTPivotBarItemView
- (void)layoutSubviews {
    %orig;
    if (!RebornNotificationsEnabled()) return;

    @try {
        NSString *pivotId = nil;
        id item = nil;
        @try { item = [self valueForKey:@"renderer"]; } @catch (NSException *e) {}
        if (item && [item respondsToSelector:@selector(pivotIdentifier)]) {
            pivotId = [item pivotIdentifier];
        }
        BOOL isNotificationsItem = [pivotId isEqualToString:@"FEnotifications_inbox"];

        if (!isNotificationsItem || _notificationsBadgeCount <= 0) {
            for (UIView *subview in self.subviews) {
                if (subview.tag == 9999) {
                    [subview removeFromSuperview];
                }
            }
            return;
        }

        UILabel *badgeLabel = nil;
        for (UIView *subview in self.subviews) {
            if (subview.tag == 9999) {
                badgeLabel = (UILabel *)subview;
                break;
            }
        }

        if (!badgeLabel) {
            badgeLabel = [[UILabel alloc] init];
            badgeLabel.tag = 9999;
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            badgeLabel.font = [UIFont boldSystemFontOfSize:10];
            badgeLabel.textAlignment = NSTextAlignmentCenter;
            badgeLabel.clipsToBounds = YES;
            [self addSubview:badgeLabel];
        }

        NSString *badgeText;
        if (_notificationsBadgeCount > 99) {
            badgeText = @"99+";
        } else {
            badgeText = [NSString stringWithFormat:@"%ld", (long)_notificationsBadgeCount];
        }
        badgeLabel.text = badgeText;

        NSDictionary *attrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10]};
        CGSize textSize = [badgeText sizeWithAttributes:attrs];
        CGFloat badgeWidth = MAX(textSize.width + 8, 18);
        CGFloat badgeHeight = 16;

        badgeLabel.frame = CGRectMake(
            self.bounds.size.width - badgeWidth / 2,
            -badgeHeight / 2,
            badgeWidth,
            badgeHeight
        );
        badgeLabel.layer.cornerRadius = badgeHeight / 2;
    } @catch (NSException *e) {
        HBLogError(@"NotificationsTab badge error: %@", e);
    }
}
%end

%end

%ctor {
    %init(gRebornTabs);
}