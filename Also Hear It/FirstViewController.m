//
//  FirstViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 10/9/2558 BE.
//  Copyright © 2558 Thanachaporn. All rights reserved.
//

#import "FirstViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Channel.h"
#import "RegisterDataStorage.h"


@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIButton *AnnouncerButton;
@property (weak, nonatomic) IBOutlet UIButton *DeafButton;


@end

@implementation FirstViewController {
    RegisterDataStorage *dataStorage;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDataStorageSingleton {
    dataStorage = [RegisterDataStorage getInstance];
}

- (void)setupUI {
    self.AnnouncerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.DeafButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
}

- (IBAction)AnnouncerButtonTapped:(id)sender {
    dataStorage.registerMode = @"announcer";
    [self performSegueWithIdentifier:@"registerFirst" sender:self];
}

- (IBAction)DeafButtonTapped:(id)sender {
    dataStorage.registerMode = @"deaf";
    [self performSegueWithIdentifier:@"registerFirst" sender:self];

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
