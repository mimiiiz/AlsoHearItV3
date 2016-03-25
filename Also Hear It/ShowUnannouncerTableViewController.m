//
//  ShowUnannouncerTableViewController.m
//  Also Hear It
//
//  Created by fasaiigoof on 2/13/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "ShowUnannouncerTableViewController.h"
#import "UnanouncerDetailViewController.h"
#import <Parse/Parse.h>
#import "ASUser.h"
#import "Channel.h"
#import "UnanouncerIDTableViewCell.h"

@interface ShowUnannouncerTableViewController ()
@end

@implementation ShowUnannouncerTableViewController{
    ASUser *currentUser;
    NSArray *channels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)setUpUI{
    currentUser = [ASUser currentUser];
    UIImage * logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.estimatedRowHeight = 100.0;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:3.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1];
    [self.refreshControl addTarget:self
                            action:@selector(getUnannouncerIDs)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getUnannouncerIDs];
}

- (void) getUnannouncerIDs{
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] init];
    [self createLoadingView:loadingView];
    
    PFQuery *queryUser = [ASUser query];
    [queryUser whereKey:@"type" equalTo:@"unannouncer"];
    [queryUser orderByAscending:@"username"];
    
    PFQuery *queryChannel = [Channel query];
    [queryChannel whereKey:@"announcer" matchesQuery:queryUser];
    [queryChannel includeKey:@"announcer"];
    
    [queryChannel findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channelJoinUser, NSError * _Nullable error) {
        channels = channelJoinUser;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        for (Channel *test in channelJoinUser) {
            NSLog(@"%@", test.name);
        }
        
    }];
}

- (void)createLoadingView:(UIActivityIndicatorView *)loadingView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [view addSubview:loadingView]; // <-- Your UIActivityIndicatorView
    self.tableView.tableHeaderView = view;
    [loadingView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return channels.count;
}

- (IBAction)tabLogOutButton:(id)sender {
    [ASUser logOutInBackground];
    UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewcontroller = [storyborad instantiateInitialViewController];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"unanouncerCell";
    UnanouncerIDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UnanouncerIDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Channel *channel = channels[indexPath.row];
    cell.unannouncerIDText.text = channel.announcer.username;
    cell.channelNameText.text = channel.name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"unanouncerDetail"]) {
        NSIndexPath *index = [self.tableView indexPathForCell:sender];
        UnanouncerDetailViewController *destViewController = segue.destinationViewController;
        destViewController.unanouncerData = channels[index.row];
    }
}

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
