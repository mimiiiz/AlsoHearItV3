//
//  RegisterAnnouncerViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterDataStorage.h"

@interface RegisterViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewconstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;


@end

@implementation RegisterViewController {
    RegisterDataStorage* dataStorage;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDataStorageSingleton {
    dataStorage = [RegisterDataStorage getInstance];
}

- (void)setupUI {
    UIImage* logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    
    self.titleLabel.text = @"Hello.";
    self.bodyLabel.text = @"Register account for using the app.";
    
    [self addBottomBorder:self.usernameTextField];
    [self addBottomBorder:self.passwordTextField];
    [self addBottomBorder:self.emailTextField];

    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    
    [self setDataField];
    //[self.usernameTextField becomeFirstResponder];

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

- (void)setDataField{
    self.usernameTextField.text = dataStorage.username;
    self.passwordTextField.text = dataStorage.password;
    self.emailTextField.text = dataStorage.email;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameTextField){
        [self.passwordTextField becomeFirstResponder];
    }else if (textField == self.passwordTextField){
        [self.emailTextField becomeFirstResponder];
    }else if (textField == self.emailTextField){
        [textField resignFirstResponder];
        self.titleLabel.text = @"Done.";
        self.bodyLabel.text = @"Tap next button on the bottom right.";
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == self.usernameTextField){
        self.titleLabel.text = @"Username";
        self.bodyLabel.text = @"At least eight characters long and only contain alphabets and numbers.";
    }else if (textField == self.passwordTextField){
        self.titleLabel.text = @"Password";
        self.bodyLabel.text = @"At least eight characters long.";

    }else if (textField == self.emailTextField){
        self.titleLabel.text = @"Email";
        self.bodyLabel.text = @"Please Double check your email spelling.";

    }
}


- (id)findFirstResponder
{
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

- (IBAction)cancelButtonTapped:(id)sender {
    dataStorage = [RegisterDataStorage clearData];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)nextButtonTapped:(id)sender {
    if ([self correctingInput]) {
        dataStorage.username = self.usernameTextField.text;
        dataStorage.password = self.passwordTextField.text;
        dataStorage.email = self.emailTextField.text;

        [self performSegueWithIdentifier:@"registerSecond" sender:self];
    } else {
        //[self alertMessage];
    }
}
- (BOOL)correctingInput {
    BOOL usernameValid = [self usernameCorrectingInput];
    BOOL passwordValid = [self passwordCorrectingInput];
    BOOL emailValid = [self emailCorrectingInput];
    if (!usernameValid) {
        [self.usernameTextField becomeFirstResponder];
        self.usernameTextField.textColor = [UIColor redColor];

    }if (!passwordValid){
        [self.passwordTextField becomeFirstResponder];
        self.passwordTextField.textColor = [UIColor redColor];

    }if (!emailValid){
        [self.emailTextField becomeFirstResponder];
        self.emailTextField.textColor = [UIColor redColor];

    }
    return usernameValid && passwordValid && emailValid;
}
#pragma Not finish implements

- (BOOL)usernameCorrectingInput {
    NSString *username = self.usernameTextField.text;
    NSString *stringFilter = @"^[A-Z0-9a-z]*$";
    NSPredicate *usernameCheck = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringFilter];
    BOOL returnValue = [usernameCheck evaluateWithObject:username] && [username length] >= 8;
    return returnValue;
}

- (BOOL)passwordCorrectingInput {
    NSString *password = self.passwordTextField.text;
    BOOL returnValue = [password length] >= 8;
    return returnValue;
}

- (BOOL)emailCorrectingInput {
    NSString *email = self.emailTextField.text;
    return [self isValidEmail:email];
}

// Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
- (BOOL) isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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

- (void)alertMessage {
    UIAlertController* alertBox = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"Please check your data again"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alertBox addAction:alertActionOK];
    [self presentViewController:alertBox animated:YES completion:nil];
}

-(void)dismissKeyboard {
    self.titleLabel.text = @"Hello.";
    self.bodyLabel.text = @"Register account for using the app.";
    [self.view endEditing:YES];
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
