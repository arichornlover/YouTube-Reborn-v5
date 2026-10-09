#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PictureInPictureController : UIViewController <AVPlayerViewControllerDelegate, AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) NSString *videoTime;
@property (nonatomic, strong) NSURL *videoPath;

@end
