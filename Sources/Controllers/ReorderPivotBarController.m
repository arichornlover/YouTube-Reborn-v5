#import "ReorderPivotBarController.h"

@interface ReorderPivotBarController () <UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *tabOrder;

@end

@implementation ReorderPivotBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    self.title = @"Reorder Tabs";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItems = @[doneButton, saveButton];
    
    if (@available(iOS 15.0, *)) {
        [self.tableView setSectionHeaderTopPadding:0.0f];
    }
    
    self.tabOrder = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"kTabOrder"]];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.tableView addGestureRecognizer:longPressGesture];
}

- (void)setupView {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TabBarTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.shadowColor = [UIColor blackColor];
            cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Home";
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Shorts";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Create";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Subscriptions";
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"You";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && indexPath.section == 1) {
        NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:self.tabOrder.count - 1 inSection:1];
        
        if (indexPath.row != self.tabOrder.count - 1) {
            [self.tableView beginUpdates];
            
            NSString *movedTabIdentifier = self.tabOrder[indexPath.row];
            [self.tabOrder removeObjectAtIndex:indexPath.row];
            [self.tabOrder insertObject:movedTabIdentifier atIndex:destinationIndexPath.row];
            
            // Update the pivot bar's tabs
            NSMutableArray *reorderedTabs = [NSMutableArray array];
            
            for (NSString *tabIdentifier in self.tabOrder) {
                if ([tabIdentifier isEqualToString:@"FEshorts"]) {
                    [reorderedTabs addObject:@"Shorts"];
                }
                else if ([tabIdentifier isEqualToString:@"FEuploads"]) {
                    [reorderedTabs addObject:@"Create"];
                }
                else if ([tabIdentifier isEqualToString:@"FEsubscriptions"]) {
                    [reorderedTabs addObject:@"Subscriptions"];
                }
                else if ([tabIdentifier isEqualToString:@"FElibrary"]) {
                    [reorderedTabs addObject:@"You"];
                }
            }
            
            // Set the new tab order
            [self setTabOrder:reorderedTabs];
            
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:destinationIndexPath];
            [self.tableView endUpdates];
        }
    }
}
- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:self.tabOrder forKey:@"kTabOrder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)done {   
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
