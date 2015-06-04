//
//  UIImageView+SDWebCache.h
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface UIImageView (SDWebCache)

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

@end
