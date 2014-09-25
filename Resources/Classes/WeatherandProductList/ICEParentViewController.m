//
//  ICEParentViewController.m
//  monMode
//
//  Created by Sunderrajan Ranganathan on 28/07/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEParentViewController.h"
#import "ICEWeatherandProductListViewController.h"
#import "ICESettingsViewController.h"
#import "ICEViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ICESingleTon.h"

@interface ICEParentViewController ()

@end

@implementation ICEParentViewController
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    BOOL isLeft;
    BOOL isfirstRun;
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_LatitudeCity;
    NSString *str_LatitudeState;
    NSString *str_LatitudeZipCode;
    NSString *str_LatitudeCountry;
    int count;
    BOOL isforecastflag;
    NSTimer *mainTimer;
    NSTimer *forecastTimer;
    
    NSInteger lastobject;
    NSTimer *mainTimer2;
    NSMutableArray *conditionarray;
    NSMutableArray *iconarray;
    NSMutableArray *popArray;
    NSMutableArray *farenheit;
    NSMutableArray *windavg;
    NSMutableArray *dateday;
    NSMutableArray *mutArr_ForeCastDate;
    NSMutableArray *mutArr_High;
    NSMutableArray *mutArr_Low;
    NSMutableArray *mutArr_HighCelcius;
    NSMutableArray *mutArr_LowCelcius;
    NSMutableArray *mutArr_Icon;
    NSMutableArray *mutArr_IconImageUrl;
    NSMutableArray *mutArr_AverageWind;
    NSMutableArray *mutArr_City;
    NSMutableArray *mutArr_Day;
    
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    CGFloat _panOriginX2;
    CGPoint _panVelocity2;
    
    BOOL isMenuHidden;
    
    ICEWeatherandProductListViewController *day1;
    ICEWeatherandProductListViewController *day2;
    ICEWeatherandProductListViewController *day3;
    int countWetGeocode;
    ICESingleTon *obj_IceSingle;
}
@synthesize scrollView,str_SignUpFlag,str_ApiKey;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    isfirstRun=YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if ([str_SignUpFlag isEqualToString:@"YES"])
    {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
        [comp setDay:[comp day]];
        [comp setHour: 5];
        [comp setMinute: 00];
        NSDate *dateToFire = [[NSCalendar currentCalendar] dateFromComponents:comp];
        
        [[NSUserDefaults standardUserDefaults] setObject:dateToFire forKey:@"PreviousTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:dateToFire forKey:@"ScheduledTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        str_SignUpFlag = @"NO";
    }
    // initialize location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    
    mutArr_HighCelcius = [[NSMutableArray alloc] init];
    mutArr_LowCelcius = [[NSMutableArray alloc] init];
    countWetGeocode = 1;
    str_ApiKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    isforecastflag = NO;
    
    if (![str_ApiKey isEqual:[NSNull null]])
    {
        [self forecastWeather];
    }
    obj_IceSingle = [ICESingleTon sharedManager];
    isMenuHidden=YES;
    day1 = [[ICEWeatherandProductListViewController alloc]init];
    day1.str_day=@"TODAY";
    day1.str_HideBtn1 = @"HIDE";
    day1.ShodowImage.hidden=YES;
    CGRect frame2 = day1.view.frame;
    frame2.origin.x = 0;
    day1.view.frame = frame2;
    
    day2 = [[ICEWeatherandProductListViewController alloc]init];
    day2.str_day=@"TOMMARO";
    day2.str_HideBtn2 = @"HIDE";
    CGRect frame = day2.view.frame;
    frame.origin.x = 320;
    day2.ShodowImage.hidden=YES;
    day2.view.frame = frame;
    
    day3 = [[ICEWeatherandProductListViewController alloc]init];
    day3.str_day=@"DAY_OFTER_TOMMARO";
    day3.str_HideBtn3 = @"HIDE";
    CGRect frame1 = day3.view.frame;
    day3.ShodowImage.hidden=YES;
    frame1.origin.x = 320;
    day3.view.frame = frame1;
    
    day1.delegate = self;
    day2.delegate = self;
    day3.delegate = self;
    
    [self.scrollView addSubview:day1.view];
    [self.scrollView addSubview:day2.view];
    [self.scrollView addSubview:day3.view];
    
    isLeft=NO;
    UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Today:)];
    pan1.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day1.bigWeatherView addGestureRecognizer:pan1];
    
    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Today:)];
    pan2.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day1.smallWeatherView addGestureRecognizer:pan2];
    
    UIPanGestureRecognizer *pan3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Tommaro:)];
    pan3.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day2.bigWeatherView addGestureRecognizer:pan3];
    
    UIPanGestureRecognizer *pan4 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Tommaro:)];
    pan4.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day2.smallWeatherView addGestureRecognizer:pan4];
    
    UIPanGestureRecognizer *pan5 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_dayAfterTommaro:)];
    pan5.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day3.bigWeatherView addGestureRecognizer:pan5];
    
    UIPanGestureRecognizer *pan6 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_dayAfterTommaro:)];
    pan6.delegate = (id<UIGestureRecognizerDelegate>)self;
    [day3.smallWeatherView addGestureRecognizer:pan6];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sample protocol delegate
