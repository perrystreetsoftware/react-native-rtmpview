#import "RNRtmpView.h"
#import <libksygpulive/KSYMoviePlayerController.h>
#import <React/RCTUIManager.h>

#import <PureLayout/PureLayout.h>

@implementation RCTConvert (MoviePlaybackState)

RCT_ENUM_CONVERTER(MPMovieScalingMode,(@{@"MovieScalingModeNone":@(MPMovieScalingModeNone),
                                           @"MovieScalingModeAspectFit":@(MPMovieScalingModeAspectFit),
                                           @"MovieScalingModeAspectFill":@(MPMovieScalingModeAspectFill),
                                           @"MovieScalingModeFill":@(MPMovieScalingModeFill)
                                           }),MPMovieScalingModeNone,integerValue);

RCT_ENUM_CONVERTER(MPMoviePlaybackState,(@{@"MoviePlaybackStateStopped":@(MPMoviePlaybackStateStopped),
                                           @"MoviePlaybackStatePlaying":@(MPMoviePlaybackStatePlaying),
                                           @"MoviePlaybackStatePaused":@(MPMoviePlaybackStatePaused),
                                           @"MoviePlaybackStateInterrupted":@(MPMoviePlaybackStateInterrupted),
                                           @"MoviePlaybackStateSeekingForward":@(MPMoviePlaybackStateSeekingForward),
                                           @"MoviePlaybackStateSeekingBackward":@(MPMoviePlaybackStateSeekingBackward)
                                           }),MPMoviePlaybackStateStopped,integerValue);

RCT_ENUM_CONVERTER(MPMovieLoadState,(@{@"MovieLoadStateUnknown":@(MPMovieLoadStateUnknown),
                                           @"MovieLoadStatePlayable":@(MPMovieLoadStatePlayable),
                                           @"MovieLoadStatePlaythroughOK":@(MPMovieLoadStatePlaythroughOK),
                                           @"MovieLoadStateStalled":@(MPMovieLoadStateStalled)
                                           }),MPMovieLoadStateUnknown,integerValue);
@end

@class BitrateCalculator;

@interface KslivePlayerView : UIView

@property (nonatomic, strong) KSYMoviePlayerController *player;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) BOOL shouldMute;
@property (nonatomic) MPMovieScalingMode scalingMode;
@property (nonatomic, readonly) NSDictionary *qosInfo;

// or RCTBubblingEventBlock
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackState;
@property (nonatomic, copy) RCTBubblingEventBlock onLoadState;
@property (nonatomic, copy) RCTBubblingEventBlock onFirstVideoFrameRendered;
@property (nonatomic, copy) RCTBubblingEventBlock onBitrateRecalculated;

@property (nonatomic, strong) NSDictionary *mediaMeta;
@property (nonatomic, strong) BitrateCalculator *bitrateCalculator;

@end

@interface BitrateCalculator: NSObject {
    NSTimeInterval lastCheckTime;
    double lastSize;
    double calculatedBitrate;
}

// Avoid retain cycle with timers by using a separate object
@property (nonatomic, weak) KslivePlayerView *playerView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readonly) double bitrate;

- (instancetype)init:(KslivePlayerView *)playerView;
- (void)cleanup;

@end

@implementation KslivePlayerView {
    long long int prepared_time;

    int fvr_costtime;
    int far_costtime;
}

+ (NSArray *)observedEvents {
  return @[MPMediaPlaybackIsPreparedToPlayDidChangeNotification,
           MPMoviePlayerPlaybackStateDidChangeNotification,
           MPMoviePlayerPlaybackDidFinishNotification,
           MPMoviePlayerLoadStateDidChangeNotification,
           MPMovieNaturalSizeAvailableNotification,
           MPMoviePlayerFirstVideoFrameRenderedNotification,
           MPMoviePlayerFirstAudioFrameRenderedNotification,
           MPMoviePlayerSuggestReloadNotification,
           MPMoviePlayerPlaybackStatusNotification,
           MPMoviePlayerNetworkStatusChangeNotification,
           MPMoviePlayerSeekCompleteNotification,
           MPMoviePlayerPlaybackTimedTextNotification
           ];
}

//- (instancetype)init {
//    if (self = [super init]) {
//    }
//
//    return self;
//}

- (void)dealloc{
    [self cleanup];
}

- (void)cleanup {
    [self.bitrateCalculator cleanup];
    [self releaseObservers:self.player];
    [self.player stop];
}

