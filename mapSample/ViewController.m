#import "ViewController.h"

#pragma mark Annotation Class

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

#pragma mark -
#pragma mark ViewController

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;
@property (strong, nonatomic) UIAlertView *alertView;
- (IBAction)locationButton:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    _searchBar.delegate = self;
    _activeIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Map code

- (void)viewDidAppear:(BOOL)animated {
    [self setStartupRegion];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchMapByAddress:searchBar.text];
}

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

#pragma mark Location code

- (IBAction)locationButton:(id)sender {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _location = nil;
    [_locationManager startUpdatingLocation];
    
    _activeIndicator.hidden = NO;
    [self performSelector:@selector(stopLocationManager) withObject:nil afterDelay:3.0];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count > 0) {
        CLLocation *p = locations[0];
        if (!_location || p.altitude < _location.altitude) {
            _location = p;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)stopLocationManager {
    _activeIndicator.hidden = YES;
    [_locationManager stopUpdatingLocation];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *address;
        if (error || !_location){
            NSLog(@"Geocode failed with error: %@", error);
            address = @"この場所はわかりません";
        } else {
            CLPlacemark *p = placemarks[0];
            address = [NSString stringWithFormat:@"%@ %@ %@%@", p.administrativeArea, p.locality, p.thoroughfare, p.subThoroughfare];
        }
        _alertView = [[UIAlertView alloc] initWithTitle:@"現在位置" message:address delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [_alertView show];
    }];
}

@end
