//
//  ViewController.m
//  mapSample
//
//  Created by Yuumi Yoshida on 2012/11/05.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import "ViewController.h"

@interface SimpleAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
- (SimpleAnnotation *) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;
@end

@implementation SimpleAnnotation
- (SimpleAnnotation *) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}
@end



@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)locationButton:(id)sender;

@end

@implementation ViewController

- (void)setStartupRegion {
	MKCoordinateRegion region;
	region.center.latitude = 35.688323;
	region.center.longitude = 139.754389;
	region.span.latitudeDelta  = 16.0;
	region.span.longitudeDelta = 16.0;
    _mapView.region = region;    
}

- (void)searchMapByAddress:(NSString *)address {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [_mapView removeAnnotations:_mapView.annotations];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Not found %@", error);
            [self setStartupRegion];
        } else {
            CLLocation *location = ((CLPlacemark *)placemarks[0]).location;
            MKCoordinateRegion region;
            region.center.latitude     = location.coordinate.latitude;
            region.center.longitude    = location.coordinate.longitude;
            region.span.latitudeDelta  = 0.02;
            region.span.longitudeDelta = 0.02;
            
            SimpleAnnotation *anno = [[SimpleAnnotation alloc] initWithCoordinate:region.center title:address];
            [_mapView addAnnotation:anno];
            _mapView.region = region;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    _searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setStartupRegion];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"--searchBarShouldEndEditing");
    [searchBar resignFirstResponder];
    [self performSelector:@selector(searchMapByAddress:) withObject:searchBar.text afterDelay:0.2];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)locationButton:(id)sender {
}

@end
