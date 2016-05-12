//
//  ChannelEditTableViewController.m
//  Also Hear It
//
//  Created by hemaphat techarunangrong on 1/31/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "ChannelEditTableViewController.h"
#import "Channel.h"
//#import "Parse/Parse.h"

@interface ChannelEditTableViewController () <MKMapViewDelegate ,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong , nonatomic) IBOutlet MKMapView *channelMap;
@property (strong, nonatomic) IBOutlet UITextField *channelNameField;
@property (weak, nonatomic) IBOutlet UIButton *imageView;

@property (strong, nonatomic) IBOutlet UITextView *channelDesc;



@end

@implementation ChannelEditTableViewController{
    Channel *channelSet;
    ASUser *currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpData{
    currentUser = [ASUser currentUser];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefault stringForKey:@"announcerChannelId"];
    PFQuery *queryChannel =[PFQuery queryWithClassName:@"Channel"];
    [queryChannel fromLocalDatastore];
    [queryChannel getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error){
        channelSet =(Channel *) object;
        [self setUpUI];
        
    }];
   }
-(void) setUpUI{
    
    //set Pin in map
    CLLocationCoordinate2D pinlocation;
    pinlocation.latitude = channelSet.location.latitude;
    pinlocation.longitude = channelSet.location.longitude;
    MKPointAnnotation *Pin = [[MKPointAnnotation alloc]init];
    Pin.coordinate = pinlocation;

    [self.channelMap addAnnotation:Pin];

    //set MapView
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = channelSet.location.latitude;
    newRegion.center.longitude = channelSet.location.longitude;
    newRegion.span.latitudeDelta = 0.005;
    newRegion.span.longitudeDelta = 0.005;
    [self.channelMap setRegion:newRegion animated:YES];
    
    //set nameTextField and DescriptionField
    self.channelNameField.text=channelSet.name;
    self.channelDesc.text=channelSet.placeDescription;
    
    //set Channel Image
    [self loadImage];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //if annotation is the user location,
    //return nil so map view shows default view for it (blue dot)...
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    static NSString *reuseId = @"annotation";
    MKAnnotationView *pinView = [self.channelMap dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!pinView){
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        [pinView setImage:[UIImage imageNamed:@"Location"]];
        pinView.canShowCallout = YES;
        
        CGPoint centerOfPin = CGPointMake(pinView.centerOffset.x, pinView.centerOffset.y-25);
        [pinView setCenterOffset:centerOfPin];
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

-(void)loadImage{
    PFFile *userImage = [channelSet objectForKey:@"channelPic"];
    [userImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if(!error){
            UIImage *image = [UIImage imageWithData:imageData];
            [self.imageView setImage:image forState:normal];
        }
        else
            NSLog(@"Error");
    }];
    
    
}


-(void)imageUpload{
    // Convert to JPEG with 50% quality
    NSData* data = UIImageJPEGRepresentation([self.imageView imageForState:normal], 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    
    // Save the image to Parse
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The image has now been uploaded to Parse. Associate it with a new object
            [channelSet setObject:imageFile forKey:@"channelPic"];
            
            [channelSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}

- (IBAction)saveBottonTapped:(id)sender {
    [self imageUpload];
    channelSet.name = self.channelNameField.text;
    channelSet.placeDescription = self.channelDesc.text;
    [channelSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            }];
}


- (IBAction)imagePickerTapped:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage] forState:normal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
