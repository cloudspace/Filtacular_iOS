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

#import "ServerWrapper.h"

#import <OAStackView.h>

@interface TweetCell ()
@property (strong, nonatomic) IBOutlet UILabel *lblDisplayName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblDatePosted;
@property (strong, nonatomic) IBOutlet UILabel *lblPostText;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (strong, nonatomic) IBOutlet UIImageView *imgUrlPic;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlText;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlDomain;
@property (strong, nonatomic) IBOutlet OAStackView *viewBottomBar;
@property (strong, nonatomic) IBOutlet UIImageView *imgBigPic;
@property (strong, nonatomic) IBOutlet UIButton *btnBigPic;
@property (strong, nonatomic) IBOutlet UIButton *btnRetweet;
@property (strong, nonatomic) IBOutlet UIButton *btnFavorite;
@property (strong, nonatomic) IBOutlet UIButton *btnToTweet;
@property (strong, nonatomic) IBOutlet UIButton *btnToTweeter;
@property (strong, nonatomic) IBOutlet UIButton *btnToLink;
@property (strong, nonatomic) IBOutlet UIButton *btnFollow;
@property (strong, nonatomic) IBOutlet UIView *viewFollow;

@property (assign, nonatomic) bool bigPicOpen;
@property (strong, nonatomic) Tweet* cachedTweet;

@end

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _viewBottomBar.distribution = OAStackViewDistributionFillEqually;
    _viewBottomBar.alignment = OAStackViewAlignmentFill;
    _viewBottomBar.axis = UILayoutConstraintAxisHorizontal;
    _viewBottomBar.spacing = 0.0f;
    
    NSArray* subviews = [_viewBottomBar.subviews copy];
    
    for (UIView* eachView in subviews) {
        [eachView removeFromSuperview];
    }
    
    for (UIView* eachView in subviews) {
        [_viewBottomBar addArrangedSubview:eachView];
    }
}

