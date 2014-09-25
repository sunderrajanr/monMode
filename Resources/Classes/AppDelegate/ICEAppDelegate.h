//
//  ICEAppDelegate.h
//  monMode
//
//  Created by Muthu Sabari on 5/28/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICELoginViewController.h"
#import "ICEViewController.h"
#import "ICEParentViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ICEAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
    
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_LatitudeCity;
    NSString *str_LatitudeState;
    NSString *str_LatitudeZipCode;
    NSString *str_LatitudeCountry;
    
    NSString *str_APIKey;
    NSTimer *mainTimer;
    NSMutableArray *mutArr_City;
    NSMutableArray *mutArr_High;
    NSMutableArray *mutArr_Low;
    NSMutableArray *mutArr_ForeCastDate;
    NSMutableArray *conditionarray;
    NSString *str_Condition;
    NSString *str_TempFaren;
    
    BOOL isSameTime;
    int countGeoCode;
    int countnew;
    int count;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICEViewController *iceViewController;
@property (strong, nonatomic) ICELoginViewController *iceLoginObject;
@property (strong, nonatomic) ICEParentViewController *obj_ParentVC;
@end