-(void)hideView
{
    // headerView.hidden=YES;
}
-(void)showView
{
    // headerView.hidden=NO;
}

#pragma mark - Animation for Swiping Next & Previous Days

-(void)startNextDay:(NSString *)str_CurrentDay
{
    if ([str_CurrentDay isEqualToString:@"TODAY"])
    {
        [UIView animateWithDuration:0.8
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             day2.view.frame =  CGRectMake(0, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                             NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                             if ([str_TemperatureUnit isEqualToString:@"C"])
                             {
                                 
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                             else{
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                             }
                             
                         }
                         completion:^(BOOL finished){
                             day2.ShodowImage.hidden=YES;
                         }];
        
    }
    else if ([str_CurrentDay isEqualToString:@"TOMMARO"])
    {
        [UIView animateWithDuration:0.8
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             day3.view.frame =  CGRectMake(0, day3.view.frame.origin.y, day3.view.frame.size.width, day3.view.frame.size.height);
                             NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                             if ([str_TemperatureUnit isEqualToString:@"C"])
                             {
                                 
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                             else{
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                             }
                             
                         }
                         completion:^(BOOL finished){
                             day3.ShodowImage.hidden=YES;
                             
                         }];
    }
}

-(void)startPreviousDay:(NSString *)str_CurrentDay
{
    if ([str_CurrentDay isEqualToString:@"TOMMARO"])
    {
        [UIView animateWithDuration:0.8
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             day2.view.frame =  CGRectMake(320, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                             NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                             if ([str_TemperatureUnit isEqualToString:@"C"])
                             {
                                 
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                             else{
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                             }
                             
                         }
                         completion:^(BOOL finished){
                             day2.ShodowImage.hidden=YES;
                         }];
    }
    else if ([str_CurrentDay isEqualToString:@"DAY_OFTER_TOMMARO"])
    {
        [UIView animateWithDuration:0.8
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             day3.view.frame =  CGRectMake(320, day3.view.frame.origin.y, day3.view.frame.size.width, day3.view.frame.size.height);
                             NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                             if ([str_TemperatureUnit isEqualToString:@"C"])
                             {
                                 
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                             else{
                                 day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                 day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                 day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                             }
                             
                         }
                         completion:^(BOOL finished){
                             day3.ShodowImage.hidden=YES;
                         }];
    }
}

- (void)swipe_Today:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _panOriginX = day2.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:day2.view];
        
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:day2.view];
        CGRect frame = day2.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        [day2 resetWeatherFreame];
        if (frame.origin.x > 0.0f )
        {
            day2.view.frame = frame;
            if (frame.origin.x < 320.0f )
                day2.ShodowImage.hidden=NO;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        
        if(day2.view.frame.origin.x<= 180)
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 day2.view.frame =  CGRectMake(0, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                                 NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                 if ([str_TemperatureUnit isEqualToString:@"C"])
                                 {
                                     
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                 else{
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                 }
                                 
                             }
                             completion:^(BOOL finished){
                                 day2.ShodowImage.hidden=YES;
                                 day1.btn_PreviousDay.hidden = YES;
                                 day1.btn_NextDay.hidden = NO;
                                 day1.isHighlighted = YES;
                                 day2.isHighlighted = YES;
                                 day3.isHighlighted = YES;
                                 
                             }];
        }
        else
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 day2.view.frame =  CGRectMake(320, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                                 NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                 if ([str_TemperatureUnit isEqualToString:@"C"])
                                 {
                                     
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                 else{
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                 }
                                 
                             }
                             completion:^(BOOL finished){
                                 day2.ShodowImage.hidden=YES;
                                 day1.btn_PreviousDay.hidden = YES;
                                 day1.btn_NextDay.hidden = NO;
                                 day1.isHighlighted = YES;
                                 day2.isHighlighted = YES;
                                 day3.isHighlighted = YES;
                             }];
        }
    }
    
}

