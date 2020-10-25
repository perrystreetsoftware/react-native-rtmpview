//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AmazonIVSPlayer/IVSBase.h>

@class IVSPlayer;

NS_ASSUME_NONNULL_BEGIN

/// Displays the visual content from `IVSPlayer`.
IVS_EXPORT
@interface IVSPlayerLayer : CALayer

/// Creates an instance of `IVSPlayerLayer` for the provided player instance.
/// @param player An instance of `IVSPlayer` to associate with this layer
+ (instancetype)playerLayerWithPlayer:(nullable IVSPlayer *)player;

/// An instance of `IVSPlayer` that displays its visual output in this layer.
///
/// This property is key-value observable.
@property (nonatomic, nullable) IVSPlayer *player;

/// A string constant describing how video is displayed within the layer bounds.
///
/// See the definitions of `AVLayerVideoGravity` in <AVFoundation/AVAnimation.h> for detailed descriptions of the available options.
///
/// This property is key-value observable.
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/// The current size and position of the video image as displayed within this layer's bounds.
/// A value of `CGRectZero` indicates that no video is displayed.
///
/// This property is key-value observable.
@property (nonatomic, readonly) CGRect videoRect;

@end

NS_ASSUME_NONNULL_END
