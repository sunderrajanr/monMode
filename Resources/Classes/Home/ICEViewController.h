//
//  ICEViewController.h
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 5/31/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Reachability.h"

@interface ICEViewController : UIViewController<FBLoginViewDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img_Hanger;
@property (weak, nonatomic) IBOutlet UIView *view_Footer;
@property (weak, nonatomic) IBOutlet UIView *view_FooterHeader;

@property (weak, nonatomic) IBOutlet UIButton *btn_TermsOfService;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;
@property (weak, nonatomic) IBOutlet UIButton *btn_Login;
@property (weak, nonatomic) IBOutlet UIButton *btn_SignUP;
@property (weak, nonatomic) IBOutlet UIButton *btn_FaceBook;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FaceBook;
@property (weak, nonatomic) IBOutlet UIImageView *img_FaceBook;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Register;


@property (weak, nonatomic) IBOutlet UIWebView *webViewTPS;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (strong,nonatomic) NSDictionary *deserializedDictionary;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

- (IBAction)act_Login:(id)sender;
- (IBAction)act_SignUp:(id)sender;
- (IBAction)act_FaceBook:(id)sender;

- (IBAction)act_TermsOfService:(id)sender;
- (IBAction)act_PrivacyPolicy:(id)sender;
- (IBAction)act_Back:(id)sender;


@end
