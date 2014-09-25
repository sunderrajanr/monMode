//
//  ICEDetailViewController.m
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/2/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEDetailViewController.h"
#import "ICEShareViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "ICEPurchaseLinkViewController.h"

#import <QuartzCore/QuartzCore.h>


@interface ICEDetailViewController ()<UIWebViewDelegate,MBProgressHUDDelegate>
{
    NSString *str_APIKey;
    NSString *str_ProductID;
    NSString *str_currency;
    NSString *str_ProductId;
    NSString *str_ImageURL;
    NSString *str_PurchaseLinkVerifiedAt;
    NSString *str_Year;
    
    NSMutableArray *mutArr_similarProducts;
    NSMutableArray *mutArr_SimilarProductImages;
    NSMutableArray *mutArr_SimilarProductLikeCount;
    NSMutableArray *mutArr_SimilarProductLikeCountFlag;
    NSMutableArray *mutArr_SimilarProductShareCount;
    
    NSMutableArray *mutArr_ProductID;
    NSMutableArray *mutArr_ProductTitle;
    NSMutableArray *mutArr_Brand;
    NSMutableArray *mutArr_ProductPrice;
    NSMutableArray *mutArr_ProductPurchaseLink;
    
    int xPos;
    int yPosL;
    int yPosR;
    
    NSMutableArray *buttonImageArr;
    CGFloat originalImageWidth;
    CGFloat originalImageHeight;
    
    UIButton *shareBtn;
    UIButton *btn_ShowMore;
    
    BOOL isLiked;
    BOOL isSaved;
    BOOL isSimilarProduct;
    BOOL isLikedFlag;
    BOOL isSlidingViewSmall;
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    
    CGFloat _panOriginY;
    CGPoint _panVelocity1;
    float detailBound;
    MBProgressHUD *HUD;
    Reachability *hostReachability;
    Reachability *internetReachability;
    Reachability *wifiReachability;
    ICEDetailViewController *detailVC;
    ICEShareViewController *shareVC;
    ICEPurchaseLinkViewController *obj_Purchase;
}

@end

