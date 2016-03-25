//
//  Tag.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/4/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "Tag.h"
#import <Parse/PFObject+Subclass.h>

@implementation Tag
@dynamic name;
@dynamic priority;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Tag";
}

@end
