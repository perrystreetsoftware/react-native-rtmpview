//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <AmazonIVSPlayer/IVSBase.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a selection of video/audio tracks from the loaded media.
/// @see `IVSPlayer.quality`
IVS_EXPORT
@interface IVSQuality : NSObject

IVS_INIT_UNAVAILABLE()

/// Name of the quality, suitable for use in a user interface.
@property (nonatomic, readonly) NSString *name;

/// Codec string representing the media codec information; e.g., `"avc1.64002A,mp4a.40.2"`.
@property (nonatomic, readonly) NSString *codecs;

/// Bitrate of the media in bits per second (bps).
@property (nonatomic, readonly) NSInteger bitrate;

/// Native video framerate (in frames/sec) or zero if unknown or not applicable.
@property (nonatomic, readonly) float framerate;

/// Native video width (in pixels) or zero if unknown or not applicable.
@property (nonatomic, readonly) NSInteger width;

/// Native video height (in pixels) or zero if unknown or not applicable.
@property (nonatomic, readonly) NSInteger height;

#pragma mark - Comparison and equality

/// Returns a comparison value that indicates ordering relative to another instance.
/// @param other Another instance created for the same URL
- (NSComparisonResult)compare:(IVSQuality *)other;

/// Returns a boolean value that indicates whether a given quality is equal to another.
/// @param other Another instance created for the same URL
- (BOOL)isEqualToQuality:(IVSQuality *)other;

@end

NS_ASSUME_NONNULL_END