@implementation ICEDetailViewController
@synthesize imgDetail,str_Cost,str_Title,str_ProductID,deserializedDictionary,deserializedDictionaryLike,detailImage,smallView,SlidingView,str_DetailImageURL;
@synthesize backView,frontView,backViewImage,backgroundImage_backview,productImageCollections,view_SimilarProducts,img_LoveAnimation;
@synthesize str_ProductTitle,str_Brand,str_ProductPrice,str_LikeCount,str_ShareCount,str_CurrentUserLike,str_PurchaseLink;
@synthesize subScrollView,detailView,HeaderView,btn_detailBack,btn_Like,btn_Save,btn_Shop,lbl_Title,lbl_BrandName,lbl_Price,lbl_PriceBrandSeparator,lbl_LikesCount,lbl_Likes,lbl_SavedCount,lbl_Saved,lbl_ShopSite,img_Line,lbl_YouMayAlsoLike;
@synthesize lbl_TitleSmallView,lbl_BrandNameSmallView,lbl_PriceSmallView,lbl_PriceBrandSeparatorSmallView,str_imageHeight,str_ImageWidth;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    img_LoveAnimation.hidden = YES;
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
    
    [[NSUserDefaults standardUserDefaults] setObject:str_ShareCount forKey:@"sharecount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    
    NSString *img_Width = [NSString stringWithFormat:@"%@",str_ImageWidth];
    NSString *img_Height = [NSString stringWithFormat:@"%@",str_imageHeight];
    
    CGFloat imageWidth = [img_Width floatValue];
    CGFloat imageHeight = [img_Height floatValue];
    CGFloat orginalHeight=imageHeight;
    CGFloat orginalwidth=imageWidth;
    CGFloat newHeight = orginalHeight * (320/orginalwidth);
    NSLog(@"Image Height : %f",newHeight);
    detailImage.frame = CGRectMake(0, 0, 320, newHeight);
    detailView.frame = CGRectMake(0, newHeight, 320, 232);
    
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            if (newHeight <= 485)
            {
                smallView.hidden = YES;
                isSlidingViewSmall = YES;
                detailBound = -170;
            }
            else
            {
                smallView.hidden = NO;
                isSlidingViewSmall = NO;
                detailBound = 568-(newHeight+232);
            }
            if (detailImage.frame.size.height >= 336)
            {
                UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ScrollDetailPage:)];
                pan1.delegate = (id<UIGestureRecognizerDelegate>)self;
                [self.view addGestureRecognizer:pan1];
                
            }
            
            
        }
        else
        {
            //iPhone 4 Version
            if (newHeight <= 395)
            {
                smallView.hidden = YES;
                isSlidingViewSmall = YES;
                detailBound = -170;
            }
            else
            {
                smallView.hidden = NO;
                isSlidingViewSmall = NO;
                detailBound = 480-(newHeight+232);
            }
            if (detailImage.frame.size.height >= 336)
            {
                UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ScrollDetailPage:)];
                pan1.delegate = (id<UIGestureRecognizerDelegate>)self;
                [self.view addGestureRecognizer:pan1];
                
            }
            
            
        }
    }
	else
	{
        //iPad Version
        
        
    }
    
    
    subScrollView.delegate = self;
    isSimilarProduct = NO;
    isLiked = NO;
    isSaved = NO;
    lbl_YouMayAlsoLike.hidden = YES;
    [self createUIObjects];
    [self memoryAllocate_mutableArray];
    
    subScrollView.contentSize=CGSizeMake(0, img_Line.frame.origin.y+img_Line.frame.size.height);
    
    self.productImageCollections.delegate=self;
    self.productImageCollections.dataSource=self;
    [self.productImageCollections registerNib:[UINib nibWithNibName:@"ICEProductImageCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    
    RFQuiltLayout* layout = (id)[self.productImageCollections collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(150,2);
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    lbl_SavedCount.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"sharecount"]];
    [productImageCollections reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
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
    [self memoryAllocate_mutableArray];
    [self showProductAPI];
    [refreshControl endRefreshing];
}

#pragma mark - Initialize Array Values
- (void)memoryAllocate_mutableArray
{
    mutArr_similarProducts = [[NSMutableArray alloc] init];
    mutArr_SimilarProductImages = [[NSMutableArray alloc] init];
    mutArr_SimilarProductLikeCount = [[NSMutableArray alloc] init];
    mutArr_SimilarProductLikeCountFlag = [[NSMutableArray alloc] init];
    mutArr_SimilarProductShareCount = [[NSMutableArray alloc] init];
    mutArr_Brand = [[NSMutableArray alloc] init];
    mutArr_ProductID = [[NSMutableArray alloc] init];;
    mutArr_ProductTitle = [[NSMutableArray alloc] init];;
    mutArr_ProductPrice = [[NSMutableArray alloc] init];;
    mutArr_ProductPurchaseLink = [[NSMutableArray alloc] init];;
}

#pragma mark - ScrollView Delegate
- (void)ScrollDetailPage:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _panOriginY = SlidingView.frame.origin.y;
        _panVelocity1 = CGPointMake(0.0f, 0.0f);
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:self.view];
        _panVelocity1 = velocity;
        CGPoint translation = [gesture translationInView:SlidingView];
        CGRect frame = SlidingView.frame;
        frame.origin.y = _panOriginY + translation.y;
        //        NSLog(@"Frame Y : %f",frame.origin.y);
        
        if (frame.origin.y < 0.0f  && frame.origin.y > detailBound)
        {
            SlidingView.frame = frame;
        }
        if (SlidingView.frame.origin.y <= -(detailImage.frame.size.height - 485))
        {
            smallView.hidden = YES;
        }
        if (SlidingView.frame.origin.y >= -(detailImage.frame.size.height - 485))
        {
            
            if (isSlidingViewSmall)
            {
                smallView.hidden = YES;
            }
            else
            {
                smallView.hidden = NO;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [productImageCollections reloadData];
    float endScrolling = self.subScrollView.contentOffset.y + self.subScrollView.frame.size.height;
    if (endScrolling >= self.subScrollView.contentSize.height)
    {
        if (!isSimilarProduct)
        {
            [self showProductAPI];
            isSimilarProduct = YES;
            [productImageCollections reloadData];
        }
    }
}

#pragma mark - Back Screen Animation
-(void)addSiginIn_gesture
{
    backViewImage.image=backgroundImage_backview;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(siginIn_pan:)];
    pan.accessibilityLabel = @"pageswipe";
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [frontView addGestureRecognizer:pan];
}

