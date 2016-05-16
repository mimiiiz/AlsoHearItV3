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
    
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    
    mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    
    [mail setSubject:@"Confirm announcer account"];
    [mail setToRecipients:@[self.user.email]];
    
    [self presentViewController:mail animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
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
