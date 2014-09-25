//
//  ICEWeatherandProductListViewController.m
//  monMode
//
//  Created by Sunderrajan Ranganathan on 24/07/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEWeatherandProductListViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ICEProductImageCell.h"
#import "ICEShareViewController.h"
#import "ICEDetailViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "ICESettingsViewController.h"
#import "ICEViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ICESingleTon.h"
#import "SDNetworkActivityIndicator.h"

#define INITIAL_PAGELOAD_COUNT 2
#define BUG_SOLUTION 0
@interface ICEWeatherandProductListViewController ()

@end

@implementation ICEWeatherandProductListViewController
{
    BOOL isAnimating;
    BOOL IspageEnd;
    NSMutableArray *mutArr_ListImages;
    NSIndexPath * selected_indexPath;
    NSString * str_TotalNumberOfPages;
    NSString * str_NumberofItemsPerPage;
    NSString * str_ApiKey;
    UISwipeGestureRecognizer *profile_SwipeGestureRecognizer;
    int PageNumber;
    BOOL isfirstrun;
    BOOL isRefreshFinished;
    BOOL isFirstimageLoad;
    BOOL isMenuHidden;
    BOOL isLikedFlag;
    BOOL isHighLight;
    
    NSString *str_ProductID;
    MBProgressHUD *HUD;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    ICEDetailViewController *detailVC;
    ICEShareViewController *shareVC;
    ICESettingsViewController *obj_Settings;
    ICESingleTon *obj_IceSingle;
    
    NSMutableArray *mutArr_ImageURL;
    NSMutableArray *mutArr_ProductID;
    NSMutableArray *mutArr_ProductTitle;
    NSMutableArray *mutArr_Brand;
    NSMutableArray *mutArr_ProductPrice;
    NSMutableArray *mutArr_ProductLikeCount;
    NSMutableArray *mutArr_ProductLikeCountFlag;
    NSMutableArray *mutArr_ProductShareCount;
    NSMutableArray *mutArr_ProductPurchaseLink;
    NSMutableArray *mutArr_ImageWidth;
    NSMutableArray *mutArr_ImageHeight;
    
    CGRect frame_smallWeatherView;
    CGRect frame_lbl_Day;
    CGRect frame_lbl_CityName;
    CGRect frame_lbl_WeatherNew;
    CGRect frame_lbl_WindNew;
    CGRect frame_lbl_POPNew;
    CGRect frame_lbl_Degree;
    CGRect frame_img_MainWeather;
    CGRect frame_img_POP;
    CGRect frame_img_Wind;
    CGRect frame_lbl_LoadingForcast;
    CGRect frame_img_BottomShadow;;
    
    CGRect frame_bigWeatherView;
    CGRect frame_big_lbl_Day;
    CGRect frame_big_lbl_CityName;
    CGRect frame_big_lbl_WeatherNew;
    CGRect frame_big_lbl_WindNew;
    CGRect frame_big_lbl_POPNew;
    CGRect frame_big_lbl_Degree;
    CGRect frame_big_img_MainWeather;
    CGRect frame_big_img_POP;
    CGRect frame_big_img_Wind;
    CGRect frame_big_lbl_LoadingForcast;
    
    NSString *img_Width;
    NSString *img_Height;
    UITapGestureRecognizer *imageTap;
}