- (void)initialize {
    self.player =
        [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.url]];

    self.player.scalingMode = self.scalingMode;
    self.player.shouldMute = self.shouldMute;
    [self setupObservers:self.player];
    [self addSubview:self.player.view];
    [self.player.view autoPinEdgesToSuperviewEdges];

    // Optimized for real-time
    self.player.bufferTimeMax = 0.01;
    self.bitrateCalculator = [[BitrateCalculator alloc] init:self];

    prepared_time = (long long int)([self getCurrentTime] * 1000);
    [self.player prepareToPlay];
}

- (NSTimeInterval) getCurrentTime{
    return [[NSDate date] timeIntervalSince1970];
}

- (void)releaseObservers:(KSYMoviePlayerController*)player {
    for (NSString *event in [KslivePlayerView observedEvents]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:event
                                                      object:player];
    }
}

- (void)setupObservers:(KSYMoviePlayerController*)player {
    for (NSString *event in [KslivePlayerView observedEvents]) {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(handlePlayerNotify:)
                                                    name:(event)
                                                  object:player];
    }
}

- (NSDictionary *)qosInfo {
    KSYQosInfo *info = self.player.qosInfo;

    NSDictionary *stats = @{@"bitrate": @(self.bitrateCalculator.bitrate),
                            @"first_video_frame_rendered": @(fvr_costtime),
                            @"first_audio_frame_rendered": @(far_costtime),
                            @"http_connection_time_ms": @((long)[(NSNumber *)[self.mediaMeta objectForKey:kKSYPLYHttpConnectTime] integerValue]),
                            @"dns_resolution_time_ms": @((long)[(NSNumber *)[self.mediaMeta objectForKey:kKSYPLYHttpAnalyzeDns] integerValue]),
                            @"first_packet_time": @((long)[(NSNumber *)[self.mediaMeta objectForKey:kKSYPLYHttpFirstDataTime] integerValue]),
                            @"audio_buffer_byte_length": @((float)info.audioBufferByteLength / 1e6),
                            @"audio_buffer_queue_length": @((float)info.audioBufferTimeLength / 1e3),
                            @"audio_total_data_mb": @((float)info.audioTotalDataSize / 1e6),
                            @"video_buffer_byte_length": @((float)info.videoBufferByteLength / 1e6),
                            @"video_buffer_queue_length": @((float)info.videoBufferTimeLength / 1e3),
                            @"video_total_data_mb": @((float)info.videoTotalDataSize / 1e6),
                            @"total_data_mb": @((float)info.totalDataSize / 1e6),
                            @"video_decoding_frame_rate": @(info.videoDecodeFPS),
                            @"video_refresh_frame_rate": @(info.videoRefreshFPS),
                            @"network_status": [self netStatus2Str:_player.networkStatus]
                            };

    return stats;
}

- (NSString *) netStatus2Str:(KSYNetworkStatus)networkStatus{
    NSString *netString = nil;
    if(networkStatus == KSYNotReachable)
        netString = @"NO INTERNET";
    else if(networkStatus == KSYReachableViaWiFi)
        netString = @"WIFI";
    else if(networkStatus == KSYReachableViaWWAN)
        netString = @"WWAN";
    else
        netString = @"Unknown";
    return netString;
}

- (void)handlePlayerNotify:(NSNotification*)notify {
    if (!self.player) {
        return;
    }

    if ([notify.name isEqualToString:MPMediaPlaybackIsPreparedToPlayDidChangeNotification]) {
        self.mediaMeta = [self.player getMetadata];

        if ([self.player isPreparedToPlay]) {
            [self.player play];
        }
    }

    if ([notify.name isEqualToString:MPMoviePlayerSuggestReloadNotification]) {
        [self.player reload:self.player.contentURL flush:YES mode:MPMovieReloadMode_Fast];
    }

    if ([notify.name isEqualToString:MPMoviePlayerPlaybackStateDidChangeNotification]) {
        if (self.onPlaybackState) {
            NSLog(@"Notify is %@ %@", notify.object, notify.userInfo);
            self.onPlaybackState(@{@"state": @(self.player.playbackState),
                                   @"qos": self.qosInfo
                                   });
        }
    } else if ([notify.name isEqualToString:MPMoviePlayerLoadStateDidChangeNotification]) {
        if (self.onLoadState) {
            self.onLoadState(@{@"state": @(self.player.loadState),
                               @"qos": self.qosInfo
                               });
        }
    } else if ([notify.name isEqualToString:MPMoviePlayerFirstVideoFrameRenderedNotification]) {
        fvr_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);

        if (self.onFirstVideoFrameRendered) {
            self.onFirstVideoFrameRendered(@{@"state": @(self.player.loadState),
                                             @"qos": self.qosInfo
                                             });
        }
    } else if ([notify.name isEqualToString:MPMoviePlayerFirstAudioFrameRenderedNotification]) {
        far_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNRtmpEvent"
                                                        object:@{@"name": notify.name}];
}

