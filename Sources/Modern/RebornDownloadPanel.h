#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RebornStreamFormat : NSObject
@property (nonatomic) int itag;
@property (nonatomic, copy, nullable) NSString *mimeType;
@property (nonatomic, copy, nullable) NSString *codecs;
@property (nonatomic, copy, nullable) NSString *qualityLabel;
@property (nonatomic, copy, nullable) NSString *resolution;
@property (nonatomic, copy, nullable) NSString *bitrateLabel;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger fps;
@property (nonatomic) NSInteger bitrate;
@property (nonatomic) unsigned long long contentLength;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic) BOOL hasAudio;
@property (nonatomic) BOOL isHDR;
@property (nonatomic, copy, nullable) NSString *directURL;
@end

@interface RebornDownloadPayload : NSObject
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *channel;
@property (nonatomic, copy, nullable) NSString *duration;
@property (nonatomic, copy, nullable) NSString *artworkURLString;
@property (nonatomic, copy) NSArray<RebornStreamFormat *> *videoFormats;
@property (nonatomic, copy) NSArray<RebornStreamFormat *> *audioFormats;
@property (nonatomic) BOOL canUseSABR;
@property (nonatomic) BOOL canDirect;
@end

typedef void (^RebornDownloadProgress)(NSString *phase, double fraction, unsigned long long bytesDownloaded);
typedef void (^RebornDownloadCompletion)(BOOL success, NSString * _Nullable path, NSString * _Nullable error);

@interface RebornDownloadEngine : NSObject
+ (instancetype)sharedEngine;
- (BOOL)canUseSABR:(NSString *)videoID;
- (BOOL)isActive:(NSString *)videoID;
- (void)startVideo:(RebornDownloadPayload *)payload
      videoFormat:(RebornStreamFormat *)videoFormat
      audioFormat:(RebornStreamFormat * _Nullable)audioFormat
         progress:(RebornDownloadProgress _Nullable)progress
       completion:(RebornDownloadCompletion _Nullable)completion;
- (void)startAudio:(RebornDownloadPayload *)payload
       audioFormat:(RebornStreamFormat *)audioFormat
          progress:(RebornDownloadProgress _Nullable)progress
        completion:(RebornDownloadCompletion _Nullable)completion;
- (void)cancelCurrent;
@end

@interface RebornDownloadPanel : NSObject
+ (void)presentForVideoID:(NSString *)videoID fromViewController:(UIViewController *)presenter;
@end

NS_ASSUME_NONNULL_END