//
//  TagsList.m
//  Also Hear It
//
//  Created by Tun on 2/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "TagsList.h"
#import "Tag.h"

@implementation TagsList
@dynamic tags;

+ (NSNumber *) getPriority:(NSArray *) tagslist{
    NSNumber *priority = 0;
    for (NSDictionary *currentTag in tagslist) {
        if ([currentTag objectForKey:@"priority"] > priority) {
            priority = [currentTag objectForKey:@"priority"];
        }
    }
    return priority;
}

@end
