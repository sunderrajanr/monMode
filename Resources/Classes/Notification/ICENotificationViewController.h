//
//  ICENotificationViewController.h
//  monMode
//
//  Created by Muthu Sabari on 7/29/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ICENotificationViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *btn_Set;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (strong, nonatomic) IBOutlet UIView *view_Header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_HeaderTitle;

//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

- (IBAction)act_Back:(id)sender;
- (IBAction)act_Set:(id)sender;

@end
