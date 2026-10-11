#import <Foundation/Foundation.h>

@interface YouTubeUtils : NSObject

+ (BOOL)validatePlayerResponse:(NSDictionary *)response;
+ (NSURL *)highestQualityThumbnailURLFromArray:(NSArray *)thumbnails;
+ (NSDictionary *)bestVideoInfoFromFormats:(NSArray *)formats;
+ (NSDictionary *)bestAudioInfoFromFormats:(NSArray *)formats;

@end
