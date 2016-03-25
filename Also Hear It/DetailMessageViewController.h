//
//  DetailMessageViewController.h
//  Also Hear It
//
//  Created by Thanachaporn on 2/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface DetailMessageViewController : UIViewController

@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) NSString *tagText;

@end
