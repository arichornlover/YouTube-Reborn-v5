#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "RebornDownloadPanel.h"
#import <YouTubeExtractor/YouTubeExtractor.h>
#import "Controllers/YouTubeUtils.h"
#import "../UYTSABR.h"
#import "../UYTMediaKit.h"
#import "YouTubeReborn-Swift.h"

@interface UIViewController (RebornPanelAlert)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end

#pragma mark - Format parsing

@implementation RebornStreamFormat
@end

@implementation RebornDownloadPayload
@end

static RebornStreamFormat *RebornFormatFromDictionary(NSDictionary *dict) {
    RebornStreamFormat *format = [RebornStreamFormat new];
    format.itag = [dict[@"itag"] intValue];
    NSString *mime = dict[@"mimeType"];
    format.mimeType = [[mime componentsSeparatedByString:@";"] firstObject];
    if (mime.length) {
        NSRange open = [mime rangeOfString:@"codecs=\""];
        if (open.location != NSNotFound) {
            NSString *tail = [mime substringFromIndex:NSMaxRange(open)];
            NSRange close = [tail rangeOfString:@"\""];
            if (close.location != NSNotFound) {
                format.codecs = [tail substringToIndex:close.location];
            }
        }
    }
    format.width = [dict[@"width"] integerValue];
    format.height = [dict[@"height"] integerValue];
    format.fps = [dict[@"fps"] integerValue];
    format.bitrate = [dict[@"bitrate"] integerValue];
    format.contentLength = [dict[@"contentLength"] unsignedLongLongValue];
    format.qualityLabel = dict[@"qualityLabel"];
    format.directURL = dict[@"url"];
    NSString *mimePrefix = format.mimeType ?: @"";
    format.hasVideo = [mimePrefix hasPrefix:@"video/"];
    format.hasAudio = [mimePrefix hasPrefix:@"audio/"];
    format.isHDR = [format.qualityLabel containsString:@"HDR"];
    if (format.width > 0 && format.height > 0) {
        format.resolution = [NSString stringWithFormat:@"%ldx%ld", (long)format.width, (long)format.height];
    }
    if (format.hasAudio && format.bitrate > 0) {
        format.bitrateLabel = [NSString stringWithFormat:@"%ld kbps", (long)lround((double)format.bitrate / 1000.0)];
    }
    return format;
}

#pragma mark - Panel

@implementation RebornDownloadPanel

+ (NSString *)humanizeDuration:(NSString *)seconds {
    long long total = seconds.longLongValue;
    if (total <= 0) return nil;
    long long hours = total / 3600;
    long long minutes = (total % 3600) / 60;
    long long secs = total % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%lld:%02lld:%02lld", hours, minutes, secs];
    }
    return [NSString stringWithFormat:@"%lld:%02lld", minutes, secs];
}

+ (void)presentForVideoID:(NSString *)videoID fromViewController:(UIViewController *)presenter {
    if (!videoID.length) {
        if (presenter) [presenter showAlertWithTitle:@"Error" message:@"Unable to retrieve video ID."];
        return;
    }
    UIViewController *presenting = presenter;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *playerResponse = [YouTubeExtractor youtubePlayerRequest:@"mediaconnect":videoID];
        RebornDownloadPayload *payload = [self payloadFromPlayerResponse:playerResponse videoID:videoID];
        BOOL fetchFailed = (payload == nil);
        if (payload) {
            payload.canUseSABR = UYTSABRHasValidCaptureForVideoID(videoID);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fetchFailed || !payload) {
                if (presenting) [presenting showAlertWithTitle:@"Error" message:@"Failed to fetch video details."];
                return;
            }
            [RebornDownloadSheet presentWithPayload:payload from:presenting];
        });
    });
}

