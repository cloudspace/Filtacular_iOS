//
//  UIImageView+SDWebCache.m
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "UIImageView+SDWebCache.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (SDWebCache)

- (void)setImageWithString:(NSString *)url placeholderImage:(UIImage *)placeholder {
    
    NSURL* urlPhoto = [NSURL URLWithString:url];
    
    NSString* key = [[SDWebImageManager sharedManager] cacheKeyForURL:urlPhoto];
    UIImage* cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    if (cachedImage) {
        [self sd_cancelCurrentImageLoad];
        [self setImage:cachedImage];
        
        return;
    }
    
    if ([urlPhoto isEqual:self.sd_imageURL])
        return;
    
    [self sd_setImageWithURL:urlPhoto placeholderImage:nil options:SDWebImageRetryFailed];
}

@end
