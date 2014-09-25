//
//  ICEShareViewController.h
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/2/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ICEShareViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic) IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic)  UIImage * backgroundImage_backview;

@property (strong, nonatomic) NSString *str_ProductID;
@property (strong, nonatomic) NSString *str_APIKey;
@property (strong, nonatomic) NSString *str_BrandNameToShare;
@property (strong,nonatomic) UIImage *detailedImage;
@property (weak, nonatomic) IBOutlet UIImageView *img_detail;
@property (strong, nonatomic) NSString *str_ShareImageURL;
@property (weak, nonatomic) IBOutlet UIButton *btn_FaceBook;
@property (weak, nonatomic) IBOutlet UIButton *btn_Twitter;
@property (weak, nonatomic) IBOutlet UIView *view_Header;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;

@property (weak, nonatomic) IBOutlet UITextField *txt_AddComment;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CommentLimit;
@property (weak, nonatomic) IBOutlet UIView *img_CommentLine;
@property (weak, nonatomic) IBOutlet UIImageView *img_FaceBook;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FaceBook;
@property (weak, nonatomic) IBOutlet UIImageView *img_Twitter;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Twitter;
@property (weak, nonatomic) IBOutlet UIButton *btn_Share;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

-(IBAction) textFieldDidUpdate:(id)sender;
- (IBAction)act_Facebook:(id)sender;
- (IBAction)act_Twitter:(id)sender;
- (IBAction)act_Back:(id)sender;
- (IBAction)act_Share:(id)sender;
- (IBAction)act_HideKB:(id)sender;

@end