+ (RebornDownloadPayload *)payloadFromPlayerResponse:(NSDictionary *)playerResponse videoID:(NSString *)videoID {
    NSDictionary *videoDetails = playerResponse[@"videoDetails"];
    NSArray *adaptiveFormats = playerResponse[@"streamingData"][@"adaptiveFormats"];
    NSArray *formats = playerResponse[@"streamingData"][@"formats"];
    if (!videoDetails) return nil;

    NSString *title = videoDetails[@"title"];
    NSString *channel = videoDetails[@"author"];
    NSArray *thumbnails = videoDetails[@"thumbnail"][@"thumbnails"];
    NSURL *artworkURL = [YouTubeUtils highestQualityThumbnailURLFromArray:thumbnails];

    RebornDownloadPayload *payload = [RebornDownloadPayload new];
    payload.videoID = videoID;
    payload.title = title.length ? title : videoID;
    payload.channel = channel;
    payload.duration = [self humanizeDuration:videoDetails[@"lengthSeconds"]];
    payload.artworkURLString = artworkURL.absoluteString;

    NSMutableArray<RebornStreamFormat *> *video = [NSMutableArray array];
    NSMutableArray<RebornStreamFormat *> *audio = [NSMutableArray array];
    BOOL directSeen = NO;
    NSArray *allFormats = [adaptiveFormats arrayByAddingObjectsFromArray:formats ?: @[]];
    for (NSDictionary *dict in allFormats) {
        RebornStreamFormat *format = RebornFormatFromDictionary(dict);
        if (format.directURL.length) directSeen = YES;
        if (format.hasVideo) [video addObject:format];
        if (format.hasAudio && !format.hasVideo) [audio addObject:format];
    }
    payload.videoFormats = video;
    payload.audioFormats = audio;
    payload.canDirect = directSeen;
    return payload;
}

@end

#pragma mark - Engine

static void *RebornDirectProgressContext = &RebornDirectProgressContext;
static char RebornDirectTaskKey;

@implementation RebornDownloadEngine {
    NSMutableDictionary<NSNumber *, RebornDownloadProgress> *_directProgress;
    NSMutableDictionary<NSNumber *, void (^)(NSURL *, NSURLResponse *, NSError *)> *_directCompletion;
    NSMutableDictionary<NSNumber *, NSURLSessionDownloadTask *> *_directTasks;
    NSMutableDictionary<NSNumber *, NSProgress *> *_directProgressObservers;
    void (^_activeCompletion)(BOOL, NSString *, NSString *);
    BOOL _cancelRequested;
}

+ (instancetype)sharedEngine {
    static RebornDownloadEngine *engine;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        engine = [RebornDownloadEngine new];
    });
    return engine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _directProgress = [NSMutableDictionary dictionary];
        _directCompletion = [NSMutableDictionary dictionary];
        _directTasks = [NSMutableDictionary dictionary];
        _directProgressObservers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)canUseSABR:(NSString *)videoID {
    return UYTSABRHasValidCaptureForVideoID(videoID);
}

- (BOOL)isActive:(NSString *)videoID {
    return UYTSABRIsDownloadActive(videoID);
}

