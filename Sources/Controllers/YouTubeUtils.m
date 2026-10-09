#import "YouTubeUtils.h"

@implementation YouTubeUtils

+ (BOOL)validatePlayerResponse:(NSDictionary *)response {
    return response && response[@"streamingData"] && response[@"videoDetails"];
}

+ (NSURL *)highestQualityThumbnailURLFromArray:(NSArray *)thumbnails {
    if (!thumbnails.count) return nil;
    return [NSURL URLWithString:thumbnails.lastObject[@"url"]];
}

+ (NSDictionary *)bestVideoInfoFromFormats:(NSArray *)formats {
    NSMutableDictionary *videoURLs = [NSMutableDictionary dictionary];
    NSArray *resolutions = @[@"2160", @"1440", @"1080", @"720", @"480", @"360", @"240"];
    NSArray *qualityLabels = @[@"hd2160", @"hd1440", @"hd1080", @"hd720", @"480p", @"360p", @"240p"];

    for (NSUInteger i = 0; i < resolutions.count; i++) {
        NSString *resolution = resolutions[i];
        NSString *quality = qualityLabels[i];

        for (NSDictionary *format in formats) {
            NSString *mimeType = format[@"mimeType"];
            NSString *height = [format[@"height"] stringValue];
            NSString *formatQuality = format[@"quality"];
            NSString *qualityLabel = format[@"qualityLabel"];
            NSString *urlString = format[@"url"];

            if ([mimeType containsString:@"video/mp4"] && 
                ((height && [height isEqualToString:resolution]) || 
                 (formatQuality && [formatQuality isEqualToString:quality]) || 
                 (qualityLabel && [qualityLabel isEqualToString:qualityLabel]))) {
                videoURLs[[resolutions[i] stringByAppendingString:@"p"]] = [NSURL URLWithString:urlString];
                break;
            }
        }
    }
    return videoURLs;
}

+ (NSDictionary *)bestAudioInfoFromFormats:(NSArray *)formats {
    NSMutableDictionary *audioInfo = [NSMutableDictionary dictionary];
    NSArray *qualities = @[@"AUDIO_QUALITY_HIGH", @"AUDIO_QUALITY_MEDIUM", @"AUDIO_QUALITY_LOW"];

    for (NSString *quality in qualities) {
        for (NSDictionary *format in formats) {
            NSString *mimeType = format[@"mimeType"];
            NSString *audioQuality = format[@"audioQuality"];
            NSString *urlString = format[@"url"];

            if ([mimeType containsString:@"audio/mp4"] && 
                audioQuality && [audioQuality isEqualToString:quality] && 
                (!audioInfo[@"url"] || 
                 [qualities indexOfObject:audioInfo[@"quality"]] > [qualities indexOfObject:quality])) {
                audioInfo[@"quality"] = quality;
                audioInfo[@"url"] = [NSURL URLWithString:urlString];
            }
        }
        if (audioInfo[@"url"]) break;
    }
    return audioInfo;
}

@end
