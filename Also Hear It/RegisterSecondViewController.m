//
//  RegisterSecondViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/20/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "RegisterSecondViewController.h"
#import "RegisterThirdAnnouncerViewController.h"
#import "RegisterDataStorage.h"

@interface RegisterSecondViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewconstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation RegisterSecondViewController{
    RegisterDataStorage *dataStorage;
    NSDate *birthdateForm;
    NSString *gender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:NO];
    dataStorage.firstname = self.firstnameTextField.text;
    dataStorage.lastname = self.lastnameTextField.text;
    dataStorage.birthdate = birthdateForm;
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
    
    [self addBottomBorder:self.firstnameTextField];
    [self addBottomBorder:self.lastnameTextField];
    [self addBottomBorder:self.birthdateTextField];
    [self addBottomBorder:self.genderSegmentedControl];
    
    self.titleLabel.text = @"Second steps";
    self.bodyLabel.text = @"Let we know you a little bit more.";
    
    self.firstnameTextField.delegate = self;
    self.lastnameTextField.delegate = self;
    self.birthdateTextField.delegate = self;
    
    [self setDataField];
    //[self.firstnameTextField becomeFirstResponder];
    [self setUIDatePickerForTextField:self.birthdateTextField];
    
    
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
    birthdateForm = dataStorage.birthdate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.firstnameTextField.text = dataStorage.firstname;
    self.lastnameTextField.text = dataStorage.lastname;
    self.birthdateTextField.text = [dateFormatter stringFromDate:dataStorage.birthdate];
    
    if ([dataStorage.gender length] == 0) {
        gender = [self getGenderFromIndex:0];
    } else {
        gender = dataStorage.gender;
    }
    self.genderSegmentedControl.selectedSegmentIndex = [self getGenderIndex:gender];
}

- (IBAction)genderChange:(id)sender {
    NSInteger gendersSlectedValude = self.genderSegmentedControl.selectedSegmentIndex;
    gender = [self getGenderFromIndex:gendersSlectedValude];
}

- (void)setUIDatePickerForTextField:(UITextField *)textfield {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];
    [textfield setInputView:datePicker];
}

- (void)updateTextField:(UIDatePicker *)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    birthdateForm = sender.date;
    self.birthdateTextField.text = [dateFormatter stringFromDate:sender.date];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (IBAction)nextButtonTapped:(id)sender {
    if ([self correctingInput]) {
        dataStorage.firstname = self.firstnameTextField.text;
        dataStorage.lastname = self.lastnameTextField.text;
        dataStorage.birthdate = birthdateForm;
        dataStorage.gender = gender;
        
        if([dataStorage.registerMode isEqualToString:@"announcer"]){
            [self performSegueWithIdentifier:@"registerThirdA" sender:self];
        }else if([dataStorage.registerMode isEqualToString:@"deaf"]){
            [self performSegueWithIdentifier:@"registerThirdB" sender:self];
            
        }
    }
    
}

- (NSString *)getGenderFromIndex:(NSInteger) index{
    if (index == 0) {
        return @"male";
    }
    return @"female";
}

- (NSInteger)getGenderIndex:(NSString *) sex{
    if ([sex  isEqual: @"male"]) {
        return 0;
    }
    return 1;
}

- (BOOL)correctingInput {
    BOOL firstnameValid = [self isFieldEmpty:self.firstnameTextField.text];
    BOOL lastnameValid = [self isFieldEmpty:self.lastnameTextField.text];
    BOOL birthdateValid = [self isFieldEmpty:self.birthdateTextField.text];
    
    if (!firstnameValid) {
        [self.firstnameTextField becomeFirstResponder];
        self.firstnameTextField.textColor = [UIColor redColor];
    } if (!lastnameValid) {
        [self.lastnameTextField becomeFirstResponder];
        self.lastnameTextField.textColor = [UIColor redColor];

    } if (!birthdateValid) {
        [self.birthdateTextField becomeFirstResponder];
        self.birthdateTextField.textColor = [UIColor redColor];

    }
    return firstnameValid && lastnameValid && birthdateValid;
    
}

- (BOOL)isFieldEmpty:(NSString*) input {
    BOOL returnValue = [input length] != 0;
    return returnValue;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.firstnameTextField){
        [self.lastnameTextField becomeFirstResponder];
    }else if (textField == self.lastnameTextField){
        [self.birthdateTextField becomeFirstResponder];
    }else if (textField == self.birthdateTextField){
        self.titleLabel.text = @"Second steps";
        self.bodyLabel.text = @"Let we know you a little bit more";
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == self.firstnameTextField){
        self.titleLabel.text = @"Firstname";
        self.bodyLabel.text = @"Prefer English but other is fine.";
    }else if (textField == self.lastnameTextField){
        self.titleLabel.text = @"Lastname";
        self.bodyLabel.text = @"Prefer English but other is fine.";
        
    }else if (textField == self.birthdateTextField){
        self.titleLabel.text = @"Birthday";
        self.bodyLabel.text = @"Select year in BE.";
        
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
    self.titleLabel.text = @"Second steps";
    self.bodyLabel.text = @"Let we know you a little bit more";
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