- (void)siginIn_pan:(UIPanGestureRecognizer*)gesture
{
    if ([gesture.accessibilityLabel isEqualToString:@"imageswipe"])
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            _panOriginY = SlidingView.frame.origin.y;
            _panVelocity1 = CGPointMake(0.0f, 0.0f);
        }
        if (gesture.state == UIGestureRecognizerStateChanged)
        {
            CGPoint velocity = [gesture velocityInView:self.view];
            _panVelocity1 = velocity;
            CGPoint translation = [gesture translationInView:SlidingView];
            CGRect frame = SlidingView.frame;
            frame.origin.y = _panOriginY + translation.y;
            if (frame.origin.y < 0.0f  && frame.origin.y > detailBound)
            {
                SlidingView.frame = frame;
            }
            if (SlidingView.frame.origin.y <= -85)
            {
                HeaderView.hidden = YES;
                smallView.hidden = YES;
            }
            if (SlidingView.frame.origin.y >= -85)
            {
                HeaderView.hidden = NO;
                if (isSlidingViewSmall)
                {
                    smallView.hidden = YES;
                }
                else
                {
                    smallView.hidden = NO;
                }
            }
        }
        
    }
    else
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            _panOriginX = self.frontView.frame.origin.x;
            _panVelocity = CGPointMake(0.0f, 0.0f);
        }
        if (gesture.state == UIGestureRecognizerStateChanged)
        {
            CGPoint velocity = [gesture velocityInView:self.frontView];
            _panVelocity = velocity;
            CGPoint translation = [gesture translationInView:self.frontView];
            CGRect frame = self.frontView.frame;
            frame.origin.x = _panOriginX + translation.x;
            
            if (frame.origin.x > 0.0f )
            {
                self.frontView.frame = frame;
            }
        }
        else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
        {
            if(self.frontView.frame.origin.x>=50)
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.frontView.frame =  CGRectMake(320, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     [self dismissViewControllerAnimated:NO completion:nil];
                                     
                                     
                                 }];
            }
            else
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.frontView.frame =  CGRectMake(0, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                     
                                 }];
            }
        }
    }
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

