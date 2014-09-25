//
//  CVCell.h
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEProductImageCell : UICollectionViewCell


@property (strong, nonatomic) IBOutlet UIImageView *cell_Image;

@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *detailBtn;

@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

//@property (strong, nonatomic) IBOutlet UILabel *label_likeCount;

@property (strong, nonatomic) IBOutlet UILabel *label_likeCount;
@property (strong, nonatomic) IBOutlet UILabel *label_shareCount;
@property (nonatomic) IBOutlet UIActivityIndicatorView *imageActivity;

//@property (strong, nonatomic) IBOutlet UILabel *label_shareCount;

@end
