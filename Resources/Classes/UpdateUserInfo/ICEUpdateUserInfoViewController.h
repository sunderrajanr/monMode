//
//  ICEUpdateUserInfoViewController.h
//  monMode
//
//  Created by Muthu Sabari on 7/29/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "DateTimePicker.h"
@interface ICEUpdateUserInfoViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txt_FullName;
@property (weak, nonatomic) IBOutlet UITextField *txt_Email;
@property (weak, nonatomic) IBOutlet UITextField *txt_MobileNumber;
@property (weak, nonatomic) IBOutlet UIButton *btn_Birthday;
@property (strong, nonatomic) UIDatePicker *datePicker_Birthday;
@property (weak, nonatomic) IBOutlet UIButton *btn_Edit;
@property (weak, nonatomic) IBOutlet UIButton *btn_Update;

- (IBAction)act_Edit:(id)sender;
- (IBAction)act_Birthday:(id)sender;
- (IBAction)act_Update:(id)sender;
- (IBAction)act_Back:(id)sender;
- (IBAction)act_DismissKeyboard:(id)sender;

@end
