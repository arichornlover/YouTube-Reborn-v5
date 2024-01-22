#import "OverlayOptionsController.h"
#import "Localization.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface OverlayOptionsController ()
- (void)coloursView;
@end

static BOOL hasDeviceNotch() {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return NO;
	} else {
		LAContext* context = [[LAContext alloc] init];
		[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
		return [context biometryType] == LABiometryTypeFaceID;
	}
}

@implementation OverlayOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.title = LOC(@"OVERLAY_OPTIONS");

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    UITableViewStyle style;
        if (@available(iOS 13, *)) {
            style = UITableViewStyleInsetGrouped;
        } else {
            style = UITableViewStyleGrouped;
        }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 17;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OverlayTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
	    cell.textLabel.shadowColor = [UIColor blackColor];
            cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"SHOW_STATUS_BAR_IN_OVERLAY");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"] == YES || hasDeviceNotch() == YES) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            }
            else {
                UISwitch *showStatusBarInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
                [showStatusBarInOverlay addTarget:self action:@selector(toggleShowStatusBarInOverlay:) forControlEvents:UIControlEventValueChanged];
                showStatusBarInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowStatusBarInOverlay"];
                cell.accessoryView = showStatusBarInOverlay;
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = LOC(@"STOCK_VOLUME_HUD");
            UISwitch *stockVolumeHUD = [[UISwitch alloc] initWithFrame:CGRectZero];
            [stockVolumeHUD addTarget:self action:@selector(toggleStockVolumeHUD:) forControlEvents:UIControlEventValueChanged];
            stockVolumeHUD.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kStockVolumeHUD"];
            cell.accessoryView = stockVolumeHUD;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = LOC(@"HIDE_PREVIOUS_BUTTON");
            UISwitch *hidePreviousButtonInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePreviousButtonInOverlay addTarget:self action:@selector(toggleHidePreviousButtonInOverlay:) forControlEvents:UIControlEventValueChanged];
            hidePreviousButtonInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePreviousButtonInOverlay"];
            cell.accessoryView = hidePreviousButtonInOverlay;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = LOC(@"HIDE_PREVIOUS_BUTTON_SHADOW");
            UISwitch *hidePreviousButtonShadowInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePreviousButtonShadowInOverlay addTarget:self action:@selector(toggleHidePreviousButtonShadowInOverlay:) forControlEvents:UIControlEventValueChanged];
            hidePreviousButtonShadowInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePreviousButtonShadowInOverlay"];
            cell.accessoryView = hidePreviousButtonShadowInOverlay;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = LOC(@"HIDE_NEXT_BUTTON");
            UISwitch *hideNextButtonInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideNextButtonInOverlay addTarget:self action:@selector(toggleHideNextButtonInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideNextButtonInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideNextButtonInOverlay"];
            cell.accessoryView = hideNextButtonInOverlay;
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = LOC(@"HIDE_PREVIOUS_BUTTON_SHADOW");
            UISwitch *hideNextButtonShadowInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideNextButtonShadowInOverlay addTarget:self action:@selector(toggleHideNextButtonShadowInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideNextButtonShadowInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideNextButtonShadowInOverlay"];
            cell.accessoryView = hideNextButtonShadowInOverlay;
        }
        if (indexPath.row == 6) {
            cell.textLabel.text = LOC(@"HIDE_SEEK_BACKWARD_BUTTON_SHADOW");
            UISwitch *hideSeekBackwardButtonShadowInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideSeekBackwardButtonShadowInOverlay addTarget:self action:@selector(toggleHideSeekBackwardButtonShadowInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideSeekBackwardButtonShadowInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideSeekBackwardButtonShadowInOverlay"];
            cell.accessoryView = hideSeekBackwardButtonShadowInOverlay;
        }
        if (indexPath.row == 7) {
            cell.textLabel.text = LOC(@"HIDE_SEEK_FORWARD_BUTTON_SHADOW");
            UISwitch *hideSeekForwardButtonShadowInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideSeekForwardButtonShadowInOverlay addTarget:self action:@selector(toggleHideSeekForwardButtonShadowInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideSeekForwardButtonShadowInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideSeekForwardButtonShadowInOverlay"];
            cell.accessoryView = hideSeekForwardButtonShadowInOverlay;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = LOC(@"HIDE_PLAY_AND_PAUSE_BUTTON_SHADOW");
            UISwitch *hidePlayPauseButtonShadowInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePlayPauseButtonShadowInOverlay addTarget:self action:@selector(toggleHidePlayPauseButtonShadowInOverlay:) forControlEvents:UIControlEventValueChanged];
            hidePlayPauseButtonShadowInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePlayPauseButtonShadowInOverlay"];
            cell.accessoryView = hidePlayPauseButtonShadowInOverlay;
        }
        if (indexPath.row == 9) {
            cell.textLabel.text = LOC(@"HIDE_AUTOPLAY_SWITCH");
            UISwitch *hideAutoPlaySwitchInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideAutoPlaySwitchInOverlay addTarget:self action:@selector(toggleHideAutoPlaySwitchInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideAutoPlaySwitchInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideAutoPlaySwitchInOverlay"];
            cell.accessoryView = hideAutoPlaySwitchInOverlay;
        }
        if (indexPath.row == 10) {
            cell.textLabel.text = LOC(@"HIDE_CAPTIONS_AND_SUBTITLES_BUTTON");
            UISwitch *hideCaptionsSubtitlesButtonInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideCaptionsSubtitlesButtonInOverlay addTarget:self action:@selector(toggleHideCaptionsSubtitlesButtonInOverlay:) forControlEvents:UIControlEventValueChanged];
            hideCaptionsSubtitlesButtonInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideCaptionsSubtitlesButtonInOverlay"];
            cell.accessoryView = hideCaptionsSubtitlesButtonInOverlay;
        }
        if (indexPath.row == 11) {
            cell.textLabel.text = LOC(@"DISABLE_RELATED_VIDEOS");
            UISwitch *disableRelatedVideosInOverlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableRelatedVideosInOverlay addTarget:self action:@selector(toggleDisableRelatedVideosInOverlay:) forControlEvents:UIControlEventValueChanged];
            disableRelatedVideosInOverlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableRelatedVideosInOverlay"];
            cell.accessoryView = disableRelatedVideosInOverlay;
        }
        if (indexPath.row == 12) {
            cell.textLabel.text = LOC(@"HIDE_CHANNEL_WATERMARK");
            UISwitch *hideChannelWatermark = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideChannelWatermark addTarget:self action:@selector(toggleHideChannelWatermark:) forControlEvents:UIControlEventValueChanged];
            hideChannelWatermark.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideChannelWatermark"];
            cell.accessoryView = hideChannelWatermark;
        }
        if (indexPath.row == 13) {
            cell.textLabel.text = LOC(@"HIDE_DARK_OVERLAY_BACKGROUND");
            UISwitch *hideOverlayDarkBackground = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideOverlayDarkBackground addTarget:self action:@selector(toggleHideOverlayDarkBackground:) forControlEvents:UIControlEventValueChanged];
            hideOverlayDarkBackground.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayDarkBackground"];
            cell.accessoryView = hideOverlayDarkBackground;
        }
        if (indexPath.row == 14) {
            cell.textLabel.text = LOC(@"HIDE_QUICK_ACTIONS");
            UISwitch *hideOverlayQuickActions = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideOverlayQuickActions addTarget:self action:@selector(toggleHideOverlayQuickActions:) forControlEvents:UIControlEventValueChanged];
            hideOverlayQuickActions.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayQuickActions"];
            cell.accessoryView = hideOverlayQuickActions;
        }
        if (indexPath.row == 15) {
            cell.textLabel.text = LOC(@"HIDE_CURRENT_TIME");
            UISwitch *hideCurrentTime = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideCurrentTime addTarget:self action:@selector(toggleHideCurrentTime:) forControlEvents:UIControlEventValueChanged];
            hideCurrentTime.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideCurrentTime"];
            cell.accessoryView = hideCurrentTime;
        }
        if (indexPath.row == 16) {
            cell.textLabel.text = LOC(@"HIDE_DURATION");
            UISwitch *hideDuration = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideDuration addTarget:self action:@selector(toggleHideDuration:) forControlEvents:UIControlEventValueChanged];
            hideDuration.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideDuration"];
            cell.accessoryView = hideDuration;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (hasDeviceNotch()) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"This option can't be enabled on notched idevices") preferredStyle:UIAlertControllerStyleAlert];

        [alertError addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];

        [self presentViewController:alertError animated:YES completion:nil];
    } else {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"This option can't be enabled with 'Enable iPad Style On iPhone' enabled") preferredStyle:UIAlertControllerStyleAlert];

        [alertError addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];

        [self presentViewController:alertError animated:YES completion:nil];
    }
}

