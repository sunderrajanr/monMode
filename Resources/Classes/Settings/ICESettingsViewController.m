//
//  ICESettingsViewController.m
//  monMode
//
//  Created by Muthu Sabari on 7/22/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICESettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ICEViewController.h"
#import "ICEUpdateUserInfoViewController.h"
#import "ICENotificationViewController.h"

@interface ICESettingsViewController ()
{
    NSString *str_APIKey;
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    ICEUpdateUserInfoViewController *obj_Update;
    ICENotificationViewController *obj_Notify;
}
@end

@implementation ICESettingsViewController

@synthesize backgroundImage_backview,backView,backViewImage,frontView,view_Header;
@synthesize lbl_HeaderTitle,btn_UpdateUserInfo,btn_NotificationSettings,btn_TemperatureUnit,btn_Celcius,btn_Farhendreit,img_UpdateArrow,img_NotificationArrow;

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
    
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
    if ([str_TemperatureUnit isEqualToString:@"C"])
    {
        [btn_Celcius setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
        [btn_Farhendreit setBackgroundColor:[UIColor colorWithRed:62.0/255.0 green:62.0/255.0 blue:62.0/255.0 alpha:1]];
    }
    else
    {
        [btn_Celcius setBackgroundColor:[UIColor colorWithRed:62.0/255.0 green:62.0/255.0 blue:62.0/255.0 alpha:1]];
        [btn_Farhendreit setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
    }
    
    //Check Internet Connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChangeMain:) name:kReachabilityChangedNotification object:nil];
    
    hostReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReachability startNotifier];
    [self updateInterfaceWithReachability:hostReachability];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    [self updateInterfaceWithReachability:internetReachability];
    
    wifiReachability = [Reachability reachabilityForLocalWiFi];
    [wifiReachability startNotifier];
    [self updateInterfaceWithReachability:wifiReachability];
    
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    [self addSiginIn_gesture];
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

#pragma mark - Back Screen Animation

-(UIImage *)takescreenshotes
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)addSiginIn_gesture
{
    backViewImage.image=backgroundImage_backview;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(siginIn_pan:)];
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [frontView addGestureRecognizer:pan];
    
}
- (void)siginIn_pan:(UIPanGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _panOriginX = self.frontView.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:self.frontView];
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:self.frontView];
        CGRect frame = self.frontView.frame;
        frame.origin.x = _panOriginX + translation.x;
        if (frame.origin.x > 0.0f )
        {
            self.frontView.frame = frame;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        if(self.frontView.frame.origin.x>=50)
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frontView.frame =  CGRectMake(320, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [self dismissViewControllerAnimated:NO completion:nil];
                             }];
        }
        else
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frontView.frame =  CGRectMake(0, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 
                                 
                             }];
            
        }
    }
}

#pragma mark - Back & LogOut

- (IBAction)act_Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)act_Update:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            obj_Update = [[ICEUpdateUserInfoViewController alloc] initWithNibName:@"ICEUpdateUserInfoViewController" bundle:nil];
            
        }
        else
        {
            //iPhone 4 Version
            obj_Update = [[ICEUpdateUserInfoViewController alloc] initWithNibName:@"ICEUpdateUserInfoViewController_iPhone4" bundle:nil];
            
        }
    }
	else
	{
        //iPad Version
    }
    
    [self presentViewController:obj_Update animated:NO completion:nil];
}

- (IBAction)act_Notification:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            obj_Notify = [[ICENotificationViewController alloc] initWithNibName:@"ICENotificationViewController" bundle:nil];
            
        }
        else
        {
            //iPhone 4 Version
            obj_Notify = [[ICENotificationViewController alloc] initWithNibName:@"ICENotificationViewController_iPhone4" bundle:nil];
            
        }
    }
	else
	{
        //iPad Version
    }
    
    [self presentViewController:obj_Notify animated:NO completion:nil];
    
}

