//
//  TagSelectorTableViewController.h
//  Also Hear It
//
//  Created by Thanachaporn on 1/30/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagMessageDelegate <NSObject>

- (void)addTagMessage:(NSMutableArray *)tag;

@end

@interface TagSelectorTableViewController : UITableViewController

@property (nonatomic, weak) id <TagMessageDelegate> tagDelegate;

-(void)setTags:(NSArray *)tagsData;
-(void)setTagIndex:(NSMutableArray *)indexData;


@end