- (void)coloursView {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self coloursView];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
}

@end

@implementation OverlayOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleShowStatusBarInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kShowStatusBarInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kShowStatusBarInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleStockVolumeHUD:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kStockVolumeHUD"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kStockVolumeHUD"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePreviousButtonInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePreviousButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePreviousButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePreviousButtonShadowInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePreviousButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePreviousButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideNextButtonInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideNextButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideNextButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideNextButtonShadowInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideNextButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideNextButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideSeekBackwardButtonShadowInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideSeekBackwardButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideSeekBackwardButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideSeekForwardButtonShadowInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideSeekForwardButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideSeekForwardButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePlayPauseButtonShadowInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePlayPauseButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePlayPauseButtonShadowInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideAutoPlaySwitchInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideAutoPlaySwitchInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideAutoPlaySwitchInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideCaptionsSubtitlesButtonInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideCaptionsSubtitlesButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideCaptionsSubtitlesButtonInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableRelatedVideosInOverlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableRelatedVideosInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableRelatedVideosInOverlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideChannelWatermark:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideChannelWatermark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideChannelWatermark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideOverlayDarkBackground:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideOverlayDarkBackground"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideOverlayDarkBackground"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideOverlayQuickActions:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideOverlayQuickActions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideOverlayQuickActions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideCurrentTime:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideCurrentTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideCurrentTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideDuration:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
