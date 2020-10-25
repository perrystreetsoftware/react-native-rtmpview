//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <AmazonIVSPlayer/IVSBase.h>

NS_ASSUME_NONNULL_BEGIN

/// Possible values returned by `IVSPlayer.state`
typedef NS_ENUM(NSInteger, IVSPlayerState) {
    /// Indicates that the status of the player is idle.
    IVSPlayerStateIdle,
    /// Indicates that the player is ready to play the selected source.
    IVSPlayerStateReady,
    /// Indicates that the player is buffering content.
    IVSPlayerStateBuffering,
    /// Indicates that the player is playing.
    IVSPlayerStatePlaying,
    /// Indicates that the player reached the end of the stream.
    IVSPlayerStateEnded,
} NS_SWIFT_NAME(IVSPlayer.State);

/// Possible log levels for `IVSPlayer.logLevel`
typedef NS_ENUM(NSInteger, IVSLogLevel) {
    IVSLogLevelDebug,
    IVSLogLevelInfo,
    IVSLogLevelWarning,
    IVSLogLevelError,
} NS_SWIFT_NAME(IVSPlayer.LogLevel);

@class IVSQuality;
@protocol IVSPlayerDelegate;

/// An object to control and observe audio video content.
IVS_EXPORT
@interface IVSPlayer : NSObject

/// An optional delegate object to receive state changes and other events.
@property (nonatomic, weak, nullable) id<IVSPlayerDelegate> delegate;

/// Indicates whether adaptive bitrate (ABR) streaming is allowed. Default: `true`.
@property (nonatomic) BOOL autoQualityMode;

/// Indicates whether the player loops the content when possible. Default: `false`.
@property (nonatomic) BOOL looping;

/// Logging level for the player. Default is `IVSLogLevelError`.
@property (nonatomic) IVSLogLevel logLevel;

/// For a live stream, the latency to the source.
@property (nonatomic, readonly) CMTime liveLatency;

/// The audio-muting state of the player. Default: false.
@property (nonatomic) BOOL muted;

/// The video-playback rate. Supported range: 0.5 to 2.0. Default: 1.0 (normal).
@property (nonatomic) float playbackRate;

/// Volume of the audio track, if any. Supported range: 0.0 to 1.0. Default: 1.0 (max).
@property (nonatomic) float volume;

/// Current approximate bandwidth estimate in bits per second (bps).
@property (nonatomic, readonly) NSInteger bandwidthEstimate;

/// Remaining duration of buffered content.
@property (nonatomic, readonly) CMTime buffered;

/// Total duration of the loaded media stream.
///
/// This property is key-value observable.
/// @see `-[IVSPlayerDelegate player:didChangeDuration]`
@property (nonatomic, readonly) CMTime duration;

/// Playback position.
@property (nonatomic, readonly) CMTime position;

/// URL of the loaded media, if any.
///
/// This property is key-value observable.
@property (nonatomic, readonly, copy, nullable) NSURL *path;

/// Current quality being played, if any.
///
/// This property returns nil before an initial quality has been determined.
///
/// Setting this to a nonnull value implicitly disables `autoQualityMode` and switches to the new value immediately.
/// Setting the property to nil implicitly enables `autoQualityMode`, and a new quality will be selected asynchronously.
///
/// This property is key-value observable.
/// @see `-[IVSPlayerDelegate player:didChangeQuality:]`
@property (nonatomic, nullable) IVSQuality *quality;

/// Quality objects from the loaded source or empty if none are currently available.
/// The qualities will be available after the `IVSPlayerStateReady` state has been entered.
/// This contains the qualities that can be assigned to `quality`.
/// Note that this set will contain only qualities capable of being played on the current device
/// and not all those present in the source stream.
@property (nonatomic, readonly) NSArray<IVSQuality *> *qualities;

/// The player's version, in the format of MAJOR.MINOR.PATCH-HASH.
@property (nonatomic, readonly) NSString *version;

/// Bitrate of the media stream.
@property (nonatomic, readonly) NSInteger videoBitrate;

/// Number of video frames that were decoded.
@property (nonatomic, readonly) NSInteger videoFramesDecoded;

/// Number of video frames that were dropped.
@property (nonatomic, readonly) NSInteger videoFramesDropped;

/// Native size of the current video source, in pixels. Default: `CGSizeZero` until the first frame is rendered.
///
/// This property is key-value observable.
/// @see `-[IVSPlayerDelegate player:didChangeVideoSize:]`
@property (nonatomic, readonly) CGSize videoSize;

/// The state of the player.
///
/// This property is key-value observable.
/// @see `-[IVSPlayerDelegate player:didChangeState:]`
@property (nonatomic, readonly) IVSPlayerState state;

