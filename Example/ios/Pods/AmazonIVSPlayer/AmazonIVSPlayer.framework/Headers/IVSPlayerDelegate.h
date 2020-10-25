//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@class IVSCue;
@class IVSPlayer;
@class IVSQuality;

/// This delegate receives state changes and other events relevant to playback on `IVSPlayer`. All are invoked on the main queue.
/// @see `IVSPlayer.delegate`
NS_SWIFT_NAME(IVSPlayer.Delegate)
@protocol IVSPlayerDelegate <NSObject>
@optional

/// Duration of the media changed.
/// @param player The player instance managing the media that changed duration.
/// @param duration The new duration.
/// @see `IVSPlayer.duration`, which supports Key-Value Observation as an alternative to this delegate method.
- (void)player:(IVSPlayer *)player didChangeDuration:(CMTime)duration;

/// State of the player changed.
/// @param player The player instance that changed state.
/// @param state The new state.
/// @see `IVSPlayer.state`, which supports Key-Value Observation as an alternative to this delegate method.
- (void)player:(IVSPlayer *)player didChangeState:(IVSPlayerState)state
    NS_SWIFT_NAME(player(_:didChangeState:));

/// The player encountered a fatal error.
/// @param player The player instance that encountered an error.
/// @param error The error. See IVSErrors.h for expected userInfo keys.
/// @see `IVSPlayer.error`, which supports Key-Value Observation as an alternative to this delegate method.
- (void)player:(IVSPlayer *)player didFailWithError:(NSError *)error;

/// The playback quality changed. This may be due to user action or an internal adaptive-quality switch.
/// @param player The player instance that switched quality.
/// @param quality The new quality.
/// @see `IVSPlayer.quality`, which supports Key-Value Observation as an alternative to this delegate method.
- (void)player:(IVSPlayer *)player didChangeQuality:(nullable IVSQuality *)quality
    NS_SWIFT_NAME(player(_:didChangeQuality:));

/// The player encountered a timed cue such as subtitles, captions, or other metadata in the stream.
/// @param player The player instance managing the stream.
/// @param cue An object with timing information and other details varying by type.
/// @see `IVSCue`
/// @see `IVSTextCue`
/// @see `IVSTextMetadataCue`
- (void)player:(IVSPlayer *)player didOutputCue:(__kindof IVSCue *)cue;

/// The player exhausted its internal buffers while playing. This is not invoked for user actions such as seeking or starting/resuming playback.
/// @param player The player instance that will rebuffer.
- (void)playerWillRebuffer:(IVSPlayer *)player;

/// A seek operation completed.
/// @param player The player that finished seeking.
/// @param time The resulting time of the seek.
- (void)player:(IVSPlayer *)player didSeekToTime:(CMTime)time;

/// The native video size for the media changed.
/// @param player The player instance managing the media that changed.
/// @param videoSize The new size in pixels.
/// @see `IVSPlayer.videoSize`, which supports Key-Value Observation as an alternative to this delegate method.
- (void)player:(IVSPlayer *)player didChangeVideoSize:(CGSize)videoSize;

@end

NS_ASSUME_NONNULL_END
