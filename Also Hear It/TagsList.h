//
//  TagsList.h
//  Also Hear It
//
//  Created by Tun on 2/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsList : NSObject
@property (strong,nonatomic) NSArray *tags;

+ (NSNumber *) getPriority:(NSArray *) tagslist;

@end
