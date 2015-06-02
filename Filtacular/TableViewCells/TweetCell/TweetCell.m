//
//  TweetCell.m
//  Filtacular
//
//  Created by Isaac Paul on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"

#import "UIView+Positioning.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TweetCell ()
@property (strong, nonatomic) IBOutlet UILabel *lblDisplayName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblDatePosted;
@property (strong, nonatomic) IBOutlet UILabel *lblPostText;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (strong, nonatomic) IBOutlet UIImageView *imgUrlPic;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlText;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlDomain;
@property (strong, nonatomic) IBOutlet UILabel *lblRetweets;
@property (strong, nonatomic) IBOutlet UILabel *lblFavorites;
@property (strong, nonatomic) IBOutlet UIView *viewBottomBar;

@end

@implementation TweetCell

- (void)configureWithObject:(Tweet*)tweet {
    bool hasUrl = (tweet.urlLink.length != 0);
    bool hasImage = (tweet.urlImage.length != 0);
    
    _lblDisplayName.text = tweet.displayName;
    _lblUserName.text = tweet.userName;
    //_lblDatePosted = [tweet datePostedAsString];
    _lblPostText.text = tweet.text;
    
    NSURL* urlPhoto = [NSURL URLWithString:tweet.profilePicUrl];
    
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:urlPhoto];
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    if (cachedImage) {
        [_imgUserPic sd_cancelCurrentImageLoad];
        [_imgUserPic setImage:cachedImage];
    }
    else {
        [_imgUserPic sd_setImageWithURL:urlPhoto placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    if (hasUrl) {
        if (hasImage) {
            urlPhoto = [NSURL URLWithString:tweet.urlImage];
            
            key = [[SDWebImageManager sharedManager] cacheKeyForURL:urlPhoto];
            cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            
            if (cachedImage) {
                [_imgUrlPic sd_cancelCurrentImageLoad];
                [_imgUrlPic setImage:cachedImage];
            }
            else {
                [_imgUrlPic sd_setImageWithURL:urlPhoto placeholderImage:nil options:SDWebImageRetryFailed];
            }
            
            
        }
        else
            _imgUrlPic.image = nil;
        _lblUrlText.text = tweet.urlDescription;
        _lblUrlDomain.text = tweet.urlTitle;
    }
    else {
        _imgUrlPic.image = nil;
        _lblUrlDomain.text = @"";
        _lblUrlText.text = @"";
    }
    _lblRetweets.text = [@(tweet.retweetCount) stringValue];
    _lblFavorites.text = [@(tweet.favoriteCount) stringValue];
    
    [self repositionSubviewsHasUrl:hasUrl hasUrlImage:hasImage];
}

const float cPadding = 16.0f;

- (void)repositionSubviewsHasUrl:(bool)hasUrl hasUrlImage:(bool)hasUrlImage {
    [self fitToHeight:_lblPostText];
    _lblPostText.height -= 16.0f;
    if (_lblPostText.height < 39.0f)
        _lblPostText.height = 39.0f;
    
    float yOffset = _lblPostText.y + _lblPostText.height + cPadding;
    
    if (hasUrl) {
        if (hasUrlImage) {
            _imgUrlPic.y = yOffset;
            yOffset += _imgUrlPic.height + cPadding;
        }
        
        [self fitToHeight:_lblUrlText];
        
        _lblUrlText.y = yOffset;
        yOffset += _lblUrlText.height + cPadding;
        
        _lblUrlDomain.y = yOffset;
        yOffset += _lblUrlDomain.height + cPadding;
    }
    
    self.height = yOffset - cPadding + _viewBottomBar.height -2.0f;
    
    //reposition username
    [self fitToWidth:_lblDisplayName maxWidth:126.0f];
    if (_lblDisplayName.width == 0.0f)
        _lblDisplayName.width = 126.0f;
    _lblUserName.x = _lblDisplayName.x + _lblDisplayName.width + 4.0f;
    [self fitToWidth:_lblUserName maxWidth:269.0f - _lblUserName.x];
    if (_lblUserName.width == 0.0f)
        _lblUserName.width = 51.0f;
}

- (void)fitToHeight:(UILabel*)label {
    CGPoint oldPosition = label.origin;
    CGFloat oldWidth = label.width;
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.height = MAXFLOAT;
    NSDictionary* attributes = @{NSFontAttributeName: label.font};
    
    CGRect newLabelRect = [label.text boundingRectWithSize:spaceToSizeIn options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    label.frame = newLabelRect;
    label.origin = oldPosition;
    label.width = oldWidth;
    
}

- (void)fitToWidth:(UILabel*)label maxWidth:(float)maxWidth {
    CGPoint oldPosition = label.origin;
    CGFloat oldHeight = label.height;
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.width = maxWidth;
    spaceToSizeIn.height = label.height;
    NSDictionary* attributes = @{NSFontAttributeName: label.font};
    
    CGRect newLabelRect = [label.text boundingRectWithSize:spaceToSizeIn options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    label.frame = newLabelRect;
    label.origin = oldPosition;
    label.height = oldHeight;
    
}

@end
