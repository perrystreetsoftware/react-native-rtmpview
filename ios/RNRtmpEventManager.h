//
//  RNRtmpEventManager.h
//
//  Created by Eric Silverberg on 4/7/18.
//  Copyright © 2018 Perry Street Software, Inc. All rights reserved.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#endif

@interface RNRtmpEventManager : RCTEventEmitter <RCTBridgeModule>

@end
