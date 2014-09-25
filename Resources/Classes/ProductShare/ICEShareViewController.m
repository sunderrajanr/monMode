//
//  ICEShareViewController.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/2/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEShareViewController.h"
#import <Social/Social.h>
#import "FHSTwitterEngine.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ICESettingsViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

#define CONSUMER_KEY @"CWZTXOWR9AomlBbCTZTCHpUor"
#define SECRECT_KEY @"qzZGbqVpJbUClB7kQtsuIsi57vPbd6hk6StNd4X6JcSkoft8bh"

@interface ICEShareViewController ()<FHSTwitterEngineAccessTokenDelegate,FBRequestDelegate>
{
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    
    NSData *data_detailImage;
    NSString *str_AuthenticationProvider;
    NSString *str_DeviceOSVersion;
    NSString *str_DeviceType;
    NSString *str_DeviceUUID;
    //FaceBook
    NSString *str_FaceBookToken;
    NSString *str_FaceBookEmail;
    NSString *str_FaceBookUserID;
    NSString *str_FaceBookName;
    //Twitter
    NSString *str_oauthToken;
    NSString *str_oauthSecretToken;
    NSString *str_TwitterUserID;
    //string lenth
    NSString *Str_LenthCountComment;
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    NSString *str_Latitude;
    NSString *str_Longitude;
    NSString *str_FirstName;
    NSString *str_LastName;
    NSString *str_Gender;
    NSString *str_Random;
    NSString *str_Comment;
    
    NSMutableDictionary *dict;
    NSMutableArray *mutarrAlert;
    
    BOOL isFBclick;
    BOOL isTclick;
    BOOL isFBShare;
    BOOL isTShare;
    int count;
    NSString *str_ShareErrorMsg;
}
@end

@implementation ICEShareViewController
@synthesize detailedImage,img_detail,str_APIKey,str_ProductID,str_ShareImageURL;
@synthesize backgroundImage_backview,backView,backViewImage,frontView;
@synthesize btn_Back,btn_FaceBook,btn_Twitter,view_Header,str_BrandNameToShare;
@synthesize txt_AddComment,lbl_CommentLimit,img_CommentLine,img_FaceBook,lbl_FaceBook,img_Twitter,lbl_Twitter,btn_Share;
int lenth=110;