- (void)cancelCurrent {
    _cancelRequested = YES;
    [YMSABR cancelCurrent];
    for (NSURLSessionDownloadTask *task in _directTasks.allValues) {
        [task cancel];
    }
    if (_activeCompletion) {
        RebornDownloadCompletion completion = _activeCompletion;
        _activeCompletion = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO, nil, @"cancelled");
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == RebornDirectProgressContext && [keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progressObject = (NSProgress *)object;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *taskID = objc_getAssociatedObject(progressObject, &RebornDirectTaskKey);
            if (!taskID) return;
            RebornDownloadProgress progress = _directProgress[taskID];
            if (!progress) return;
            double fraction = progressObject.fractionCompleted;
            unsigned long long bytes = (unsigned long long)(progressObject.totalUnitCount > 0 ? progressObject.completedUnitCount : 0);
            if (_cancelRequested) return;
            progress(@"Downloading…", fraction, bytes);
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)directDownload:(NSString *)urlString
              progress:(RebornDownloadProgress)progress
            completion:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            NSNumber *taskID = @(task.taskIdentifier);
            NSProgress *observer = strongSelf->_directProgressObservers[taskID];
            if (observer) {
                [observer removeObserver:strongSelf forKeyPath:@"fractionCompleted" context:RebornDirectProgressContext];
            }
            [strongSelf->_directProgressObservers removeObjectForKey:taskID];
            [strongSelf->_directProgress removeObjectForKey:taskID];
            [strongSelf->_directCompletion removeObjectForKey:taskID];
            [strongSelf->_directTasks removeObjectForKey:taskID];
            completion(location, response, error);
        });
    }];

    NSNumber *taskID = @(task.taskIdentifier);
    NSProgress *progressObject = [task progress];
    [progressObject addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:RebornDirectProgressContext];
    objc_setAssociatedObject(progressObject, &RebornDirectTaskKey, taskID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _directProgress[taskID] = progress ?: ^(NSString *p, double f, unsigned long long b) {};
    _directCompletion[taskID] = completion;
    _directTasks[taskID] = task;
    _directProgressObservers[taskID] = progressObject;
    [task resume];
}