/// Fatal error encountered during playback.
///
/// This property is key-value observable.
/// @see `-[IVSPlayerDelegate player:didFailWithError:]`
@property (nonatomic, readonly, nullable) NSError *error;

/// Indicates whether live low-latency streaming is enabled for the current stream.
@property (nonatomic, readonly, getter=isLiveLowLatency) BOOL liveLowLatency NS_SWIFT_NAME(isLiveLowLatency);

/// Loads the stream at the specified URL and prepares the player for playback.
/// @param path Location of the streaming manifest, clip, or file.
- (void)load:(nullable NSURL *)path;

/// A unique identifier for the current playback session. This session identifier can be
/// shared with support or displayed in an user interface to help troubleshoot or diagnose
/// playback issues with the currently playing stream.
@property (nonatomic, readonly) NSString *sessionId;

/// Pauses playback. `state` transitions to `IVSPlayerStateIdle`.
- (void)pause;

/// Starts or resumes playback of the current stream, if no stream is loaded indicates intent to
/// play and the player will automatically play on a subsequent `load` call.
/// On success depending on the type of stream the player state will change to `IVSPlayerStateBuffering`
/// and then `IVSPlayerStatePlaying` or just `IVSPlayerStatePlaying`. On failure invokes the error delegate.
- (void)play;

/// Seeks to the given time in the stream and begins playing at that position if play() has been
/// called. If no stream is loaded the seek will be be deferred until load is called.
/// On success depending on the type of stream the player state will change to
/// `IVSPlayerStateBuffering` and then State::Playing or remain in `IVSPlayerStatePlaying`.
/// The position will update to the seeked time. On failure invokes the error delegate.
/// @param position Seek position.
- (void)seekTo:(CMTime)position;

/// Sets the playback time to the specified value and invokes a completion handler when done.
/// @param position Seek position.
/// @param completionHandler A block to invoke on the main queue when done. This takes one parameter, indicating whether seeking was successful.
- (void)seekTo:(CMTime)position
    completionHandler:(void (^)(BOOL finished))completionHandler;

/// Enable low-latency mode when encountering a compatible live stream. Default: `true`.
/// @param enable Thether to enable this mode when available.
/// @see `liveLowLatency` property, which is `true` when this mode is enabled for the stream.
- (void)setLiveLowLatencyEnabled:(BOOL)enable;

/// Set the maximum quality when using auto quality mode. This can be used to control resource usage.
/// The quality you provide here is applied to the current stream. If you load a new stream, call this again after `IVSPlayerStateReady`.
/// @param quality Maximum quality to use.
- (void)setAutoMaxQuality:(nullable IVSQuality *)quality;

@end

///@see AVPlayer (AVPlayerTimeObservation) in <AVFoundation/AVPlayer.h>
@interface IVSPlayer (IVSPlayerTimeObservation)

/// Requests to invoke `block` on `queue` at repeating `interval`.
/// @param interval Duration between block invocations, in terms of playback time.
/// @param queue The queue where the block should be enqueued. If `nil`, the main queue is used.
/// @param block The block to be invoked after each interval.
/// @return An object which must be retained for as long as this observer is active. Pass this object to `-removeTimeObserver:` to end observation.
/// @see `-[AVPlayer addPeriodicTimeObserverForInterval:queue:usingBlock:]`
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(nullable dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block NS_WARN_UNUSED_RESULT;

/// Requests to invoke `block` at designated playback `times`.
/// @param times An array of timestamps to invoke the block. In Objective-C, use `[NSValue valueWithCMTime:]` to wrap each value. In Swift, an array of CMTime values can be passed directly using `as [NSValue]`.
/// @param queue The queue where the block should be enqueued. If `nil`, the main queue is used.
/// @param block The block to be invoked when any of the `times` is passed during playback.
/// @return An object which must be retained for as long as this observer is active. Pass this object to `-removeTimeObserver:` to end observation.
/// @see `-[AVPlayer addBoundaryTimeObserverForTimes:queue:usingBlock:]`
- (id)addBoundaryTimeObserverForTimes:(NSArray<NSValue *> *)times
                                queue:(nullable dispatch_queue_t)queue
                           usingBlock:(void (^)(void))block NS_WARN_UNUSED_RESULT;

/// Removes a registered observer and cancels all future invocations.
/// @param observer An object returned from `-addPeriodicTimeObserverForInterval:queue:usingBlock:` or `-addBoundaryTimeObserverForTimes:queue:usingBlock:`.
/// @see `-[AVPlayer removeTimeObserver:]`
- (void)removeTimeObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
