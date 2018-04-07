#import "RNRtmpView.h"
#import <libksygpulive/KSYMoviePlayerController.h>
#import <React/RCTUIManager.h>

#import <PureLayout/PureLayout.h>

@implementation RCTConvert (MoviePlaybackState)

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



@interface KslivePlayerView : UIView {

}

@property (nonatomic, strong) KSYMoviePlayerController *player;
@property (nonatomic, assign) NSString *url;

// or RCTBubblingEventBlock
@property (nonatomic, copy) RCTBubblingEventBlock onPlaybackState;

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

- (void)setUrl:(NSString *)urlString {
    self.player =
        [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlString]];

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

    if ([notify.name isEqualToString:MPMoviePlayerPlaybackStateDidChangeNotification]) {
        if (self.onPlaybackState) {
            NSLog(@"Notify is %@ %@", notify.object, notify.userInfo);
            self.onPlaybackState(@{@"state": @(self.player.playbackState)});
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
//RCT_EXPORT_VIEW_PROPERTY(loadState, MPMovieLoadState)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(onPlaybackState, RCTBubblingEventBlock)

//RCT_CUSTOM_VIEW_PROPERTY(url, NSString, KslivePlayerView) {
//    [view setUrl:json];
//}

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
              @"MovieLoadStateStalled":@(MPMovieLoadStateStalled)

              };
}

@end
  
