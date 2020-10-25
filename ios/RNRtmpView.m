#import "RNRtmpView.h"
#import <React/RCTUIManager.h>

#import <PureLayout/PureLayout.h>
#import <AmazonIVSPlayer/AmazonIVSPlayer.h>

@implementation RCTConvert (IVSPlayerState)

RCT_ENUM_CONVERTER(IVSPlayerState, (@{
    @"IVSPlayerStateIdle": @(IVSPlayerStateIdle),
    @"IVSPlayerStateReady": @(IVSPlayerStateReady),
    @"IVSPlayerStateBuffering": @(IVSPlayerStateBuffering),
    @"IVSPlayerStatePlaying": @(IVSPlayerStatePlaying),
    @"IVSPlayerStateEnded": @(IVSPlayerStateEnded)
                                    }), IVSPlayerStateIdle, integerValue);
@end

@interface RNIVSPlayerView () <IVSPlayerDelegate>
@property (nonatomic, copy) RCTBubblingEventBlock onDidChangeState;

@end

@implementation RNIVSPlayerView

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[IVSPlayerView alloc] init];
}

RCT_EXPORT_METHOD(load:(NSNumber * __nonnull)reactTag url:(NSString *)urlString) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, IVSPlayerView *> *viewRegistry) {
        IVSPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[IVSPlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting IVSPlayerView, got: %@", view);
        }

        IVSPlayer *player = [[IVSPlayer alloc] init];
        player.delegate = self;
        view.player = player;

        NSURL *videoUrl = [NSURL URLWithString:urlString];

        [view.player load:videoUrl];
    }];
}

RCT_EXPORT_METHOD(pause:(NSNumber * __nonnull)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, IVSPlayerView *> *viewRegistry) {
        IVSPlayerView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[IVSPlayerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting IVSPlayerView, got: %@", view);
        }

        [view.player pause];
    }];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

// MARK: - IVSPlayerDelegate

- (void)player:(IVSPlayer *)player didChangeState:(IVSPlayerState)state {
    if (state == IVSPlayerStateReady) {
        [player play];
    }

    if (self.onDidChangeState) {
        NSLog(@"Notify is %@", @(state));

        self.onDidChangeState(@{@"state": @(state)});
    }
}

- (NSDictionary *)constantsToExport {
    return @{ @"IVSPlayerStateIdle":@(IVSPlayerStateIdle),
              @"IVSPlayerStateReady":@(IVSPlayerStateReady),
              @"IVSPlayerStateBuffering":@(IVSPlayerStateBuffering),
              @"IVSPlayerStatePlaying":@(IVSPlayerStatePlaying),
              @"IVSPlayerStateEnded":@(IVSPlayerStateEnded)
              };
}

@end
