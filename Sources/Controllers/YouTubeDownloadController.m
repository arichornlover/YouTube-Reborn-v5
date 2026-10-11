#import "YouTubeDownloadController.h"
#import "../UYTMediaKit.h"

@interface YouTubeDownloadController () {
    UIImageView *artworkImage;
    UILabel *titleLabel;
    UILabel *downloadPercentLabel;
    UILabel *noticeLabel;
    NSString *activeProgressFormat;
}
- (void)coloursView;
- (void)videoDownloaderPartOne;
- (void)videoDownloaderPartTwo;
- (void)audioDownloader;
@property (nonatomic, copy) void(^progressCleanupHandler)(void);
@end

@implementation YouTubeDownloadController

- (void)loadView {
    [super loadView];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [self coloursView];

    UIWindow *boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];

    artworkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, 300)];
    UIImage *artwork = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.artworkURL]];
    artworkImage.image = artwork;

    if ([[self.artworkURL pathExtension] isEqualToString:@"jpg"]) {
        [self.view addSubview:artworkImage];
    }

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, boundsWindow.safeAreaInsets.top + 300, self.view.bounds.size.width, 50)];
    titleLabel.text = self.downloadTitle;
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        titleLabel.textColor = [UIColor blackColor];
    } else {
        titleLabel.textColor = [UIColor whiteColor];
    }

    [self.view addSubview:titleLabel];

    downloadPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, boundsWindow.safeAreaInsets.top + 300 + titleLabel.frame.size.height, self.view.bounds.size.width, 50)];
    downloadPercentLabel.numberOfLines = 1;
    downloadPercentLabel.adjustsFontSizeToFitWidth = YES;
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        downloadPercentLabel.textColor = [UIColor blackColor];
    } else {
        downloadPercentLabel.textColor = [UIColor whiteColor];
    }

    [self.view addSubview:downloadPercentLabel];

    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, boundsWindow.safeAreaInsets.top + 300 + titleLabel.frame.size.height + downloadPercentLabel.frame.size.height, self.view.bounds.size.width, 50)];
    noticeLabel.text = @"Don't Exit The App\nThis will automatically close on completion";
    noticeLabel.numberOfLines = 2;
    noticeLabel.adjustsFontSizeToFitWidth = YES;
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        noticeLabel.textColor = [UIColor blackColor];
    } else {
        noticeLabel.textColor = [UIColor whiteColor];
    }

    [self.view addSubview:noticeLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner;
    self.modalInPresentation = YES;

    if (self.downloadOption == 0) {
        [self videoDownloaderPartOne];
    } else if (self.downloadOption == 1) {
        [self audioDownloader];
    } else if (self.downloadOption == 2) {
        [self shortsDownloader];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.progressCleanupHandler) {
        self.progressCleanupHandler();
        self.progressCleanupHandler = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->activeProgressFormat) {
                double downloadPercent = [(NSProgress *)object fractionCompleted] * 100.0;
                self->downloadPercentLabel.text = [NSString stringWithFormat:self->activeProgressFormat, downloadPercent];
            }
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSURLSessionDownloadTask *)downloadTaskForURL:(NSURL *)url progressFormat:(NSString *)format completion:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    activeProgressFormat = format;
    __weak typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSLog(@"[YouTubeReborn] download finished: %@, error: %@", [response URL], error);
        if (weakSelf.progressCleanupHandler) {
            weakSelf.progressCleanupHandler();
            weakSelf.progressCleanupHandler = nil;
        }
        completion(location, response, error);
    }];

    NSProgress *progress = downloadTask.progress;
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    self.progressCleanupHandler = ^{
        [progress removeObserver:weakSelf forKeyPath:@"fractionCompleted"];
    };
    [downloadTask resume];
    return downloadTask;
}

- (void)videoDownloaderPartOne {
    __weak typeof(self) weakSelf = self;
    [self downloadTaskForURL:self.videoURL progressFormat:@"Progress (Part 1/2): %.02f%%" completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error && location) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[documentsDirectoryURL URLByAppendingPathComponent:@"video.mp4"] error:nil];
            [weakSelf videoDownloaderPartTwo];
        }
    }];
}

- (void)videoDownloaderPartTwo {
    __weak typeof(self) weakSelf = self;
    [self downloadTaskForURL:self.audioURL progressFormat:@"Progress (Part 2/2): %.02f%%" completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error || !location) {
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        UYTFFRun(@[@"-i", [location path], @"-c:a", @"libmp3lame", @"-q:a", @"8", [NSString stringWithFormat:@"%@/audio.mp3", documentsDirectory]]);
        UYTFFRun(@[@"-i", [NSString stringWithFormat:@"%@/video.mp4", documentsDirectory], @"-i", [NSString stringWithFormat:@"%@/audio.mp3", documentsDirectory], @"-c:v", @"copy", @"-c:a", @"aac", [NSString stringWithFormat:@"%@/output.mp4", documentsDirectory]]);
        [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@/output.mp4", documentsDirectory] toPath:[NSString stringWithFormat:@"%@/%@.mp4", documentsDirectory, [[weakSelf.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[location path] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/video.mp4", documentsDirectory] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/audio.mp3", documentsDirectory] error:nil];
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)audioDownloader {
    __weak typeof(self) weakSelf = self;
    [self downloadTaskForURL:self.audioURL progressFormat:@"Progress: %.02f%%" completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error || !location) {
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *safeTitle = [[self.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        UYTFFRun(@[@"-i", [location path], @"-c:a", @"libmp3lame", @"-q:a", @"8", [NSString stringWithFormat:@"%@/%@.mp3", documentsDirectory, safeTitle]]);
        [[NSFileManager defaultManager] removeItemAtPath:[location path] error:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)shortsDownloader {
    [self downloadTaskForURL:self.dualURL progressFormat:@"Progress: %.02f%%" completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error || !location) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:[NSString stringWithFormat:@"%@/%@.mp4", documentsDirectory, [[self.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[location path] error:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)coloursView {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self coloursView];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        titleLabel.textColor = [UIColor blackColor];
        downloadPercentLabel.textColor = [UIColor blackColor];
        noticeLabel.textColor = [UIColor blackColor];
    } else {
        titleLabel.textColor = [UIColor whiteColor];
        downloadPercentLabel.textColor = [UIColor whiteColor];
        noticeLabel.textColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
}

@end