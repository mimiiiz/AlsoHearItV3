//
//  Message.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "Message.h"
#import <Parse/PFObject+Subclass.h>

@implementation Message

@dynamic text;
@dynamic tag;
@dynamic image;
@dynamic channel;
@dynamic receiver;
@dynamic tags;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Message";
}

+ (Class )receiverItemClass {
    return [ASUser class];
}

@end
