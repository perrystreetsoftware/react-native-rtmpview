//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AmazonIVSPlayer/IVSCue.h>

NS_ASSUME_NONNULL_BEGIN

IVS_EXPORT IVSCueType const IVSCueTypeTextMetadata;

/// Plaintext timed metdatada cue.
IVS_EXPORT
@interface IVSTextMetadataCue : IVSCue

/// Returns `IVSCueTypeTextMetadata`.
@property (nonatomic, readonly) IVSCueType type;

/// Text content of the cue.
@property (nonatomic, readonly) NSString *text;

/// Description of the text content.
@property (nonatomic, readonly) NSString *textDescription;

@end

NS_ASSUME_NONNULL_END
