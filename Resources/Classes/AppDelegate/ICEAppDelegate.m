//
//  ICEAppDelegate.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 5/28/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEAppDelegate.h"

#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"
#import "Reachability.h"
#import "ICESingleTon.h"

#define backgroundIntervelSec 5

@implementation ICEAppDelegate
{
    NSTimer *backgroundTimer;
}
@synthesize obj_ParentVC;
#pragma mark - Application Life Cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [Flurry startSession:@"RXPTHPJ5V6NGGP7MMZ6B"];
    
    countnew = 1;
    countGeoCode = 1;
    isSameTime = NO;
    //Location Manager
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    
    UILocalNotification *notification = [launchOptions objectForKey:
                                         UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (notification)
    {
        //If user open the app through notification message
        //Device Checking
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (IS_IPHONE_5)
            {
                //iPhone 5, 5C & 5S Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController" bundle:nil];
            }
            else
            {
                //iPhone 4 Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController_iPhone4" bundle:nil];
            }
        }
        else
        {
            //iPad Version
        }
        obj_ParentVC.str_SignUpFlag = @"NO";
        self.window.rootViewController = obj_ParentVC;
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"] == NO)
    {
        //New user login
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"api_key"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tauthentication"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fbauthentication"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduledTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PreviousTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"useremail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userfirstname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userlastname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usertemperatureunit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Device Checking
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (IS_IPHONE_5)
            {
                //iPhone 5, 5C & 5S Version
                self.iceViewController = [[ICEViewController alloc] initWithNibName:@"ICEViewController" bundle:nil];
            }
            else
            {
                //iPhone 4 Version
                self.iceViewController = [[ICEViewController alloc] initWithNibName:@"ICEViewController_iPhone4" bundle:nil];
            }
        }
        else
        {
            //iPad Version
        }
        self.window.rootViewController = self.iceViewController;
    }
    else
    {
        //Already Login user
        //Device Checking
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (IS_IPHONE_5)
            {
                //iPhone 5, 5C & 5S Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController" bundle:nil];
            }
            else
            {
                //iPhone 4 Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController_iPhone4" bundle:nil];
            }
        }
        else
        {
            //iPad Version
        }
        obj_ParentVC.str_SignUpFlag = @"NO";
        self.window.rootViewController = obj_ParentVC;
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self checkBackgroundRefreshStatus];
    [self checkLocationService];
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        // If there's no cached session, we will show a login button
    }
    else
    {
        
    }
    
    return YES;
}

// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    //
    // You can add your app-specific url handling code here if needed
    if (wasHandled)
    {
        return wasHandled;
    }
    self.iceLoginObject = [[ICELoginViewController alloc] initWithNibName:@"ICELoginViewController" bundle:nil];
    self.window.rootViewController = self.iceLoginObject;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[FBSession activeSession] close];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSString *str_apiKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    
    NSDate *previousDate = [[NSUserDefaults standardUserDefaults]valueForKey:@"ScheduledTime"];
    if (![str_apiKey isEqualToString:@""])
    {
        if (previousDate != nil)
        {
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground)
            {
                backgroundTimer=nil;
                [backgroundTimer invalidate];
                backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self  selector:@selector(backgroundTasks) userInfo:nil repeats:YES];
                
            }
        }
    }
    
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self checkBackgroundRefreshStatus];
    [self checkLocationService];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (UIApplication.sharedApplication.applicationState != 0)
    {
        //Device Checking
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (IS_IPHONE_5)
            {
                //iPhone 5, 5C & 5S Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController" bundle:nil];
            }
            else
            {
                //iPhone 4 Version
                obj_ParentVC=[[ICEParentViewController alloc]initWithNibName:@"ICEParentViewController_iPhone4" bundle:nil];
            }
        }
        else
        {
            //iPad Version
        }
        
        obj_ParentVC.str_SignUpFlag = @"NO";
        self.window.rootViewController = obj_ParentVC;
    }
}


#pragma mark - Internet, Location, Background Refresh
-(void)checkLocationService
{
    if(![CLLocationManager locationServicesEnabled] ||[CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"please go to Settings>Privacy>Location Services to allow monMode to access your location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)checkBackgroundRefreshStatus
{
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Background App Refresh Disabled" message:@"please go to Settings> General > Background App Refresh to allow monMode." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Background App Refresh" message:@"unavailable on this system due to device configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (BOOL)checkConnection
{
	//Check Internet Connection
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        UIAlertView * alert4Connectivity = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"You don’t have internet connection! Once you are back online, then come back to the app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert4Connectivity show];
		return NO;
	}
    else
    {
        return YES;
    }
}

#pragma mark - lat and long of the location

- (void)locationManager:(CLLocationManager *)inManager didFailWithError:(NSError *)inError{
    if (inError.code ==  kCLErrorDenied)
    {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil)
    {
        str_Latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        str_Longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    }
    countGeoCode += 1;
    
    if (countGeoCode>=8)
    {
        // Reverse Geocoding
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error == nil && [placemarks count] > 0)
             {
                 placemark = [placemarks lastObject];
                 
                 str_LatitudeCity = [NSString stringWithFormat:@"%@",placemark.locality];
                 str_LatitudeState = [NSString stringWithFormat:@"%@",placemark.administrativeArea];
                 str_LatitudeZipCode = [NSString stringWithFormat:@"%@",placemark.postalCode];
                 str_LatitudeCountry = [NSString stringWithFormat:@"%@",placemark.ISOcountryCode];
                 if (isSameTime && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground)
                 {
                     [self updateUserLatLong:str_Latitude Longitude:str_Longitude City:str_LatitudeCity State:str_LatitudeState ZipCode:str_LatitudeZipCode Country:str_LatitudeCountry];
                 }
                 countGeoCode = 1;
             }
         } ];
    }
}


