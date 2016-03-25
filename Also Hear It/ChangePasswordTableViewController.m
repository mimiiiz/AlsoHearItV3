//
//  ChangePasswordTableViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/15/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "ChangePasswordTableViewController.h"
#import "ASUser.h"
#import <Parse/Parse.h>

@interface ChangePasswordTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation ChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    
}
- (IBAction)sendButtonTapped:(id)sender {
    ASUser *currentUser = [ASUser currentUser];
    if ([self.emailTextField.text isEqualToString:currentUser.email]) {
        [ASUser requestPasswordResetForEmailInBackground:currentUser.email];
        [self alertSending];
    }
    else{
        [self alertError];
    }
}

-(void) alertError {
    UIAlertController* alertBox = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"Email address not match "
                                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alertBox addAction:alertActionOK];
    [self presentViewController:alertBox animated:YES completion:nil];
}
-(void) alertSending{
    UIAlertController* alertBox = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"Reset password link sended via email."
                                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alertBox addAction:alertActionOK];
    [self presentViewController:alertBox animated:YES completion:nil];
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
