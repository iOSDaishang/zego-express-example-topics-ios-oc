//
//  ZGKeyCenter.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/11.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGKeyCenter.h"

@implementation ZGKeyCenter

// Apply AppID and AppSign from Zego
+ (unsigned int)appID {
// for example:
//     return 1234567890;
    return 928464678;
}

// Apply AppID and AppSign from Zego
+ (NSString *)appSign {
// for example:
//     return @"abcdefghijklmnopqrstuvwzyv123456789abcdefghijklmnopqrstuvwzyz123";
    return @"2a485d1d1fe964eb7255d3c65ab1131fc8ad374a12231a1c7566827912096770";
}

@end
