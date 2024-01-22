#import "YouTubeDownloadController.h"
#import "Localization.h"
#import "../MobileFFmpeg/MobileFFmpegConfig.h"
#import "../MobileFFmpeg/MobileFFmpeg.h"
#import "../MobileFFmpeg/libavcodec/avcodec.h"
#import "../MobileFFmpeg/libavdevice/avdevice.h"
#import "../MobileFFmpeg/libavfilter/avfilter.h"
#import "../MobileFFmpeg/libavutil/avutil.h"
#import "../MobileFFmpeg/libswresample/swresample.h"
#import "../MobileFFmpeg/libswscale/swscale.h"
#import "../AFNetworking/AFNetworking.h"

@interface YouTubeDownloadController () {
    UIImageView *artworkImage;
    UILabel *titleLabel;
    UILabel *downloadPercentLabel;
    UILabel *noticeLabel;
}
- (void)coloursView;
- (void)videoDownloaderPartOne;
- (void)videoDownloaderPartTwo;
- (void)audioDownloader;
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
    noticeLabel.text = LOC(@"DOWNLOAD_NOTICE");
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

- (void)videoDownloaderPartOne {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.videoURL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float downloadPercent = downloadProgress.fractionCompleted * 100;
            downloadPercentLabel.text = [NSString stringWithFormat:LOC(@"Progress (Part 1/2): %.02f%%"), downloadPercent];
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [[NSFileManager defaultManager] moveItemAtPath:[filePath path] toPath:[NSString stringWithFormat:@"%@/video.mp4", documentsDirectory] error:nil];
        [self videoDownloaderPartTwo];
    }];
    [downloadTask resume];
}

- (void)videoDownloaderPartTwo {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.audioURL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float downloadPercent = downloadProgress.fractionCompleted * 100;
            downloadPercentLabel.text = [NSString stringWithFormat:LOC(@"Progress (Part 2/2): %.02f%%"), downloadPercent];
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -c:a libmp3lame -q:a 8 %@/audio.mp3", filePath, documentsDirectory]];
        [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@/video.mp4 -i %@/audio.mp3 -c:v copy -c:a aac %@/output.mp4", documentsDirectory, documentsDirectory, documentsDirectory]];
        [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@/output.mp4", documentsDirectory] toPath:[NSString stringWithFormat:@"%@/%@.mp4", documentsDirectory, [[self.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[filePath path] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/video.mp4", documentsDirectory] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/audio.mp3", documentsDirectory] error:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [downloadTask resume];
}

- (void)audioDownloader {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.audioURL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float downloadPercent = downloadProgress.fractionCompleted * 100;
            downloadPercentLabel.text = [NSString stringWithFormat:LOC(@"Progress: %.02f%%"), downloadPercent];
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -c:a libmp3lame -q:a 8 %@/%@.mp3", filePath, documentsDirectory, [[self.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]]];
        [[NSFileManager defaultManager] removeItemAtPath:[filePath path] error:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [downloadTask resume];
}

- (void)shortsDownloader {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.dualURL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float downloadPercent = downloadProgress.fractionCompleted * 100;
            downloadPercentLabel.text = [NSString stringWithFormat:LOC(@"Progress: %.02f%%"), downloadPercent];
        });
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        [[NSFileManager defaultManager] moveItemAtPath:[filePath path] toPath:[NSString stringWithFormat:@"%@/%@.mp4", documentsDirectory, [[self.downloadTitle componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[filePath path] error:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [downloadTask resume];
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
}

@end
