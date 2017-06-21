//
//  RegisterThirdAnnouncerViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "RegisterThirdAnnouncerViewController.h"
#import "ASUser.h"
#import "Channel.h"
#import "RegisterDataStorage.h"

@interface RegisterThirdAnnouncerViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *placenameTextField;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewconstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation RegisterThirdAnnouncerViewController{
    RegisterDataStorage *dataStorage;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setUpDataStorageSingleton {
    dataStorage = [RegisterDataStorage getInstance];
    
}

- (void)setupUI {
    UIImage* logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    
    [self addBottomBorder:self.placenameTextField];
    [self addBottomBorder:self.locationTextField];
    
    self.titleLabel.text = @"Place's information";
    self.bodyLabel.text = @"Receiver will know you from this.";
    
    self.placenameTextField.delegate = self;
    self.locationTextField.delegate = self;
    [self.loadingView stopAnimating];
    
    [self setDataField];
    //[self.placenameTextField becomeFirstResponder];
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapOutside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)setDataField{
    self.locationTextField.text = dataStorage.locationText;
    self.placenameTextField.text = dataStorage.placename;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:NO];
    dataStorage.placename = self.placenameTextField.text;
    dataStorage.locationText = self.locationTextField.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.placenameTextField){
        [self.locationTextField becomeFirstResponder];
    }else if (textField == self.locationTextField){
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == self.placenameTextField){
        self.titleLabel.text = @"Place name.";
        self.bodyLabel.text = @"Check your spelling correctly.";
    }else if (textField == self.locationTextField){
        self.titleLabel.text = @"Your location place";
        self.bodyLabel.text = @"Pin your location place.";
        [self performSegueWithIdentifier:@"mapView" sender:self];

    }
}


- (id)findFirstResponder{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
    }
    return nil;
}

//start sign up
- (IBAction)signUpButtonTapped:(id)sender {
    [self setAnimationLoading:YES];
    if([self correctingInput]){
        [self signupWithUserCustomClass];
    } else {
        [self setAnimationLoading:NO];
        [self alertMessage];
    }
}

- (BOOL)correctingInput {
    BOOL placenameValid = [self isFieldEmpty:self.placenameTextField.text];
    BOOL placelocationValid = [self isFieldEmpty:self.locationTextField.text];
    
    if (placenameValid) {
        self.placenameTextField.textColor = [UIColor redColor];
    }
    if(placelocationValid){
        self.locationTextField.textColor = [UIColor redColor];
    }
        return !placenameValid && !placelocationValid  ;
    
}

- (BOOL)isFieldEmpty:(NSString*) input {
    BOOL returnValue = [input length] == 0;
    return returnValue;
}

- (void)signupWithUserCustomClass {
    ASUser *user = [ASUser user];
    user.username = dataStorage.username;
    user.password = dataStorage.password;
    user.email = dataStorage.email;
    
    // other fields can be set just like with PFObject
    user.firstname = dataStorage.firstname;
    user.lastname = dataStorage.lastname;
    user.birthdate = dataStorage.birthdate;
    user.gender = dataStorage.gender;
    user.type = @"announcer";
    
    Channel *channel = [Channel object];
    channel.name = self.placenameTextField.text;
    channel.location = dataStorage.location;
    channel.radius = [NSNumber numberWithDouble:1000.00];
    
    channel.announcer = user;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //stop loading animation
        [self setAnimationLoading:NO];
        if (!error) {   // Hooray! Let them use the app now.
            [channel saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [ASUser logOutInBackground];
                dataStorage = [RegisterDataStorage clearData];
                [self goToMainPage];
            }];
        } else {
            //NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user
        }
    }];
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

- (void) goToMainPage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertMessage {
    UIAlertController* alertBox = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"Please check your data again"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alertBox addAction:alertActionOK];
    [self presentViewController:alertBox animated:YES completion:nil];
}

- (void)addBottomBorder:(UIView *)view {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    bottomBorder.frame = CGRectMake(0, view.frame.size.height-1, CGRectGetWidth(view.frame), 0.5f);
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

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"location : %@", dataStorage.locationText);
    self.locationTextField.text = dataStorage.locationText;
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

