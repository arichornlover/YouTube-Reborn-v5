#import "StartupPageOptionsController.h"

@interface StartupPageOptionsController ()
- (void)coloursView;
@end

@implementation StartupPageOptionsController

int selectedIndex;

- (void)loadView {
	[super loadView];
    [self coloursView];

    self.title = @"Startup Page Options";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"]) {
        selectedIndex = 0;
    } else {
        selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StartupPageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed: 0.06 green: 0.06 blue: 0.06 alpha: 1.00];
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
            cell.textLabel.text = @"Home";
            if (selectedIndex == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Explore";
            if (selectedIndex == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Shorts";
            if (selectedIndex == 2) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"Subscriptions";
            if (selectedIndex == 3) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"You";
            if (selectedIndex == 4) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"kStartupPageIntVTwo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
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

@implementation StartupPageOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
