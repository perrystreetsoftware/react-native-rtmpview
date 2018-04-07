//
//  RNRtmpEventManager.m
//
//  Created by Eric Silverberg on 4/7/18.
//  Copyright © 2018 Perry Street Software, Inc. All rights reserved.
//

#import "RNRtmpEventManager.h"

@implementation RNRtmpEventManager

RCT_EXPORT_MODULE();

- (void)startObserving {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    for (NSString *notificationName in [self supportedEvents]) {
        [center addObserver:self
                   selector:@selector(emitEventInternal:)
                       name:notificationName
                     object:nil];
    }
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"RNRtmpEvent"];
}

- (void)emitEventInternal:(NSNotification *)notification {
    [self sendEventWithName:notification.name
                       body:notification.object];
}

@end