#pragma mark - BackGround Service call
-(void)backgroundTasks
{
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied || [self checkConnection] == NO)
    {
        
    }
    else
    {
        countnew +=1;
        if (countnew>=480)
        {
            [locationManager stopUpdatingLocation];
            [locationManager startUpdatingLocation];
            countnew = 1;
        }
        
        NSDate *CurrentDate = [NSDate date];
        NSString *CurrentdateString = [NSString stringWithFormat:@"%@",CurrentDate];
        NSDate *previousDate1 = [[NSUserDefaults standardUserDefaults]valueForKey:@"ScheduledTime"];
        previousDate1 = [previousDate1 dateByAddingTimeInterval:-2];
        NSString *PreviousdateString1 = [NSString stringWithFormat:@"%@",previousDate1];
        if ([PreviousdateString1 isEqualToString:CurrentdateString])
        {
            isSameTime = YES;
            NSDate *previousDate = [[NSUserDefaults standardUserDefaults]valueForKey:@"ScheduledTime"];
            previousDate = [previousDate dateByAddingTimeInterval:86400];
            [[NSUserDefaults standardUserDefaults] setObject:previousDate forKey:@"ScheduledTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            NSDate *NewDate = [[NSUserDefaults standardUserDefaults]valueForKey:@"ScheduledTime"];
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = NewDate;
            localNotification.alertBody = @"See today's recommendations";
            localNotification.alertAction = @"Reminder";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.repeatInterval = NSDayCalendarUnit;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}


//Update User Location
- (void)updateUserLatLong:(NSString *)latitude Longitude:(NSString *)longitude City:(NSString *)city State:(NSString *)state ZipCode:(NSString *)zipcode Country:(NSString *)country
{
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/me/current_location" ];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[city]=%@",city]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[state]=%@",state]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[lat]=%@",latitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[long]=%@",longitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[zipcode]=%@",zipcode]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&current_location[country]=%@",country]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
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
            isSameTime = NO;
            mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(appDelegateTimerFired:) userInfo:nil repeats:YES];
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

#pragma mark - Weather Forecasts & Present Notification
- (void)forecastWeather
{
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/me/forecasts" ];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&format=json"]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"GET"];
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
            if ([[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"success"]] isEqualToString:[NSString stringWithFormat:@"0"]])
            {
                mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(appDelegateTimerFired:) userInfo:nil repeats:YES];
            }
            else
            {
                NSMutableDictionary *dict_ForeCast = [jsonObject objectForKey:@"forecasts"];
                if ([dict_ForeCast count] == 0)
                {
                    mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(appDelegateTimerFired:) userInfo:nil repeats:YES];
                }
                else
                {
                    NSMutableArray *Location = (NSMutableArray *)[dict_ForeCast valueForKey:@"location_rollup"];
                    NSMutableDictionary *wind;
                    mutArr_City = [[NSMutableArray alloc] init];
                    for (int i = 0; i<[Location count]; i++)
                    {
                        wind = [[Location objectAtIndex:i] objectForKey:@"city"];
                        [mutArr_City addObject:wind];
                    }
                    
                    conditionarray = (NSMutableArray *)[dict_ForeCast valueForKey:@"conditions"];
                    mutArr_High = (NSMutableArray *)[dict_ForeCast valueForKey:@"high"];
                    mutArr_Low = (NSMutableArray *)[dict_ForeCast valueForKey:@"low"];
                    mutArr_ForeCastDate = (NSMutableArray *)[dict_ForeCast valueForKey:@"forecast_date"];
                    
                    str_Condition = [NSString stringWithFormat:@"%@",[conditionarray lastObject]];
                    str_TempFaren = [NSString stringWithFormat:@"%@",[mutArr_High lastObject]];
                    
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    localNotif.fireDate = [NSDate date];
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    localNotif.alertBody = [NSString stringWithFormat:@"%@° F - %@, See today's recommendations",str_TempFaren,str_Condition];
                    localNotif.alertAction = @"Reminder";
                    
                    localNotif.soundName = UILocalNotificationDefaultSoundName;
                    localNotif.applicationIconBadgeNumber =0;
                    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
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
}

- (void)appDelegateTimerFired:(NSTimer *)timer
{
    count += 1;
    if (count>=5)
    {
        [mainTimer invalidate];
        mainTimer = nil;
        [self forecastWeather];
        count = 1;
    }
}

#pragma mark - facebook
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    // Handle errors
    if (error)
    {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
                // Handle session closures that happen outside of the app
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}


@end