#pragma mark - View Life Cycle
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
    
    count = 0;
    isFBShare = NO;
    isTShare = NO;
    txt_AddComment.delegate = self;
    mutarrAlert = [[NSMutableArray alloc] init];
    img_detail.contentMode = UIViewContentModeScaleAspectFit;
    
    [img_detail setImageWithURL:[NSURL URLWithString:str_ShareImageURL]];
    dict = [[NSMutableDictionary alloc] init];
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    str_DeviceUUID = [dev.identifierForVendor  UUIDString];
    str_DeviceOSVersion = [UIDevice currentDevice].systemVersion;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FbClicked"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TClicked"];
    
    //Twitter Login and set Delegate
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:CONSUMER_KEY andSecret:SECRECT_KEY];
    
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    [self addSiginIn_gesture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    
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
- (void)siginIn_pan:(UIPanGestureRecognizer*)gesture
{
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


#pragma mark - UITextField Delegate Methods
- (IBAction)act_HideKB:(id)sender
{
    [txt_AddComment resignFirstResponder];
    
}
-(IBAction) textFieldDidUpdate:(id)sender
{
	UITextField * textField = (UITextField *) sender;
	int maxChars = 110;
	int charsLeft = maxChars - (int)[textField.text length];
    
	if(charsLeft == 0)
    {
	}
    if (lbl_CommentLimit.text.length==110)
    {
        
    }
    else
    {
        lbl_CommentLimit.text = [NSString stringWithFormat:@"%d",charsLeft];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   	if (textField == txt_AddComment)
	{
		str_Comment = [NSString stringWithFormat:@"%@",textField.text];
	}
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txt_AddComment)
    {
    }
}
-(void)updateLabel
{
    // Get the text from the message
    // find the length of the text
    // subtract from the converted number in the charCounter Label
    // display in the charCounter Label
    int charLeft;
    NSInteger length = txt_AddComment.text.length;
    if (length==0)
    {
        charLeft = 110 - ((int)length+1);
        
    }
    else
    {
        charLeft = 110 - ((int)length+1);
    }
    NSString* charCountStr = [NSString stringWithFormat:@"%i", charLeft];
    lbl_CommentLimit.text = charCountStr;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text isEqualToString:@""])
    {
    }
    int len = (int)[textField.text length];
    if( len + string.length > 110)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - Sharing
- (IBAction)act_Share:(id)sender
{
    if (txt_AddComment.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Add Comments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
    else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        isFBclick=[defaults boolForKey:@"FbClicked"];
        isTclick=[defaults boolForKey:@"TClicked"];
        if (isFBclick == YES && isTclick == YES)
        {
            isTShare = [self twitterShare];
            isFBShare = [self faceBookShare];
            [defaults setBool:NO forKey:@"FbClicked"];
            [defaults setBool:NO forKey:@"TClicked"];
            [defaults synchronize];
            [self shareBack:isTShare :isFBShare];
        }
        else if (isFBclick == YES && isTclick == NO)
        {
            isFBShare = [self faceBookShare];
            isTShare = YES;
            [defaults setBool:NO forKey:@"FbClicked"];
            [defaults synchronize];
            [self shareBack:isTShare :isFBShare];
        }
        else if (isFBclick == NO && isTclick == YES)
        {
            isFBShare = YES;
            isTShare = [self twitterShare];
            [defaults setBool:NO forKey:@"TClicked"];
            [defaults synchronize];
            [self shareBack:isTShare :isFBShare];
        }
        else if (isFBclick == NO && isTclick == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"monMOde" message:@"Choose AnyOne" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//OK button pressed
    {
        isTShare = YES;
        isFBShare = YES;
        [self shareBack:isTShare :isFBShare];
    }
}

- (void)shareBack:(BOOL)ifFBShared :(BOOL)ifTwitShared
{
    if (ifFBShared == YES && ifTwitShared == YES)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:str_ShareErrorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
}

#pragma mark - FaceBook Sharing
- (IBAction)act_Facebook:(id)sender
{
    NSString *authentication = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"fbauthentication"]];
    if (![authentication isEqualToString:@"Facebook"])
    {
        [self login];
    }
    else
    {
        
    }
    UIImage *img_Checked=[[UIImage alloc]init];
    img_Checked = [UIImage imageNamed:@"mark_Circle.png"];
    UIImage *img_UnCheck=[[UIImage alloc]init];
    img_UnCheck = [UIImage imageNamed:@"circle.png"];
    UIButton *theButton = (UIButton *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isclick=[defaults boolForKey:@"FbClicked"];
    if (isclick==NO)
    {
        if ([theButton currentImage] == img_Checked)
        {
            [theButton setImage:img_UnCheck forState:UIControlStateNormal];
            [defaults setBool:NO forKey:@"FbClicked"];
            [defaults synchronize];
        }
        else
        {
            [defaults setBool:YES forKey:@"FbClicked"];
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
            [defaults setBool:NO forKey:@"FbClicked"];
            [defaults synchronize];
            
        }
        else
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"FbClicked"];
            [defaults synchronize];
            [theButton setImage:img_Checked forState:UIControlStateNormal];
        }
    }
}

- (BOOL)faceBookShare
{
    str_ProductID = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"productid"];
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/share.json",str_ProductID];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&provider=Facebook"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&message=%@",txt_AddComment.text]];
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"POST"];
    NSLog(@"FaceBook Share Request : %@",url);
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
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"FaceBook Share Response: %@",jsonObject);
                if ([[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"success"]] isEqualToString:@"true"])
                {
                    NSString *str_ShareCount = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"sharecount"]];
                    int lc = [str_ShareCount intValue];
                    int newLikeCount = lc+1;
                    NSString *str_NewShareCount = [NSString stringWithFormat:@"%d",newLikeCount];
                    [[NSUserDefaults standardUserDefaults] setObject:str_NewShareCount forKey:@"sharecount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    count +=1;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return YES;
                    
                }
                else
                {
                    count +=1;
                    str_ShareErrorMsg = [NSString stringWithFormat:@"FaceBook : %@",[jsonObject objectForKey:@"error"]];
                    return NO;
                }
            }
        }
        else if (error != nil)
        {
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
            [alertsuccess show];
        }
        else if ([data length] == 0 && error == nil)
        {
            
        }
    }
    return YES;
}

