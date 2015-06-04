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
#import "UIImageView+SDWebCache.h"


@interface TweetCell ()
@property (strong, nonatomic) IBOutlet UILabel *lblDisplayName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblDatePosted;
@property (strong, nonatomic) IBOutlet UILabel *lblPostText;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (strong, nonatomic) IBOutlet UIImageView *imgUrlPic;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlText;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlDomain;
@property (strong, nonatomic) IBOutlet UIView *viewBottomBar;
@property (strong, nonatomic) IBOutlet UIImageView *imgBigPic;
@property (strong, nonatomic) IBOutlet UIButton *btnBigPic;
@property (strong, nonatomic) IBOutlet UIButton *btnRetweet;
@property (strong, nonatomic) IBOutlet UIButton *btnFavorite;

@property (assign, nonatomic) bool bigPicOpen;
@property (strong, nonatomic) Tweet* cachedTweet;

@end

@implementation TweetCell

- (void)configureWithObject:(Tweet*)tweet {
    
    _cachedTweet = tweet;
    _bigPicOpen = tweet.bigPicOpenedCache;
    _imgUrlPic.image = nil;
    _lblUrlDomain.text = @"";
    _lblUrlText.text = @"";
    
    _lblDisplayName.text = tweet.displayName;
    _lblUserName.text = tweet.userName;
    //_lblDatePosted = [tweet datePostedAsString];
    _lblPostText.text = tweet.text;
    
    [_imgUserPic setImageWithURL:tweet.profilePicUrl placeholderImage:nil options:SDWebImageRetryFailed];
    
    [_btnRetweet setTitle:[@(tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    [_btnFavorite setTitle:[@(tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    
    bool disableRetweet = (tweet.retweeted);
    bool disableFavorite = (tweet.favorited);
    [_btnRetweet setEnabled:!disableRetweet];
    [_btnFavorite setEnabled:!disableFavorite];
    
    if (tweet.pictureOnly) {
        [self configureBigPic:tweet];
    }
    else {
        _btnBigPic.hidden = true;
        _imgBigPic.hidden = true;
        [self configureLinkDetails:tweet];
    }
    
    [self repositionSubviewsWithTweet:tweet];
}

- (void)configureBigPic:(Tweet*)tweet {
    _btnBigPic.hidden = false;
    _imgBigPic.hidden = false;
    [_imgBigPic setImageWithURL:tweet.urlImage placeholderImage:nil options:SDWebImageRetryFailed];
}

- (void)configureLinkDetails:(Tweet*)tweet {
    bool hasUrl = (tweet.urlLink.length != 0);
    bool hasImage = (tweet.urlImage.length != 0);
    
    if (hasUrl == false)
        return;
    
    if (hasImage) {
        [_imgUrlPic setImageWithURL:tweet.urlImage placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    _lblUrlText.text = tweet.urlDescription;
    _lblUrlDomain.text = tweet.urlTitle;
}

const float cPadding = 16.0f;

- (void)repositionSubviewsWithTweet:(Tweet*)tweet {
    
    bool hasUrl = (tweet.urlLink.length != 0 && tweet.pictureOnly == false);
    bool hasImage = (tweet.urlImage.length != 0);
    
    //reposition username
    [self fitToWidth:_lblDisplayName maxWidth:126.0f];
    if (_lblDisplayName.width == 0.0f)
        _lblDisplayName.width = 126.0f;
    _lblUserName.x = _lblDisplayName.x + _lblDisplayName.width + 4.0f;
    [self fitToWidth:_lblUserName maxWidth:269.0f - _lblUserName.x];
    if (_lblUserName.width == 0.0f)
        _lblUserName.width = 51.0f;
    
    //reposition everything else
    [self fitToHeight:_lblPostText];
    _lblPostText.height -= 16.0f;
    if (_lblPostText.height < 39.0f)
        _lblPostText.height = 39.0f;
    
    float yOffset = _lblPostText.y + _lblPostText.height + cPadding;
    
    if (hasUrl) {
        if (hasImage) {
            _imgUrlPic.y = yOffset;
            yOffset += _imgUrlPic.height + cPadding;
        }
        
        [self fitToHeight:_lblUrlText];
        
        _lblUrlText.y = yOffset;
        yOffset += _lblUrlText.height + cPadding;
        
        _lblUrlDomain.y = yOffset;
        yOffset += _lblUrlDomain.height + cPadding;
    }
    
    if (tweet.pictureOnly) {
        if (_bigPicOpen) {
            self.height = yOffset + _imgBigPic.height + _viewBottomBar.height;
            _imgBigPic.y = yOffset;
            _btnBigPic.y = yOffset;
        }
        else {
            self.height = _imgBigPic.height + cPadding * 2;
            _imgBigPic.y = cPadding;
            _btnBigPic.y = cPadding;
        }
    }
    else {
        self.height = yOffset - cPadding + _viewBottomBar.height;
    }
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

- (void)tapBigPic {
    _cachedTweet.bigPicOpenedCache = !_cachedTweet.bigPicOpenedCache;
    
    if (_cachedTweet.tappedBigPic)
        _cachedTweet.tappedBigPic();
}

- (IBAction)tapReply {

}

- (IBAction)tapRetweet {
    
    _cachedTweet.retweeted = true;
    _btnRetweet.enabled = false;
    
    if (_cachedTweet.tappedBigPic)
        _cachedTweet.tappedBigPic();
}

- (IBAction)tapFavorite {
    
    _cachedTweet.favorited = true;
    _btnFavorite.enabled = false;
    
    if (_cachedTweet.tappedBigPic)
        _cachedTweet.tappedBigPic();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //This is called when the cell height changes. So we need to reconfigure so we can reposition our elements.
    if (_cachedTweet)
        [self configureWithObject:_cachedTweet];
}

@end
