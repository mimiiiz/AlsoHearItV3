//
//  Tag.h
//  Also Hear It
//
//  Created by Thanachaporn on 2/4/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Parse/Parse.h>

@interface Tag : PFObject<PFSubclassing>

@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSNumber *priority;


+ (NSString *)parseClassName;

@end