#pragma mark -
#pragma mark FBSessionDelegate methods

- (void)login
{
    if (![FBSession.activeSession isOpen])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",@"publish_actions", nil];
        
        [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:true completionHandler:^(FBSession *session,FBSessionState status,NSError *error)
         
         {
             NSLog(@"Error : %@",error);
             // Did something go wrong during login? I.e. did the user cancel?
             if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening)
             {
                 // If so, just send them round the loop again
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool:NO forKey:@"FbClicked"];
                 [defaults synchronize];
                 
                 UIImage *img_UnCheck=[[UIImage alloc]init];
                 img_UnCheck = [UIImage imageNamed:@"circle.png"];
                 [btn_FaceBook setImage:img_UnCheck forState:UIControlStateNormal];
                 
                 [[FBSession activeSession] closeAndClearTokenInformation];
                 [FBSession setActiveSession:nil];
                 FBSession* session = [[FBSession alloc] init];
                 [FBSession setActiveSession: session];
             }
             else
             {
                 str_FaceBookToken = [[[FBSession activeSession] accessTokenData] accessToken];
                 // Updates our game now we've logged in
                 // Save the session locally
                 // Make the API request that uses FQL
                 [FBRequestConnection startWithGraphPath:@"/me?fields=id,name,email,first_name,last_name,gender" completionHandler:^(FBRequestConnection *connection,id result,NSError *error)
                  {
                      if (error)
                      {
                          NSLog(@"Error");
                      }
                      else
                      {
                          
                          if (session.isOpen)
                          {
                              str_FaceBookEmail = [result objectForKey:@"email"];
                              str_FaceBookUserID = [result objectForKey:@"id"];
                              str_FaceBookName = [result objectForKey:@"first_name"];
                              
                              NSArray *fullNamearr = [str_FaceBookName componentsSeparatedByString:@" "];
                              str_FirstName = [NSString stringWithFormat:@"%@",[fullNamearr objectAtIndex:0]];
                              NSMutableArray *mut = [NSMutableArray arrayWithArray:fullNamearr];
                              
                              [mut removeObjectAtIndex:0];
                              NSString *str = @"";
                              for (int i = 0; i<[mut count]; i++)
                              {
                                  str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ ",[mut objectAtIndex:i]]];
                              }
                              str_LastName = [NSString stringWithFormat:@"%@",str];
                              
                              [self updateUserAuthentication];
                          }
                      }
                  }];
             }
         }];
    }
}

