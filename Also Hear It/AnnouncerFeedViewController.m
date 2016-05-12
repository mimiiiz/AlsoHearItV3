//
//  AnnouncerFeedViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/5/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "AnnouncerFeedViewController.h"
#import "PFTableCustomViewCell.h"
#import "DetailMessageViewController.h"

#import <math.h>
#import "ASUser.h"
#import "Message.h"
#import "Channel.h"
#import "TagsList.h"

@interface AnnouncerFeedViewController ()

@end

@implementation AnnouncerFeedViewController{
    ASUser *currentUser;
    Channel *announcerChannel;
    NSString *cellTagText;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        self.parseClassName = @"Message";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage* logoImage = [UIImage imageNamed:@"WhiteBarLogo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery
}


 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
     currentUser = [ASUser currentUser];
     PFQuery *query = [Message query];
     PFQuery *queryChannel =[PFQuery queryWithClassName:@"Channel"];
     [queryChannel fromLocalDatastore];
     [queryChannel whereKey:@"objectId" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"announcerChannelId"]];
     [query whereKey:@"channel" matchesQuery:queryChannel];
     [query includeKey:@"channel"];
/*
//    If Pull To Refresh is enabled, query against the network by default.
     if (self.pullToRefreshEnabled) {
         query.cachePolicy = kPFCachePolicyNetworkOnly;
     }
//      If no objects are loaded in memory, we look to the cache first to fill the table
//      and then subsequently do a query against the network.
     if (self.objects.count == 0) {
         query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     }
*/
     [query orderByDescending:@"createdAt"];

     return query;
}



 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
 // and the imageView being the imageKey in the object.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(Message *)object {
     static NSString *CellIdentifier = @"myCell";
 
     PFTableCustomViewCell *cell = (PFTableCustomViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         cell = [[PFTableCustomViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
     
    // Configure the cell
     cell.nameLabel.text = object.channel.name;
     cell.messageLabel.text = object.text;
     
     NSNumber *priority = [TagsList getPriority:object.tags];
     NSString *priorityFlagName = [NSString stringWithFormat:@"bookmark-%@", priority];
     cell.imageFlag.image = [UIImage imageNamed:priorityFlagName];
     cell.tagLabel.text = [self getTags:object.tags];
     
     cell.profilePic.image = [UIImage imageNamed:@"Profile.png"];
     PFFile *imageFile = object.channel.channelPic;
     [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
         cell.profilePic.image = [UIImage imageWithData:data];
     }];
     
      cell.timeLabel.text = [self getTime:object.createdAt];
     return cell;
 }

-(NSString *)getTime:(NSDate *)date {
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    NSUInteger day = (NSUInteger)(timeSinceDate / (timeSinceDate /  60.0 * 60.0));

    // print up to 24 hours as a relative offset
    if(timeSinceDate < 24.0 * 60.0 * 60.0){
        NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
        NSUInteger secsSinceDate = (NSUInteger) fmod(timeSinceDate,(24.0 * 60.0 * 60.0));
        switch(hoursSinceDate){
            default:{
                return [NSString stringWithFormat:@"%lu hours ago", (unsigned long)hoursSinceDate];
            }case 1:{
                return @"1 hour ago";
            }case 0: {
                NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / 60.0);
                if(minutesSinceDate <= 0){
                    return [NSString stringWithFormat:@"%lu secs ago",(unsigned long)secsSinceDate];
                }else {
                    return [NSString stringWithFormat:@"%lu mins ago",(unsigned long)minutesSinceDate];
                }
            }
        }
    }if(day > 0){
        return [NSString stringWithFormat:@"%lu days ago",(unsigned long)day];
    }if(day > 7){
        return [NSString stringWithFormat:@"%lu weeks ago",(unsigned long)day/7];
    }
    
    return @"";
}
 
- (NSString *)getTags:(NSArray *)tags{
    NSString *tagtext= @"";
    for (NSDictionary *tag in tags) {
        if ([tagtext isEqualToString:@""]) {
            tagtext = [tagtext stringByAppendingString:[tag objectForKey:@"name"]];
        }else{
            tagtext = [tagtext stringByAppendingString:@", "];
            tagtext = [tagtext stringByAppendingString:[tag objectForKey:@"name"]];
        }
    }
    return tagtext;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Detail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFTableCustomViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        cellTagText = selectedCell.tagLabel.text;
        DetailMessageViewController *destViewController = segue.destinationViewController;
        destViewController.message = [self.objects objectAtIndex:indexPath.row];
        destViewController.tagText = cellTagText;

    }
}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
*/

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDataSource

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
 // Delete the object from Parse and reload the table view
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, and save it to Parse
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];

}

@end