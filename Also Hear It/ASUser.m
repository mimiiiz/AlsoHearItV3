//
//  ASUser.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/21/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "ASUser.h"

@implementation ASUser

@dynamic firstname;
@dynamic lastname;
@dynamic gender;
@dynamic birthdate;
@dynamic type;
@dynamic channels;


+(ASUser *)currentUser {
    return (ASUser *)[PFUser currentUser];
}

+ (void)load {
    [self registerSubclass];
}

@end
