#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface YouTubeDownloadController : UIViewController

@property (nonatomic, strong) NSString *downloadTitle;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *dualURL;
@property (nonatomic, strong) NSURL *artworkURL;
@property (nonatomic, assign) NSInteger downloadOption;

@end