- (void)swipe_Tommaro:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _panOriginX = day2.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        _panOriginX2 = day3.view.frame.origin.x;
        _panVelocity2 = CGPointMake(0.0f, 0.0f);
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:day2.view];
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:day2.view];
        CGRect frame = day2.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        CGPoint velocity2 = [gesture velocityInView:day3.view];
        _panVelocity2 = velocity2;
        CGPoint translation2 = [gesture translationInView:day3.view];
        CGRect frame2 = day3.view.frame;
        frame2.origin.x = _panOriginX2 + translation2.x;
        
        [day1 resetWeatherFreame];
        [day3 resetWeatherFreame];
        if (frame.origin.x > 0.0f )
        {
            isLeft=NO;
            day2.view.frame = frame;
            day2.ShodowImage.hidden=NO;
        }
        else if(frame.origin.x < 0.0f )
        {
            isLeft=YES;
            day3.view.frame = frame2;
            day3.ShodowImage.hidden=NO;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        if(isLeft)
        {
            if(day2.view.frame.origin.x<= 180)
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     day3.view.frame =  CGRectMake(0, day3.view.frame.origin.y, day3.view.frame.size.width, day3.view.frame.size.height);
                                     NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                     if ([str_TemperatureUnit isEqualToString:@"C"])
                                     {
                                         
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                     else{
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                     }
                                     
                                 }
                                 completion:^(BOOL finished){
                                     day3.ShodowImage.hidden=YES;
                                     day2.btn_PreviousDay.hidden = NO;
                                     day2.btn_NextDay.hidden = NO;
                                     day1.isHighlighted = YES;
                                     day2.isHighlighted = YES;
                                     day3.isHighlighted = YES;
                                     
                                 }];
            }
            else
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     day2.view.frame =  CGRectMake(0, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                                     NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                     if ([str_TemperatureUnit isEqualToString:@"C"])
                                     {
                                         
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                     else{
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                     }
                                     
                                 }
                                 completion:^(BOOL finished){
                                     day2.ShodowImage.hidden=YES;
                                     day2.btn_PreviousDay.hidden = NO;
                                     day2.btn_NextDay.hidden = NO;
                                     day1.isHighlighted = YES;
                                     day2.isHighlighted = YES;
                                     day3.isHighlighted = YES;
                                 }];
            }
        }
        else
        {
            if(day2.view.frame.origin.x>= 180)
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     day2.view.frame =  CGRectMake(320, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                                     NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                     if ([str_TemperatureUnit isEqualToString:@"C"])
                                     {
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];
                                     }
                                     else
                                     {
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                     }
                                 }
                                 completion:^(BOOL finished){
                                     day2.ShodowImage.hidden=YES;
                                     day2.btn_PreviousDay.hidden = NO;
                                     day2.btn_NextDay.hidden = NO;
                                     day1.isHighlighted = YES;
                                     day2.isHighlighted = YES;
                                     day3.isHighlighted = YES;
                                 }];
            }
            else
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     day2.view.frame =  CGRectMake(0, day2.view.frame.origin.y, day2.view.frame.size.width, day2.view.frame.size.height);
                                     NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                     if ([str_TemperatureUnit isEqualToString:@"C"])
                                     {
                                         
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                     else{
                                         day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                         day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                         day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                     }
                                     
                                 }
                                 completion:^(BOOL finished){
                                     day2.ShodowImage.hidden=YES;
                                     day2.btn_PreviousDay.hidden = NO;
                                     day2.btn_NextDay.hidden = NO;
                                     day1.isHighlighted = YES;
                                     day2.isHighlighted = YES;
                                     day3.isHighlighted = YES;
                                 }];
            }
        }
    }
}