#pragma mark - Show Product Detail
- (void)showProductAPI
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/products/";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"%@",str_ProductID]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"GET"];
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
            deserializedDictionary = jsonObject;
            str_Brand = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"brand"]];
            str_currency = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"currency"]];
            str_ProductID = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"id"]];
            str_ImageURL = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"image_url"]];
            NSURL *url_Image = [NSURL URLWithString:str_ImageURL];
            NSData *imgData = [NSData dataWithContentsOfURL:url_Image];
            imgDetail = [UIImage imageWithData:imgData];
            
            str_LikeCount = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"like_count"]];
            str_ShareCount = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"share_count"]];
            [[NSUserDefaults standardUserDefaults] setObject:str_ShareCount forKey:@"sharecount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            str_ProductPrice = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"price"]];
            str_PurchaseLink = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"purchase_link"]];
            str_PurchaseLinkVerifiedAt = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"purchase_link_verified_at"]];
            str_ProductTitle = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"title"]];
            str_Year = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"year"]];
            str_CurrentUserLike = [NSString stringWithFormat:@"%@",[deserializedDictionary valueForKey:@"current_user_like"]];
            
            NSMutableDictionary *dict_SimalarProducts = [deserializedDictionary objectForKey:@"similar_products"];
            NSMutableArray *imageArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"image_url"];
            NSMutableArray *likeArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"like_count"];
            NSMutableArray *likeflagArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"current_user_like"];
            NSMutableArray *shareArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"share_count"];
            NSMutableArray *IDArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"id"];
            NSMutableArray *titleArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"title"];
            NSMutableArray *brandArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"brand"];
            NSMutableArray *priceArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"price"];
            NSMutableArray *purchaseLinkArray = (NSMutableArray *)[dict_SimalarProducts valueForKey:@"purchase_link"];
            
            for (int i = 0; i<[imageArray count]; i++)
            {
                [mutArr_similarProducts addObject:[imageArray objectAtIndex:i]];
                [mutArr_ProductID addObject:[IDArray objectAtIndex:i]];
                [mutArr_ProductTitle addObject:[titleArray objectAtIndex:i]];
                [mutArr_Brand addObject:[brandArray objectAtIndex:i]];
                [mutArr_ProductPrice addObject:[priceArray objectAtIndex:i]];
                [mutArr_SimilarProductLikeCount addObject:[likeArray objectAtIndex:i]];
                [mutArr_SimilarProductShareCount addObject:[shareArray objectAtIndex:i]];
                [mutArr_SimilarProductLikeCountFlag addObject:[likeflagArray objectAtIndex:i]];
                [mutArr_ProductPurchaseLink addObject:[purchaseLinkArray objectAtIndex:i]];
            }
            
            if ([mutArr_similarProducts count])
            {
                subScrollView.contentSize = CGSizeMake(0, productImageCollections.frame.origin.y+productImageCollections.frame.size.height);
                lbl_YouMayAlsoLike.hidden = NO;
                
                for (int i = 0; i<[mutArr_similarProducts count]; i++)
                {
                    
                }
                [productImageCollections sizeToFit];
            }
            else
            {
                lbl_YouMayAlsoLike.hidden = YES;
            }
        }
    }
    else if (error != nil)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 0;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    else if ([data length] == 0 && error == nil)
    {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)
    {
        if(buttonIndex == 0)//OK button pressed
        {
            //do something
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if(buttonIndex == 1)//Try Again button pressed.
        {
            [self showProductAPI];
        }
    }
    else if(alertView.tag ==1)
    {
        if(buttonIndex == 0)//OK button pressed
        {
            //do something
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if(buttonIndex == 1)//Tryagain button pressed.
        {
            //do something
            [self act_Like:nil];
        }
    }
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mutArr_SimilarProductImages count];
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICEProductImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if([mutArr_SimilarProductImages count])
    {
        UIImage *img = [mutArr_SimilarProductImages objectAtIndex:indexPath.row];
        cell.cell_Image.image=img;
        
        if([ [mutArr_SimilarProductShareCount objectAtIndex:indexPath.item ] intValue])
        {
            cell.label_shareCount.hidden=NO;
        }
        else
        {
            cell.label_shareCount.hidden=YES;
        }
        if([ [mutArr_SimilarProductLikeCount objectAtIndex:indexPath.item ] intValue])
        {
            cell.label_likeCount.hidden=NO;
        }
        else
        {
            cell.label_likeCount.hidden=YES;
        }
        cell.cell_Image.alpha=1;
        
        CGFloat orginalHeight=img.size.height;
        CGFloat orginalwidth=img.size.width;
        CGFloat newHeight = orginalHeight * (150/orginalwidth);
        cell.cell_Image.frame=CGRectMake(cell.cell_Image.frame.origin.x, cell.cell_Image.frame.origin.y, 150, newHeight);
        
        float freamHeight=cell.cell_Image.frame.origin.y+newHeight+8;
        
        cell.likeBtn.frame = CGRectMake(cell.cell_Image.frame.origin.x, freamHeight, 15, 14);
        cell.label_likeCount.text=[NSString stringWithFormat:@"%@",[mutArr_SimilarProductLikeCount objectAtIndex:(int)indexPath.row]];
        cell.label_likeCount.textColor=[UIColor whiteColor];
        cell.label_likeCount.backgroundColor=[UIColor clearColor];
        
        NSString *str_CurrentUserLikes=[NSString stringWithFormat:@"%@",[mutArr_SimilarProductLikeCountFlag objectAtIndex:(int)indexPath.row]];
        if ([str_CurrentUserLikes isEqualToString:@"1"])
        {
            [cell.likeBtn setImage:[UIImage imageNamed:@"v3_loved.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.likeBtn setImage:[UIImage imageNamed:@"v3_love.png"] forState:UIControlStateNormal];
        }
        
        cell.label_likeCount.frame =CGRectMake(cell.likeBtn.frame.size.width+4, freamHeight, 20,14);
        cell.shareBtn.frame =CGRectMake(cell.label_likeCount.frame.origin.x+cell.label_likeCount.frame.size.width+10 , freamHeight, 15, 14);
        
        cell.label_shareCount.text=[NSString stringWithFormat:@"%@",[mutArr_SimilarProductShareCount objectAtIndex:(int)indexPath.row]];
        cell.label_shareCount.textColor=[UIColor whiteColor];
        cell.label_shareCount.backgroundColor=[UIColor clearColor];
        
        cell.label_shareCount.frame =CGRectMake(cell.shareBtn.frame.origin.x+cell.shareBtn.frame.size.width+4, freamHeight,20,14);
        cell.likeBtn.tag=(NSInteger)indexPath.item;
        cell.shareBtn.tag=(NSInteger)indexPath.item;
        [cell.likeBtn addTarget:self action:@selector(similarProductLike:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareBtn addTarget:self action:@selector(sharepage:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.tag=(NSInteger)indexPath.item;
    }
    
    CGSize contentSize = collectionView.contentSize;
    productImageCollections.frame = CGRectMake(productImageCollections.frame.origin.x, productImageCollections.frame.origin.y, productImageCollections.frame.size.width, contentSize.height);
    subScrollView.contentSize = CGSizeMake(0, productImageCollections.frame.origin.y+productImageCollections.frame.size.height);
    view_SimilarProducts.frame = CGRectMake(view_SimilarProducts.frame.origin.x, view_SimilarProducts.frame.origin.y, view_SimilarProducts.frame.size.width, contentSize.height+100);
    return cell;
}

#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *img = [mutArr_SimilarProductImages objectAtIndex:indexPath.row];
    CGFloat orginalHeight=img.size.height;
    CGFloat orginalwidth=img.size.width;
    CGFloat newHeight = orginalHeight * (150/orginalwidth);
    CGFloat scaleSize = (newHeight+37)/2.0;
    return CGSizeMake(1,scaleSize);
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(2, 10, 2, 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICEProductImageCell *cell= (ICEProductImageCell*) [self.productImageCollections  cellForItemAtIndexPath:indexPath];
    self.referenceImageView=cell.cell_Image;
    self.referenceImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self showDetailPage:(int)indexPath.row];
}

- (void)showDetailPage:(int)rowIndex
{
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
    detailVC.imgDetail = [mutArr_SimilarProductImages objectAtIndex:rowIndex];
    detailVC.str_ProductTitle = [NSString stringWithFormat:@"%@",[mutArr_ProductTitle objectAtIndex:rowIndex]];
    detailVC.str_Brand = [NSString stringWithFormat:@"%@",[mutArr_Brand objectAtIndex:rowIndex]];
    detailVC.str_ProductPrice = [NSString stringWithFormat:@"%@",[mutArr_ProductPrice objectAtIndex:rowIndex]];
    detailVC.str_LikeCount = [NSString stringWithFormat:@"%@",[mutArr_SimilarProductLikeCount objectAtIndex:rowIndex]];
    detailVC.str_ShareCount = [NSString stringWithFormat:@"%@",[mutArr_SimilarProductShareCount objectAtIndex:rowIndex]];
    detailVC.str_CurrentUserLike = [NSString stringWithFormat:@"%@",[mutArr_SimilarProductLikeCountFlag objectAtIndex:rowIndex]];
    detailVC.str_PurchaseLink = [NSString stringWithFormat:@"%@",[mutArr_ProductPurchaseLink objectAtIndex:rowIndex]];
    detailVC.transitioningDelegate = self;
    [self presentViewController:detailVC animated:YES completion:nil];
}


#pragma mark - Create UI Objects
- (void)createUIObjects
{
    [detailImage setImageWithURL:[NSURL URLWithString:str_DetailImageURL]];
    lbl_Title.text = [NSString stringWithFormat:@"%@",str_ProductTitle];
    lbl_TitleSmallView.text = [NSString stringWithFormat:@"%@",str_ProductTitle];
    
    lbl_BrandName.text = [NSString stringWithFormat:@"%@",str_Brand];
    lbl_BrandNameSmallView.text = [NSString stringWithFormat:@"%@",str_Brand];
    
    [self coinesSeperateCount:(NSString *)str_ProductPrice];
    
    lbl_Price.text = [NSString stringWithFormat:@"%@",str_ProductPrice];
    lbl_PriceSmallView.text = [NSString stringWithFormat:@"%@",str_ProductPrice];
    if ([str_CurrentUserLike isEqualToString:@"1"])
    {
        isLikedFlag = YES;
        [btn_Like setImage:[UIImage imageNamed:@"loved3.png"] forState:UIControlStateNormal];
        
    }
    else
    {
        isLikedFlag = NO;
        [btn_Like setImage:[UIImage imageNamed:@"love3.png"] forState:UIControlStateNormal];
        lbl_Likes.text = @"Love";
    }
    
    if (![str_PurchaseLink isEqualToString:@"https://www.monmode.today/product-not-available"])
    {
        btn_Shop.alpha = 1.0;
        [btn_Shop setImage:[UIImage imageNamed:@"shop3.png"] forState:UIControlStateNormal];
        btn_Shop.userInteractionEnabled = YES;
    }
    else
    {
        btn_Shop.alpha = 0.4;
        [btn_Shop setImage:[UIImage imageNamed:@"shop3.png"] forState:UIControlStateNormal];
        btn_Shop.userInteractionEnabled = NO;
        
    }
    if ([str_PurchaseLink isEqualToString:@"<null>"]) {
        btn_Shop.alpha = 0.4;
        [btn_Shop setImage:[UIImage imageNamed:@"shop3.png"] forState:UIControlStateNormal];
        btn_Shop.userInteractionEnabled = NO;
        
    }
    else
    {
        btn_Shop.alpha = 1.0;
        [btn_Shop setImage:[UIImage imageNamed:@"shop3.png"] forState:UIControlStateNormal];
        btn_Shop.userInteractionEnabled = YES;
    }
    
    if ([str_LikeCount intValue] >= 2)
    {
        lbl_LikesCount.frame = CGRectMake(16, 174, 28, 21);
        lbl_Likes.frame = CGRectMake(42, 174, 42, 21);
        lbl_Likes.text = @"Loves";
    }
    else
    {
        lbl_LikesCount.frame = CGRectMake(20, 174, 28, 21);
        lbl_Likes.frame = CGRectMake(38, 174, 42, 21);
        lbl_Likes.text = @"Love";
        
    }
    
    lbl_LikesCount.text = [NSString stringWithFormat:@"%@",str_LikeCount];
    lbl_SavedCount.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"sharecount"]];
    
    if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"sharecount"]] isEqualToString:@"0"])
    {
        lbl_SavedCount.frame = CGRectMake(108, 174, 28, 21);
        lbl_Saved.frame = CGRectMake(133, 174, 85, 21);
        lbl_Saved.text = @"Share Now";
    }
    else
    {
        lbl_SavedCount.frame = CGRectMake(125, 174, 28, 21);
        lbl_Saved.frame = CGRectMake(150, 174, 85, 21);
        lbl_Saved.text = @"Shared";
    }
    lbl_ShopSite.text = [NSString stringWithFormat:@"%@",str_Brand];
}