@synthesize productImageCollections,bigWeatherView,smallWeatherView,shodowView,parrentView,referenceImageView;
@synthesize str_day,btn_NextDay,btn_PreviousDay,mutArr_HighCelcius;
@synthesize img_MainWeather,lbl_CityName,lbl_Day,lbl_Degree,activityIndi,lbl_WeatherNew,lbl_WindNew,lbl_POPNew,img_POP,img_Wind,str_WeatherColor;
@synthesize big_img_MainWeather,big_lbl_CityName,big_lbl_Day,big_lbl_Degree,big_lbl_WeatherNew,big_lbl_WindNew,big_lbl_POPNew,big_img_POP,big_img_Wind,big_lbl_LoadingForcast,lbl_LoadingForcast,img_BottomShadow;
@synthesize str_SignUpFlag,str_CelciusTemperature,str_FahrenheitTemperature;
@synthesize menu_view,slide_view,btn_Menu,ShodowImage,path,isHighlighted;
@synthesize str_CelciusTemperature2,str_CelciusTemperature3,str_FahrenheitTemperature2,str_FahrenheitTemperature3;
@synthesize str_HideBtn1,str_HideBtn2,str_HideBtn3;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([str_HideBtn1 isEqualToString:@"HIDE"])
    {
        btn_PreviousDay.hidden = YES;
        btn_NextDay.hidden = NO;
        str_HideBtn1 = @"SHOW";
    }
    else if ([str_HideBtn2 isEqualToString:@"HIDE"])
    {
        btn_PreviousDay.hidden = NO;
        btn_NextDay.hidden = NO;
        str_HideBtn2 = @"SHOW";
    }
    else if ([str_HideBtn3 isEqualToString:@"HIDE"])
    {
        btn_PreviousDay.hidden = NO;
        btn_NextDay.hidden = YES;
        str_HideBtn3 = @"SHOW";
    }
    
    if ([str_day isEqualToString:@"TODAY"])
    {
        NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
        if ([str_TemperatureUnit isEqualToString:@"C"])
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature];
        }
        else
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature];
        }
    }
    else if ([str_day isEqualToString:@"TOMMARO"])
    {
        NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
        if ([str_TemperatureUnit isEqualToString:@"C"])
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature2];
        }
        else
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature2];
        }
    }
    else
    {
        NSString *str_TemperatureUnit = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usertemperatureunit"]];
        if ([str_TemperatureUnit isEqualToString:@"C"])
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_CelciusTemperature3];
        }
        else
        {
            big_lbl_Degree.text = [NSString stringWithFormat:@"%@",obj_IceSingle.str_FahrenheitTemperature3];
        }
    }
    [self  startShowView ];
    [productImageCollections reloadData];
}
-(void)initFreamSize
{
    frame_smallWeatherView=smallWeatherView.frame;
    frame_lbl_Day=lbl_Day.frame;
    frame_lbl_CityName=lbl_CityName.frame;
    frame_lbl_WeatherNew=lbl_WeatherNew.frame;
    frame_lbl_WindNew=lbl_WindNew.frame;
    frame_lbl_POPNew=lbl_POPNew.frame;
    frame_lbl_Degree=lbl_Degree.frame;
    frame_img_MainWeather=img_MainWeather.frame;
    frame_img_POP=img_POP.frame;
    frame_img_Wind=img_Wind.frame;
    frame_lbl_LoadingForcast=lbl_LoadingForcast.frame;
    frame_img_BottomShadow = img_BottomShadow.frame;
    
    frame_bigWeatherView=bigWeatherView.frame;
    frame_big_lbl_Day=big_lbl_Day.frame;
    frame_big_lbl_CityName=big_lbl_CityName.frame;
    frame_big_lbl_WeatherNew=big_lbl_WeatherNew.frame;
    frame_big_lbl_WindNew=big_lbl_WindNew.frame;
    frame_big_lbl_POPNew=big_lbl_POPNew.frame;
    frame_big_lbl_Degree=big_lbl_Degree.frame;
    frame_big_img_MainWeather=big_img_MainWeather.frame;
    frame_big_img_POP=big_img_POP.frame;
    frame_big_img_Wind=big_img_Wind.frame;
    frame_big_lbl_LoadingForcast=big_lbl_LoadingForcast.frame;
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
    
    [self initFreamSize];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    obj_IceSingle = [ICESingleTon sharedManager];
    isMenuHidden=YES;
    
    UITapGestureRecognizer *tap_GestureHideMenu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuViewWeatherAndProduct)];
    tap_GestureHideMenu.delegate = (id<UIGestureRecognizerDelegate>)self;
    [menu_view addGestureRecognizer:tap_GestureHideMenu];
    
    IspageEnd=NO;
    isfirstrun=YES;
    isFirstimageLoad = YES;
    isRefreshFinished = NO;
    isHighlighted = YES;
    [self memoryAllocate_mutableArray];
    
    str_ApiKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    [self hideForCasteDataFeild];
    
    [self.productImageCollections registerNib:[UINib nibWithNibName:@"ICEProductImageCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    productImageCollections.delegate=self;
    productImageCollections.dataSource=self;
    
    RFQuiltLayout* layout = (id)[self.productImageCollections collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(150,2);
    
    PageNumber=1;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
     
    HUD.dimBackground = NO;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    //    [self ProductLists];
    
    [HUD showWhileExecuting:@selector(ProductLists) onTarget:self withObject:nil animated:YES];
    [self addRefreshControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidDisappear:(BOOL)animated
{
    
}

#pragma mark - Initializing NSMutableArray
-(void)memoryAllocate_mutableArray
{
    
    [mutArr_ListImages removeAllObjects];
    [mutArr_ImageWidth removeAllObjects];
    [mutArr_ImageHeight removeAllObjects];
    [mutArr_ImageURL removeAllObjects];
    [mutArr_ProductID removeAllObjects];
    [mutArr_ProductTitle removeAllObjects];
    [mutArr_Brand removeAllObjects];
    [mutArr_ProductPrice removeAllObjects];
    [mutArr_ProductLikeCount removeAllObjects];
    [mutArr_ProductLikeCountFlag removeAllObjects];
    [mutArr_ProductShareCount removeAllObjects];
    [mutArr_ProductPurchaseLink removeAllObjects];
    
    mutArr_ListImages = nil;
    mutArr_ImageWidth = nil;
    mutArr_ImageHeight = nil;
    mutArr_ImageURL = nil;
    mutArr_ProductID = nil;
    mutArr_ProductTitle = nil;
    mutArr_Brand = nil;
    mutArr_ProductPrice = nil;
    mutArr_ProductLikeCount = nil;
    mutArr_ProductLikeCountFlag = nil;
    mutArr_ProductShareCount = nil;
    mutArr_ProductPurchaseLink = nil;
    
    mutArr_ListImages=[[NSMutableArray alloc]init];
    mutArr_ImageWidth=[[NSMutableArray alloc]init];
    mutArr_ImageHeight=[[NSMutableArray alloc]init];
    mutArr_ImageURL = [[NSMutableArray alloc] init];
    mutArr_ProductID = [[NSMutableArray alloc] init];
    mutArr_ProductTitle = [[NSMutableArray alloc] init];
    mutArr_Brand = [[NSMutableArray alloc] init];
    mutArr_ProductPrice = [[NSMutableArray alloc] init];
    mutArr_ProductLikeCount = [[NSMutableArray alloc] init];
    mutArr_ProductLikeCountFlag = [[NSMutableArray alloc] init];
    mutArr_ProductShareCount = [[NSMutableArray alloc] init];
    mutArr_ProductPurchaseLink = [[NSMutableArray alloc] init];
}

#pragma mark - Hide and Show Weather Details
-(void)hideForCasteDataFeild
{
    
    lbl_Day.hidden=YES;
    lbl_CityName.hidden=YES;
    lbl_WeatherNew.hidden=YES;
    lbl_WindNew.hidden=YES;
    lbl_POPNew.hidden=YES;
    lbl_Degree.hidden=YES;
    img_MainWeather.hidden=YES;
    img_POP.hidden=YES;
    img_Wind.hidden=YES;
    lbl_LoadingForcast.hidden=NO;
    
    big_lbl_Day.hidden=YES;
    big_lbl_CityName.hidden=YES;
    big_lbl_WeatherNew.hidden=YES;
    big_lbl_WindNew.hidden=YES;
    big_lbl_POPNew.hidden=YES;
    big_lbl_Degree.hidden=YES;
    big_img_MainWeather.hidden=YES;
    big_img_POP.hidden=YES;
    big_img_Wind.hidden=YES;
    big_lbl_LoadingForcast.hidden=NO;
}
-(void)showForCasteDataFeild
{
    
    lbl_LoadingForcast.hidden=YES;
    lbl_Day.hidden=NO;
    lbl_WindNew.hidden=NO;
    lbl_POPNew.hidden=NO;
    lbl_Degree.hidden=NO;
    img_MainWeather.hidden=NO;
    img_POP.hidden=NO;
    img_Wind.hidden=NO;
    
    big_lbl_Day.hidden=NO;
    big_lbl_CityName.hidden=NO;
    big_lbl_WeatherNew.hidden=NO;
    big_lbl_WindNew.hidden=NO;
    big_lbl_POPNew.hidden=NO;
    big_lbl_Degree.hidden=NO;
    big_img_MainWeather.hidden=NO;
    big_img_POP.hidden=NO;
    big_img_Wind.hidden=NO;
    big_lbl_LoadingForcast.hidden=YES;
}

-(void)setForeCastValue:(NSString *)strr_day cityName:(NSString *)str_cityName weatherNew:(NSString *)str_weatherNew windNew:(NSString *)str_windNew pOPNew:(NSString *)str_POPNew degreeHigh:(NSString *)str_HighDegree degreeLow:(NSString *)str_lowDegree iconName:(NSString *)str_iconName
{
    [self setBackgroundColor:[NSString stringWithFormat:@"%@",str_iconName]];
    NSString *str_ImageName = [NSString stringWithFormat:@"%@.gif",str_iconName];
    big_img_MainWeather.image =  [UIImage imageNamed:str_ImageName];
    img_MainWeather.image = [UIImage imageNamed:str_ImageName];
    if ([str_weatherNew isEqualToString:@"Chance of Tstrom"])
    {
        big_img_Wind.frame = CGRectMake(226, 191, 13, 13);
        big_img_POP.frame = CGRectMake(162, 192, 13, 13);
        big_lbl_WeatherNew.frame = CGRectMake(38, 185, 111, 27);
        big_lbl_POPNew.frame = CGRectMake(179, 187, 39, 23);
        big_lbl_WindNew.frame = CGRectMake(246, 186, 85, 24);
        frame_big_lbl_WeatherNew=big_lbl_WeatherNew.frame;
        frame_big_lbl_WindNew=big_lbl_WindNew.frame;
        frame_big_lbl_POPNew=big_lbl_POPNew.frame;
        frame_big_img_POP=big_img_POP.frame;
        frame_big_img_Wind=big_img_Wind.frame;
    }
    else if ([str_weatherNew isEqualToString:@"Clear"] || [str_weatherNew isEqualToString:@"Sunny"] || [str_weatherNew isEqualToString:@"Cloudy"] || [str_weatherNew isEqualToString:@"Hazy"] || [str_weatherNew isEqualToString:@"Fog"] || [str_weatherNew isEqualToString:@"Rain"] || [str_weatherNew isEqualToString:@"Sleet"] || [str_weatherNew isEqualToString:@"Flurries"] || [str_weatherNew isEqualToString:@"Snow"])
    {
        big_img_Wind.frame = CGRectMake(190, 191, 13, 13);
        big_img_POP.frame = CGRectMake(126, 192, 13, 13);
        big_lbl_WeatherNew.frame = CGRectMake(2, 185, 111, 27);
        big_lbl_POPNew.frame = CGRectMake(143, 187, 39, 23);
        big_lbl_WindNew.frame = CGRectMake(211, 186, 85, 24);
        frame_big_lbl_WeatherNew=big_lbl_WeatherNew.frame;
        frame_big_lbl_WindNew=big_lbl_WindNew.frame;
        frame_big_lbl_POPNew=big_lbl_POPNew.frame;
        frame_big_img_POP=big_img_POP.frame;
        frame_big_img_Wind=big_img_Wind.frame;
    }
    else
    {
        big_img_Wind.frame = CGRectMake(216, 191, 13, 13);
        big_img_POP.frame = CGRectMake(152, 192, 13, 13);
        big_lbl_WeatherNew.frame = CGRectMake(28, 185, 111, 27);
        big_lbl_POPNew.frame = CGRectMake(169, 187, 39, 23);
        big_lbl_WindNew.frame = CGRectMake(237, 186, 85, 24);
        frame_big_lbl_WeatherNew=big_lbl_WeatherNew.frame;
        frame_big_lbl_WindNew=big_lbl_WindNew.frame;
        frame_big_lbl_POPNew=big_lbl_POPNew.frame;
        frame_big_img_POP=big_img_POP.frame;
        frame_big_img_Wind=big_img_Wind.frame;
    }
    
    big_lbl_Day.text = [NSString stringWithFormat:@"%@",strr_day];
    big_lbl_CityName.text = [NSString stringWithFormat:@"%@",str_cityName];
    big_lbl_WeatherNew.text = [NSString stringWithFormat:@"%@",str_weatherNew];
    big_lbl_WindNew.text = [NSString stringWithFormat:@"%@mph",str_windNew];
    big_lbl_POPNew.text = [NSString stringWithFormat:@"%@%%",str_POPNew];
    big_lbl_Degree.text = [NSString stringWithFormat:@"%@° / %@°",str_HighDegree,str_lowDegree];
    
    lbl_Day.text = [NSString stringWithFormat:@"%@",strr_day];
    lbl_CityName.text = [NSString stringWithFormat:@"%@",str_cityName];
    lbl_WeatherNew.text = [NSString stringWithFormat:@"%@",str_weatherNew];
    lbl_WindNew.text = [NSString stringWithFormat:@"%@mph",str_windNew];
    lbl_POPNew.text = [NSString stringWithFormat:@"%@%%",str_POPNew];
    lbl_Degree.text = [NSString stringWithFormat:@"%@° / %@°",str_HighDegree,str_lowDegree];
    
    [self showForCasteDataFeild];
}

- (void)setBackgroundColor:(NSString *)wetherType
{
    
    UIColor *backgroundColor;
    if( [@"clear" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:52.0/255.0 green:159.0/255.0 blue:226.0/255.0 alpha:1];
    }
    else if( [@"sunny" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:250.0/255.0 green:176.0/255.0 blue:58.0/255.0 alpha:1];
    }
    else if( [@"mostlysunny" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:249.0/255.0 green:145.0/255.0 blue:30.0/255.0 alpha:1];
    }
    else if( [@"partlysunny" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:249.0/255.0 green:112.0/255.0 blue:49.0/255.0 alpha:1];
    }
    else if( [@"partlycloudy" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:158.0/255.0 green:198.0/255.0 blue:102.0/255.0 alpha:1];
    }
    else if( [@"mostlycloudy" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:105.0/255.0 green:178.0/255.0 blue:3.0/255.0 alpha:1];
    }
    else if( [@"cloudy" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:140.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1];
    }
    else if( [@"hazy" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:94.0/255.0 green:211.0/255.0 blue:198.0/255.0 alpha:1];
    }
    else if( [@"fog" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:49.0/255.0 green:196.0/255.0 blue:206.0/255.0 alpha:1];
    }
    else if( [@"chancerain" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:38.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:1];
    }
    else if( [@"rain" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:62.0/255.0 green:167.0/255.0 blue:242.0/255.0 alpha:1];
    }
    else if( [@"tstorms" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:198.0/255.0 green:156.0/255.0 blue:109.0/255.0 alpha:1];
    }
    else if( [@"chancetstorms" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:173/255.0 green:116.0/255.0 blue:60.0/255.0 alpha:1];
    }
    else if( [@"chancesleet" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:51.0/255.0 green:187.0/255.0 blue:216.0/255.0 alpha:1];
    }
    else if( [@"sleet" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:96.0/255.0 green:141.0/255.0 blue:232.0/255.0 alpha:1];
    }
    else if( [@"chanceflurries" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:133.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1];
    }
    else if( [@"flurries" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:113.0/255.0 green:130.0/255.0 blue:216.0/255.0 alpha:1];
    }
    else if( [@"chancesnow" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:152.0/255.0 green:122.0/255.0 blue:234.0/255.0 alpha:1];
    }
    else if( [@"snow" caseInsensitiveCompare:wetherType] == NSOrderedSame )
    {
        backgroundColor=[UIColor colorWithRed:169.0/255.0 green:117.0/255.0 blue:207/255.0 alpha:1];
    }
    
    parrentView.backgroundColor=backgroundColor;
    
}

#pragma mark - Pull Down Refresh
-(void)addRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(productImageCollections_refresh:) forControlEvents:UIControlEventValueChanged];
    [productImageCollections addSubview:refreshControl];
}

- (void)productImageCollections_refresh:(UIRefreshControl *)refreshControl
{
    PageNumber=1;
    str_TotalNumberOfPages=@"0";
    IspageEnd=NO;
    isRefreshFinished = YES;
    productImageCollections.scrollEnabled = NO;
    productImageCollections.userInteractionEnabled = NO;
    [self memoryAllocate_mutableArray];
    [productImageCollections reloadData];
    [self ProductLists];
    [refreshControl endRefreshing];
}

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.productImageCollections.contentOffset.y>=5)
    {
        if(scrollView.userInteractionEnabled==NO || productImageCollections.userInteractionEnabled ==NO)
        {
            return;
        }
        scrollView.userInteractionEnabled=NO;
        self.productImageCollections.userInteractionEnabled = NO;
        
        self.productImageCollections.frame = CGRectMake(self.productImageCollections.frame.origin.x,115 , self.productImageCollections.frame.size.width, 464);
        
        btn_NextDay.hidden = YES;
        btn_PreviousDay.hidden = YES;
        img_BottomShadow.hidden = YES;
        [UIView animateWithDuration:1.0f
                              delay:0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             bigWeatherView.frame=frame_smallWeatherView;
                             big_lbl_Day.frame=frame_lbl_Day;
                             big_lbl_CityName.frame=frame_lbl_CityName;
                             big_lbl_WeatherNew.frame=frame_lbl_WeatherNew;
                             big_lbl_WindNew.frame=frame_lbl_WindNew;
                             big_lbl_POPNew.frame=frame_lbl_POPNew;
                             big_lbl_Degree.frame=frame_lbl_Degree;
                             big_img_MainWeather.frame=frame_img_MainWeather;
                             big_img_POP.frame=frame_img_POP;
                             big_img_Wind.frame=frame_img_Wind;
                             big_lbl_LoadingForcast.frame=frame_lbl_LoadingForcast;
                             
                             img_BottomShadow.frame = CGRectMake(img_BottomShadow.frame.origin.x,115 , img_BottomShadow.frame.size.width, 25);
                         }
                         completion: ^(BOOL finished)
         {
             img_BottomShadow.hidden = NO;
             self.productImageCollections.userInteractionEnabled = YES;
             scrollView.userInteractionEnabled=YES;
         }];
    }
    else if(self.productImageCollections.contentOffset.y<=-1 && productImageCollections.frame.origin.y==115)
    {
        if(scrollView.userInteractionEnabled==NO || productImageCollections.userInteractionEnabled ==NO)
        {
            return;
        }
        scrollView.userInteractionEnabled=NO;
        self.productImageCollections.userInteractionEnabled = NO;
        self.productImageCollections.frame = CGRectMake(self.productImageCollections.frame.origin.x,224 , self.productImageCollections.frame.size.width, 345);
        img_BottomShadow.hidden = YES;
        
        [UIView animateWithDuration:1.0f
                              delay:0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             bigWeatherView.frame=frame_bigWeatherView;
                             big_lbl_Day.frame=frame_big_lbl_Day;
                             big_lbl_CityName.frame=frame_big_lbl_CityName;
                             big_lbl_WeatherNew.frame=frame_big_lbl_WeatherNew;
                             big_lbl_WindNew.frame=frame_big_lbl_WindNew;
                             big_lbl_POPNew.frame=frame_big_lbl_POPNew;
                             big_lbl_Degree.frame=frame_big_lbl_Degree;
                             big_img_MainWeather.frame=frame_big_img_MainWeather;
                             big_img_POP.frame=frame_big_img_POP;
                             big_img_Wind.frame=frame_big_img_Wind;
                             big_lbl_LoadingForcast.frame=frame_big_lbl_LoadingForcast;
                             img_BottomShadow.frame = frame_img_BottomShadow;
                         }
                         completion: ^(BOOL finished)
         {
             if ([str_day isEqualToString:@"TODAY"])
             {
                 btn_NextDay.hidden = NO;
             }
             else if ([str_day isEqualToString:@"TOMMARO"])
             {
                 btn_NextDay.hidden = NO;
                 btn_PreviousDay.hidden = NO;
             }
             else if ([str_day isEqualToString:@"DAY_OFTER_TOMMARO"])
             {
                 btn_PreviousDay.hidden = NO;
             }
             img_BottomShadow.hidden = YES;
             self.productImageCollections.userInteractionEnabled = YES;
             scrollView.userInteractionEnabled=YES;
         }];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    float endScrolling = self.productImageCollections.contentOffset.y + self.productImageCollections.frame.size.height;
    if (endScrolling >= self.productImageCollections.contentSize.height)
    {
        [self loadNextPage];
    }
}

