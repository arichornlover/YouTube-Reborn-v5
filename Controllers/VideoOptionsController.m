#import "VideoOptionsController.h"
#import "Localization.h"

@interface VideoOptionsController ()
- (void)coloursView;
@end

@implementation VideoOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.title = LOC(@"VIDEO_OPTIONS");

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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCustomDoubleTapToSkipDuration"] == YES) {
        return 14;
    }
    return 17;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VideoTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
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
            cell.textLabel.text = LOC(@"ENABLE_NO_ADS");
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == YES) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            } else {
                UISwitch *enableNoVideoAds = [[UISwitch alloc] initWithFrame:CGRectZero];
                [enableNoVideoAds addTarget:self action:@selector(toggleEnableNoVideoAds:) forControlEvents:UIControlEventValueChanged];
                enableNoVideoAds.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableNoVideoAds"];
                cell.accessoryView = enableNoVideoAds;
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = LOC(@"ENABLE_BACKGROUND_PLAYBACK");
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == YES) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            } else {
                UISwitch *enableBackgroundPlayback = [[UISwitch alloc] initWithFrame:CGRectZero];
                [enableBackgroundPlayback addTarget:self action:@selector(toggleEnableBackgroundPlayback:) forControlEvents:UIControlEventValueChanged];
                enableBackgroundPlayback.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"];
                cell.accessoryView = enableBackgroundPlayback;
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = LOC(@"ALLOW_HD_ON_CELLULAR_DATA");
            UISwitch *allowHDOnCellularData = [[UISwitch alloc] initWithFrame:CGRectZero];
            [allowHDOnCellularData addTarget:self action:@selector(toggleAllowHDOnCellularData:) forControlEvents:UIControlEventValueChanged];
            allowHDOnCellularData.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAllowHDOnCellularData"];
            cell.accessoryView = allowHDOnCellularData;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = LOC(@"PORTRAIT_FULLSCREEN");
            UISwitch *portraitFullscreen = [[UISwitch alloc] initWithFrame:CGRectZero];
            [portraitFullscreen addTarget:self action:@selector(togglePortraitFullscreen:) forControlEvents:UIControlEventValueChanged];
            portraitFullscreen.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kPortraitFullscreen"];
            cell.accessoryView = portraitFullscreen;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = LOC(@"AUTO_PLAY_IN_FULLSCREEN");
            UISwitch *autoFullScreen = [[UISwitch alloc] initWithFrame:CGRectZero];
            [autoFullScreen addTarget:self action:@selector(toggleAutoFullScreen:) forControlEvents:UIControlEventValueChanged];
            autoFullScreen.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoFullScreen"];
            cell.accessoryView = autoFullScreen;
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = LOC(@"DISABLE_PINCH_TO_ZOOM");
            UISwitch *disablePinchToZoom = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disablePinchToZoom addTarget:self action:@selector(toggleDisablePinchToZoom:) forControlEvents:UIControlEventValueChanged];
            disablePinchToZoom.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisablePinchToZoom"];
            cell.accessoryView = disablePinchToZoom;
        }
        if (indexPath.row == 6) {
            cell.textLabel.text = LOC(@"DISABLE_VIDEO_ENDSCREEN_POPUPS");
            UISwitch *disableVideoEndscreenPopups = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoEndscreenPopups addTarget:self action:@selector(toggleDisableVideoEndscreenPopups:) forControlEvents:UIControlEventValueChanged];
            disableVideoEndscreenPopups.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoEndscreenPopups"];
            cell.accessoryView = disableVideoEndscreenPopups;
        }
        if (indexPath.row == 7) {
            cell.textLabel.text = LOC(@"DISABLE_VIDEO_INFO_CARDS");
            UISwitch *disableVideoInfoCards = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoInfoCards addTarget:self action:@selector(toggleDisableVideoInfoCards:) forControlEvents:UIControlEventValueChanged];
            disableVideoInfoCards.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoInfoCards"];
            cell.accessoryView = disableVideoInfoCards;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = LOC(@"DISABLE_VIDEO_AUTOPLAY");
            UISwitch *disableVideoAutoPlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoAutoPlay addTarget:self action:@selector(toggleDisableVideoAutoPlay:) forControlEvents:UIControlEventValueChanged];
            disableVideoAutoPlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoAutoPlay"];
            cell.accessoryView = disableVideoAutoPlay;
        }
	if (indexPath.row == 9) {
            cell.textLabel.text = LOC(@"RED_PROGRESS_BAR");
            UISwitch *redProgressBar = [[UISwitch alloc] initWithFrame:CGRectZero];
            [redProgressBar addTarget:self action:@selector(toggleRedProgressBar:) forControlEvents:UIControlEventValueChanged];
            redProgressBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kRedProgressBar"];
            cell.accessoryView = redProgressBar;
        }
	if (indexPath.row == 10) {
            cell.textLabel.text = LOC(@"GRAY_BUFFER_PROGRESS");
            UISwitch *grayBufferProgress = [[UISwitch alloc] initWithFrame:CGRectZero];
            [grayBufferProgress addTarget:self action:@selector(toggleGrayBufferProgress:) forControlEvents:UIControlEventValueChanged];
            grayBufferProgress.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kGrayBufferProgress"];
            cell.accessoryView = grayBufferProgress;
        }
        if (indexPath.row == 11) {
            cell.textLabel.text = LOC(@"HIDE_PLAYER_BAR_HEATWAVE");
            UISwitch *hidePlayerBarHeatwave = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePlayerBarHeatwave addTarget:self action:@selector(toggleHidePlayerBarHeatwave:) forControlEvents:UIControlEventValueChanged];
            hidePlayerBarHeatwave.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePlayerBarHeatwave"];
            cell.accessoryView = hidePlayerBarHeatwave;
        }
        if (indexPath.row == 12) {
            cell.textLabel.text = LOC(@"ALWAYS_SHOW_PLAYER_BAR");
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableRelatedVideosInOverlay"] == NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayQuickActions"] == NO) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            } else {
                UISwitch *alwaysShowPlayerBar = [[UISwitch alloc] initWithFrame:CGRectZero];
                [alwaysShowPlayerBar addTarget:self action:@selector(toggleAlwaysShowPlayerBar:) forControlEvents:UIControlEventValueChanged];
                alwaysShowPlayerBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlwaysShowPlayerBarVTwo"];
                cell.accessoryView = alwaysShowPlayerBar;
            }
        }
        if (indexPath.row == 13) {
            cell.textLabel.text = LOC(@"ENABLE_EXTRA_SPEED_OPTIONS");
            UISwitch *enableExtraSpeedOptions = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableExtraSpeedOptions addTarget:self action:@selector(toggleExtraSpeedOptions:) forControlEvents:UIControlEventValueChanged];
            enableExtraSpeedOptions.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableExtraSpeedOptions"];
            cell.accessoryView = enableExtraSpeedOptions;
        }
        if (indexPath.row == 14) {
            cell.textLabel.text = LOC(@"DISABLE_DOUBLE_TAP_TO_SKIP");
            UISwitch *disableDoubleTapToSkip = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableDoubleTapToSkip addTarget:self action:@selector(toggleDisableDoubleTapToSkip:) forControlEvents:UIControlEventValueChanged];
            disableDoubleTapToSkip.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableDoubleTapToSkip"];
            cell.accessoryView = disableDoubleTapToSkip;
        }
        if (indexPath.row == 15) {
            cell.textLabel.text = LOC(@"ENABLE_CUSTOM_DOUBLE_TAP_TO_SKIP_DURATION");
            UISwitch *enableCustomDoubleTapToSkipDuration = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableCustomDoubleTapToSkipDuration addTarget:self action:@selector(toggleEnableCustomDoubleTapToSkipDuration:) forControlEvents:UIControlEventValueChanged];
            enableCustomDoubleTapToSkipDuration.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCustomDoubleTapToSkipDuration"];
            cell.accessoryView = enableCustomDoubleTapToSkipDuration;
        }
        if (indexPath.row == 16) {
            UIStepper *customDoubleTapToSkipDurationStepper = [[UIStepper alloc] initWithFrame:CGRectZero];
            customDoubleTapToSkipDurationStepper.stepValue = 1;
            customDoubleTapToSkipDurationStepper.minimumValue = 1;
            customDoubleTapToSkipDurationStepper.maximumValue = 1000;
            if ([[NSUserDefaults standardUserDefaults] doubleForKey:@"kCustomDoubleTapToSkipDuration"]) {
                customDoubleTapToSkipDurationStepper.value = [[NSUserDefaults standardUserDefaults] doubleForKey:@"kCustomDoubleTapToSkipDuration"];
                cell.textLabel.text = [NSString stringWithFormat:LOC(@"Value (Seconds): %.lf"), [[NSUserDefaults standardUserDefaults] doubleForKey:@"kCustomDoubleTapToSkipDuration"]];
            } else {
                customDoubleTapToSkipDurationStepper.value = 10;
                cell.textLabel.text = LOC(@"Value (Seconds): 10");
            }
            [customDoubleTapToSkipDurationStepper addTarget:self action:@selector(customDoubleTapToSkipDurationStepperValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = customDoubleTapToSkipDurationStepper;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"This feature has been disabled cause you have the 'I Have YouTube Premium' option enabled") preferredStyle:UIAlertControllerStyleAlert];

        [alertError addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];

        [self presentViewController:alertError animated:YES completion:nil];
    }
    if (indexPath.row == 10) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"You must enable 'Disable Related Videos In Overlay' and 'Hide Overlay Quick Actions' in YouTube Reborn settings to use 'Always Show Player Bar'") preferredStyle:UIAlertControllerStyleAlert];

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
}

