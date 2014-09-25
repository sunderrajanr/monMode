//
//  ICESignUPViewController.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/3/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICESignUPViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "ICELoginViewController.h"
#import "ICEParentViewController.h"

#import "Flurry.h"

@interface ICESignUPViewController ()<MBProgressHUDDelegate>
{
    NSString *str_Password;
    NSString *str_VerifyPassword;
    NSString *str_emailId;
    NSString *str_FirstName;
    NSString *str_LastName;
    NSString *str_Gender;
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_HomeZipCode;
    NSString *str_Country;
    NSString *str_City;
    NSString *str_State;
    NSString *str_Format;
    NSString *str_MobileNumber;
    NSString *str_DeviceOSVersion;
    NSString *str_DeviceType;
    NSString *str_DeviceUUID;
    
    MBProgressHUD *HUD;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    
    ICEParentViewController *obj_ParentVC;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    int countWetGeocode;
    
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    UITextField *selectedTextField;
    
}
@end

@implementation ICESignUPViewController
@synthesize txt_Email,txt_Password,deserializedDictionary,btn_Female,btn_Male,txt_MobileNumber;
@synthesize txt_FirstName,btn_FindMyFashion;
@synthesize webViewTPS,activityIndicator,btn_Back,img_FullNameLogo,img_PwdLogo,img_EmailLogo,img_PhoneLogo;
@synthesize backgroundImage_backview,backView,backViewImage,frontView,img_EmailLine,img_FullNameLine,img_PhoneLine,img_PwdLine;
@synthesize view_Footer,btn_Privacy,btn_TermsOfService;

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
    
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor whiteColor]];
    
    // initialize location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    
    countWetGeocode = 1;
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    str_DeviceUUID = [dev.identifierForVendor  UUIDString];
    str_DeviceOSVersion = [UIDevice currentDevice].systemVersion;
    
    // text field delgate
    txt_Email.delegate=self;
    txt_Password.delegate=self;
    txt_FirstName.delegate = self;
    txt_MobileNumber.delegate = self;
    str_Gender = @"Female";
    
    //Set Number Pad for PhoneNumber TextField
    UIToolbar* numberToolbar1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar1.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad2)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad2)],
                            nil];
    txt_MobileNumber.inputAccessoryView = numberToolbar1;
    [self addSiginIn_gesture];
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

- (void)viewDidDisappear:(BOOL)animated
{
    
}

#pragma mark - Back Screen Animation
-(void)addSiginIn_gesture
{
    backViewImage.image=backgroundImage_backview;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(siginIn_pan:)];
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [frontView addGestureRecognizer:pan];
}
- (void)siginIn_pan:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if (selectedTextField && [selectedTextField isFirstResponder])
        {
            [selectedTextField resignFirstResponder];
        }
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


- (void)cancelNumberPad2
{
    [txt_MobileNumber resignFirstResponder];
    txt_MobileNumber.text = @"";
}

- (void)doneWithNumberPad2
{
    [txt_MobileNumber resignFirstResponder];
}

#pragma mark - Choose Male or Female
- (IBAction)act_Female:(id)sender
{
    //Female Selection
    str_Gender = nil;
    [btn_Female setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
    [btn_Male setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
    str_Gender = @"Female";
}

- (IBAction)act_Male:(id)sender
{
    //Male Selection
    str_Gender = nil;
    [btn_Female setBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
    [btn_Male setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:8.0/255.0 blue:74.0/255.0 alpha:1]];
    str_Gender = @"Male";
}


#pragma mark - UITextField Delegate Methods
- (IBAction)hideKB:(id)sender
{
    [txt_Email resignFirstResponder];
    
    [txt_Password resignFirstResponder];
    [txt_FirstName resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectedTextField = textField;
    if (textField == txt_Email)
    {
        [self animateTextView : YES moveDistance:0];
    }
    else if (textField == txt_MobileNumber)
    {
        [self animateTextView : YES moveDistance:0];
    }
    else
    {
        [self animateTextView : YES moveDistance:0];
    }
}

- (void)animateTextView:(BOOL) up moveDistance:(float)height
{
	const int movementDistance =height;
	const float movementDuration = 0.3f;
	int movement= movement = (up ? -movementDistance : movementDistance);
	[UIView beginAnimations: @"anim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	frontView.frame = CGRectOffset(frontView.frame, 0, movement);
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    selectedTextField = nil;
	if (textField == txt_Email)
    {
        [self animateTextView : NO moveDistance:0];
    }
    else if (textField == txt_MobileNumber)
    {
        [self animateTextView : NO moveDistance:0];
        str_MobileNumber=txt_MobileNumber.text;
        int length = [self getLength:textField.text];
        NSRange range;
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 10)
        {
            NSString *num = [self formatNumber:textField.text];
            str_MobileNumber=num;
        }
    }
    else //if (textField == txt_phoneNumber)
    {
        [self animateTextView : NO moveDistance:0];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==txt_MobileNumber)
    {
        int length = [self getLength:textField.text];
        //NSLog(@"Length  =  %d ",length);
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@-",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            
            textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
        return YES;
    }
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    return length;
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
            countWetGeocode = 1;
            
        }
        else
        {
            
        }
    } ];
    
    [manager stopUpdatingLocation];
    locationManager.delegate = nil;
}

