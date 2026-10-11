// Shim header. The pinned PoomSmart/YouTubeHeader submodule does not ship this
// renderer, but Reborn references it. Kept here so <YouTubeHeader/...> resolves
// via the tweak's -I Sources include path.
#import <YouTubeHeader/GPBMessage.h>
#import <YouTubeHeader/YTIFormattedString.h>
#import <YouTubeHeader/YTICompactListItemThumbnailSupportedRenderers.h>

@interface YTICompactListItemRenderer : GPBMessage
@property (nonatomic, strong) YTICompactListItemThumbnailSupportedRenderers *thumbnail;
@property (nonatomic, strong) YTIFormattedString *title;
- (BOOL)hasThumbnail;
- (BOOL)hasTitle;
@end