@end

@implementation VideoOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleEnableNoVideoAds:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableNoVideoAds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableNoVideoAds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnableBackgroundPlayback:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableBackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableBackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnablePictureInPicture:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnablePictureInPicture"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnablePictureInPicture"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAllowHDOnCellularData:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAllowHDOnCellularData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAllowHDOnCellularData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)togglePortraitFullscreen:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kPortraitFullscreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kPortraitFullscreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAutoFullScreen:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAutoFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAutoFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisablePinchToZoom:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisablePinchToZoom"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisablePinchToZoom"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoEndscreenPopups:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoEndscreenPopups"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoEndscreenPopups"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoInfoCards:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoInfoCards"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoInfoCards"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoAutoPlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoAutoPlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoAutoPlay"];
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

- (void)toggleRedProgressBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kRedProgressBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kRedProgressBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleGrayBufferProgress:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kGrayBufferProgress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kGrayBufferProgress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePlayerBarHeatwave:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePlayerBarHeatwave"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePlayerBarHeatwave"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAlwaysShowPlayerBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAlwaysShowPlayerBarVTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAlwaysShowPlayerBarVTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleExtraSpeedOptions:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableExtraSpeedOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableExtraSpeedOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableDoubleTapToSkip:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableDoubleTapToSkip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableDoubleTapToSkip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnableCustomDoubleTapToSkipDuration:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableCustomDoubleTapToSkipDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableCustomDoubleTapToSkipDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self.tableView reloadData];
}

- (void)customDoubleTapToSkipDurationStepperValueChanged:(UIStepper *)sender {
    [[NSUserDefaults standardUserDefaults] setDouble:sender.value forKey:@"kCustomDoubleTapToSkipDuration"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end