- (IBAction)act_Celcius:(id)sender
{
    //celcius Selection
    [btn_Celcius setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
    [btn_Farhendreit setBackgroundColor:[UIColor colorWithRed:62.0/255.0 green:62.0/255.0 blue:62.0/255.0 alpha:1]];
    [self actionAssignTemperature:@"C"];
}

- (IBAction)act_Farhendeit:(id)sender
{
    //Farhendeit Selection
    [btn_Celcius setBackgroundColor:[UIColor colorWithRed:62.0/255.0 green:62.0/255.0 blue:62.0/255.0 alpha:1]];
    [btn_Farhendreit setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
    [self actionAssignTemperature:@"F"];
}

- (void)actionAssignTemperature:(NSString *)str_Temperature
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/me/profile";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&profile[temperature_unit]=%@",str_Temperature]];
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Temperature Unit Request : %@",url);
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
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Temperature Unit Response : %@",jsonObject);
            NSString *str_TemperatureUnit = (NSString *)[jsonObject valueForKey:@"temperature_unit"];
            [[NSUserDefaults standardUserDefaults] setObject:str_TemperatureUnit forKey:@"usertemperatureunit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 1;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
}

#pragma  mark - Check Internet Connection
- (void)reachabilityDidChangeMain:(NSNotification *)notification
{
	Reachability* curReach = [notification object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == hostReachability)
	{
        [self removeWifiAnimation];
        [self configureInterNetConnection:reachability];
        BOOL connectionRequired = [reachability connectionRequired];
        
        if (!connectionRequired)
        {
            
            [self removeWifiAnimation];
        }
    }
    
	if (reachability == internetReachability)
	{
        
	}
    
	if (reachability == wifiReachability)
	{
        [self removeWifiAnimation];
		[self configureInterNetConnection:reachability];
	}
    
}

- (void)configureInterNetConnection:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    
    switch (netStatus)
    {
        case NotReachable:        {
            [self wifiAnimation];
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            [self removeWifiAnimation];
            break;
        }
        case ReachableViaWiFi:        {
            [self removeWifiAnimation];
            break;
        }
    }
    if (connectionRequired)
    {
        [self removeWifiAnimation];
    }
}

- (void)removeWifiAnimation
{
    [self.image_CheckInternet stopAnimating];
    self.view_CheckInternet.hidden = YES;
    [self.view_CheckInternet removeFromSuperview];
    self.view_CheckInternet = nil;
}


- (void)wifiAnimation
{
    self.view_CheckInternet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.view_CheckInternet.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    self.lbl_CheckInternet = [[UILabel alloc] initWithFrame:CGRectMake(40, 293, 240, 40)];
    self.lbl_CheckInternet.font = [UIFont fontWithName:@"Helvetica" size:16];
    self.lbl_CheckInternet.textColor = [UIColor whiteColor];
    self.lbl_CheckInternet.textAlignment = NSTextAlignmentCenter;
    self.lbl_CheckInternet.text = @"Please Check Your Internet";
    [self.view_CheckInternet addSubview:self.lbl_CheckInternet];
    
    self.image_CheckInternet = [[UIImageView alloc] initWithFrame:CGRectMake(135, 235, 50, 50)];
    self.image_CheckInternet.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"wifi1.png"],
                                              [UIImage imageNamed:@"wifi2.png"],
                                              [UIImage imageNamed:@"wifi3.png"],
                                              [UIImage imageNamed:@"wifi4.png"],nil];
    
    // all frames will execute in 1.75 seconds
    self.image_CheckInternet.animationDuration = 1.75;
    // repeat the annimation forever
    self.image_CheckInternet.animationRepeatCount = 0;
    // start animating
    [self.image_CheckInternet startAnimating];
    //    self.animatingImage.contentMode = UIViewContentModeScaleAspectFill;
    self.image_CheckInternet.clipsToBounds = YES;
    // add the animation view to the main window
    [self.view_CheckInternet addSubview:self.image_CheckInternet];
    
    [self.view addSubview:self.view_CheckInternet];
    self.view_CheckInternet.hidden = NO;
}

@end