- (void)coinesSeperateCount:(NSString *)string
{
    double a = [string doubleValue]/100;
    NSString *strSum = [NSString stringWithFormat:@"%f",a];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    str_ProductPrice = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[strSum doubleValue]]];
}

#pragma mark - Go To Share Page
- (IBAction)sharepage:(id)sender
{
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
    
    shareVC.str_BrandNameToShare = str_Brand;
    shareVC.backgroundImage_backview=[self takescreenshotes];
    shareVC.str_ShareImageURL = [NSString stringWithFormat:@"%@",str_DetailImageURL];
    [self presentViewController:shareVC animated:YES completion:nil];
}


- (void)similarProductLike:(UIButton*)sender
{
    int IsAlredyLiked=[ [mutArr_SimilarProductLikeCountFlag objectAtIndex:(int)sender.tag ] intValue];
    NSString *str_product_Id=[NSString stringWithFormat:@"%@",[mutArr_ProductID objectAtIndex:(int)sender.tag]];
    
    NSString *urlAsString;
    if(IsAlredyLiked)
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/unlike",str_product_Id];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    }
    else
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/like",str_product_Id];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    }
    
    NSURL *url = [NSURL URLWithString:urlAsString];
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
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * deserializedSimilarLike = jsonObject;
                if ([[NSString stringWithFormat:@"%@",[deserializedSimilarLike valueForKey:@"id"]] isEqualToString:str_product_Id])
                {
                    if (!IsAlredyLiked)
                    {
                        int count1=[ [mutArr_SimilarProductLikeCount objectAtIndex:(int)sender.tag ] intValue];
                        count1 += 1;
                        [mutArr_SimilarProductLikeCount replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", count1]];
                        [mutArr_SimilarProductLikeCountFlag replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", 1]];
                        isLikedFlag = YES;
                    }
                    else
                    {
                        int count1=[ [mutArr_SimilarProductLikeCount objectAtIndex:(int)sender.tag ] intValue];
                        count1 -= 1;
                        [mutArr_SimilarProductLikeCount replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", count1]];
                        [mutArr_SimilarProductLikeCountFlag replaceObjectAtIndex:(int)sender.tag withObject:[NSString stringWithFormat:@"%d", 0]];
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

#pragma mark - Like, Save and Shop Actions

- (void)loveAccept
{
    NSString *urlAsString;
    if (isLikedFlag == NO)
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/like",str_ProductID];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    }
    else
    {
        urlAsString = [NSString stringWithFormat:@"https://www.monmode.today/api/v1/products/%@/unlike",str_ProductID];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    }
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    NSLog(@"Product Like Request : %@",url);
    [urlRequest setTimeoutInterval:60.0f];
    if (isLikedFlag == NO)
    {
        [urlRequest setHTTPMethod:@"POST"];
    }
    else
    {
        [urlRequest setHTTPMethod:@"DELETE"];
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
            NSLog(@"Product Like Response : %@",jsonObject);
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                deserializedDictionaryLike = jsonObject;
                if ([[NSString stringWithFormat:@"%@",[deserializedDictionaryLike valueForKey:@"id"]] isEqualToString:str_ProductID])
                {
                    if (isLikedFlag == NO)
                    {
                        [btn_Like setImage:[UIImage imageNamed:@"loved3.png"] forState:UIControlStateNormal];
                        
                        int lc = [str_LikeCount intValue];
                        int newLikeCount = lc+1;
                        str_LikeCount = [NSString stringWithFormat:@"%d",newLikeCount];
                        lbl_LikesCount.text = [NSString stringWithFormat:@"%d",newLikeCount];
                        isLikedFlag = YES;
                    }
                    else
                    {
                        [btn_Like setImage:[UIImage imageNamed:@"love3.png"] forState:UIControlStateNormal];
                        int lc = [str_LikeCount intValue];
                        int newLikeCount = lc-1;
                        str_LikeCount = [NSString stringWithFormat:@"%d",newLikeCount];
                        lbl_LikesCount.text = [NSString stringWithFormat:@"%d",newLikeCount];
                        isLikedFlag = NO;
                    }
                }
                else
                {
                    UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:[jsonObject objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertsuccess show];
                }
            }
            [img_LoveAnimation stopAnimating];
            img_LoveAnimation.hidden=YES;
        }
        else if (error != nil)
        {
            [img_LoveAnimation stopAnimating];
            img_LoveAnimation.hidden=YES;
            
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
            
            alertsuccess.tag = 1;
            alertsuccess.delegate = self;
            [alertsuccess show];
        }
        else if ([data length] == 0 && error == nil)
        {
            [img_LoveAnimation stopAnimating];
            img_LoveAnimation.hidden=YES;
        }
    }
    
}

- (IBAction)act_Like:(id)sender
{
    img_LoveAnimation.hidden=NO;
    @autoreleasepool {
        NSMutableArray *mutarray=[NSMutableArray array];
        for (int i=1; i<=19; i++) {
            NSString *pageFilename = [NSString stringWithFormat:@"LoveAnim%d",i];
            NSLog(@"Page : %@",pageFilename);
            NSString * pathFilename = [[NSBundle mainBundle] pathForResource:pageFilename ofType:@"png"];
            NSLog(@"Path : %@",pathFilename);
            [mutarray addObject:[UIImage imageWithContentsOfFile:pathFilename]];
            
        }
        
        img_LoveAnimation.animationImages = mutarray;
    }
    // all frames will execute in 1.75 seconds
    img_LoveAnimation.animationDuration = 1.75;
    // repeat the annimation forever
    img_LoveAnimation.animationRepeatCount = 0;
    
    // start animating
    [img_LoveAnimation startAnimating];
    
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                     }
                     completion:^(BOOL finished){
                         
                         [self loveAccept];
                         
                     }];
    
    
}

- (IBAction)act_ShopLink:(id)sender
{
    //Device Checking
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        if (IS_IPHONE_5)
        {
            //iPhone 5, 5C & 5S Version
            obj_Purchase = [[ICEPurchaseLinkViewController alloc] initWithNibName:@"ICEPurchaseLinkViewController" bundle:nil];
        }
        else
        {
            //iPhone 4 Version
            obj_Purchase = [[ICEPurchaseLinkViewController alloc] initWithNibName:@"ICEPurchaseLinkViewController_iPhone4" bundle:nil];
        }
    }
	else
	{
        //iPad Version
    }
    obj_Purchase.str_PurchaseLink = [NSString stringWithFormat:@"%@",str_PurchaseLink];
    obj_Purchase.backgroundImage_backview=[self takescreenshotes];
    [self presentViewController:obj_Purchase animated:YES completion:nil];
}

- (IBAction)backpage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
