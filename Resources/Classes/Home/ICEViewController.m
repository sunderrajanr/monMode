//
//  ICEViewController.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 5/31/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEViewController.h"
#import "ICELoginViewController.h"
#import "ICESignUPViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ICEParentViewController.h"
#import "ICESingleTon.h"

@interface ICEViewController ()<MBProgressHUDDelegate,CLLocationManagerDelegate>
{
    //Initialize Facebook Login View
    FBLoginView *loginView;
    MBProgressHUD *HUD;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    
    ICEParentViewController *obj_ParentVC;
    
    NSString *str_FaceBookToken;
    NSString *str_FaceBookEmail;
    NSString *str_FaceBookUserID;
    NSString *str_FaceBookFirstName;
    NSString *str_FaceBookLastName;
    NSString *str_FaceBookUserSex;
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_HomeZipCode;
    NSString *str_Country;
    NSString *str_City;
    NSString *str_State;
    
    NSString *str_AuthenticationProvider;
    NSString *str_DeviceOSVersion;
    NSString *str_DeviceType;
    NSString *str_DeviceUUID;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (strong, nonatomic) ICESignUPViewController *signUPVC;
@property (strong, nonatomic) ICELoginViewController *loginVC;
@end

@implementation ICEViewController
@synthesize webViewTPS,activityIndicator,btn_Back,deserializedDictionary,signUPVC,loginVC;
@synthesize img_Hanger,view_Footer,btn_TermsOfService,btn_Privacy,btn_Login,btn_SignUP,btn_FaceBook,lbl_FaceBook,img_FaceBook,lbl_Register,view_FooterHeader;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    
    // initialize location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    str_DeviceUUID = [dev.identifierForVendor  UUIDString];
    str_DeviceOSVersion = [UIDevice currentDevice].systemVersion;
    str_DeviceType = @"iOS";
}

- (void)viewDidAppear:(BOOL)animated
{
    btn_Back.hidden = YES;
    webViewTPS.hidden = YES;
    activityIndicator.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    btn_Back.hidden = YES;
    webViewTPS.hidden = YES;
    activityIndicator.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    img_Hanger = nil;
    view_Footer = nil;
    view_FooterHeader = nil;
    btn_Back = nil;
    btn_FaceBook = nil;
    btn_Login = nil;
    btn_Privacy = nil;
    btn_SignUP = nil;
    btn_TermsOfService = nil;
    lbl_FaceBook = nil;
    lbl_Register = nil;
    img_FaceBook = nil;
    webViewTPS = nil;
    activityIndicator = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lat and long of the location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil)
    {
        str_Latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        str_Longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    }
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            
            str_City = [NSString stringWithFormat:@"%@",placemark.locality];
            str_State = [NSString stringWithFormat:@"%@",placemark.administrativeArea];
            str_HomeZipCode = [NSString stringWithFormat:@"%@",placemark.postalCode];
            str_Country = [NSString stringWithFormat:@"%@",placemark.ISOcountryCode];
        }
        else
        {
        }
    } ];
    
    [manager stopUpdatingLocation];
    locationManager.delegate = nil;
}

#pragma mark - Login & SignUp

- (IBAction)act_Login:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            loginVC = [[ICELoginViewController alloc] initWithNibName:@"ICELoginViewController" bundle:nil];
        }
        else
        {
            //iPhone 4 Version
            loginVC = [[ICELoginViewController alloc] initWithNibName:@"ICELoginViewController_iPhone4" bundle:nil];
            
        }
    }
	else
	{
        //iPad Version
    }
    loginVC.backgroundImage_backview=[self takescreenshotes];
    [self presentViewController:loginVC animated:YES completion:nil];
    
}

- (IBAction)act_SignUp:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            signUPVC = [[ICESignUPViewController alloc] initWithNibName:@"ICESignUPViewController" bundle:nil];
        }
        else
        {
            //iPhone 4 Version
            signUPVC = [[ICESignUPViewController alloc] initWithNibName:@"ICESignUPViewController_iPhone4" bundle:nil];
        }
    }
	else
	{
        //iPad Version
    }
    signUPVC.backgroundImage_backview=[self takescreenshotes];
    [self presentViewController:signUPVC animated:YES completion:nil];
    
}

#pragma mark - Open Terms of Service , Privacy Policy & Settings
- (IBAction)act_TermsOfService:(id)sender
{
    //Open TermsOfService in Local Webview
    webViewTPS.delegate = self;
    webViewTPS.hidden = NO;
    loginView.hidden = YES;
    NSString *websiteaddress = @"http://www.everydayluxury.com/";
    NSURL *url = [NSURL URLWithString:websiteaddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) [webViewTPS loadRequest:request];
                               else if (error != nil) NSLog(@"Error: %@", error);
                           }];
}

