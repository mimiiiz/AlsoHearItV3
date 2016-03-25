//
//  RegisterDataStorage.h
//  Also Hear It
//
//  Created by Thanachaporn on 1/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface RegisterDataStorage : NSObject
{
    NSString *registerMode;
    
    NSString *username;
    NSString *password;
    NSString *email;
    
    NSString *firstname;
    NSString *lastname;
    NSDate *birthdate;
    NSString *gender;
    
    NSString *placename;
    PFGeoPoint *location;
    NSString *locationText;
    
    NSString *signLanguage;
    

}

@property (nonatomic) NSString *registerMode;

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *email;

@property (nonatomic) NSString *firstname;
@property (nonatomic) NSString *lastname;
@property (nonatomic) NSDate *birthdate;
@property (nonatomic) NSString *gender;

@property (nonatomic) NSString *placename;
@property (nonatomic) PFGeoPoint *location;
@property (nonatomic) NSString *locationText;

@property (nonatomic) NSString *signLanguage;




+ (id)getInstance;
+ (id)clearData;

@end
