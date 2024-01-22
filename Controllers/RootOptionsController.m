#import "RootOptionsController.h"
#import "DownloadsController.h"
#import "VideoOptionsController.h"
#import "OverlayOptionsController.h"
#import "TabBarOptionsController.h"
#import "ReorderPivotBarController.h"
#import "ColourOptionsController.h"
#import "ColourOptionsController2.h"
#import "ColourOptionsController3.h"
#import "PictureInPictureOptionsController.h"
#import "ShortsOptionsController.h"
#import "SponsorBlockOptionsController.h"
#import "OtherOptionsController.h"
#import "RebornSettingsController.h"
#import "CreditsController.h"
#import "Localization.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface RootOptionsController ()
- (void)coloursView;
@end

@implementation RootOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.title = @"YouTube Reborn";

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    self.searchBar.delegate = self;

    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.filteredItems = [NSArray array];
    self.isSearching = NO;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = doneButton;

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:LOC(@"Apply") style:UIBarButtonItemStylePlain target:self action:@selector(apply)];
    self.navigationItem.rightBarButtonItem = applyButton;

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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;

    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
        self.filteredItems = [self.allItems filteredArrayUsingPredicate:predicate];
        self.isSearching = YES;
    } else {
        self.filteredItems = [NSArray array];
        self.isSearching = NO;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"filza://"]]) {
            return 2;
        } else {
            return 1;
        }
    }
    if (section == 1) {
        return 11;
    }
    if (section == 2) {
        return 2;
    }
    
    if (self.isSearching) {
        return self.filteredItems.count;
    } else {
        return self.allItems.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RootTableViewCell";
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
        if (indexPath.section == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = LOC(@"VIEW_DOWNLOADS");
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = LOC(@"VIEW_DOWNLOADS_IN_FILZA");
            }
        }
        if (indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = LOC(@"VIDEO_OPTIONS");
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = LOC(@"OVERLAY_OPTIONS");
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = LOC(@"TAB_BAR_OPTIONS");
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = LOC(@"REORDER_TABS");
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = LOC(@"COLOR_OPTIONS");
            }
            if (indexPath.row == 5) {
                cell.textLabel.text = LOC(@"COLOR_OPTIONS_2");
            }
            if (indexPath.row == 6) {
                cell.textLabel.text = LOC(@"COLOR_OPTIONS_3");
            }
            if (indexPath.row == 7) {
                cell.textLabel.text = LOC(@"PICTURE_IN_PICTURE_OPTIONS");
            }
            if (indexPath.row == 8) {
                cell.textLabel.text = LOC(@"SHORTS_OPTIONS");
            }
            if (indexPath.row == 9) {
                cell.textLabel.text = LOC(@"SPONSOR_BLOCK_OPTIONS");
            }
            if (indexPath.row == 10) {
                cell.textLabel.text = LOC(@"OTHER_OPTIONS");
            }
        }
        if (indexPath.section == 2) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = LOC(@"REBORN_SETTINGS");
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = LOC(@"CREDITS_BUTTON");
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {    
            DownloadsController *downloadsController = [[DownloadsController alloc] init];
            UINavigationController *downloadsControllerView = [[UINavigationController alloc] initWithRootViewController:downloadsController];
            downloadsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:downloadsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            NSFileManager *fm = [[NSFileManager alloc] init];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *content = @"Filza Check";
            NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"FilzaCheck.txt"];
            [fm createFileAtPath:filePath contents:fileContents attributes:nil];
            NSString *path = [NSString stringWithFormat:@"filza://view%@/FilzaCheck.txt", documentsDirectory];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path] options:@{} completionHandler:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            VideoOptionsController *videoOptionsController = [[VideoOptionsController alloc] init];
            UINavigationController *videoOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:videoOptionsController];
            videoOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:videoOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            OverlayOptionsController *overlayOptionsController = [[OverlayOptionsController alloc] init];
            UINavigationController *overlayOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:overlayOptionsController];
            overlayOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:overlayOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 2) {
            TabBarOptionsController *tabBarOptionsController = [[TabBarOptionsController alloc] init];
            UINavigationController *tabBarOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:tabBarOptionsController];
            tabBarOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:tabBarOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 3) {
            ReorderPivotBarController *reorderPivotBarController = [[ReorderPivotBarController alloc] init];
	    UINavigationController *reorderPivotBarControllerView = [[UINavigationController alloc] initWithRootViewController:reorderPivotBarController];
            reorderPivotBarControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:reorderPivotBarControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 4) {
            ColourOptionsController *colourOptionsController = [[ColourOptionsController alloc] init];
            UINavigationController *colourOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:colourOptionsController];
            colourOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:colourOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 5) {
            ColourOptionsController2 *colourOptionsController2 = [[ColourOptionsController2 alloc] init];
            UINavigationController *colourOptionsController2View = [[UINavigationController alloc] initWithRootViewController:colourOptionsController2];
            colourOptionsController2View.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:colourOptionsController2View animated:YES completion:nil];
        }
        if (indexPath.row == 6) {
            ColourOptionsController3 *colourOptionsController3 = [[ColourOptionsController3 alloc] init];
            UINavigationController *colourOptionsController3View = [[UINavigationController alloc] initWithRootViewController:colourOptionsController3];
            colourOptionsController3View.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:colourOptionsController3View animated:YES completion:nil];
        }
        if (indexPath.row == 7) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.0")) {
                PictureInPictureOptionsController *pictureInPictureOptionsController = [[PictureInPictureOptionsController alloc] init];
                UINavigationController *pictureInPictureOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:pictureInPictureOptionsController];
                pictureInPictureOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

                [self presentViewController:pictureInPictureOptionsControllerView animated:YES completion:nil];
            } else {
                UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Picture In Picture Options is only available for iOS 15+" preferredStyle:UIAlertControllerStyleAlert];

                [alertError addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }]];

                [self presentViewController:alertError animated:YES completion:nil];
            }
        }
        if (indexPath.row == 8) {
            ShortsOptionsController *shortsOptionsController = [[ShortsOptionsController alloc] init];
            UINavigationController *shortsOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:shortsOptionsController];
            shortsOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
	    
            [self presentViewController:shortsOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 9) {
            SponsorBlockOptionsController *sponsorBlockOptionsController = [[SponsorBlockOptionsController alloc] init];
            UINavigationController *sponsorBlockOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:sponsorBlockOptionsController];
            sponsorBlockOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:sponsorBlockOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 10) {
            OtherOptionsController *otherOptionsController = [[OtherOptionsController alloc] init];
            UINavigationController *otherOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:otherOptionsController];
            otherOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:otherOptionsControllerView animated:YES completion:nil];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            RebornSettingsController *rebornSettingsController = [[RebornSettingsController alloc] init];
            UINavigationController *rebornSettingsControllerView = [[UINavigationController alloc] initWithRootViewController:rebornSettingsController];
            rebornSettingsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:rebornSettingsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            CreditsController *creditsController = [[CreditsController alloc] init];
            UINavigationController *creditsControllerView = [[UINavigationController alloc] initWithRootViewController:creditsController];
            creditsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:creditsControllerView animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return @"YouTube Reborn v5.0.0";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    [footer.textLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSection"]]];
    [footer.textLabel setFont:[UIFont systemFontOfSize:14]];
    footer.textLabel.textAlignment = NSTextAlignmentCenter;
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

@implementation RootOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)apply {
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:0.5];
    exit(0); 
}

@end
