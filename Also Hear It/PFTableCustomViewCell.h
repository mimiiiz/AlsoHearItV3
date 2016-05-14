//
//  PFTableCustomViewCell.h
//  Also Hear It
//
//  Created by Thanachaporn on 10/29/2558 BE.
//  Copyright © 2558 Thanachaporn. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface PFTableCustomViewCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageFlag;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
