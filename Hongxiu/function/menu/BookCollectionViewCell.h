//
//  BookCollectionViewCell.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCollectionViewCell : UICollectionViewCell

nonatomic_strong_readonly(UILabel    , *titleLabel)
nonatomic_strong_readonly(UIImageView, *imageView)

@end
