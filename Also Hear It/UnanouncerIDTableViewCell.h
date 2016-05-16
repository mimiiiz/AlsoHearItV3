//
//  UnanouncerIDTableViewCell.h
//  Also Hear It
//
//  Created by fasaiigoof on 2/13/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnanouncerIDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateTimeText;
@property (strong, nonatomic) IBOutlet UILabel *unannouncerIDText;
@property (strong, nonatomic) IBOutlet UILabel *channelNameText;
@end
