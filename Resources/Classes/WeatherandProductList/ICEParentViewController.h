//
//  ICEParentViewController.h
//  monMode
//
//  Created by Sunderrajan Ranganathan on 28/07/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ICEWeatherandProductListViewController.h"
#import "Reachability.h"
@interface ICEParentViewController : UIViewController<CLLocationManagerDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,UIScrollViewDelegate,SampleProtocolDelegate>

@property (strong, nonatomic) IBOutlet UIView *scrollView;
@property (strong, nonatomic) NSString *str_ApiKey;
@property (strong, nonatomic) NSString *str_SignUpFlag;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

@end