-(void)resetWeatherFreame
{
    img_BottomShadow.hidden = YES;
    productImageCollections.contentOffset = CGPointMake(0, 0);
    productImageCollections.frame = CGRectMake(productImageCollections.frame.origin.x,224 , productImageCollections.frame.size.width, 345);
    bigWeatherView.frame=frame_bigWeatherView;
    big_lbl_Day.frame=frame_big_lbl_Day;
    big_lbl_CityName.frame=frame_big_lbl_CityName;
    big_lbl_WeatherNew.frame=frame_big_lbl_WeatherNew;
    big_lbl_WindNew.frame=frame_big_lbl_WindNew;
    big_lbl_POPNew.frame=frame_big_lbl_POPNew;
    big_lbl_Degree.frame=frame_big_lbl_Degree;
    big_img_MainWeather.frame=frame_big_img_MainWeather;
    big_img_POP.frame=frame_big_img_POP;
    big_img_Wind.frame=frame_big_img_Wind;
    big_lbl_LoadingForcast.frame=frame_big_lbl_LoadingForcast;
    img_BottomShadow.frame = frame_img_BottomShadow;
}

-(void)loadNextPage
{
    if(!IspageEnd)
    {
        [self ProductLists];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

#pragma mark - Get Product Lists
- (void)ProductLists
{
    int  noOfPage1 = [str_TotalNumberOfPages intValue];
    if(PageNumber==noOfPage1)
    {
        IspageEnd=YES;
    }
    NSString *urlAsString = @"https://www.monmode.today/api/v1/products.json";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_ApiKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&page=%d",PageNumber]];
    
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Product List Request : %@",url);
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:nil
                                                     error:nil];
    if ([data length] >0  && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingAllowFragments
                         error:&error];
        if (jsonObject != nil && error == nil)
        {
            
            NSMutableDictionary *  deserializedDictionary = jsonObject;
            NSLog(@"Product List Response : %@",deserializedDictionary);
            str_TotalNumberOfPages = (NSString*)[deserializedDictionary objectForKey:@"total_number_of_pages"];
            str_NumberofItemsPerPage = (NSString*)[deserializedDictionary objectForKey:@"number_of_items_per_page"];
            NSMutableDictionary *mutDict_Products = [deserializedDictionary objectForKey:@"products"];
            NSMutableArray *IDArray = (NSMutableArray *)[mutDict_Products valueForKey:@"id"];
            NSMutableArray *titleArray = (NSMutableArray *)[mutDict_Products valueForKey:@"title"];
            NSMutableArray *brandArray = (NSMutableArray *)[mutDict_Products valueForKey:@"brand"];
            NSMutableArray *priceArray = (NSMutableArray *)[mutDict_Products valueForKey:@"price"];
            NSMutableArray *likeArray = (NSMutableArray *)[mutDict_Products valueForKey:@"like_count"];
            NSMutableArray *shareArray = (NSMutableArray *)[mutDict_Products valueForKey:@"share_count"];
            NSMutableArray *likeflagArray = (NSMutableArray *)[mutDict_Products valueForKey:@"current_user_like"];
            NSMutableArray *purchaseLinkArray = (NSMutableArray *)[mutDict_Products valueForKey:@"purchase_link"];
            NSMutableArray *imageAssetsArray = (NSMutableArray *)[mutDict_Products valueForKey:@"image"];
            NSMutableDictionary *imageURLDictionary;
            NSMutableDictionary *imageWidthDictionary;
            NSMutableDictionary *imageHeightDictionary;
            for (int imageCount = 0; imageCount<[imageAssetsArray count]; imageCount++)
            {
                
                if (![[[imageAssetsArray objectAtIndex:imageCount] objectForKey:@"width"] isEqual:[NSNull null]] && ![[[imageAssetsArray objectAtIndex:imageCount] objectForKey:@"height"] isEqual:[NSNull null]])
                {
                    imageURLDictionary = [[imageAssetsArray objectAtIndex:imageCount] objectForKey:@"url"];
                    [mutArr_ImageURL addObject:imageURLDictionary];
                    imageWidthDictionary = [[imageAssetsArray objectAtIndex:imageCount] objectForKey:@"width"];
                    [mutArr_ImageWidth addObject:imageWidthDictionary];
                    imageHeightDictionary = [[imageAssetsArray objectAtIndex:imageCount] objectForKey:@"height"];
                    [mutArr_ImageHeight addObject:imageHeightDictionary];
                    [mutArr_ProductID addObject:[IDArray objectAtIndex:imageCount]];
                    [mutArr_ProductTitle addObject:[titleArray objectAtIndex:imageCount]];
                    [mutArr_Brand addObject:[brandArray objectAtIndex:imageCount]];
                    [mutArr_ProductPrice addObject:[priceArray objectAtIndex:imageCount]];
                    [mutArr_ProductLikeCount addObject:[likeArray objectAtIndex:imageCount]];
                    [mutArr_ProductShareCount addObject:[shareArray objectAtIndex:imageCount]];
                    [mutArr_ProductLikeCountFlag addObject:[likeflagArray objectAtIndex:imageCount]];
                    [mutArr_ProductPurchaseLink addObject:[purchaseLinkArray objectAtIndex:imageCount]];
                }
                else
                {
                }
                
            }
            int  noOfPage = [str_TotalNumberOfPages intValue];
            
            if((PageNumber+1)<=noOfPage)
            {
                PageNumber+=1;
            }
            
            [productImageCollections reloadData];
            productImageCollections.scrollEnabled = YES;
            productImageCollections.userInteractionEnabled = YES;
            IDArray = nil;
            titleArray = nil;
            brandArray = nil;
            priceArray = nil;
            likeArray = nil;
            shareArray = nil;
            likeflagArray = nil;
            purchaseLinkArray = nil;
        }
    }
    else if (error != nil)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 1;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    else if ([data length] == 0 && error == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Nothing was downloaded." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
            alertsuccess.tag = 1;
            alertsuccess.delegate = self;
            [alertsuccess show];
        });
    }
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mutArr_ImageURL count];
    
}

