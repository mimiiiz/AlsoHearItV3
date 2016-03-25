//
//  UnanouncerDetailViewController.m
//  Also Hear It
//
//  Created by fasaiigoof on 2/14/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "UnanouncerDetailViewController.h"
#import "SendEmailViewController.h"
#import "ASUser.h"
#import <Parse/Parse.h>

@interface UnanouncerDetailViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *locationMapViewLabel;

@property (strong, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *loactionLabel;

@property (strong, nonatomic) IBOutlet UITextField *radiusText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation UnanouncerDetailViewController{
    ASUser *currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpUI{
    currentUser = [ASUser currentUser];
    
    self.title = self.unanouncerData.announcer.username;
    
    [self addBottomBorder:self.topView];
    [self addBottomBorder:self.middleView];
    [self addBottomBorder:self.bottomView];

    self.mapView.delegate = self;
    [self setLocation];
    self.locationMapViewLabel.text = @"Loading...";
    
    self.channelNameLabel.text = self.unanouncerData.name;
    self.channelNameLabel.layer.masksToBounds = YES;
    self.channelNameLabel.layer.cornerRadius = 10.0;
    
    [self setLocationText:self.loactionLabel :self.unanouncerData.location.latitude:self.unanouncerData.location.longitude];
    
    [self.loadingView stopAnimating];
}

- (void)setLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = CLLocationCoordinate2DMake(self.unanouncerData.location.latitude, self.unanouncerData.location.longitude);
    [self.mapView setRegion:region animated:YES];
    
}

- (void)setLocationText:(UILabel *)textField :(double) latitude : (double) longtitude{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    
    [geocoder reverseGeocodeLocation:location
                   completionHandler: ^(NSArray *placemarks, NSError *error) {
                       CLPlacemark *currentPlaceMark = [placemarks objectAtIndex:0];
                       
                       NSString *placeMarkAddressString = [NSString stringWithFormat:@"%@, %@", currentPlaceMark.locality, currentPlaceMark.administrativeArea];
                       // if some data is null then cut it out
                       placeMarkAddressString = [placeMarkAddressString stringByReplacingOccurrencesOfString:@"(null), "
                                                                                                  withString:@""];
                       textField.text = placeMarkAddressString;
                   }
     ];
}

// call when already moved mapview
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self.locationMapViewLabel setHidden:NO];
    [self setLocationText:self.locationMapViewLabel :self.mapView.centerCoordinate.latitude :self.mapView.centerCoordinate.longitude];
}

// call when start moving mapview
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [self.locationMapViewLabel setHidden:YES];
}

- (IBAction)tapConfirmButton:(id)sender {
    [self setAnimationLoading:YES];
    
    // prepare new data for channel
    PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    NSNumberFormatter *convertToNum = [[NSNumberFormatter alloc] init];
    convertToNum.numberStyle = NSNumberFormatterDecimalStyle;
    // set up new data for channel
    self.unanouncerData.radius = [convertToNum numberFromString:self.radiusText.text];
    self.unanouncerData.location = newLocation;
    // save
    [self.unanouncerData saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {}];
    
    // call clound function to change unannouncer to announcer
    [PFCloud callFunctionInBackground:@"setUserToAnnouncer" withParameters:@{@"type" : currentUser.type, @"objectId" : self.unanouncerData.announcer.objectId} block:^(id object, NSError *error) {
        [self setAnimationLoading:NO];
        [self.navigationController popViewControllerAnimated:NO];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sendEmailToUnanouncer"]) {
        SendEmailViewController *destViewController = segue.destinationViewController;
        destViewController.user = self.unanouncerData.announcer;
    }
}


- (void)addBottomBorder:(UIView *)view {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    bottomBorder.frame = CGRectMake(0, view.frame.size.height-1, CGRectGetWidth(view.frame), 1.0f);
    [view.layer addSublayer:bottomBorder];
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
