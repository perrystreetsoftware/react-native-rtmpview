//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <AmazonIVSPlayer/IVSBase.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Error domain

/// Domain used by all errors produced by the player.
///
/// At minimum, these errors will have a useful localized failure reason (`localizedFailureReason` property)
/// and description (`localizedDescription` property) as well as a unique error code (`code` property).
/// Other data may be provided in the `userInfo` via the `NSErrorUserInfoKey` constants defined in this library.
IVS_EXPORT NSErrorDomain const IVSPlayerErrorDomain;

#pragma mark - Error user info keys

/// `NSString`, short text describing the component that encountered the error.
IVS_EXPORT NSErrorUserInfoKey const IVSSourceDescriptionErrorKey;

/// `NSString`, short text describing the type of error encountered.
IVS_EXPORT NSErrorUserInfoKey const IVSResultDescriptionErrorKey;

NS_ASSUME_NONNULL_END
