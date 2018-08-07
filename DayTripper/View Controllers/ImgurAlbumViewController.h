//
//  ImgurAlbumViewController.h
//  DayTripper
//
//  Created by Michael Abelar on 8/2/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "imgurShareViewController.h"

@interface ImgurAlbumViewController : UIViewController <ImgurPicturePasser>
@property (strong, nonatomic) Trip* trip;
@property (strong, nonatomic) UIImage *imageUpload;
@end
