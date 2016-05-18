//
//  MapPinViewController.m
//  Also Hear It
//
//  Created by fasaiigoof on 2/12/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "MapPinViewController.h"
#import <Parse/Parse.h>

@interface MapPinViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation MapPinViewController{
    NSArray *channels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupData {
    PFQuery *query = [Channel query];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        channels = [NSArray arrayWithArray:objects];
        [self addPinFromChannels];
    }];
    [self setupUI];

}

- (void)setupUI{
    self.mapView.delegate = self;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        if(!error){
            CLLocationCoordinate2D currentUserlocation;
            currentUserlocation.latitude = geoPoint.latitude;
            currentUserlocation.longitude = geoPoint.longitude;
            [self goToLocation:currentUserlocation];
        }

    }];
    

    
    
}


- (void)goToLocation:(CLLocationCoordinate2D )location{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.025;
    span.longitudeDelta = 0.025;
    region.span = span;
    region.center = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [self.mapView setRegion:region animated:YES];
}

- (void)addPinFromChannels{
    for (Channel *tmp in channels){
        if (self.currentChannel == tmp) {
            [self addPintoMap:tmp.location :tmp.name :YES];
        } else {
            [self addPintoMap:tmp.location :tmp.name :NO];
        }
    }
}

- (void)addPintoMap:(PFGeoPoint *)pinPoint :(NSString *)channelName :(BOOL)isCurrentChannel{
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setCoordinate:CLLocationCoordinate2DMake(pinPoint.latitude, pinPoint.longitude)];
    [pin setTitle:channelName];
    if (isCurrentChannel) {
        [pin setSubtitle:@"current location"];
    }
    [self.mapView addAnnotation:pin];
    if (isCurrentChannel) {
        [self.mapView selectAnnotation:pin animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //if annotation is the user location,
    //return nil so map view shows default view for it (blue dot)...
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    static NSString *reuseId = @"annotation";
    MKAnnotationView *pinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!pinView){
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        if ([annotation.subtitle isEqualToString:@"current location"]) {
            [pinView setImage:[UIImage imageNamed:@"Location"]];
        } else {
            [pinView setImage:[UIImage imageNamed:@"locationMarkRed"]];
        }
        pinView.canShowCallout = YES;
        
        CGPoint centerOfPin = CGPointMake(pinView.centerOffset.x, pinView.centerOffset.y-25);
        [pinView setCenterOffset:centerOfPin];
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView;
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
