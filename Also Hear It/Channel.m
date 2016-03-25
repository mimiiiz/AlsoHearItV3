//
//  Channel.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "Channel.h"
#import <Parse/PFObject+Subclass.h>


@implementation Channel

@dynamic name;
@dynamic announcer;
@dynamic location;
@dynamic radius;
@dynamic placeDescription;
@dynamic URL;
@dynamic channelPic;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Channel";
}
@end