- (void)swipe_dayAfterTommaro:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        day1.view.userInteractionEnabled = NO;
        day2.view.userInteractionEnabled = NO;
        _panOriginX = day3.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:day3.view];
        
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:day3.view];
        CGRect frame = day3.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        [day2 resetWeatherFreame];
        if (frame.origin.x >= 0.0f )
        {
            day3.view.frame = frame;
            day3.ShodowImage.hidden=NO;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        if(day3.view.frame.origin.x>= 180)
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 day3.view.frame =  CGRectMake(320, day3.view.frame.origin.y, day3.view.frame.size.width, day3.view.frame.size.height);
                                 NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                 if ([str_TemperatureUnit isEqualToString:@"C"])
                                 {
                                     
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                 else{
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                 }
                                 
                             }
                             completion:^(BOOL finished){
                                 day3.btn_PreviousDay.hidden = NO;
                                 day3.btn_NextDay.hidden = YES;
                                 day1.view.userInteractionEnabled = YES;
                                 day2.view.userInteractionEnabled = YES;
                                 day3.ShodowImage.hidden=YES;
                                 day1.isHighlighted = YES;
                                 day2.isHighlighted = YES;
                                 day3.isHighlighted = YES;
                             }];
        }
        else
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 day3.view.frame =  CGRectMake(0, day3.view.frame.origin.y, day3.view.frame.size.width, day3.view.frame.size.height);
                                 NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
                                 if ([str_TemperatureUnit isEqualToString:@"C"])
                                 {
                                     
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];}
                                 else{
                                     day1.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
                                     day2.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
                                     day3.big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
                                 }
                                 
                             }
                             completion:^(BOOL finished){
                                 day3.ShodowImage.hidden=YES;
                                 day3.btn_PreviousDay.hidden = NO;
                                 day3.btn_NextDay.hidden = YES;
                                 day1.isHighlighted = YES;
                                 day2.isHighlighted = YES;
                                 day3.isHighlighted = YES;
                                 
                             }];
            
        }
    }
}

#pragma mark - Screen Animation
-(UIImage *)takescreenshotes
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - lat and long of the location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil)
    {
        str_Latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        str_Longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    }
    countWetGeocode += 1;
    if (countWetGeocode >= 8)
    {
        // Reverse Geocoding
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0)
            {
                placemark = [placemarks lastObject];
                
                str_LatitudeCity = [NSString stringWithFormat:@"%@",placemark.locality];
                str_LatitudeState = [NSString stringWithFormat:@"%@",placemark.administrativeArea];
                str_LatitudeZipCode = [NSString stringWithFormat:@"%@",placemark.postalCode];
                str_LatitudeCountry = [NSString stringWithFormat:@"%@",placemark.ISOcountryCode];
                [self updateUserLatLong:str_Latitude Longitude:str_Longitude City:str_LatitudeCity State:str_LatitudeState ZipCode:str_LatitudeZipCode Country:str_LatitudeCountry];
                countWetGeocode = 1;
            }
            else
            {
                
            }
        } ];
        [manager stopUpdatingLocation];
        locationManager.delegate = nil;
    }
}