- (IBAction)act_PrivacyPolicy:(id)sender
{
    //Open PrivacyPolicy in Local Webview
    webViewTPS.delegate = self;
    webViewTPS.hidden = NO;
    loginView.hidden = YES;
    NSString *websiteaddress = @"http://www.everydayluxury.com/";
    NSURL *url = [NSURL URLWithString:websiteaddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) [webViewTPS loadRequest:request];
                               else if (error != nil) NSLog(@"Error: %@", error);
                           }];
}

#pragma mark - UIWebView Delegate
//Called whenever the view starts loading something
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
}

//Called whenever the view finished loading something
- (void)webViewDidFinishLoad:(UIWebView *)webView_
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    btn_Back.hidden = NO;
}

- (IBAction)act_Back:(id)sender
{
    webViewTPS.hidden = YES;
    btn_Back.hidden = YES;
}

#pragma mark - FaceBook & FaceBook Delegate Methods

- (IBAction)act_FaceBook:(id)sender
{
    if (![FBSession.activeSession isOpen])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",@"publish_actions", nil];
        [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:true completionHandler:^(FBSession *session,FBSessionState status,NSError *error)
         {
             // Did something go wrong during login? I.e. did the user cancel?
             if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening)
             {
                 // If so, just send them round the loop again
                 [[FBSession activeSession] closeAndClearTokenInformation];
                 [FBSession setActiveSession:nil];
                 FBSession* session = [[FBSession alloc] init];
                 [FBSession setActiveSession: session];
             }
             else
             {
                 //                 NSLog(@"Successfully logged in");
                 str_FaceBookToken = [[[FBSession activeSession] accessTokenData] accessToken];
                 
                 // Save the session locally
                 // Make the API request that uses FQL
                 [FBRequestConnection startWithGraphPath:@"/me?fields=id,name,email,first_name,last_name,gender" completionHandler:^(FBRequestConnection *connection,id result,NSError *error)
                  {
                      if (error)
                      {
                          NSLog(@"ERror : %@",error);
                      }
                      else
                      {
                          NSLog(@"Result:%@",result);
                          if (session.isOpen)
                          {
                              
                              str_FaceBookEmail = [result objectForKey:@"email"];
                              str_FaceBookUserID = [result objectForKey:@"id"];
                              str_FaceBookFirstName = [result objectForKey:@"first_name"];
                              str_FaceBookLastName = [result objectForKey:@"last_name"];
                              NSString *str_Sex = [result objectForKey:@"gender"];
                              if ([str_Sex isEqualToString:@"male"])
                              {
                                  str_FaceBookUserSex = @"Male";
                              }
                              else
                              {
                                  str_FaceBookUserSex = @"Female";
                              }
                              
                              NSString *str_FBUserID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"fbuserID"]];
                              
                              if ([str_FBUserID isEqualToString:str_FaceBookUserID])
                              {
                                  HUD = [[MBProgressHUD alloc] initWithView:self.view];
                                  [self.view addSubview:HUD];
                                  
                                  HUD.dimBackground = NO;
                                  // Regiser for HUD callbacks so we can remove it from the window at the right time
                                  HUD.delegate = self;
                                  // Show the HUD while the provided method executes in a new thread
                                  [HUD showWhileExecuting:@selector(productListPage) onTarget:self withObject:nil animated:YES];
                                  
                              }
                              else
                              {
                                  HUD = [[MBProgressHUD alloc] initWithView:self.view];
                                  [self.view addSubview:HUD];
                                  
                                  HUD.dimBackground = NO;
                                  // Regiser for HUD callbacks so we can remove it from the window at the right time
                                  HUD.delegate = self;
                                  // Show the HUD while the provided method executes in a new thread
                                  [HUD showWhileExecuting:@selector(faceBookSignUP) onTarget:self withObject:nil animated:YES];
                              }
                          }
                      }
                  }];
             }
         }];
    }
}