-(BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICEProductImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    
    path = indexPath;
    
    NSString *imageName=(NSString*)[mutArr_ImageURL objectAtIndex:path.item];
    cell.imageActivity.center = cell.cell_Image.center;
    [cell.cell_Image setImageWithURL:[NSURL URLWithString:imageName]];
    if([ [mutArr_ProductShareCount objectAtIndex:path.item ] intValue])
    {
        cell.label_shareCount.hidden=NO;
    }
    else
    {
        cell.label_shareCount.hidden=YES;
    }
    if([ [mutArr_ProductLikeCount objectAtIndex:path.item ] intValue])
    {
        cell.label_likeCount.hidden=NO;
    }
    else
    {
        cell.label_likeCount.hidden=YES;
    }
    cell.cell_Image.alpha=1;
    CGFloat imageWidth = [[mutArr_ImageWidth objectAtIndex:indexPath.item] floatValue];
    CGFloat imageHeight = [[mutArr_ImageHeight objectAtIndex:indexPath.item] floatValue];
    CGFloat orginalHeight=imageHeight;
    CGFloat orginalwidth=imageWidth;
    CGFloat newHeight = orginalHeight * (138/orginalwidth);
    
    
    cell.cell_Image.frame=CGRectMake(cell.cell_Image.frame.origin.x, cell.cell_Image.frame.origin.y, 138, newHeight);
    float freamHeight=cell.cell_Image.frame.origin.y+newHeight+8;
    
    cell.cell_Image.layer.cornerRadius = 0.0;
    cell.cell_Image.layer.borderWidth = 1;
    cell.cell_Image.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204./255.0 alpha:1.0].CGColor;
    
    cell.detailBtn.frame = cell.cell_Image.frame;
    cell.likeBtn.frame =CGRectMake(cell.cell_Image.frame.origin.x, freamHeight, 15, 14);
    cell.label_likeCount.text=[NSString stringWithFormat:@"%@",[mutArr_ProductLikeCount objectAtIndex:(int)path.item]];
    cell.label_likeCount.textColor=[UIColor whiteColor];
    cell.label_likeCount.backgroundColor=[UIColor clearColor];
    
    NSString *str_CurrentUserLike=[NSString stringWithFormat:@"%@",[mutArr_ProductLikeCountFlag objectAtIndex:(int)path.item]];
    if ([str_CurrentUserLike isEqualToString:@"1"])
    {   isLikedFlag = YES;
        [cell.likeBtn setImage:[UIImage imageNamed:@"v3_loved.png"] forState:UIControlStateNormal];
    }
    else
    {
        isLikedFlag = NO;
        [cell.likeBtn setImage:[UIImage imageNamed:@"v3_love.png"] forState:UIControlStateNormal];
    }
    cell.label_likeCount.frame =CGRectMake(cell.likeBtn.frame.size.width+4, freamHeight, 20,14);
    cell.shareBtn.frame =CGRectMake(cell.label_likeCount.frame.origin.x+cell.label_likeCount.frame.size.width+10 , freamHeight, 15, 14);
    cell.label_shareCount.text=[NSString stringWithFormat:@"%@",[mutArr_ProductShareCount objectAtIndex:(int)path.item]];
    cell.label_shareCount.textColor=[UIColor whiteColor];
    cell.label_shareCount.backgroundColor=[UIColor clearColor];
    cell.label_shareCount.frame =CGRectMake(cell.shareBtn.frame.origin.x+cell.shareBtn.frame.size.width+4, freamHeight,29,14);
    cell.likeBtn.tag=(NSInteger)path.item;
    cell.shareBtn.tag=(NSInteger)path.item;
    cell.detailBtn.tag = (NSInteger)path.item;
    
    [cell.likeBtn addTarget:self action:@selector(ActionLikeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareBtn addTarget:self action:@selector(AcctionShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.detailBtn addTarget:self action:@selector(AcctionDetailBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.tag=(NSInteger)path.item;
    return cell;
}

- (void)AcctionDetailBtn:(UIButton *)sender
{
    
    NSIndexPath *detailPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    
    ICEProductImageCell *cell = (ICEProductImageCell *)[self.productImageCollections cellForItemAtIndexPath:detailPath];
    NSLog(@"Cell Image Size Width : %f, Height : %f",cell.cell_Image.frame.size.width,cell.cell_Image.frame.size.height);
    referenceImageView = cell.cell_Image;
    referenceImageView.contentMode = UIViewContentModeScaleAspectFill;
    NSLog(@"Cell Reference Image Size Width : %f, Height : %f",referenceImageView.frame.size.width,referenceImageView.frame.size.height);
    [self showDetailPage:(int)detailPath.item];
}

#pragma mark - Like & Share
- (IBAction)ActionLikeBtn:(UIButton*)sender
{
    int IsAlredyLiked=[[mutArr_ProductLikeCountFlag objectAtIndex:(int)sender.tag] intValue];
    NSString *str_product_Id=[NSString stringWithFormat:@"%@",[mutArr_ProductID objectAtIndex:(int)sender.tag]];
    
    NSString *urlAsString;
    if(IsAlredyLiked)
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/unlike",str_product_Id];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_ApiKey]];
    }
    else
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/like",str_product_Id];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_ApiKey]];
    }
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSLog(@"Like Request : %@",url);
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setTimeoutInterval:60.0f];
    if (IsAlredyLiked)
    {
        [urlRequest setHTTPMethod:@"DELETE"];
    }
    else
    {
        [urlRequest setHTTPMethod:@"POST"];
    }
    
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
            NSLog(@"Like Response : %@",jsonObject);
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * deserializedDictionaryLike = jsonObject;
                if ([[NSString stringWithFormat:@"%@",[deserializedDictionaryLike valueForKey:@"id"]] isEqualToString:str_product_Id])
                {
                    if (!IsAlredyLiked)
                    {
                        int count1=[ [mutArr_ProductLikeCount objectAtIndex:(int)sender.tag ] intValue];
                        count1 += 1;
                        
                        [mutArr_ProductLikeCount replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", count1]];
                        [mutArr_ProductLikeCountFlag replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", 1]];
                        isLikedFlag = YES;
                    }
                    else
                    {
                        int count1=[ [mutArr_ProductLikeCount objectAtIndex:(int)sender.tag ] intValue];
                        count1 -= 1;
                        [mutArr_ProductLikeCount replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", count1]];
                        [mutArr_ProductLikeCountFlag replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", 0]];
                        isLikedFlag = NO;
                    }
                    [productImageCollections reloadData];
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
            
            alertsuccess.tag = 1;
            alertsuccess.delegate = self;
            [alertsuccess show];
        }
        else if ([data length] == 0 && error == nil)
        {
            
        }
    }
}

- (IBAction)AcctionShareBtn:(UIButton*)sender
{
    str_ProductID = [NSString stringWithFormat:@"%@",[mutArr_ProductID objectAtIndex:(int)sender.tag]];
    [[NSUserDefaults standardUserDefaults] setObject:str_ProductID forKey:@"productid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            shareVC = [[ICEShareViewController alloc]initWithNibName:@"ICEShareViewController" bundle:nil];
        }
        else
        {
            //iPhone 4 Version
            shareVC = [[ICEShareViewController alloc]initWithNibName:@"ICEShareViewController_iPhone4" bundle:nil];
        }
    }
	else
	{
        //iPad Version
    }
    shareVC.backgroundImage_backview=[self takescreenshotes];
    shareVC.str_BrandNameToShare = [NSString stringWithFormat:@"%@",[mutArr_Brand objectAtIndex:(int)sender.tag]];
    shareVC.str_ShareImageURL = [NSString stringWithFormat:@"%@",[mutArr_ImageURL objectAtIndex:(int)sender.tag]];
    [self presentViewController:shareVC animated:YES completion:nil];
    
}
#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageWidth = [[mutArr_ImageWidth objectAtIndex:indexPath.item] floatValue];
    CGFloat imageHeight = [[mutArr_ImageHeight objectAtIndex:indexPath.item] floatValue];
    CGFloat orginalHeight=imageHeight;
    CGFloat orginalwidth=imageWidth;
    CGFloat newHeight = orginalHeight * (150/orginalwidth);
    
    CGFloat scaleSize= (newHeight+37)/2.0;
    return CGSizeMake(1,scaleSize);
    
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //top,left,bottom,right
    return UIEdgeInsetsMake(2, 10, 2, 2);
}


#pragma mark - Show Detail Page

- (void)showDetailPage:(int)rowIndex
{
    [self startHideView];
    [[NSUserDefaults standardUserDefaults] setObject:self.str_day forKey:@"day"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            detailVC = [[ICEDetailViewController alloc] initWithNibName:@"ICEDetailViewController" bundle:nil];
        }
        else
        {
            //iPhone 4 Version
            detailVC = [[ICEDetailViewController alloc] initWithNibName:@"ICEDetailViewController_iPhone4" bundle:nil];
        }
    }
	else
	{
        //iPad Version
    }
    detailVC.backgroundImage_backview=[self takescreenshotes];
    detailVC.str_ProductID = [NSString stringWithFormat:@"%@",[mutArr_ProductID objectAtIndex:rowIndex]];
    detailVC.str_DetailImageURL = [NSString stringWithFormat:@"%@",[mutArr_ImageURL objectAtIndex:rowIndex]];
    detailVC.str_ImageWidth = [NSString stringWithFormat:@"%@",[mutArr_ImageWidth objectAtIndex:rowIndex]];
    detailVC.str_imageHeight = [NSString stringWithFormat:@"%@",[mutArr_ImageHeight objectAtIndex:rowIndex]];
    detailVC.str_ProductTitle = [NSString stringWithFormat:@"%@",[mutArr_ProductTitle objectAtIndex:rowIndex]];
    detailVC.str_Brand = [NSString stringWithFormat:@"%@",[mutArr_Brand objectAtIndex:rowIndex]];
    detailVC.str_ProductPrice = [NSString stringWithFormat:@"%@",[mutArr_ProductPrice objectAtIndex:rowIndex]];
    detailVC.str_LikeCount = [NSString stringWithFormat:@"%@",[mutArr_ProductLikeCount objectAtIndex:rowIndex]];
    detailVC.str_ShareCount = [NSString stringWithFormat:@"%@",[mutArr_ProductShareCount objectAtIndex:rowIndex]];
    detailVC.str_CurrentUserLike = [NSString stringWithFormat:@"%@",[mutArr_ProductLikeCountFlag objectAtIndex:rowIndex]];
    detailVC.str_PurchaseLink = [NSString stringWithFormat:@"%@",[mutArr_ProductPurchaseLink objectAtIndex:rowIndex]];
    detailVC.transitioningDelegate = self;
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma - mark Hide and Show Next Days view

-(void)startHideView
{
    [self.delegate hideView ];
}

-(void)startShowView
{
    [self.delegate showView ];
}

-(void)startNextDay:(NSString *)str_CurrentDay
{
    [self.delegate startNextDay:str_CurrentDay];
}

-(void)startPreviousDay:(NSString *)str_CurrentDay
{
    [self.delegate startPreviousDay:str_CurrentDay];
}

- (IBAction)ActionNextDay:(id)sender
{
    [self startNextDay:str_day];
}

- (IBAction)ActionPreviousDay:(id)sender
{
    [self startPreviousDay:str_day];
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:ICEDetailViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:referenceImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:ICEDetailViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:referenceImageView];
        [productImageCollections reloadData];
    }
    return nil;
}