- (NSString *)sanitizeTitle:(NSString *)title fallback:(NSString *)fallback {
    NSString *safe = title.length ? title : fallback;
    NSCharacterSet *invalid = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    safe = [[safe componentsSeparatedByCharactersInSet:invalid] componentsJoinedByString:@" "];
    safe = [safe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (safe.length > 120) safe = [safe substringToIndex:120];
    if (!safe.length) safe = fallback;
    return safe;
}

- (NSString *)uniqueFilePathInDirectory:(NSString *)directory base:(NSString *)base extension:(NSString *)extension {
    NSString *candidate = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", base, extension]];
    NSUInteger index = 2;
    while ([[NSFileManager defaultManager] fileExistsAtPath:candidate]) {
        candidate = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %lu.%@", base, (unsigned long)index++, extension]];
    }
    return candidate;
}

- (NSString *)outputDirectory {
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dir = [docs stringByAppendingPathComponent:@"Downloaded"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (void)saveArtwork:(NSString *)urlString toPath:(NSString *)jpgPath {
    if (!urlString.length) return;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    if (data.length > 0) {
        [data writeToFile:jpgPath atomically:YES];
    }
}

- (BOOL)muxVideo:(NSString *)videoPath audio:(NSString * _Nullable)audioPath to:(NSString *)outputPath {
    if (UYTFFActiveBackend() == UYTFFBackendNone) return NO;
    BOOL muxed = NO;
    @try {
        if (audioPath.length) {
            muxed = UYTFFSmartRemuxToMP4(videoPath, audioPath, outputPath);
        } else if (UYTFileLooksLikeWebm(videoPath)) {
            muxed = UYTFFConvertWebmVideoToMp4(videoPath, outputPath);
        } else {
            muxed = ([[NSFileManager defaultManager] copyItemAtPath:videoPath toPath:outputPath error:nil] == YES);
        }
    } @catch (NSException *exception) {
    }
    return muxed;
}

- (void)startVideo:(RebornDownloadPayload *)payload
      videoFormat:(RebornStreamFormat *)videoFormat
      audioFormat:(RebornStreamFormat * _Nullable)audioFormat
         progress:(RebornDownloadProgress)progress
       completion:(RebornDownloadCompletion)completion {
    _cancelRequested = NO;
    _activeCompletion = completion;

    NSString *outDir = [self outputDirectory];
    NSString *safeTitle = [self sanitizeTitle:payload.title fallback:payload.videoID];
    NSString *finalPath = [self uniqueFilePathInDirectory:outDir base:safeTitle extension:@"mp4"];
    NSString *jpgPath = [[finalPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];

    void (^finish)(BOOL, NSString *, NSString *) = ^(BOOL success, NSString *path, NSString *err) {
        RebornDownloadCompletion done = _activeCompletion;
        _activeCompletion = nil;
        if (done) done(success, path, err);
    };

    BOOL useSABR = payload.canUseSABR;
    if (useSABR) {
        if (progress) progress(@"Connecting to on-device session…", -1, 0);
        [YMSABR downloadVideoItag:videoFormat.itag audioItag:audioFormat ? audioFormat.itag : 0
                         progress:^(float fraction, unsigned long long bytes, BOOL isAudio) {
            if (_cancelRequested) return;
            if (progress) progress(isAudio ? @"Downloading audio…" : @"Downloading video…", (double)fraction, bytes);
        } completion:^(NSURL *videoURL, NSURL *audioURL, NSString *err) {
            if (_cancelRequested || err || !videoURL) {
                finish(NO, nil, err ?: @"cancelled");
                return;
            }
            if (progress) progress(@"Muxing with ffmpeg…", -1, 0);
            BOOL muxed = [self muxVideo:videoURL.path audio:audioURL.path to:finalPath];
            if (!muxed) {
                finish(NO, nil, @"Muxing failed (ffmpeg unavailable).");
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self saveArtwork:payload.artworkURLString toPath:jpgPath];
            });
            [[NSFileManager defaultManager] removeItemAtPath:videoURL.path error:nil];
            if (audioURL) [[NSFileManager defaultManager] removeItemAtPath:audioURL.path error:nil];
            finish(YES, finalPath, nil);
        }];
        return;
    }

    if (!videoFormat.directURL.length) {
        finish(NO, nil, @"No direct download available and no on-device capture. Play the video for a few seconds, then retry.");
        return;
    }

    NSString *tmpVideo = [outDir stringByAppendingPathComponent:[NSString stringWithFormat:@".reborn_v_%@.part", payload.videoID]];
    if (progress) progress(@"Downloading video…", 0, 0);
    [self directDownload:videoFormat.directURL progress:progress completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (_cancelRequested || error || !location) {
            finish(NO, nil, error ? (error.code == NSURLErrorCancelled ? @"cancelled" : [NSString stringWithFormat:@"Video download failed: %@", error.localizedDescription]) : @"cancelled");
            return;
        }
        [[NSFileManager defaultManager] removeItemAtPath:tmpVideo error:nil];
        if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:tmpVideo error:nil]) {
            finish(NO, nil, @"Failed to write video file.");
            return;
        }
        if (audioFormat && audioFormat.directURL.length) {
            NSString *tmpAudio = [outDir stringByAppendingPathComponent:[NSString stringWithFormat:@".reborn_a_%@.part", payload.videoID]];
            if (progress) progress(@"Downloading audio…", 0, 0);
            [self directDownload:audioFormat.directURL progress:progress completion:^(NSURL *audioLocation, NSURLResponse *audioResponse, NSError *audioError) {
                if (_cancelRequested || audioError || !audioLocation) {
                    finish(NO, nil, audioError ? (audioError.code == NSURLErrorCancelled ? @"cancelled" : [NSString stringWithFormat:@"Audio download failed: %@", audioError.localizedDescription]) : @"cancelled");
                    [[NSFileManager defaultManager] removeItemAtPath:tmpVideo error:nil];
                    return;
                }
                [[NSFileManager defaultManager] removeItemAtPath:tmpAudio error:nil];
                if (![[NSFileManager defaultManager] moveItemAtPath:audioLocation.path toPath:tmpAudio error:nil]) {
                    [[NSFileManager defaultManager] removeItemAtPath:tmpVideo error:nil];
                    finish(NO, nil, @"Failed to write audio file.");
                    return;
                }
                if (progress) progress(@"Muxing with ffmpeg…", -1, 0);
                BOOL muxed = [self muxVideo:tmpVideo audio:tmpAudio to:finalPath];
                [[NSFileManager defaultManager] removeItemAtPath:tmpVideo error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:tmpAudio error:nil];
                if (!muxed) {
                    finish(NO, nil, @"Muxing failed (ffmpeg unavailable).");
                    return;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self saveArtwork:payload.artworkURLString toPath:jpgPath];
                });
                finish(YES, finalPath, nil);
            }];
        } else {
            if (progress) progress(@"Finalizing…", -1, 0);
            BOOL muxed = [self muxVideo:tmpVideo audio:nil to:finalPath];
            [[NSFileManager defaultManager] removeItemAtPath:tmpVideo error:nil];
            if (!muxed) {
                finish(NO, nil, @"Finalizing failed.");
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self saveArtwork:payload.artworkURLString toPath:jpgPath];
            });
            finish(YES, finalPath, nil);
        }
    }];
}

