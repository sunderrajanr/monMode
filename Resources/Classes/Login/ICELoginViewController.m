//
//  ICELoginViewController.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/3/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICELoginViewController.h"
#import "Reachability.h"
#import "Flurry.h"
#import "ICEParentViewController.h"
#import "ICESingleTon.h"

@interface ICELoginViewController ()
{
    NSString *str_Username;
    NSString *str_Password;
    NSString *str_DeviceOSVersion;
    NSString *str_DeviceType;
    NSString *str_DeviceUUID;
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_LatitudeCity;
    NSString *str_LatitudeState;
    
    MBProgressHUD *HUD;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    
    ICEParentViewController *obj_ParentVC;
    
    CLLocationManager *locationManager;
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    UITextField * selectedTextField;
}


@end

@implementation ICELoginViewController
@synthesize txt_UserName,txt_Password,deserializedDictionary,webViewTPS,activityIndicator,btn_Back;
@synthesize backgroundImage_backview,backView,backViewImage,frontView,btn_CheckMark,lbl_RememberMe;
@synthesize view_Footer,btn_TermsOfService,btn_Privacy,img_emailLine,img_PwdLine,img_emailLogo,img_PwdLogo,btn_Forgot,btn_Login;
@synthesize loadingView,loadingAnimatingImage;

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
    
    loadingView.hidden = YES;
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
    
    txt_UserName.delegate = self;
    txt_Password.delegate = self;
    selectedTextField.delegate=self;
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    
    UIColor *color = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    
    txt_Password.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Password"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName : [UIFont fontWithName:@"Roboto-Regular" size:17.0]
                                                 }];

    // initialize location manager
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    str_DeviceUUID = [dev.identifierForVendor  UUIDString];
    str_DeviceOSVersion = [UIDevice currentDevice].systemVersion;
    
    [self addSiginIn_gesture];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isclick=[defaults boolForKey:@"checkboxclick"];
    if (isclick==YES)
    {
        txt_UserName.text = [defaults valueForKey:@"rememberemail"];
        txt_Password.text=@"";
        [btn_CheckMark setImage:[UIImage imageNamed:@"mark_Circle.png"] forState:UIControlStateNormal];
    }
    else
    {
        txt_UserName.text=@"";
        txt_Password.text=@"";
        [btn_CheckMark setImage:[UIImage imageNamed:@"circle.png"] forState:UIControlStateNormal];
    }
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
            [selectedTextField resignFirstResponder];
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login

- (IBAction)act_Login:(id)sender
{
    [Flurry logEvent:@"Login Button Clicked"];
    str_DeviceType = @"iOS";
    // Login Validation
    [txt_UserName resignFirstResponder];
    [txt_Password resignFirstResponder];
    if (txt_UserName.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
    else if(![self validateEmail:txt_UserName.text])
    {
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter Valid Email"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    //validate empty Password
    else if (txt_Password.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter Password"
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
        [HUD showWhileExecuting:@selector(login) onTarget:self withObject:nil animated:YES];
    }
    
}

- (void)login
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users/sign_in.json";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user[email]=%@",txt_UserName.text]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[password]=%@",txt_Password.text]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[os_version]]=%@",str_DeviceOSVersion]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[device_type]]=%@",str_DeviceType]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[device[uid]]=%@",str_DeviceUUID]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Login Request : %@",url);
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
            NSLog(@"Login Response : %@",jsonObject);
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)
    {
        if(buttonIndex == 0)//OK button pressed
        {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if(buttonIndex == 1)//Tryagain button pressed.
        {
            
            [self login];
        }
    }
    else if(alertView.tag ==1)
    {
        if(buttonIndex == 0)//OK button pressed
        {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if(buttonIndex == 1)//Tryagain button pressed.
        {
            [self forgotPassword];
        }
    }
}

- (IBAction)act_CheckRememberMe:(id)sender
{
    UIImage *img_Checked=[[UIImage alloc]init];
    img_Checked = [UIImage imageNamed:@"mark_Circle.png"];
    UIImage *img_UnCheck=[[UIImage alloc]init];
    img_UnCheck = [UIImage imageNamed:@"circle.png"];
    UIButton *theButton = (UIButton *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isclick=[defaults boolForKey:@"checkboxclick"];
    if (isclick==NO)
    {
        if ([theButton currentImage] == img_Checked)
        {
            [theButton setImage:img_UnCheck forState:UIControlStateNormal];
            [defaults setValue:str_Username forKey:@"rememberemail"];
            
            [defaults setBool:NO forKey:@"checkboxclick"];
            [defaults synchronize];
        }
        else
        {
            str_Username=txt_UserName.text;
            str_Password=txt_Password.text;
            [defaults setValue:str_Username forKey:@"rememberemail"];
            [defaults setBool:YES forKey:@"checkboxclick"];
            [defaults synchronize];
            [theButton setImage:img_Checked forState:UIControlStateNormal];
        }
    }
    else
    {
        if ([theButton currentImage] == img_Checked)
        {
            [theButton setImage:img_UnCheck forState:UIControlStateNormal];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *new=@"";
            [defaults setValue:new forKey:@"rememberemail"];
            [defaults setBool:NO forKey:@"checkboxclick"];
            [defaults synchronize];
        }
        else
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:str_Username forKey:@"rememberemail"];
            [defaults setBool:YES forKey:@"checkboxclick"];
            [defaults synchronize];
            [theButton setImage:img_Checked forState:UIControlStateNormal];
            
        }
    }
}

#pragma mark - UITextField Delegate Methods

- (IBAction)act_HideKB:(id)sender
{
    [txt_UserName resignFirstResponder];
    [txt_Password resignFirstResponder];
}

- (void) animateTextView:(BOOL) up
{
	const int movementDistance =80.0;
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
	if (textField==txt_UserName)
	{
		str_Username = textField.text;
	}
	else if (textField == txt_Password)
	{
		str_Password = textField.text;
	}
    [self animateTextView : NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectedTextField = textField;
    if (textField==txt_Password)
    {
        
    }
    [self animateTextView : YES];
}

#pragma mark - Email Validation

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


#pragma mark - Forgot Password

- (IBAction)act_ForgotPassword:(id)sender
{
    txt_Password.text = @"";
    if (str_Username.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
    else if(![self validateEmail:str_Username])
    {
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please enter valid email"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        //[self.view bringSubviewToFront:HUD];
        HUD.dimBackground = NO;
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(forgotPassword) onTarget:self withObject:nil animated:YES];
    }
}

- (void)forgotPassword
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users/password";
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?format=json"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&email=%@",str_Username]];
	NSURL *url = [NSURL URLWithString:urlAsString];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"monMode" message:[jsonObject valueForKey:@"status"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
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

#pragma mark - lat and long of the location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    str_Latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    str_Longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    [manager stopUpdatingLocation];
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
