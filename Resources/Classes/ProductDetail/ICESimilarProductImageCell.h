//
//  ICESimilarProductImageCell.h
//  monMode
//
//  Created by Muthu Sabari on 8/6/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICESimilarProductImageCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cell_Image;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *label_likeCount;
@property (strong, nonatomic) IBOutlet UILabel *label_shareCount;

@end
