//
//  ICELoginViewController.h
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/3/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface ICELoginViewController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic) IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic)  UIImage * backgroundImage_backview;

@property (weak, nonatomic) IBOutlet UIView *view_Footer;
@property (weak, nonatomic) IBOutlet UIButton *btn_TermsOfService;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;
@property (weak, nonatomic) IBOutlet UIImageView *img_emailLine;
@property (weak, nonatomic) IBOutlet UIImageView *img_PwdLine;
@property (weak, nonatomic) IBOutlet UIImageView *img_emailLogo;
@property (weak, nonatomic) IBOutlet UIImageView *img_PwdLogo;
@property (weak, nonatomic) IBOutlet UIButton *btn_Forgot;
@property (weak, nonatomic) IBOutlet UIButton *btn_Login;

@property (weak, nonatomic) IBOutlet UITextField *txt_UserName;
@property (weak, nonatomic) IBOutlet UITextField *txt_Password;
@property (weak, nonatomic) IBOutlet UIWebView *webViewTPS;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property(strong,nonatomic) NSDictionary *deserializedDictionary;

@property (weak, nonatomic) IBOutlet UIButton *btn_CheckMark;
@property (weak, nonatomic) IBOutlet UILabel *lbl_RememberMe;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

@property (nonatomic , retain) IBOutlet UIView *loadingView;
@property (nonatomic , retain) IBOutlet UIImageView *loadingAnimatingImage;

- (IBAction)act_CheckRememberMe:(id)sender;
- (IBAction)act_Login:(id)sender;
- (IBAction)act_BackWebView:(id)sender;
- (IBAction)act_ForgotPassword:(id)sender;
- (IBAction)act_HideKB:(id)sender;
- (IBAction)act_TermsOfService:(id)sender;
- (IBAction)act_PrivacyPolicy:(id)sender;


@end
