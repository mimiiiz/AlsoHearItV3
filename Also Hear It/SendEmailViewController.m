//
//  SendEmailViewController.m
//  Also Hear It
//
//  Created by fasaiigoof on 2/14/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "SendEmailViewController.h"
#import <MessageUI/MessageUI.h>
@interface SendEmailViewController () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation SendEmailViewController{
    MFMailComposeViewController *mail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpUI{
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstname, self.user.lastname];
    [self.loadingView stopAnimating];
    
    [self addBottomBorder:self.subjectTextField];
    [self addBottomBorder:self.messageTextView];
    
    mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
}

- (IBAction)tapSendEmail:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        [self setAnimationLoading:YES];
    
        [mail setSubject:self.subjectTextField.text];
        [mail setToRecipients:@[self.user.email]];
        [mail setMessageBody:self.messageTextView.text isHTML:NO];

        [self presentViewController:mail animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self setAnimationLoading:NO];
    if (!error) {
        NSLog(@"mail sended");
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        NSLog(@"%@", error);
    }
}

- (void) setAnimationLoading:(BOOL) setting{
    if (setting) {
        [self.loadingView startAnimating];
        self.loadingView.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor];
        self.loadingView.frame = self.view.bounds;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
    } else {
        if ([self.loadingView isAnimating]) {
            [self.loadingView stopAnimating];
        }
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    }
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
