//
//  LoginViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 10/9/2558 BE.
//  Copyright © 2558 Thanachaporn. All rights reserved.
//
#import <Parse/Parse.h>

#import "LoginViewController.h"

#import "ASUser.h"
#import "Channel.h"
#import "Tag.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewconstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    UIImage* logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    //[self addUpperBorder:self.bottomView];
    [self addBottomBorder:self.usernameTextField];
    [self addBottomBorder:self.passwordTextField];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.loadingActivity stopAnimating];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (IBAction)LogInButtonTapped:(id)sender {
    if ([self.usernameTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
        NSString *message = @"Please type your username and password";
        self.errorLabel.text = message;
    }
    else{
        [self setAnimationLoading:YES];
        [ASUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                        [self setAnimationLoading:NO];
                                        if (user) {
                                            // Do stuff after successful login.
                                            ASUser *currentUser = [ASUser currentUser];
                                            if (currentUser) {
                                                if ([currentUser.type isEqualToString:@"announcer"]) {
                                                    [self goingAnnouncerView];
                                                } else if ([currentUser.type isEqualToString:@"deaf"]) {
                                                    [self goingDeafView];
                                                } else if ([currentUser.type isEqualToString:@"admin"]){
                                                    [self goingAdminView];
                                                } else {
                                                    [ASUser logOutInBackground];
                                                    NSString *message = @"This account may not be confirmed yet";
                                                    self.errorLabel.text = message;
                                                }
                                            }
                                        } else {
                                            NSString *message = @"Invalid username or password";
                                            self.errorLabel.text = message;
                                        }
                                    }];}
}

- (void) goingAnnouncerView {
    [self getDatachannel];
    [self getAllTag];
    UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Announcer" bundle:nil];
    UIViewController* viewcontroller = [storyborad instantiateInitialViewController];
    [self setAnimationLoading:NO];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}

-(void) goingDeafView {
    [self getAllDataChannel];
    [self getAllTag];
    UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Deaf" bundle:nil];
    UIViewController* viewcontroller = [storyborad instantiateInitialViewController];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}

-(void) goingAdminView {
    UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Admin" bundle:nil];
    UIViewController* viewcontroller = [storyborad instantiateInitialViewController];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}

- (void)getDatachannel {
    PFQuery *query = [Channel query];
    [query whereKey:@"announcer" equalTo:[ASUser currentUser]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    Channel *channel =  [query getFirstObject];
    [channel pin];
    [userDefaults setObject:channel.objectId forKey:@"announcerChannelId"];
    
}

-(void)getAllDataChannel {
    PFQuery *query = [Channel query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
       if(!error)
           [Channel pinAllInBackground:objects];
    }];
}

- (void)getAllTag {
    PFQuery *query = [Tag query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [Tag pinAllInBackground:objects];
            [self setSelectedTags:objects];
        }
    }];
}
-(void)setSelectedTags:(NSArray *)tags {
    
    NSMutableArray *selectedTagsPref = [tags valueForKeyPath:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:selectedTagsPref forKey:@"TagsPref"];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameTextField){
        [self.passwordTextField becomeFirstResponder];
    }else if (textField == self.passwordTextField)
        [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)keyboardDidShow:(NSNotification*)notification {
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    self.bottomViewconstraint.constant = height;
    [self.view layoutIfNeeded];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    self.bottomViewconstraint.constant = 0.0;
    [self.view layoutIfNeeded];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void) setAnimationLoading:(BOOL) setting{
    if (setting) {
        [self.loadingActivity startAnimating];
        self.loadingActivity.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor];
        self.loadingActivity.frame = self.view.bounds;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
    } else {
        if ([self.loadingActivity isAnimating]) {
            [self.loadingActivity stopAnimating];
        }
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    }
}

@end
