//
//  AnnouncerSettingTableViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/26/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "AnnouncerSettingTableViewController.h"
#import "ASUser.h"
#import "Channel.h"
#import "Tag.h"

@interface AnnouncerSettingTableViewController () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *LogOutCell;

@end

@implementation AnnouncerSettingTableViewController{
    Channel* announcerChannel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) getChannelObject {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefault stringForKey:@"announcerChannelId"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Channel"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error){
        announcerChannel = (Channel *)object;

    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.LogOutCell) {
        [self announcerLogout];
        
    }
}

- (void)announcerLogout {
    [Channel unpinAllObjectsInBackground];
    [Tag unpinAllObjectsInBackground];
    [ASUser logOutInBackground];
    UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewcontroller = [storyborad instantiateInitialViewController];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}



#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/
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