//Update User Location
- (void)updateUserLatLong:(NSString *)latitude Longitude:(NSString *)longitude City:(NSString *)city State:(NSString *)state ZipCode:(NSString *)zipcode Country:(NSString *)country
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/me/current_location" ];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_ApiKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[city]=%@",city]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[state]=%@",state]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[lat]=%@",latitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[long]=%@",longitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[zipcode]=%@",zipcode]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[country]=%@",country]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Update Weather Request : %@",url);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    if ([data length] >0  && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingAllowFragments
                         error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Update Weather Response: %@",jsonObject);
            forecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(parentTimerFired:) userInfo:nil repeats:YES];
            count = 1;
        }
    }
    else if (error != nil)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 0;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    else if ([data length] == 0 && error == nil)
    {
        
    }
}

- (void)parentTimerFired:(NSTimer *)timer
{
    count += 1;
    if (count>=5)
    {
        [forecastTimer invalidate];
        forecastTimer = nil;
        [self forecastWeather];
        count = 1;
    }
}

#pragma mark - Weather Forecasts
- (void)forecastWeather
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/me/forecasts" ];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_ApiKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&format=json"]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"ForeCast Request : %@",url);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] >0  && error == nil)
        {
            error = nil;
            id jsonObject = [NSJSONSerialization
                             JSONObjectWithData:data
                             options:NSJSONReadingAllowFragments
                             error:&error];
            if (jsonObject != nil && error == nil)
            {
                NSLog(@"ForeCast Response : %@",jsonObject);
                if ([[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"success"]] isEqualToString:[NSString stringWithFormat:@"0"]])
                {
                    [self setForCasteLoadingText:@"Forecast data is not available"];
                    forecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(parentTimerFired:) userInfo:nil repeats:YES];
                }
                else
                {
                    NSMutableDictionary *dict_ForeCast = [jsonObject objectForKey:@"forecasts"];
                    if ([dict_ForeCast count] == 0)
                    {
                        [self setForCasteLoadingText:@"Forecast data is not available"];
                        forecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(parentTimerFired:) userInfo:nil repeats:YES];
                    }
                    else
                    {
                        NSMutableArray *Location = (NSMutableArray *)[dict_ForeCast valueForKey:@"location_rollup"];
                        NSMutableDictionary *wind;
                        mutArr_City = [[NSMutableArray alloc] init];
                        conditionarray = [[NSMutableArray alloc] init];
                        for (int i = 0; i<[Location count]; i++)
                        {
                            wind = [[Location objectAtIndex:i] objectForKey:@"city"];
                            [mutArr_City addObject:wind];
                        }
                        mutArr_Day = [[NSMutableArray alloc] init];
                        //Condition
                        NSMutableArray *arr_Condition = (NSMutableArray *)[dict_ForeCast valueForKey:@"conditions"];
                        NSString *strMainCondition;
                        for (int i = 0; i<[arr_Condition count]; i++)
                        {
                            strMainCondition = [NSString stringWithFormat:@"%@",[arr_Condition objectAtIndex:i]];
                            [conditionarray addObject:strMainCondition];
                            
                        }
                        for (int i = 0; i<[conditionarray count]; i++)
                        {
                            NSString *strMainMainCondition = [NSString stringWithFormat:@"%@",[conditionarray objectAtIndex:i]];
                            if ([strMainMainCondition isEqualToString:@"Chance of a Thunderstorm"])
                            {
                                NSString *strCondition = @"Chance of Tstorm";
                                [conditionarray replaceObjectAtIndex:i withObject:strCondition];
                            }
                        }
                        windavg = (NSMutableArray *)[dict_ForeCast valueForKey:@"average_wind"];
                        iconarray = (NSMutableArray *)[dict_ForeCast valueForKey:@"icon"];
                        popArray = (NSMutableArray *)[dict_ForeCast valueForKey:@"pop"];
                        mutArr_High = (NSMutableArray *)[dict_ForeCast valueForKey:@"high"];
                        mutArr_Low = (NSMutableArray *)[dict_ForeCast valueForKey:@"low"];
                        mutArr_ForeCastDate = (NSMutableArray *)[dict_ForeCast valueForKey:@"forecast_date"];
                        
                        for (int i =0; i<[mutArr_High count]; i++)
                        {
                            NSString *strHighTemp = (NSString *)[mutArr_High objectAtIndex:i];
                            double highFahrenheit = [strHighTemp doubleValue];
                            double highCelcius = (highFahrenheit-32)*5.0/9.0;
                            NSString *strHighCelcius = [NSString stringWithFormat:@"%.1f",highCelcius];
                            [mutArr_HighCelcius addObject:strHighCelcius];
                            NSString *strLowTemp = (NSString *)[mutArr_Low objectAtIndex:i];
                            double lowFahrenheit = [strLowTemp doubleValue];
                            double lowCelcius = (lowFahrenheit-32)*5.0/9.0;
                            NSString *strlowCelcius = [NSString stringWithFormat:@"%.1f",lowCelcius];
                            [mutArr_LowCelcius addObject:strlowCelcius];
                        }
                        [self setForeCastValue];
                    }
                }
            }
        }
        else if (error != nil)
        {
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
            alertsuccess.tag = 0;
            alertsuccess.delegate = self;
            [alertsuccess show];
        }
        else if ([data length] == 0 && error == nil)
        {
            
        }
    }];
}

