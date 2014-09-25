//
//  ICEPurchaseLinkViewController.h
//  monMode
//
//  Created by Muthu Sabari on 7/30/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPurchaseLinkViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic) IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic)  UIImage * backgroundImage_backview;
@property (weak, nonatomic) IBOutlet UIView *view_Header;
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (weak, nonatomic) IBOutlet UIWebView *webviewShopping;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) NSString *str_PurchaseLink;

- (IBAction)act_Back:(id)sender;
@end