- (void)handleBitrateRecalculated:(double)bitrate {
    if (self.onBitrateRecalculated) {
        self.onBitrateRecalculated(@{@"bitrate": @(self.bitrateCalculator.bitrate)});
    }
}

@end

@interface RNRtmpView ()

@end

@implementation RNRtmpView

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[KslivePlayerView alloc] init];
}

//RCT_EXPORT_VIEW_PROPERTY(playbackState, MPMoviePlaybackState)
RCT_EXPORT_VIEW_PROPERTY(scalingMode, MPMovieScalingMode)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackState, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadState, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFirstVideoFrameRendered, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBitrateRecalculated, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(shouldMute, BOOL)

RCT_EXPORT_METHOD(loadState:(NSNumber * __nonnull)reactTag completion:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        callback(@[@(view.player.loadState)]);
    }];
}

RCT_EXPORT_METHOD(playbackState:(NSNumber * __nonnull)reactTag completion:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        callback(@[@(view.player.playbackState)]);
    }];
}

RCT_EXPORT_METHOD(initialize:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view initialize];
    }];
}

// https://stackoverflow.com/a/31936516/61072
RCT_EXPORT_METHOD(play:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view.player play];
    }];
}

RCT_EXPORT_METHOD(stop:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view.player stop];
    }];
}

RCT_EXPORT_METHOD(pause:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view.player pause];
    }];
}

RCT_EXPORT_METHOD(mute:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view.player setShouldMute:YES];
    }];
}

RCT_EXPORT_METHOD(unmute:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, KslivePlayerView *> *viewRegistry) {
        KslivePlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[KslivePlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
        }
        // Call your native component's method here
        [view.player setShouldMute:NO];
    }];
}

- (NSDictionary *)constantsToExport {
    return @{ @"MoviePlaybackStateStopped":@(MPMoviePlaybackStateStopped),
              @"MoviePlaybackStatePlaying":@(MPMoviePlaybackStatePlaying),
              @"MoviePlaybackStatePaused":@(MPMoviePlaybackStatePaused),
              @"MoviePlaybackStateInterrupted":@(MPMoviePlaybackStateInterrupted),
              @"MoviePlaybackStateSeekingForward":@(MPMoviePlaybackStateSeekingForward),
              @"MoviePlaybackStateSeekingBackward":@(MPMoviePlaybackStateSeekingBackward),

              @"MovieLoadStateUnknown":@(MPMovieLoadStateUnknown),
              @"MovieLoadStatePlayable":@(MPMovieLoadStatePlayable),
              @"MovieLoadStatePlaythroughOK":@(MPMovieLoadStatePlaythroughOK),
              @"MovieLoadStateStalled":@(MPMovieLoadStateStalled),

              @"MovieScalingModeNone":@(MPMovieScalingModeNone),
              @"MovieScalingModeAspectFit":@(MPMovieScalingModeAspectFit),
              @"MovieScalingModeAspectFill":@(MPMovieScalingModeAspectFill),
              @"MovieScalingModeFill":@(MPMovieScalingModeFill)

              };
}

@end

@implementation BitrateCalculator

- (instancetype)init:(KslivePlayerView *)playerView {
    if (self = [super init]) {
        self.playerView = playerView;

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(onTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
    }

    return self;
}

- (double)bitrate {
    return calculatedBitrate;
}

- (void)onTimer:(id)sender {
    if (self.playerView) {
        NSTimeInterval currentTime = [self.playerView getCurrentTime];

        if (0 == lastCheckTime) {
            lastCheckTime = currentTime;

            return;
        }

        double flowSize = [self.playerView.player readSize];

        calculatedBitrate = 8 * 1024.0 * (flowSize - lastSize) / (currentTime - lastCheckTime);
        lastCheckTime = currentTime;
        lastSize = flowSize;

        [self.playerView handleBitrateRecalculated:self.bitrate];
    }
}

- (void)cleanup {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
