//
//  ASUser.h
//  Also Hear It
//
//  Created by Thanachaporn on 1/21/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <Parse/Parse.h>

@interface ASUser : PFUser<PFSubclassing>

@property(strong,nonatomic) NSString *type;
@property(strong,nonatomic) NSString *firstname;
@property(strong,nonatomic) NSString *lastname;
@property(strong,nonatomic) NSString *gender;
@property(strong,nonatomic) NSDate *birthdate;
@property(strong,nonatomic) NSArray *channels;

+(ASUser *)currentUser;

@end
