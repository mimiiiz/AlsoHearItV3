//
//  RegisterDataStorage.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "RegisterDataStorage.h"

@implementation RegisterDataStorage

static RegisterDataStorage *dataSingleton;

@synthesize registerMode;

@synthesize username;
@synthesize password;
@synthesize email;

@synthesize firstname;
@synthesize lastname;
@synthesize birthdate;
@synthesize gender;

@synthesize placename;
@synthesize location;
@synthesize locationText;

@synthesize signLanguage;



+ (id)getInstance {
    if (dataSingleton == nil) {
        dataSingleton = [[super alloc] init];
    }
    return dataSingleton;
}

+ (id) clearData {
    dataSingleton.username = nil;
    dataSingleton.password = nil;
    dataSingleton.email = nil;
    
    dataSingleton.firstname = nil;
    dataSingleton.lastname = nil;
    dataSingleton.birthdate = nil;
    dataSingleton.gender = nil;
    
    dataSingleton.placename = nil;
    dataSingleton.location = nil;
    dataSingleton.locationText = nil;
    
    dataSingleton.signLanguage = nil;
    
    return dataSingleton;
}


@end
