//
//  DeafChannelTableViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/7/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "DeafChannelTableViewController.h"
#import "MapPinViewController.h"
#import <Parse/Parse.h>
#import "Channel.h"
#import "ASUser.h"

@interface DeafChannelTableViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;

@end

@implementation DeafChannelTableViewController {
    NSArray *channels;
    ASUser *currentUser;
    Channel *currentChannel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    self.currentLabel.text = @"Tap locate button to get the nearest channel.";
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        [self setCurrentChannel:geoPoint];
//    }];
}
-(void)setupData {
    
    self.locations = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 50;
    if([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]){
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    currentUser = [ASUser currentUser];
    PFQuery *query = [Channel query];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        channels = [NSArray arrayWithArray:objects];
    }];
}
- (IBAction)assignChannelTap:(id)sender {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [self setCurrentChannel:geoPoint];
    }];
}
- (IBAction)enabledAutoUpdateStateChange:(UISwitch*)sender {
    if (sender.on)
    {
        NSLog(@"start");
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"stop");

        [self.locationManager stopUpdatingLocation];
    }
}

-(void)setCurrentChannel:(PFGeoPoint *)geoPoint{
    //fix location
    //geoPoint = [PFGeoPoint geoPointWithLatitude:13.9133006 longitude:100.5984918];
    currentChannel = [self findNearestChannel:geoPoint];
    
    if(currentChannel != NULL){
        [self assignChannel:currentChannel];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:@[@"admin"] forKey:@"channels"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            self.currentLabel.text = @"Place not found. Please try again";
        }];
        

    }
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:newLocation];
    [self setCurrentChannel:geoPoint];
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive){
        NSLog(@"App is Active. New location is %@", newLocation);
    }else{
        NSLog(@"App is backgrounded. New location is %@", newLocation);
    }
}

-(Channel *)findNearestChannel:(PFGeoPoint *)currentGeopoint{
    double nearestRange = 999;
    Channel *nearestChannel = nil;

    for (Channel *tmp in channels){
        double distance = [currentGeopoint distanceInKilometersTo:tmp.location];
        double radius = [tmp.radius doubleValue]/1000;
        NSLog(@"user latitude %f : longitude %f",currentGeopoint.latitude ,currentGeopoint.longitude);
        NSLog(@"channel latitude %f : longitude %f",tmp.location.latitude ,tmp.location.longitude);
        NSLog(@"Distance from user to %@ channel is %f km",tmp.name ,distance);
        NSLog(@"Channel's radius: %f", radius);
        if (distance <= radius && distance < nearestRange){
            nearestChannel = tmp;
            nearestRange = distance;
        }
    }
    return nearestChannel;
}

- (void)assignChannel:(Channel *)channel{
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSMutableArray *selectedTagsPref = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"TagsPref"]];
    NSMutableArray *Channeltexts = [NSMutableArray array];
    NSCharacterSet *charactersToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"] invertedSet];
    for (NSString *tag in selectedTagsPref) {
        NSString *text = [NSString stringWithFormat:@"%@_%@",channel.name, tag];
        text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        [Channeltexts addObject:text];
    }
    [Channeltexts addObject:@"admin"];
    [currentInstallation setObject:Channeltexts forKey:@"channels"];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.currentLabel.text = currentChannel.name;
    }];
    
    currentUser.channels = Channeltexts;
    [currentUser saveInBackground];
    
    [[NSUserDefaults standardUserDefaults] setObject:channel.objectId forKey:@"currentChannel"];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"mapPinView"]) {
        MapPinViewController *destViewController = segue.destinationViewController;
        destViewController.currentChannel = currentChannel;
    }
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