- (void)startAudio:(RebornDownloadPayload *)payload
       audioFormat:(RebornStreamFormat *)audioFormat
          progress:(RebornDownloadProgress)progress
        completion:(RebornDownloadCompletion)completion {
    _cancelRequested = NO;
    _activeCompletion = completion;

    NSString *outDir = [self outputDirectory];
    NSString *safeTitle = [self sanitizeTitle:payload.title fallback:payload.videoID];
    NSString *finalPath = [self uniqueFilePathInDirectory:outDir base:safeTitle extension:@"m4a"];
    NSString *jpgPath = [[finalPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];

    void (^finish)(BOOL, NSString *, NSString *) = ^(BOOL success, NSString *path, NSString *err) {
        RebornDownloadCompletion done = _activeCompletion;
        _activeCompletion = nil;
        if (done) done(success, path, err);
    };

    void (^handleResult)(NSURL *) = ^(NSURL *sourceURL) {
        if (_cancelRequested || !sourceURL) {
            finish(NO, nil, @"cancelled");
            return;
        }
        if (progress) progress(@"Finalizing audio…", -1, 0);
        BOOL webm = UYTFileLooksLikeWebm(sourceURL.path);
        BOOL ok = NO;
        if (webm) {
            if (UYTFFActiveBackend() != UYTFFBackendNone) {
                @try {
                    ok = UYTFFConvertWebmAudioToM4a(sourceURL.path, finalPath);
                } @catch (NSException *exception) {
                }
            }
        } else {
            ok = [[NSFileManager defaultManager] copyItemAtPath:sourceURL.path toPath:finalPath error:nil];
        }
        [[NSFileManager defaultManager] removeItemAtPath:sourceURL.path error:nil];
        if (!ok) {
            finish(NO, nil, webm ? @"Audio conversion failed (ffmpeg unavailable)." : @"Failed to write audio file.");
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveArtwork:payload.artworkURLString toPath:jpgPath];
        });
        finish(YES, finalPath, nil);
    };

    BOOL useSABR = payload.canUseSABR;
    if (useSABR) {
        if (progress) progress(@"Connecting to on-device session…", -1, 0);
        [YMSABR downloadAudioItag:audioFormat.itag progress:^(float fraction, unsigned long long bytes) {
            if (_cancelRequested) return;
            if (progress) progress(@"Downloading audio…", (double)fraction, bytes);
        } completion:^(NSURL *audioURL, NSString *err) {
            if (_cancelRequested || err || !audioURL) {
                finish(NO, nil, err ?: @"cancelled");
                return;
            }
            handleResult(audioURL);
        }];
        return;
    }

    if (!audioFormat.directURL.length) {
        finish(NO, nil, @"No direct download available and no on-device capture. Play the video for a few seconds, then retry.");
        return;
    }

    if (progress) progress(@"Downloading audio…", 0, 0);
    [self directDownload:audioFormat.directURL progress:progress completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (_cancelRequested || error || !location) {
            finish(NO, nil, error ? (error.code == NSURLErrorCancelled ? @"cancelled" : [NSString stringWithFormat:@"Audio download failed: %@", error.localizedDescription]) : @"cancelled");
            return;
        }
        handleResult(location);
    }];
}

@end