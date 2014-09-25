//
//  ICESignUPViewController.h
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/3/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ICESignUPViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate,UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic) IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic)  UIImage * backgroundImage_backview;

@property (weak, nonatomic) IBOutlet UIView *view_Footer;
@property (weak, nonatomic) IBOutlet UIButton *btn_TermsOfService;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;

@property (strong, nonatomic) IBOutlet UIImageView *img_FullNameLine;
@property (strong, nonatomic) IBOutlet UIImageView *img_PhoneLine;
@property (strong, nonatomic) IBOutlet UIImageView *img_EmailLine;
@property (strong, nonatomic) IBOutlet UIImageView *img_PwdLine;
@property (strong, nonatomic) IBOutlet UIImageView *img_EmailLogo;
@property (strong, nonatomic) IBOutlet UIImageView *img_PwdLogo;
@property (strong, nonatomic) IBOutlet UIImageView *img_PhoneLogo;
@property (strong, nonatomic) IBOutlet UIImageView *img_FullNameLogo;
@property (weak, nonatomic) IBOutlet UITextField *txt_Email;
@property (weak, nonatomic) IBOutlet UITextField *txt_Password;
@property (weak, nonatomic) IBOutlet UITextField *txt_FirstName;

@property (weak, nonatomic) IBOutlet UIWebView *webViewTPS;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;

@property(strong,nonatomic) NSDictionary *deserializedDictionary;
@property (weak, nonatomic) IBOutlet UIButton *btn_Female;
@property (weak, nonatomic) IBOutlet UIButton *btn_Male;
@property (weak, nonatomic) IBOutlet UIButton *btn_FindMyFashion;
@property (weak, nonatomic) IBOutlet UITextField *txt_MobileNumber;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;


- (IBAction)signUP:(id)sender;
- (IBAction)hideKB:(id)sender;
- (IBAction)act_Female:(id)sender;
- (IBAction)act_Male:(id)sender;
- (IBAction)act_BackWebView:(id)sender;
- (IBAction)act_TermsOfService:(id)sender;
- (IBAction)act_PrivacyPolicy:(id)sender;


@end
