//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AmazonIVSPlayer/IVSBase.h>

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>

@class IVSPlayer;
@class IVSPlayerLayer;

NS_ASSUME_NONNULL_BEGIN

/// A view whose backing layer is an instance of `IVSPlayerLayer`.
IVS_EXPORT
@interface IVSPlayerView: UIView

/// This view's backing layer, guaranteed to be an instance of `IVSPlayerLayer`.
@property (nonatomic, readonly) IVSPlayerLayer *playerLayer;

@end


/// Passthrough accessors for functionality on `IVSPlayerLayer`
@interface IVSPlayerView (IVSConvenience)

/// Convenience accessor for the `player`  property on `playerLayer`.
///
/// This property is key-value observable.
@property (nonatomic, nullable) IVSPlayer *player;

/// Convenience accessor for the `videoGravity` property on `playerLayer`.
///
/// This property is key-value observable.
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/// Convenience accessor for the `videoRect` property on `playerLayer`.
///
/// This property is key-value observable.
@property (nonatomic, readonly) CGRect videoRect;

@end

NS_ASSUME_NONNULL_END

#endif // __has_include(<UIKit/UIKit.h>)
