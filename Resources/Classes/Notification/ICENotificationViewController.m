//
//  ICENotificationViewController.m
//  monMode
//
//  Created by Muthu Sabari on 7/29/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICENotificationViewController.h"

@interface ICENotificationViewController ()
{
    NSDate *pickerDate;
    BOOL isFirstTime;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
}
@end

@implementation ICENotificationViewController
@synthesize btn_Set,datePicker,btn_Back,view_Header,lbl_HeaderTitle;

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
    
    isFirstTime = YES;
    
    [UIView appearanceWhenContainedIn:[UITableView class], [UIDatePicker class], nil].backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PreviousTime"])
    {
        datePicker.date = [[NSUserDefaults standardUserDefaults] valueForKey:@"PreviousTime"];
    }
    else
    {
        datePicker.date = [NSDate date];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"PreviousTime"])
    {
        datePicker.date = [[NSUserDefaults standardUserDefaults] valueForKey:@"PreviousTime"];
    }
    else
    {
        datePicker.date = [NSDate date];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set Notification
- (IBAction)act_Set:(id)sender
{
    // Get the current date
    pickerDate = [datePicker date];
    
    // Schedule the notification
    [[NSUserDefaults standardUserDefaults] setObject:pickerDate forKey:@"PreviousTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertBody = @"See today's recommendations";
    localNotification.alertAction = @"Reminder";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval = NSDayCalendarUnit;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:pickerDate];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString *str_TimeFormat;
    NSString *str_HourFormat;
    NSString *str_MinFormat;
    
    if (hour >=12)
    {
        str_TimeFormat = @"PM";
    }
    else
    {
        str_TimeFormat = @"AM";
    }
    if (hour <=9)
    {
        str_HourFormat = [NSString stringWithFormat:@"0%d",(int)hour];
    }
    else
    {
        str_HourFormat = [NSString stringWithFormat:@"%d",(int)hour];
    }
    if (minute <=9)
    {
        str_MinFormat = [NSString stringWithFormat:@"0%d",(int)minute];
    }
    else
    {
        str_MinFormat = [NSString stringWithFormat:@"%d",(int)minute];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:pickerDate forKey:@"ScheduledTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"monMode" message:[NSString stringWithFormat:@"monMode notifications are now set for %@:%@ %@",str_HourFormat,str_MinFormat,str_TimeFormat] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//OK button pressed
    {
        //do something
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

- (IBAction)act_Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
