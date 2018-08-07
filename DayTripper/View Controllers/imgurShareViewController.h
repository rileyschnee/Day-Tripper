//
//  imgurShareViewController.h
//  DayTripper
//
//  Created by Michael Abelar on 8/1/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
@protocol ImgurPicturePasser
@property (strong, nonatomic) UIImage *imageUpload;
- (void)reloadCollectionView;
@end

@interface imgurShareViewController : UIViewController
@property (strong, nonatomic) Trip* trip;
@property (strong, nonatomic) id<ImgurPicturePasser> delegate;
@end
