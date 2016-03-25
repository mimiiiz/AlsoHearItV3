//
//  Message.h
//  Also Hear It
//
//  Created by Thanachaporn on 1/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
#import "ASUser.h"

@interface Message : PFObject<PFSubclassing>

@property(strong,nonatomic) NSString *text;
@property(strong,nonatomic) PFRelation *tag;
@property(strong,nonatomic) PFFile *image;
@property(strong,nonatomic) Channel *channel;
@property(strong,nonatomic) PFRelation *receiver;
@property(strong,nonatomic) NSArray *tags;

+ (NSString *)parseClassName;

+ (Class)receiverItemClass;

@end
