#import "TabBarOptionsController.h"
#import "StartupPageOptionsController.h"
#import "Localization.h"

@interface TabBarOptionsController ()
- (void)coloursView;
@end

@implementation TabBarOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.title = LOC(@"TAB_BAR_OPTIONS");

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TabBarTableViewCell";
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
        if (indexPath.section == 0) {
            cell.textLabel.text = LOC(@"STARTUP_PAGE");
            if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"]) {
                cell.detailTextLabel.text = LOC(@"Home");
            } else {
                int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"];
                if (selectedTab == 0) {
                    cell.detailTextLabel.text = LOC(@"Home");
                }
                if (selectedTab == 1) {
                    cell.detailTextLabel.text = LOC(@"Explore");
                }
                if (selectedTab == 2) {
                    cell.detailTextLabel.text = LOC(@"Shorts");
                }
                if (selectedTab == 3) {
                    cell.detailTextLabel.text = LOC(@"Subscriptions");
                }
                if (selectedTab == 4) {
                    cell.detailTextLabel.text = LOC(@"You");
                }
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = LOC(@"HIDE_TAB_BAR_LABELS");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideTabBarLabels = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideTabBarLabels addTarget:self action:@selector(toggleHideTabBarLabels:) forControlEvents:UIControlEventValueChanged];
                hideTabBarLabels.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideTabBarLabels"];
                cell.accessoryView = hideTabBarLabels;
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = LOC(@"HIDE_EXPLORE_TAB");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideExploreTab = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideExploreTab addTarget:self action:@selector(toggleHideExploreTab:) forControlEvents:UIControlEventValueChanged];
                hideExploreTab.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideExploreTab"];
                cell.accessoryView = hideExploreTab;
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = LOC(@"HIDE_SHORTS_TAB");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideShortsTab = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideShortsTab addTarget:self action:@selector(toggleHideShortsTab:) forControlEvents:UIControlEventValueChanged];
                hideShortsTab.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsTab"];
                cell.accessoryView = hideShortsTab;
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = LOC(@"HIDE_CREATE_TAB");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideUploadTab = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideUploadTab addTarget:self action:@selector(toggleHideUploadTab:) forControlEvents:UIControlEventValueChanged];
                hideUploadTab.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideUploadTab"];
                cell.accessoryView = hideUploadTab;
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = LOC(@"HIDE_SUBSCRIPTIONS_TAB");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideSubscriptionsTab = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideSubscriptionsTab addTarget:self action:@selector(toggleHideSubscriptionsTab:) forControlEvents:UIControlEventValueChanged];
                hideSubscriptionsTab.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideSubscriptionsTab"];
                cell.accessoryView = hideSubscriptionsTab;
            }
            if (indexPath.row == 5) {
                cell.textLabel.text = LOC(@"HIDE_YOU_TAB");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *hideYouTab = [[UISwitch alloc] initWithFrame:CGRectZero];
                [hideYouTab addTarget:self action:@selector(toggleHideYouTab:) forControlEvents:UIControlEventValueChanged];
                hideYouTab.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideYouTab"];
                cell.accessoryView = hideYouTab;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
	    UINavigationController *startupPageOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:[[StartupPageOptionsController alloc] init]];
            [startupPageOptionsControllerView setModalPresentationStyle:UIModalPresentationFullScreen];

            [self presentViewController:startupPageOptionsControllerView animated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

@end

@implementation TabBarOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleHideTabBarLabels:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideTabBarLabels"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideTabBarLabels"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideExploreTab:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideExploreTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideExploreTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideShortsTab:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideShortsTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideShortsTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideUploadTab:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideUploadTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideUploadTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideSubscriptionsTab:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideSubscriptionsTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideSubscriptionsTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideYouTab:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideYouTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideYouTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