- (void)faceBookSignUP
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user[current_location[lat]]=%@",str_Latitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[long]]=%@",str_Longitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[zipcode]]=%@",str_HomeZipCode]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[country]]=%@",str_Country]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[state]]=%@",str_State]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[city]]=%@",str_City]];
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[email]=%@",str_FaceBookEmail]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[first_name]]=%@",str_FaceBookFirstName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[last_name]]=%@",str_FaceBookLastName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[gender]]=%@",str_FaceBookUserSex]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[long_token]]=%@",str_FaceBookToken]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[provider]]=Facebook"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[account_id]]=%@",str_FaceBookUserID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[uid]]=%@",str_DeviceUUID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[device_type]]=%@",str_DeviceType]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[os_version]]=%@",str_DeviceOSVersion]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"FaceBook SignUP Request : %@",url);
	NSMutableURLRequest *urlRequest =
	[NSMutableURLRequest requestWithURL:url];
	[urlRequest setTimeoutInterval:60.0f];
	[urlRequest setHTTPMethod:@"POST"];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if ([data length] >0  && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Facebook signUP : %@",jsonObject);
            NSString *str_APIKey = (NSString *)[jsonObject valueForKey:@"api_key"];
            if (str_APIKey.length > 0)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
                
                [[NSUserDefaults standardUserDefaults] setObject:str_FaceBookUserID forKey:@"fbuserID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_FBemail = [NSString stringWithFormat:@"%@",str_FaceBookEmail];
                
                [[NSUserDefaults standardUserDefaults] setObject:str_FBemail forKey:@"fbemail"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *str_FaceBookAuthentication = @"Facebook";
                [[NSUserDefaults standardUserDefaults] setObject:str_FaceBookAuthentication forKey:@"fbauthentication"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setObject:str_APIKey forKey:@"api_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *str_Email = (NSString *)[jsonObject valueForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:str_Email forKey:@"useremail"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_FirstName = (NSString *)[jsonObject valueForKey:@"first_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_FirstName forKey:@"userfirstname"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_LastName = (NSString *)[jsonObject valueForKey:@"last_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_LastName forKey:@"userlastname"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_TemperatureUnit = @"F";
                [[NSUserDefaults standardUserDefaults] setObject:str_TemperatureUnit forKey:@"usertemperatureunit"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userDateOfBirth"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userMobileNumber"];
                [[NSUserDefaults standardUserDefaults] synchronize];
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
                obj_ParentVC.str_SignUpFlag = @"YES";
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self presentViewController:obj_ParentVC animated:NO completion:nil];
                });
            }
            else
            {
                UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertsuccess show];
            }
        }
        else if ([data length] >0  && error != nil)
        {
            error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (jsonObject != nil && error == nil)
            {
                UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertsuccess show];
                
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
}

- (void)productListPage
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users/sign_in.json";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user[email]=%@",str_FaceBookEmail]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[provider]]=Facebook"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[os_version]]=%@",str_DeviceOSVersion]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[device_type]]=%@",str_DeviceType]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[uid]]=%@",str_DeviceUUID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[account_id]]=%@",str_FaceBookUserID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[long_token]]=%@",str_FaceBookToken]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Facebook Login Request: %@",url);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"POST"];
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
            NSLog(@"Facebook Login Response : %@",jsonObject);
            NSString *str_APIKey = (NSString *)[jsonObject valueForKey:@"api_key"];
            NSMutableDictionary *mutDict = [jsonObject objectForKey:@"authentications"];
            NSMutableArray *pro = (NSMutableArray *)[mutDict valueForKey:@"provider"];
            for (NSString *strPro in pro)
            {
                if ([strPro isEqualToString:@"Twitter"])
                {
                    NSString *str_TwitterAuthentication = @"Twitter";
                    [[NSUserDefaults standardUserDefaults] setObject:str_TwitterAuthentication forKey:@"tauthentication"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else if([strPro isEqualToString:@"Facebook"])
                {
                    NSString *str_FaceBookAuthentication = @"Facebook";
                    [[NSUserDefaults standardUserDefaults] setObject:str_FaceBookAuthentication forKey:@"fbauthentication"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    
                }
            }
            if (str_APIKey.length > 0)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
                
                [[NSUserDefaults standardUserDefaults] setObject:str_APIKey forKey:@"api_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *str_Email = (NSString *)[jsonObject valueForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:str_Email forKey:@"useremail"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_FirstName = (NSString *)[jsonObject valueForKey:@"first_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_FirstName forKey:@"userfirstname"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_LastName = (NSString *)[jsonObject valueForKey:@"last_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_LastName forKey:@"userlastname"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_TemperatureUnit = (NSString *)[jsonObject valueForKey:@"temperature_unit"];
                [[NSUserDefaults standardUserDefaults] setObject:str_TemperatureUnit forKey:@"usertemperatureunit"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
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
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self presentViewController:obj_ParentVC animated:NO completion:nil];
                });
            }
            else
            {
                UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertsuccess show];
            }
        }
    }
    else if ([data length] >0  && error != nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (jsonObject != nil && error == nil)
        {
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertsuccess show];
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

#pragma mark - Screen Animation

-(UIImage *)takescreenshotes{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