- (void)configureWithObject:(Tweet*)tweet {
    
    _cachedTweet = tweet;
    _bigPicOpen = tweet.bigPicOpenedCache;
    _imgUrlPic.image = nil;
    _lblUrlDomain.text = @"";
    _lblUrlText.text = @"";
    
    _lblDisplayName.text = tweet.displayName;
    _lblUserName.text = [NSString stringWithFormat:@"@%@", tweet.userName];
    _lblDatePosted.text = [tweet simpleTimeAgo];
    _lblPostText.text = tweet.text;
    
    [_imgUserPic setImageWithURL:tweet.profilePicUrl placeholderImage:nil options:SDWebImageRetryFailed];
    
    [_btnRetweet setTitle:[@(tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    [_btnFavorite setTitle:[@(tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    
    bool disableRetweet = (tweet.retweeted);
    bool disableFavorite = (tweet.favorited);
    [_btnRetweet setEnabled:!disableRetweet];
    [_btnFavorite setEnabled:!disableFavorite];
    [_btnFollow setEnabled:!tweet.followed];
    
    [_viewFollow setHidden:!tweet.showFollowButton];
    
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
    [_imgBigPic setImageWithURL:tweet.imageUrl placeholderImage:nil options:SDWebImageRetryFailed];
    
    _btnToLink.enabled = false;
    
    bool enableTopBarLinks = (_bigPicOpen);
    
    _btnToTweet.enabled = enableTopBarLinks;
    _btnToTweeter.enabled = enableTopBarLinks;
}

- (void)configureLinkDetails:(Tweet*)tweet {
    bool hasUrl = (tweet.urlLink.length != 0);
    bool hasImage = (tweet.imageUrl.length != 0);
    bool hasUrlTitle = (tweet.urlTitle.length != 0);
    
    _btnToLink.enabled = hasUrl;
    
    if (hasUrl == false)
        return;
    
    if (hasImage) {
        [_imgUrlPic setImageWithURL:tweet.imageUrl placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    if (hasUrlTitle) {
        _lblUrlText.text = tweet.urlTitle;
        _lblUrlDomain.text = [[NSURL URLWithString:tweet.urlLink] host];
    }
}

const float cPadding = 16.0f;

- (void)repositionSubviewsWithTweet:(Tweet*)tweet {
    
    bool hasUrl = (tweet.urlLink.length != 0 && tweet.pictureOnly == false);
    bool hasImage = (tweet.imageUrl.length != 0);
    
    //reposition username
    [self fitToWidth:_lblDisplayName maxWidth:126.0f];
    if (_lblDisplayName.width == 0.0f)
        _lblDisplayName.width = 126.0f;
    _lblUserName.x = _lblDisplayName.x + _lblDisplayName.width + 4.0f;

    _lblUserName.width = 263.0f - _lblUserName.x;
    
    //reposition everything else
    [self fitToHeight:_lblPostText];
    _lblPostText.height -= 16.0f;
    if (_lblPostText.height < 39.0f)
        _lblPostText.height = 39.0f;
    
    float yOffset = _lblPostText.y + _lblPostText.height + cPadding;
    
    _btnToLink.y = yOffset;
    _btnToLink.height = self.height - _btnToLink.y - _viewBottomBar.height;
    
    if (hasUrl) {
        if (hasImage) {
            _imgUrlPic.y = yOffset;
            yOffset += _imgUrlPic.height + cPadding;
        }
        
        if (_lblUrlText.text.length > 0) {
        
            [self fitToHeight:_lblUrlText];
        
            _lblUrlText.y = yOffset;
            yOffset += _lblUrlText.height + cPadding;
            
            _lblUrlDomain.y = yOffset;
            yOffset += _lblUrlDomain.height + cPadding;
        }
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
        self.height = yOffset + _viewBottomBar.height;
    }
}

- (void)fitToHeight:(UILabel*)label {
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.height = MAXFLOAT;
    
    CGSize newLabelSize = [self boundingSizeInSpace:spaceToSizeIn WithLabel:label];
    
    label.height = newLabelSize.height + label.font.lineHeight;
}

- (void)fitToWidth:(UILabel*)label maxWidth:(float)maxWidth {
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.width = maxWidth;
    spaceToSizeIn.height = label.height;

    CGSize newLabelSize = [self boundingSizeInSpace:spaceToSizeIn WithLabel:label];
    
    label.width = newLabelSize.width;
}

- (CGSize)boundingSizeInSpace:(CGSize)space WithLabel:(UILabel*)label {
    if (label.text == nil)
        label.text = @"";
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary* attributes = @{NSFontAttributeName: label.font, NSParagraphStyleAttributeName:paragraphStyle};
    label.text = [label.text stringByReplacingOccurrencesOfString:@"رً ॣ ॣ ॣ" withString:@"j ॣ ॣ ॣ"];
    
    CGRect newLabelRect = [label.text boundingRectWithSize:space options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return newLabelRect.size;
}

- (void)tapBigPic {
    
    if (_cachedTweet.tappedBigPic)
        _cachedTweet.tappedBigPic();
}

- (IBAction)tapReply {
    if (_cachedTweet.tappedLink == nil)
        return;
    
    NSString* username = _cachedTweet.userName;
    NSString* tweetId = _cachedTweet.tweetId;
    NSString* link = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@#tweet-box-reply-to-%@", username, tweetId, tweetId];
    _cachedTweet.tappedLink(link);
}

- (IBAction)tapRetweet {
    
    _cachedTweet.retweeted = true;
    _cachedTweet.retweetCount += 1;
    _btnRetweet.enabled = false;
    [_btnRetweet setTitle:[@(_cachedTweet.retweetCount) stringValue] forState:UIControlStateNormal];
    
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/retweet";
    request.parameters = @{@"tweet_id":_cachedTweet.tweetId};
    request.noMappingRequired = true;
    [[ServerWrapper sharedInstance] performRequest:request];
}

- (IBAction)tapFavorite {
    
    _cachedTweet.favorited = true;
    _cachedTweet.favoriteCount += 1;
    _btnFavorite.enabled = false;
    [_btnFavorite setTitle:[@(_cachedTweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/favorite";
    request.parameters = @{@"tweet_id":_cachedTweet.tweetId};
    request.noMappingRequired = true;
    [[ServerWrapper sharedInstance] performRequest:request];
}

- (IBAction)tapFollow {
    _cachedTweet.followed = true;
    _btnFollow.enabled = false;
    
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/follow";
    request.parameters = @{@"tweet_id":_cachedTweet.tweetId};
    request.noMappingRequired = true;
    [[ServerWrapper sharedInstance] performRequest:request];
}

- (IBAction)tapToTweet {
    if (_cachedTweet.tappedLink == nil)
        return;
    
    NSString* link = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", _cachedTweet.userName, _cachedTweet.tweetId];
    _cachedTweet.tappedLink(link);
}

- (IBAction)tapToTweeter {
    if (_cachedTweet.tappedLink == nil)
        return;
    
    NSString* link = [NSString stringWithFormat:@"https://twitter.com/%@", _cachedTweet.userName];
    _cachedTweet.tappedLink(link);
}

- (IBAction)tapToLink {
    if (_cachedTweet.tappedLink == nil)
        return;
    _cachedTweet.tappedLink(_cachedTweet.urlLink);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //This is called when the cell height changes. So we need to reconfigure so we can reposition our elements.
    if (_cachedTweet)
        [self configureWithObject:_cachedTweet];
}

@end