- (void)updateUserAuthentication
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/users"];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?format=json"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[account_id]]=%@",str_FaceBookUserID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[long_token]]=%@",str_FaceBookToken]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[provider]]=Facebook"]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSLog(@"Update Facebook Auth Request : %@",url);
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
            NSLog(@"Update Facebook Auth Response : %@",jsonObject);
            NSString *str_FaceBookAuthentication = @"Facebook";
            [[NSUserDefaults standardUserDefaults] setObject:str_FaceBookAuthentication forKey:@"fbauthentication"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:str_FaceBookUserID forKey:@"fbuserID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if (error != nil)
    {
        
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    else if ([data length] == 0 && error == nil)
    {
        
    }
}

#pragma mark - Twitter Sharing

- (IBAction)act_Twitter:(id)sender
{
    NSString *authentication = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"tauthentication"]];
    
    if (![authentication isEqualToString:@"Twitter"])
    {
        UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success)
                                             {
                                                 if(success)
                                                 {
                                                     // get user ID from twitter
                                                     str_TwitterUserID = FHSTwitterEngine.sharedEngine.authenticatedID;
                                                     [self twitterUserAuthentication];
                                                 }
                                                 
                                             }];
        [self presentViewController:loginController animated:YES completion:nil];
    }
    else
    {
        
    }
    UIImage *img_Checked=[[UIImage alloc]init];
    img_Checked = [UIImage imageNamed:@"mark_Circle.png"];
    UIImage *img_UnCheck=[[UIImage alloc]init];
    img_UnCheck = [UIImage imageNamed:@"circle.png"];
    UIButton *theButton = (UIButton *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isclick=[defaults boolForKey:@"TClicked"];
    if (isclick==NO)
    {
        if ([theButton currentImage] == img_Checked)
        {
            [theButton setImage:img_UnCheck forState:UIControlStateNormal];
            [defaults setBool:NO forKey:@"TClicked"];
            [defaults synchronize];
            
        }
        else
        {
            [defaults setBool:YES forKey:@"TClicked"];
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
            [defaults setBool:NO forKey:@"TClicked"];
            [defaults synchronize];
            
        }
        else
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"TClicked"];
            [defaults synchronize];
            [theButton setImage:img_Checked forState:UIControlStateNormal];
            
        }
    }
    
}

// twitter store access token
- (void)storeAccessToken:(NSString *)accessToken
{
    NSArray *arr_TwitterToken = [accessToken componentsSeparatedByString:@"&"];
    NSString *str_oToken = [arr_TwitterToken objectAtIndex:0];
    NSString *str_oSecret = [arr_TwitterToken objectAtIndex:1];
    
    NSArray *arr_oauthToken = [str_oToken componentsSeparatedByString:@"="];
    str_oauthToken = [arr_oauthToken objectAtIndex:1];
    NSArray *arr_oauthSecretToken = [str_oSecret componentsSeparatedByString:@"="];
    str_oauthSecretToken = [arr_oauthSecretToken objectAtIndex:1];
}

- (void)twitterUserAuthentication
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/users"];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?format=json"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[account_id]]=%@",str_TwitterUserID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[oauth_token]]=%@",str_oauthToken]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[oauth_secret]]=%@",str_oauthSecretToken]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[authentication[provider]]=Twitter"]];
    
	NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSLog(@"Update Twitter Auth Request : %@",url);
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
            NSLog(@"Update Twitter Auth Response : %@",jsonObject);
            if (![[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"success"]] isEqualToString:[NSString stringWithFormat:@"0"]])
            {
                NSString *str_TwitterAuthentication = @"Twitter";
                [[NSUserDefaults standardUserDefaults] setObject:str_TwitterAuthentication forKey:@"tauthentication"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[jsonObject objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertsuccess show];
            }
        }
    }
    else if (error != nil)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    else if ([data length] == 0 && error == nil)
    {
        
    }
}

- (BOOL)twitterShare
{
    str_APIKey = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"];
    str_ProductID = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"productid"];
    NSString *urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/share.json",str_ProductID];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&provider=Twitter"]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&message=%@",txt_AddComment.text]];
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    NSLog(@"Twitter Share Request : %@",url);
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
        id jsonObject = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingAllowFragments
                         error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Twitter Share Response : %@",jsonObject);
            if ([[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"success"]] isEqualToString:@"true"])
            {
                NSString *str_ShareCount = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"sharecount"]];
                int lc = [str_ShareCount intValue];
                int newShareCount = lc+1;
                NSString *str_NewShareCount = [NSString stringWithFormat:@"%d",newShareCount];
                [[NSUserDefaults standardUserDefaults] setObject:str_NewShareCount forKey:@"sharecount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                count +=1;
                
                return YES;
            }
            else
            {
                count +=1;
                str_ShareErrorMsg = [NSString stringWithFormat:@"Twitter : %@",[jsonObject objectForKey:@"error"]];
                return NO;
            }
        }
        else if (error != nil)
        {
            
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
            alertsuccess.delegate = self;
            [alertsuccess show];
        }
        else if ([data length] == 0 && error == nil)
        {
            
        }
    }
    return YES;
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
