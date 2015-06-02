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
    _lblDisplayName.text = tweet.displayName;
    _lblUserName.text = tweet.userName;
    //_lblDatePosted = [tweet datePostedAsString];
    //_lblPostText.text = tweet.postText;
    [_imgUserPic sd_setImageWithURL:[NSURL URLWithString:tweet.profilePicUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    //[_imgUrlPic sd_setImageWithURL:[NSURL URLWithString:tweet.linkPicUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    //_lblUrlText.text = tweet.urlText;
    //_lblUrlDomain.text = tweet.urlDomain;
    _lblRetweets.text = [@(tweet.retweetCount) stringValue];
    _lblFavorites.text = [@(tweet.favoriteCount) stringValue];
    
    [self repositionSubviewsHasUrl:true hasUrlImage:true];
}

const float cPadding = 8.0f;

- (void)repositionSubviewsHasUrl:(bool)hasUrl hasUrlImage:(bool)hasUrlImage {
    [self fitToHeight:_lblPostText];
    float yOffset = _lblPostText.y + _lblPostText.height + cPadding;
    
    if (hasUrl) {
        if (hasUrlImage) {
            _imgUrlPic.y = yOffset;
            yOffset += _imgUrlPic.height + cPadding;
        }
        _lblUrlText.y = yOffset;
        yOffset += _lblUrlText.height + cPadding;
        
        _lblUrlDomain.y = yOffset;
        yOffset += _lblUrlDomain.height + cPadding;
    }
    
    self.height = yOffset + _viewBottomBar.height;
}

- (void)fitToHeight:(UILabel*)label {
    CGPoint oldPosition = label.origin;
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.height = MAXFLOAT;
    NSDictionary* attributes = @{NSFontAttributeName: label.font};
    CGRect newLabelRect = [label.text boundingRectWithSize:spaceToSizeIn options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    label.frame = newLabelRect;
    label.origin = oldPosition;
}

@end
