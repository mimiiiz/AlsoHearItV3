//
//  DetailMessageViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "DetailMessageViewController.h"
#import "TagsList.h"

@interface DetailMessageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *priorityFlag;

@end

@implementation DetailMessageViewController {
    
    CGSize viewSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
    // Do any additional setup after loading the view.
}
- (IBAction)actionButtonTapped:(id)sender {
    NSArray *activityItemsArray = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@\r%@",self.message.channel.name, self.message.text]];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItemsArray applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypeAirDrop,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    viewSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated{
    [self.scrollView setContentSize:viewSize];
}

-(void)setupData {
    PFFile *imageFile = self.message.channel.channelPic;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];
}

- (void)setupUI {
    [self.scrollView setContentSize:self.view.bounds.size];
    
    self.nameLabel.text = self.message.channel.name;
    self.textLabel.text = self.message.text;
    self.tagLabel.text = self.tagText;
    
    NSDate *date = self.message.createdAt;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *timeText = [dateFormatter stringFromDate:date];
    self.timeLabel.text = timeText;
    
    NSNumber *priority = [TagsList getPriority:self.message.tags];
    NSString *priorityFlagName = [NSString stringWithFormat:@"bookmark-%@", priority];
    self.priorityFlag.image = [UIImage imageNamed:priorityFlagName];
    
    [self addUpperBorder:self.bottomView];
}

- (void)addUpperBorder:(UIView *)view {
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0,CGRectGetWidth(view.frame), 1.0f);
    [view.layer addSublayer:upperBorder];
}

- (void)addBottomBorder:(UIView *)view {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    bottomBorder.frame = CGRectMake(0, view.frame.size.height-1, CGRectGetWidth(view.frame), 1.0f);
    [view.layer addSublayer:bottomBorder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
