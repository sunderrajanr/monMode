//
//  ICEWeatherandProductListViewController.h
//  monMode
//
//  Created by Sunderrajan Ranganathan on 24/07/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
@protocol SampleProtocolDelegate <NSObject>
@required
- (void) hideView;
- (void) showView;
@end

@interface ICEWeatherandProductListViewController : UIViewController<RFQuiltLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,CLLocationManagerDelegate,UIViewControllerTransitioningDelegate,MBProgressHUDDelegate,UIGestureRecognizerDelegate>
{
    id <SampleProtocolDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

-(void)startHideView;
-(void)startShowView;
-(void)startNextDay:(NSString *)str_CurrentDay;
-(void)startPreviousDay:(NSString *)str_CurrentDay;

@property (weak, nonatomic) IBOutlet UICollectionView *productImageCollections;
/////Weather Objects/////
@property(strong, nonatomic) NSMutableArray *mutArr_HighCelcius;
@property (weak, nonatomic) IBOutlet UIImageView *img_MainWeather;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CityName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Day;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Degree;
@property (nonatomic)  UIActivityIndicatorView *activityIndi;
@property (weak, nonatomic) IBOutlet UILabel *lbl_WeatherNew;
@property (weak, nonatomic) IBOutlet UILabel *lbl_WindNew;
@property (weak, nonatomic) IBOutlet UILabel *lbl_POPNew;
@property (weak, nonatomic) IBOutlet UIImageView *img_POP;
@property (weak, nonatomic) IBOutlet UIImageView *img_Wind;
@property (strong, nonatomic) IBOutlet UILabel *lbl_LoadingForcast;

@property (weak, nonatomic) IBOutlet UIImageView *big_img_MainWeather;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_CityName;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_Day;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_Degree;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_WeatherNew;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_WindNew;
@property (weak, nonatomic) IBOutlet UILabel *big_lbl_POPNew;
@property (weak, nonatomic) IBOutlet UIImageView *big_img_POP;
@property (weak, nonatomic) IBOutlet UIImageView *big_img_Wind;

@property (strong, nonatomic) IBOutlet UILabel *big_lbl_LoadingForcast;
@property (strong, nonatomic) NSString *str_SignUpFlag;
@property (strong, nonatomic) UIImageView *referenceImageView;
@property (strong, nonatomic) NSString *str_day;

@property (strong, nonatomic) IBOutlet UIView *bigWeatherView;
@property (strong, nonatomic) IBOutlet UIView *smallWeatherView;
@property (strong, nonatomic) IBOutlet UIView *shodowView;

@property (strong, nonatomic) IBOutlet UIImageView *img_BottomShadow;
@property (strong, nonatomic) IBOutlet UIView *parrentView;
//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

@property (strong, nonatomic) IBOutlet UIImageView *ShodowImage;

@property (retain) NSIndexPath *path;
@property (strong, nonatomic) IBOutlet UIView *menu_view;
@property (strong, nonatomic) IBOutlet UIView *slide_view;
@property (weak, nonatomic) IBOutlet UIButton *btn_Menu;

@property (nonatomic) BOOL isHighlighted;
@property (weak, nonatomic) IBOutlet UIButton *btn_NextDay;
@property (weak, nonatomic) IBOutlet UIButton *btn_PreviousDay;

@property (strong, nonatomic) NSString *str_WeatherColor;
@property (strong, nonatomic) NSString *str_CelciusTemperature;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature;
@property (strong, nonatomic) NSString *str_CelciusTemperature2;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature2;
@property (strong, nonatomic) NSString *str_CelciusTemperature3;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature3;
@property (strong, nonatomic) NSString *str_HideBtn1;
@property (strong, nonatomic) NSString *str_HideBtn2;
@property (strong, nonatomic) NSString *str_HideBtn3;

-(void)setForeCastValue:(NSString *)strr_day cityName:(NSString *)str_cityName weatherNew:(NSString *)str_weatherNew windNew:(NSString *)str_windNew pOPNew:(NSString *)str_POPNew degreeHigh:(NSString *)str_HighDegree degreeLow:(NSString *)str_lowDegree iconName:(NSString *)str_iconName;

- (void)setBackgroundColor:(NSString *)wetherType;
-(void)loadNextPage;
-(void)resetWeatherFreame;
- (IBAction)ActionSettingsBtn:(id)sender;
- (IBAction)ActionLogOutBtn:(id)sender;
- (IBAction)Action_menuBtn:(id)sender;
- (IBAction)ActionNextDay:(id)sender;
- (IBAction)ActionPreviousDay:(id)sender;


@end
