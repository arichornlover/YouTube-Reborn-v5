#import "OtherOptionsController.h"

@interface OtherOptionsController ()
- (void)coloursView;
@end

@implementation OtherOptionsController

- (void)loadView {
	[super loadView];
    [self coloursView];

    self.title = @"Other Options";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OtherTableViewCell";
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
            cell.textLabel.text = @"Enable iPad Style On iPhone - iPad Layout";
            UISwitch *enableiPadStyleOniPhone = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableiPadStyleOniPhone addTarget:self action:@selector(toggleEnableiPadStyleOniPhone:) forControlEvents:UIControlEventValueChanged];
            enableiPadStyleOniPhone.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"];
            cell.accessoryView = enableiPadStyleOniPhone;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Enable iPhone Style On iPad - iPhone Layout";
            UISwitch *enableiPhoneStyleOniPad = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableiPhoneStyleOniPad addTarget:self action:@selector(toggleEnableiPhoneStyleOniPad:) forControlEvents:UIControlEventValueChanged];
            enableiPhoneStyleOniPad.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPhoneStyleOniPad"];
            cell.accessoryView = enableiPhoneStyleOniPad;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"No Cast Button";
            UISwitch *noCastButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [noCastButton addTarget:self action:@selector(toggleNoCastButton:) forControlEvents:UIControlEventValueChanged];
            noCastButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kNoCastButton"];
            cell.accessoryView = noCastButton;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"No Notification Button";
            UISwitch *noNotificationButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [noNotificationButton addTarget:self action:@selector(toggleNoNotificationButton:) forControlEvents:UIControlEventValueChanged];
            noNotificationButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kNoNotificationButton"];
            cell.accessoryView = noNotificationButton;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"No Search Button";
            UISwitch *noSearchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [noSearchButton addTarget:self action:@selector(toggleNoSearchButton:) forControlEvents:UIControlEventValueChanged];
            noSearchButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kNoSearchButton"];
            cell.accessoryView = noSearchButton;
        }
         if (indexPath.row == 5) {
            cell.textLabel.text = @"Hide 'Play next in queue'";
            UISwitch *hidePlayNextInQueue = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePlayNextInQueue addTarget:self action:@selector(toggleHidePlayNextInQueue:) forControlEvents:UIControlEventValueChanged];
            hidePlayNextInQueue.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePlayNextInQueue"];
            cell.accessoryView = hidePlayNextInQueue;
        }
        if (indexPath.row == 6) {
            cell.textLabel.text = @"Disable YouTube Kids";
            UISwitch *disableYouTubeKidsPopup = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableYouTubeKidsPopup addTarget:self action:@selector(toggleDisableYouTubeKidsPopup:) forControlEvents:UIControlEventValueChanged];
            disableYouTubeKidsPopup.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableYouTubeKidsPopup"];
            cell.accessoryView = disableYouTubeKidsPopup;
        }
        if (indexPath.row == 7) {
            cell.textLabel.text = @"Disable Hints";
            UISwitch *disableHints = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableHints addTarget:self action:@selector(toggleDisableHints:) forControlEvents:UIControlEventValueChanged];
            disableHints.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableHints"];
            cell.accessoryView = disableHints;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = @"Premium YouTube Logo";
            UISwitch *premiumYouTubeLogo = [[UISwitch alloc] initWithFrame:CGRectZero];
            [premiumYouTubeLogo addTarget:self action:@selector(togglePremiumYouTubeLogo:) forControlEvents:UIControlEventValueChanged];
            premiumYouTubeLogo.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kPremiumYouTubeLogo"];
            cell.accessoryView = premiumYouTubeLogo;
	}
        if (indexPath.row == 9) {
            cell.textLabel.text = @"Hide YouTube Logo";
            UISwitch *hideYouTubeLogo = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideYouTubeLogo addTarget:self action:@selector(toggleHideYouTubeLogo:) forControlEvents:UIControlEventValueChanged];
            hideYouTubeLogo.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideYouTubeLogo"];
            cell.accessoryView = hideYouTubeLogo;
	}
         if (indexPath.row == 10) {
            cell.textLabel.text = @"Stick Navigation Bar";
            UISwitch *stickNavigationBar = [[UISwitch alloc] initWithFrame:CGRectZero];
            [stickNavigationBar addTarget:self action:@selector(toggleStickNavigationBar:) forControlEvents:UIControlEventValueChanged];
            stickNavigationBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kStickNavigationBar"];
            cell.accessoryView = stickNavigationBar;
	}
        if (indexPath.row == 11) {
            cell.textLabel.text = @"Low Contrast Mode";
            UISwitch *lowContrastMode = [[UISwitch alloc] initWithFrame:CGRectZero];
            [lowContrastMode addTarget:self action:@selector(toggleLowContrastMode:) forControlEvents:UIControlEventValueChanged];
            lowContrastMode.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kLowContrastMode"];
            cell.accessoryView = lowContrastMode;
        }
        if (indexPath.row == 12) {
            cell.textLabel.text = @"Auto-Hide Home Bar";
            UISwitch *autoHideHomeBar = [[UISwitch alloc] initWithFrame:CGRectZero];
            [autoHideHomeBar addTarget:self action:@selector(toggleAutoHideHomeBar:) forControlEvents:UIControlEventValueChanged];
            autoHideHomeBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoHideHomeBar"];
            cell.accessoryView = autoHideHomeBar;
        }
    }
    return cell;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    UITableView *tableView = self.tableView;
    tableView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0);
    tableView.layer.maskedCorners = kCALayerMinXMinYCorner;
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner;
}

@end

@implementation OtherOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleEnableiPadStyleOniPhone:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableiPadStyleOniPhone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableiPadStyleOniPhone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnableiPhoneStyleOniPad:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableiPhoneStyleOniPad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableiPhoneStyleOniPad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleNoCastButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kNoCastButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kNoCastButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleNoNotificationButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kNoNotificationButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kNoNotificationButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleNoSearchButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kNoSearchButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kNoSearchButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePlayNextInQueue:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePlayNextInQueue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePlayNextInQueue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableYouTubeKidsPopup:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableYouTubeKidsPopup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableYouTubeKidsPopup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableHints:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableHints"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableHints"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)togglePremiumYouTubeLogo:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kPremiumYouTubeLogo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kPremiumYouTubeLogo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideYouTubeLogo:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideYouTubeLogo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideYouTubeLogo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleStickNavigationBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kStickNavigationBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kStickNavigationBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleLowContrastMode:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kLowContrastMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kLowContrastMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAutoHideHomeBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAutoHideHomeBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAutoHideHomeBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
