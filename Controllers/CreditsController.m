#import "CreditsController.h"
#import "Localization.h"

@interface CreditsController ()
- (void)coloursView;
@end

@implementation CreditsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.title = LOC(@"CREDITS_BUTTON");

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13, *)) {
        style = UITableViewStyleInsetGrouped;
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CreditsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Lillie";
            cell.detailTextLabel.text = LOC(@"DEVELOPER_TEXT");
            [self loadImageWithURLString:@"https://avatars.githubusercontent.com/u/91358136?v=4" forImageView:cell.imageView];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Alpha_Stream";
            cell.detailTextLabel.text = LOC(@"ICON_DESIGNER_TEXT");
            [self loadImageWithURLString:@"" forImageView:cell.imageView];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"kirb";
            cell.detailTextLabel.text = LOC(@"Development Support");
            [self loadImageWithURLString:@"https://avatars.githubusercontent.com/u/773309?v=4" forImageView:cell.imageView];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Dayanch96";
            cell.detailTextLabel.text = LOC(@"Features: \"YouTube Reborn v5 Menu\", \"Red Progress Bar\", \"Gray Buffer Progress\", \"Stick Navigation Bar\", \"Disable Double tap to skip\"");
            [self loadImageWithURLString:@"https://avatars.githubusercontent.com/u/38832025?v=4" forImageView:cell.imageView];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"PoomSmart";
            cell.detailTextLabel.text = LOC(@"Features: \"YouTube Reborn Button under Video Player\", \"YouTube-X/Adblock\", \"AutoPlay In Fullscreen\"");
            [self loadImageWithURLString:@"https://avatars.githubusercontent.com/u/3608783?v=4" forImageView:cell.imageView];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"NguyenASang";
            cell.detailTextLabel.text = LOC(@"Features: \"YouTube Reborn Button under Video Player\"");
            [self loadImageWithURLString:@"https://avatars.githubusercontent.com/u/87893636?v=4" forImageView:cell.imageView];
        } else if (indexPath.row == 5) {
            cell.textLabel.text = @"Snoolie";
            cell.detailTextLabel.text = LOC(@"Features: \"Enable Extra Video Speed\"");
            [self loadImageWithURLString:@"" forImageView:cell.imageView];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self openURLWithString:@"https://github.com/LillieH1000"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self openURLWithString:@"https://twitter.com/Kutarin_"];
        } else if (indexPath.row == 1) {
            [self openURLWithString:@"https://github.com/Dayanch96"];
        } else if (indexPath.row == 2) {
            [self openURLWithString:@"https://github.com/kirb"];
        } else if (indexPath.row == 3) {
            [self openURLWithString:@"https://twitter.com/PoomSmart"];
        } else if (indexPath.row == 4) {
            [self openURLWithString:@"https://github.com/0xilis"];
        }
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

- (void)loadImageWithURLString:(NSString *)urlString forImageView:(UIImageView *)imageView {
    if (urlString.length > 0) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        imageView.image = image;
    } else {
        imageView.image = nil;
    }
}

- (void)openURLWithString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end

@implementation CreditsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
