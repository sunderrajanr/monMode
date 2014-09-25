//
//  ICEDetailViewController.h
//  EveryDayLuxury
//
//  Created by Muthu Sabari on 6/2/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEProductImageCell.h"
#import "ICESimilarProductImageCell.h"
#import "RFQuiltLayout.h"

@interface ICEDetailViewController : UIViewController<RFQuiltLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate,UIViewControllerTransitioningDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;
@property (strong, nonatomic) IBOutlet UIImageView *backViewImage;
@property (strong, nonatomic)  UIImage * backgroundImage_backview;


@property (strong, nonatomic)  IBOutlet  UIScrollView *subScrollView;
@property (strong, nonatomic)  IBOutlet UIView *detailView;
@property (strong, nonatomic)  IBOutlet UIImageView *detailImage;

@property (strong, nonatomic)  IBOutlet  UIView *HeaderView;
@property (strong, nonatomic)  IBOutlet  UIButton *btn_detailBack;
@property (strong, nonatomic)  IBOutlet  UIButton *btn_Save;
@property (strong, nonatomic)  IBOutlet  UIButton *btn_Shop;
@property (strong, nonatomic)  IBOutlet  UIButton *btn_Like;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_Title;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_BrandName;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_Price;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_PriceBrandSeparator;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_LikesCount;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_Likes;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_SavedCount;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_Saved;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_ShopSite;
@property (strong, nonatomic)  IBOutlet  UIImageView *img_Line;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_YouMayAlsoLike;
@property (weak, nonatomic) IBOutlet UIView *smallView;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_TitleSmallView;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_BrandNameSmallView;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_PriceSmallView;
@property (strong, nonatomic)  IBOutlet  UILabel *lbl_PriceBrandSeparatorSmallView;
@property (strong, nonatomic)  IBOutlet  UIImageView *img_LoveAnimation;
@property (nonatomic) IBOutlet UICollectionView *productImageCollections;

@property (strong, nonatomic) NSString *str_ProductTitle;
@property (strong, nonatomic) NSString *str_Brand;
@property (strong, nonatomic) NSString *str_ProductPrice;
@property (strong, nonatomic) NSString *str_LikeCount;
@property (strong, nonatomic) NSString *str_ShareCount;
@property (strong, nonatomic) NSString *str_CurrentUserLike;
@property (strong, nonatomic) NSString *str_PurchaseLink;
@property (strong, nonatomic) NSString *str_DetailImageURL;
@property (strong, nonatomic) NSString *str_ImageWidth;
@property (strong, nonatomic) NSString *str_imageHeight;

@property (strong, nonatomic) UIImageView *referenceImageView;

@property (strong, nonatomic) NSString *str_ProductID;
@property (strong, nonatomic) UIImage *imgDetail;
@property (strong, nonatomic) NSString *str_Title;
@property (strong, nonatomic) NSString *str_Cost;

@property (strong, nonatomic) NSDictionary *deserializedDictionary;
@property (strong, nonatomic) NSDictionary *deserializedDictionaryLike;

@property (nonatomic , retain) IBOutlet UIView *view_SimilarProducts;
@property (nonatomic , retain) IBOutlet UIView *SlidingView;
//Check Internet Connection
@property (nonatomic , retain) IBOutlet UIImageView *image_CheckInternet;
@property (nonatomic , retain) IBOutlet UIView *view_CheckInternet;
@property (nonatomic , retain) IBOutlet UILabel *lbl_CheckInternet;

- (IBAction)backpage:(id)sender;
- (IBAction)act_Like:(id)sender;
- (IBAction)sharepage:(id)sender;
- (IBAction)act_ShopLink:(id)sender;




@end
