// Shim header. The pinned PoomSmart/YouTubeHeader submodule does not ship this
// renderer, but Reborn references it. Kept here so <YouTubeHeader/...> resolves
// via the tweak's -I Sources include path.
#import <YouTubeHeader/GPBMessage.h>
#import <YouTubeHeader/YTIIconThumbnailRenderer.h>

@interface YTICompactListItemThumbnailSupportedRenderers : GPBMessage
@property (nonatomic, strong) YTIIconThumbnailRenderer *iconThumbnailRenderer;
- (BOOL)hasIconThumbnailRenderer;
@end
