#import "ShortsOptionsController.h"

@interface ShortsOptionsController ()
- (void)coloursView;
@end

@implementation ShortsOptionsController

- (void)loadView {
	[super loadView];
    [self coloursView];

    self.title = @"Shorts Options";

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
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShortsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Hide Channel Avatar Button";
            UISwitch *hideShortsChannelAvatarButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsChannelAvatarButton addTarget:self action:@selector(toggleHideShortsChannelAvatarButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsChannelAvatarButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsChannelAvatarButton"];
            cell.accessoryView = hideShortsChannelAvatarButton;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Hide Like Button";
            UISwitch *hideShortsLikeButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsLikeButton addTarget:self action:@selector(toggleHideShortsLikeButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsLikeButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsLikeButton"];
            cell.accessoryView = hideShortsLikeButton;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Hide Dislike Button";
            UISwitch *hideShortsDislikeButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsDislikeButton addTarget:self action:@selector(toggleHideShortsDislikeButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsDislikeButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsDislikeButton"];
            cell.accessoryView = hideShortsDislikeButton;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"Hide Comments Button";
            UISwitch *hideShortsCommentsButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsCommentsButton addTarget:self action:@selector(toggleHideShortsCommentsButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsCommentsButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsCommentsButton"];
            cell.accessoryView = hideShortsCommentsButton;
	}
        if (indexPath.row == 4) {
            cell.textLabel.text = @"Hide Remix Button";
            UISwitch *hideShortsRemixButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsRemixButton addTarget:self action:@selector(toggleHideShortsRemixButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsRemixButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsRemixButton"];
            cell.accessoryView = hideShortsRemixButton;
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = @"Hide Share Button";
            UISwitch *hideShortsShareButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsShareButton addTarget:self action:@selector(toggleHideShortsShareButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsShareButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsShareButton"];
            cell.accessoryView = hideShortsShareButton;
        }
        if (indexPath.row == 6) {
            cell.textLabel.text = @"Hide More Actions Button";
            UISwitch *hideShortsMoreActionsButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsMoreActionsButton addTarget:self action:@selector(toggleHideShortsMoreActionsButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsMoreActionsButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsMoreActionsButton"];
            cell.accessoryView = hideShortsMoreActionsButton;
        }
        if (indexPath.row == 7) {
            cell.textLabel.text = @"Hide Search Button";
            UISwitch *hideShortsSearchButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsSearchButton addTarget:self action:@selector(toggleHideShortsSearchButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsSearchButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsSearchButton"];
            cell.accessoryView = hideShortsSearchButton;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = @"Hide 'Buy Super Thanks' Banner";
            UISwitch *hideShortsBuySuperThanks = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsBuySuperThanks addTarget:self action:@selector(toggleHideShortsBuySuperThanks:) forControlEvents:UIControlEventValueChanged];
            hideShortsBuySuperThanks.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsBuySuperThanks"];
            cell.accessoryView = hideShortsBuySuperThanks;
	}
        if (indexPath.row == 9) {
            cell.textLabel.text = @"Hide Subscriptions Button";
            UISwitch *hideShortsSubscriptionsButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideShortsSubscriptionsButton addTarget:self action:@selector(toggleHideShortsSubscriptionsButton:) forControlEvents:UIControlEventValueChanged];
            hideShortsSubscriptionsButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsSubscriptionsButton"];
            cell.accessoryView = hideShortsSubscriptionsButton;
	}
        if (indexPath.row == 10) {
            cell.textLabel.text = @"Disable Resume to Shorts";
            UISwitch *disableResumeToShorts = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableResumeToShorts addTarget:self action:@selector(toggleDisableResumeToShorts:) forControlEvents:UIControlEventValueChanged];
            disableResumeToShorts.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableResumeToShorts"];
            cell.accessoryView = disableResumeToShorts;
	}
         if (indexPath.row == 11) {
            cell.textLabel.text = @"Always Show Shorts Player Bar";
            UISwitch *alwaysShowShortsPlayerBar = [[UISwitch alloc] initWithFrame:CGRectZero];
            [alwaysShowShortsPlayerBar addTarget:self action:@selector(toggleAlwaysShowShortsPlayerBar:) forControlEvents:UIControlEventValueChanged];
            alwaysShowShortsPlayerBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlwaysShowShortsPlayerBar"];
            cell.accessoryView = alwaysShowShortsPlayerBar;
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

@implementation ShortsOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleHideShortsChannelAvatarButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsChannelAvatarButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsChannelAvatarButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsLikeButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsLikeButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsLikeButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsDislikeButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsDislikeButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsDislikeButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsCommentsButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsCommentsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsCommentsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsRemixButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsRemixButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsRemixButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsShareButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsShareButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsShareButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsMoreActionsButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsMoreActionsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsMoreActionsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsSearchButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsSearchButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsSearchButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsBuySuperThanks:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsBuySuperThanks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsBuySuperThanks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsSubscriptionsButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsSubscriptionsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsSubscriptionsButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableResumeToShorts:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableResumeToShorts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableResumeToShorts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAlwaysShowShortsPlayerBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAlwaysShowShortsPlayerBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAlwaysShowShortsPlayerBar"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
