//
//  ForgetPasswordViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/13/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//
#import <Parse/Parse.h>
#import "ForgetPasswordViewController.h"
#import "ASUser.h"

@interface ForgetPasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupUI {
    
    UIImage* logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    
    [self addBottomBorder:self.emailTextField];
    self.emailTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}
- (IBAction)sendButtonTapped:(id)sender {
    ASUser *currentUser = [ASUser currentUser];
    if ([self.emailTextField.text isEqualToString:currentUser.email]) {
        [ASUser requestPasswordResetForEmailInBackground:currentUser.email];
    }
    else{
        self.errorLabel.text = @"Invalid email address.";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.emailTextField){
        [self.emailTextField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
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