#pragma mark - FindMyFashion Process
- (IBAction)signUP:(id)sender
{
    [Flurry logEvent:@"Sign UP Button Clicked"];
    //Validating SignUp Process
    
    [txt_Password resignFirstResponder];
    [txt_Email resignFirstResponder];
    [txt_MobileNumber resignFirstResponder];
    
    if (txt_FirstName.text.length ==0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter Full Name"
                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else
    {
        NSArray *fullNamearr = [txt_FirstName.text componentsSeparatedByString:@" "];
        str_FirstName = [NSString stringWithFormat:@"%@",[fullNamearr objectAtIndex:0]];
        NSMutableArray *mut = [NSMutableArray arrayWithArray:fullNamearr];
        
        [mut removeObjectAtIndex:0];
        NSString *str = @"";
        for (int i = 0; i<[mut count]; i++)
        {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ ",[mut objectAtIndex:i]]];
        }
        str_LastName = [NSString stringWithFormat:@"%@",str];
    }
    
    //Validate Email
    if (txt_Email.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please enter email address"
                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if(![self validateEmail:txt_Email.text])
    {
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please enter valid email id"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    //Validate Empty Password
    else if (txt_Password.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please enter password"
                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if(![self isPasswordValid:txt_Password.text])
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Password should have minimum 8 characters"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if (str_MobileNumber.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Mobile Number should have minimum 10 digits"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if (str_MobileNumber.length<10 ||str_MobileNumber.length>10)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter valid Mobile Number"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.dimBackground = NO;
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(siginUp) onTarget:self withObject:nil animated:YES];
    }
}

- (void)siginUp
{
    str_DeviceType = @"iOS";
    
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user[current_location[lat]]=%@",str_Latitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[long]]=%@",str_Longitude]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[zipcode]]=%@",str_HomeZipCode]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[country]]=%@",str_Country]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[state]]=%@",str_State]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[current_location[city]]=%@",str_City]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[email]=%@",txt_Email.text]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[first_name]]=%@",str_FirstName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[last_name]]=%@",str_LastName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[gender]]=%@",str_Gender]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[profile[mobile_number]]=%@",str_MobileNumber]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[uid]]=%@",str_DeviceUUID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[device_type]]=%@",str_DeviceType]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[os_version]]=%@",str_DeviceOSVersion]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[password]=%@",txt_Password.text]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"SignUp Request : %@",url);
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
            NSLog(@"SignUp Response : %@",jsonObject);
            [HUD removeFromSuperview];
            NSString *str_APIKey = (NSString *)[jsonObject valueForKey:@"api_key"];
            if (str_APIKey.length > 0)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
                
                [[NSUserDefaults standardUserDefaults] setObject:str_APIKey forKey:@"api_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *str_Email = (NSString *)[jsonObject valueForKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:str_Email forKey:@"useremail"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_FirstNameRes = (NSString *)[jsonObject valueForKey:@"first_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_FirstNameRes forKey:@"userfirstname"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *str_LastNameRes = (NSString *)[jsonObject valueForKey:@"last_name"];
                [[NSUserDefaults standardUserDefaults] setObject:str_LastNameRes forKey:@"userlastname"];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)
    {
        if(buttonIndex == 0)//OK button pressed
        {
            //do something
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if(buttonIndex == 1)//Tryagain button pressed.
        {
            //do something
            [self siginUp];
        }
    }
}

- (IBAction)act_Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  email validation
// email vaildation
-(BOOL)validatephonenumber:(NSString *)phonenumber
{
    NSString *emailRegex = @"^[0-9]*$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	//NSRange aRange;
    return [emailTest evaluateWithObject:phonenumber];
}

