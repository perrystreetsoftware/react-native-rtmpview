//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AmazonIVSPlayer/IVSBase.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *IVSCueType NS_TYPED_ENUM NS_SWIFT_NAME(IVSCue.CueType);

/// Abstract base class for timed cues.
/// @see `-[IVSPlayerDelegate player:didOutputCue:]`
IVS_EXPORT
@interface IVSCue : NSObject

IVS_INIT_UNAVAILABLE()

/// Type of cue.
@property (nonatomic, readonly) IVSCueType type;

/// Start time of the cue.
@property (nonatomic, readonly) CMTime startTime;

/// End time of the cue.
@property (nonatomic, readonly) CMTime endTime;

@end

NS_ASSUME_NONNULL_END