-(void)setForeCastValue
{
    for (int i = 0; i<[mutArr_ForeCastDate count]; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%@",[mutArr_ForeCastDate objectAtIndex:i]];
        NSArray *arr = [str componentsSeparatedByString:@"T"];
        
        NSString *myDateString = [NSString stringWithFormat:@"%@",[arr objectAtIndex:0]];
        // Convert the string to NSDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *date = [[NSDate alloc] init];
        date = [dateFormatter dateFromString:myDateString];
        
        // Extract the day name (Sunday)
        dateFormatter.dateFormat = @"EEEE";
        NSString *dayName = [dateFormatter stringFromDate:date];
        [mutArr_Day addObject:dayName];
        
    }
    //Incoming Date
    NSString *str = [NSString stringWithFormat:@"%@",[mutArr_ForeCastDate lastObject]];
    NSArray *arr = [str componentsSeparatedByString:@"T"];
    
    NSString *myDateString = [NSString stringWithFormat:@"%@",[arr objectAtIndex:0]];
    // Convert the string to NSDate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormatter dateFromString:myDateString];
    
    //System Date
    NSDate *dateDevice = [NSDate date];
    NSString *str_NewDate = [NSString stringWithFormat:@"%@",dateDevice];
    NSArray *arr1 = [str_NewDate componentsSeparatedByString:@" "];
    NSString *myNewDateString = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
    
    lastobject = 0;
    
    lastobject = [mutArr_Day count]-1;
    if ([myDateString isEqualToString:myNewDateString])
    {
        NSString *strToday = @"Today";
        [mutArr_Day replaceObjectAtIndex:lastobject withObject:strToday];
    }
    
    obj_IceSingle.str_CelciusTemperature = [NSString stringWithFormat:@"%@° / %@°",[mutArr_HighCelcius objectAtIndex:lastobject],[mutArr_LowCelcius objectAtIndex:lastobject]];
    obj_IceSingle.str_CelciusTemperature2 = [NSString stringWithFormat:@"%@° / %@°",[mutArr_HighCelcius objectAtIndex:lastobject-1],[mutArr_LowCelcius objectAtIndex:lastobject-1]];
    obj_IceSingle.str_CelciusTemperature3 = [NSString stringWithFormat:@"%@° / %@°",[mutArr_HighCelcius objectAtIndex:lastobject-2],[mutArr_LowCelcius objectAtIndex:lastobject-2]];
    
    obj_IceSingle.str_FahrenheitTemperature = [NSString stringWithFormat:@"%@° / %@°",[mutArr_High objectAtIndex:lastobject],[mutArr_Low objectAtIndex:lastobject]];
    obj_IceSingle.str_FahrenheitTemperature2 = [NSString stringWithFormat:@"%@° / %@°",[mutArr_High objectAtIndex:lastobject-1],[mutArr_Low objectAtIndex:lastobject-1]];
    obj_IceSingle.str_FahrenheitTemperature3 = [NSString stringWithFormat:@"%@° / %@°",[mutArr_High objectAtIndex:lastobject-2],[mutArr_Low objectAtIndex:lastobject-2]];
    
    NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
    if ([str_TemperatureUnit isEqualToString:@"C"])
    {
        [day1 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject] windNew:[windavg objectAtIndex:lastobject] pOPNew:[popArray objectAtIndex:lastobject] degreeHigh:[mutArr_HighCelcius objectAtIndex:lastobject] degreeLow:[mutArr_LowCelcius objectAtIndex:lastobject] iconName:[iconarray objectAtIndex:lastobject]];
        [day2 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject-1] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject-1] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject-1] windNew:[windavg objectAtIndex:lastobject-1] pOPNew:[popArray objectAtIndex:lastobject-1] degreeHigh:[mutArr_HighCelcius objectAtIndex:lastobject-1] degreeLow:[mutArr_LowCelcius objectAtIndex:lastobject-1] iconName:[iconarray objectAtIndex:lastobject-1]];
        [day3 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject-2] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject-2] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject-2] windNew:[windavg objectAtIndex:lastobject-2] pOPNew:[popArray objectAtIndex:lastobject-2] degreeHigh:[mutArr_HighCelcius objectAtIndex:lastobject-2] degreeLow:[mutArr_LowCelcius objectAtIndex:lastobject-2] iconName:[iconarray objectAtIndex:lastobject-2]];
    }
    else
    {
        [day1 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject] windNew:[windavg objectAtIndex:lastobject] pOPNew:[popArray objectAtIndex:lastobject] degreeHigh:[mutArr_High objectAtIndex:lastobject] degreeLow:[mutArr_Low objectAtIndex:lastobject] iconName:[iconarray objectAtIndex:lastobject]];
        [day2 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject-1] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject-1] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject-1] windNew:[windavg objectAtIndex:lastobject-1] pOPNew:[popArray objectAtIndex:lastobject-1] degreeHigh:[mutArr_High objectAtIndex:lastobject-1] degreeLow:[mutArr_Low objectAtIndex:lastobject-1] iconName:[iconarray objectAtIndex:lastobject-1]];
        [day3 setForeCastValue:[[mutArr_Day objectAtIndex:lastobject-2] uppercaseString] cityName:[[mutArr_City objectAtIndex:lastobject-2] uppercaseString] weatherNew:[conditionarray objectAtIndex:lastobject-2] windNew:[windavg objectAtIndex:lastobject-2] pOPNew:[popArray objectAtIndex:lastobject-2] degreeHigh:[mutArr_High objectAtIndex:lastobject-2] degreeLow:[mutArr_Low objectAtIndex:lastobject-2] iconName:[iconarray objectAtIndex:lastobject-2]];
    }
}

- (void)setForCasteLoadingText :(NSString *)text
{
    day1.lbl_LoadingForcast.text=text;
    day2.lbl_LoadingForcast.text=text;
    day3.lbl_LoadingForcast.text= text;
    
    day1.big_lbl_LoadingForcast.text= text;
    day2.big_lbl_LoadingForcast.text= text;
    day3.big_lbl_LoadingForcast.text= text;
}

@end