#pragma mark - Screen Animation

-(UIImage *)takescreenshotes
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Menu View and Prefrences & LogOut

- (void)hideMenuViewWeatherAndProduct
{
    isMenuHidden=YES;
    slide_view.frame = CGRectMake(0, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
    [UIView animateWithDuration: 1.0f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         [UIView setAnimationRepeatCount:1];
                         
                         slide_view.frame = CGRectMake(-slide_view.frame.size.width, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
                         
                     }
                     completion: ^(BOOL finished)
     {
         menu_view.hidden=YES;
     }];
}

- (IBAction)Action_menuBtn:(id)sender
{
    if(isMenuHidden)
    {
        isMenuHidden=NO;
        slide_view.frame = CGRectMake(-slide_view.frame.size.width, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
        menu_view.hidden=NO;
        
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             [UIView setAnimationRepeatCount:1];
                             
                             slide_view.frame = CGRectMake(0, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
                             
                         }
                         completion: ^(BOOL finished)
         {
         }];
    }
    else
    {
        isMenuHidden=YES;
        slide_view.frame = CGRectMake(0, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
        [UIView animateWithDuration: 1.0f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             [UIView setAnimationRepeatCount:1];
                             
                             slide_view.frame = CGRectMake(-slide_view.frame.size.width, slide_view.frame.origin.y, slide_view.frame.size.width, slide_view.frame.size.height);
                             
                         }
                         completion: ^(BOOL finished)
         {
             menu_view.hidden=YES;
             
         }];
    }
}

- (IBAction)ActionSettingsBtn:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            obj_Settings = [[ICESettingsViewController alloc] initWithNibName:@"ICESettingsViewController" bundle:nil];
            
        }
        else
        {
            //iPhone 4 Version
            obj_Settings = [[ICESettingsViewController alloc] initWithNibName:@"ICESettingsViewController_iPhone4" bundle:nil];
            
        }
    }
	else
	{
        //iPad Version
        
        
    }
    obj_Settings.backgroundImage_backview=[self takescreenshotes];
    [self presentViewController:obj_Settings animated:YES completion:nil];
}

- (IBAction)ActionLogOutBtn:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"api_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tauthentication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fbauthentication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduledTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PreviousTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"useremail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userfirstname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userlastname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usertemperatureunit"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userDateOfBirth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userMobileNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	[[FBSession activeSession] closeAndClearTokenInformation];
	[FBSession setActiveSession:nil];
    ICEViewController *obj_MainVC;
    obj_MainVC = [[ICEViewController alloc] initWithNibName:@"ICEViewController" bundle:nil];
    [self presentViewController:obj_MainVC animated:YES completion:nil];
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
