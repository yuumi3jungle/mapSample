//
//  ViewController.h
//  mapSample
//
//  Created by Yuumi Yoshida on 2012/11/05.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>

@end
