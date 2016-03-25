//
//  Channel.h
//  Also Hear It
//
//  Created by Thanachaporn on 1/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ASUser.h"

@interface Channel : PFObject<PFSubclassing>

@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) ASUser *announcer;
@property(strong,nonatomic) PFGeoPoint *location;
@property(strong,nonatomic) NSNumber *radius;
@property(strong,nonatomic) NSString *placeDescription;
@property(strong,nonatomic) NSString *URL;
@property(strong,nonatomic) PFFile *channelPic;


+ (NSString *)parseClassName;

@end
