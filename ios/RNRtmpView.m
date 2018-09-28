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



@interface KslivePlayerView : UIView

@property (nonatomic, strong) KSYMoviePlayerController *player;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) BOOL shouldMute;
@property (nonatomic) MPMovieScalingMode scalingMode;

// or RCTBubblingEventBlock
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackState;
@property (nonatomic, copy) RCTBubblingEventBlock onLoadState;
@property (nonatomic, copy) RCTBubblingEventBlock onFirstVideoFrameRendered;

@end

@implementation KslivePlayerView

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

    [self.player prepareToPlay];
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

- (void)handlePlayerNotify:(NSNotification*)notify {
    if (!self.player) {
        return;
    }

    if ([notify.name isEqualToString:MPMediaPlaybackIsPreparedToPlayDidChangeNotification]) {
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
            self.onPlaybackState(@{@"state": @(self.player.playbackState)});
        }
    } else if ([notify.name isEqualToString:MPMoviePlayerLoadStateDidChangeNotification]) {
        if (self.onLoadState) {
            self.onLoadState(@{@"state": @(self.player.loadState)});
        }
    } else if ([notify.name isEqualToString:MPMoviePlayerFirstVideoFrameRenderedNotification]) {
        if (self.onFirstVideoFrameRendered) {
            self.onFirstVideoFrameRendered(@{});
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNRtmpEvent"
                                                        object:@{@"name": notify.name}];
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