- (BOOL)validateEmail:(NSString *)email
{
	NSString *emailRegex = @"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";//@"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	NSRange aRange;
	if([emailTest evaluateWithObject:email])
	{
		aRange = [email rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [email length])];
        NSUInteger indexOfDot = 0;
        if (aRange.location)
        {
            indexOfDot = [NSNumber numberWithLongLong: aRange.location].unsignedIntValue;
        }
        //		int indexOfDot = aRange.location;
		if(aRange.location != NSNotFound)
        {
			NSString *topLevelDomain = [email substringFromIndex:indexOfDot];
			topLevelDomain = [topLevelDomain lowercaseString];
			NSSet *TLD;
			TLD = [NSSet setWithObjects:@".aero", @".asia", @".biz", @".cat", @".com", @".coop", @".edu", @".gov", @".info", @".int", @".jobs", @".mil", @".mobi", @".museum", @".name", @".net", @".org", @".pro", @".tel", @".travel", @".ac", @".ad", @".ae", @".af", @".ag", @".ai", @".al", @".am", @".an", @".ao", @".aq", @".ar", @".as", @".at", @".au", @".aw", @".ax", @".az", @".ba", @".bb", @".bd", @".be", @".bf", @".bg", @".bh", @".bi", @".bj", @".bm", @".bn", @".bo", @".br", @".bs", @".bt", @".bv", @".bw", @".by", @".bz", @".ca", @".cc", @".cd", @".cf", @".cg", @".ch", @".ci", @".ck", @".cl", @".cm", @".cn", @".co", @".cr", @".cu", @".cv", @".cx", @".cy", @".cz", @".de", @".dj", @".dk", @".dm", @".do", @".dz", @".ec", @".ee", @".eg", @".er", @".es", @".et", @".eu", @".fi", @".fj", @".fk", @".fm", @".fo", @".fr", @".ga", @".gb", @".gd", @".ge", @".gf", @".gg", @".gh", @".gi", @".gl", @".gm", @".gn", @".gp", @".gq", @".gr", @".gs", @".gt", @".gu", @".gw", @".gy", @".hk", @".hm", @".hn", @".hr", @".ht", @".hu", @".id", @".ie", @" No", @".il", @".im", @".in", @".io", @".iq", @".ir", @".is", @".it", @".je", @".jm", @".jo", @".jp", @".ke", @".kg", @".kh", @".ki", @".km", @".kn", @".kp", @".kr", @".kw", @".ky", @".kz", @".la", @".lb", @".lc", @".li", @".lk", @".lr", @".ls", @".lt", @".lu", @".lv", @".ly", @".ma", @".mc", @".md", @".me", @".mg", @".mh", @".mk", @".ml", @".mm", @".mn", @".mo", @".mp", @".mq", @".mr", @".ms", @".mt", @".mu", @".mv", @".mw", @".mx", @".my", @".mz", @".na", @".nc", @".ne", @".nf", @".ng", @".ni", @".nl", @".no", @".np", @".nr", @".nu", @".nz", @".om", @".pa", @".pe", @".pf", @".pg", @".ph", @".pk", @".pl", @".pm", @".pn", @".pr", @".ps", @".pt", @".pw", @".py", @".qa", @".re", @".ro", @".rs", @".ru", @".rw", @".sa", @".sb", @".sc", @".sd", @".se", @".sg", @".sh", @".si", @".sj", @".sk", @".sl", @".sm", @".sn", @".so", @".sr", @".st", @".su", @".sv", @".sy", @".sz", @".tc", @".td", @".tf", @".tg", @".th", @".tj", @".tk", @".tl", @".tm", @".tn", @".to", @".tp", @".tr", @".tt", @".tv", @".tw", @".tz", @".ua", @".ug", @".uk", @".us", @".uy", @".uz", @".va", @".vc", @".ve", @".vg", @".vi", @".vn", @".vu", @".wf", @".ws", @".ye", @".yt", @".za", @".zm", @".zw", nil];
			if(topLevelDomain != nil && ([TLD containsObject:topLevelDomain]))
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}

#pragma mark - pwd validation

// check password is greater than 6 charc and less than 32 char
-(BOOL) isPasswordValid:(NSString *)pwd
{
    pwd = txt_Password.text;
    if ( [pwd length]< 8 || [pwd length]>32 )
    {
		return NO;
    }
    else
    {
		return YES;
    }
}

#pragma mark - Open Terms of Service , Privacy Policy

- (IBAction)act_TermsOfService:(id)sender
{
    //Open TermsOfService in Local Webview
    webViewTPS.delegate = self;
    webViewTPS.hidden = NO;
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

- (IBAction)act_BackWebView:(id)sender
{
    webViewTPS.hidden = YES;
    btn_Back.hidden = YES;
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
