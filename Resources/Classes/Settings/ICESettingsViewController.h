//
//  ICESettingsViewController.h
//  monMode
//
//  Created by Muthu Sabari on 7/22/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ICESettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic)  IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic) UIImage * backgroundImage_backview;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (strong, nonatomic) IBOutlet UIView *view_Header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_HeaderTitle;
@property (weak, nonatomic) IBOutlet UIButton *btn_UpdateUserInfo;
@property (weak, nonatomic) IBOutlet UIButton *btn_NotificationSettings;
@property (weak, nonatomic) IBOutlet UIButton *btn_TemperatureUnit;
@property (weak, nonatomic) IBOutlet UIButton *btn_Celcius;
@property (weak, nonatomic) IBOutlet UIButton *btn_Farhendreit;
@property (weak, nonatomic) IBOutlet UIImageView *img_UpdateArrow;
@property (weak, nonatomic) IBOutlet UIImageView *img_NotificationArrow;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

- (IBAction)act_Back:(id)sender;
- (IBAction)act_Update:(id)sender;
- (IBAction)act_Notification:(id)sender;
- (IBAction)act_Celcius:(id)sender;
- (IBAction)act_Farhendeit:(id)sender;

@end
