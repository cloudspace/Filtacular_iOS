//
//  UIImageView+SDWebCache.h
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SDWebCache)

- (void)setImageWithString:(NSString *)url placeholderImage:(UIImage *)placeholder;

@end
