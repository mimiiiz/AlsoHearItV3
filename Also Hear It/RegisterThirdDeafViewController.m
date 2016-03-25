//
//  RegisterThirdDeafViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/23/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "RegisterThirdDeafViewController.h"
#import "RegisterDataStorage.h"
#import "ASUser.h"

@interface RegisterThirdDeafViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *signLanguageSegmentedControl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewconstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation RegisterThirdDeafViewController{
    RegisterDataStorage *dataStorage;
    NSString *signLanguage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    dataStorage.signLanguage = signLanguage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDataStorageSingleton {
    dataStorage = [RegisterDataStorage getInstance];
}

- (void)setupUI {
    [self setDataField];
    [self.loadingView stopAnimating];
    self.titleLabel.text = @"Did  Language";
    self.bodyLabel.text = @"Did";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToMainPage)
                                                 name:@"callGotoMainPage"
                                               object:nil];
}

- (void)setDataField{
    if ([dataStorage.signLanguage length] == 0) {
        signLanguage = [self getsignLanguageFromIndex:0];
    } else {
        signLanguage = dataStorage.signLanguage;
    }
    self.signLanguageSegmentedControl.selectedSegmentIndex = [self getsignLanguageIndex:signLanguage];
}

- (IBAction)signLanguageChange:(id)sender {
    NSInteger signLanguageSlectedValude = self.signLanguageSegmentedControl.selectedSegmentIndex;
    signLanguage = [self getsignLanguageFromIndex:signLanguageSlectedValude];
}

- (NSString *)getsignLanguageFromIndex:(NSInteger) index{
    if (index == 0) {
        return @"SignLanguage";
    }
    return @"UnSignLanguage";
}

- (NSInteger)getsignLanguageIndex:(NSString *) signLang{
    if ([signLang  isEqual: @"SignLanguage"]) {
        return 0;
    }
    return 1;
}

- (IBAction)signUpButtonTapped:(id)sender {
    [self setAnimationLoading:YES];
    [self signupWithUserCustomClass];
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
    user.type = [NSString stringWithFormat:@"deaf%@", signLanguage];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self setAnimationLoading:NO];
        if (!error) {   // Hooray! Let them use the app now.
            [ASUser logOutInBackground];
            dataStorage = [RegisterDataStorage clearData];
            [self goToMainPage];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
