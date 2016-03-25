//
//  SelectLocationViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/23/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "SelectLocationViewController.h"
#import "RegisterDataStorage.h"
#import <Parse/Parse.h>

@interface SelectLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveLocationButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation SelectLocationViewController{
    CLGeocoder *geocoder;
    RegisterDataStorage *dataStorage;
    CLLocation *location;
    CLPlacemark *currentPlaceMark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDataStorageSingleton];
    [self setupMapView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDataStorageSingleton {
    dataStorage = [RegisterDataStorage getInstance];
}

- (void)setupMapView {
    self.mapView.delegate = self;
    self.locationLabel.layer.masksToBounds = YES;
    self.locationLabel.layer.cornerRadius = 10;
    
    //chekc if user enable location service
    if (!CLLocationManager.locationServicesEnabled) {
        [self alertWhenLocationOff];
    } else {
        [self getCurrentLocation];
    }
}

- (IBAction)tapCurrentLocation:(id)sender {
    if (!self.locationManager) {
        [self getCurrentLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

// cant test
- (void)getCurrentLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self setUpMapViewRegion:newLocation];
    location = newLocation;
}

- (void)setUpMapViewRegion:(CLLocation*)currentLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = currentLocation.coordinate;
    [self.mapView setRegion:region animated:YES];
}

- (void)alertWhenLocationOff{
    UIAlertController* alertBox = [UIAlertController alertControllerWithTitle:nil
                                                                      message:@"Turn On Location Service to Allow \"Also Hear it\" to Determine Your Location."
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* alertActionSetting = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                               }];
    UIAlertAction* alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alertBox addAction:alertActionSetting];
    [alertBox addAction:alertActionOK];
    [self presentViewController:alertBox animated:YES completion:nil];
}

// call when already moved mapview
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self saveSelectedLocation];
    [self.locationLabel setHidden:NO];
}

// call when start moving mapview
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [self.locationLabel setHidden:YES];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"locationAddreass" sender:self];
}


- (void)saveSelectedLocation {
    double latitude = self.mapView.centerCoordinate.latitude;
    double longitude = self.mapView.centerCoordinate.longitude;
    location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    PFGeoPoint *geolocation = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    dataStorage.location = geolocation;
    [self setLocationText];
}

- (void)setLocationText {
    if(!geocoder){
        geocoder = [[CLGeocoder alloc] init];
    }
    
    //block
    [geocoder reverseGeocodeLocation:location
                completionHandler: ^(NSArray *placemarks, NSError *error) {
                    currentPlaceMark = [placemarks objectAtIndex:0];
                    
                    NSString *placeMarkAddressString = [NSString stringWithFormat:@"%@, %@", currentPlaceMark.locality, currentPlaceMark.administrativeArea];
                    // if some data is null then cut it out
                    placeMarkAddressString = [placeMarkAddressString stringByReplacingOccurrencesOfString:@"(null), "
                                                                                               withString:@""];
                    if ([placeMarkAddressString isEqualToString:@"(null)"]) {
                        placeMarkAddressString = @"Loading..";
                    }
                    self.locationLabel.text = placeMarkAddressString;
                    NSLog(@"place mark at : %@",placeMarkAddressString);
                    dataStorage.locationText = placeMarkAddressString;
                }
     ];
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
