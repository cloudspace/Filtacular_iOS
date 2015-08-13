//
//  TweetCell.m
//  Filtacular
//
//  Created by Isaac Paul on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"

#import "RestkitRequest+API.h"
#import "UIView+Positioning.h"
#import "UIImageView+SDWebCache.h"
#import "UIColor+Filtacular.h"

#import "ServerWrapper.h"

#import <OAStackView.h>
#import <TTTAttributedLabel.h>

@interface TweetCell () <TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblDisplayName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *lblDatePosted;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *lblPostText;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (strong, nonatomic) IBOutlet UIImageView *imgUrlPic;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlText;
@property (strong, nonatomic) IBOutlet UILabel *lblUrlDescription;
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
@property (strong, nonatomic) IBOutlet UIView *viewLinkyLooCover;

@property (assign, nonatomic) bool bigPicOpen;
@property (strong, nonatomic) Tweet* cachedTweet;

@end

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self reloadBottomBar];
    
    //Default config for links
    _lblPostText.linkAttributes = @{
        (NSString *)kCTUnderlineStyleAttributeName :@(1),
        (NSString *)kCTForegroundColorAttributeName:(id)([UIColor fBarBlue].CGColor)
    };
    
    _lblPostText.delegate = self;
    _lblPostText.userInteractionEnabled = true;
}

- (void)reloadBottomBar {
    //Configure the bottom bar layout
    _viewBottomBar.distribution = OAStackViewDistributionFillEqually;
    _viewBottomBar.alignment = OAStackViewAlignmentFill;
    _viewBottomBar.axis = UILayoutConstraintAxisHorizontal;
    _viewBottomBar.spacing = 0.0f;
    
    //We remove each view and readd it so it gets layed out with the new config
    NSArray* subviews = [_viewBottomBar.subviews copy];
    for (UIView* eachView in subviews) {
        [eachView removeFromSuperview];
    }
    
    for (UIView* eachView in subviews) {
        [_viewBottomBar addArrangedSubview:eachView];
    }
}

- (void)configureWithObject:(Tweet*)tweet {
    
    [self resetUI];
    [self populateUIWithTweet:tweet];
    [self createLinks];
    
    //Set Images
    [_imgUserPic setImageWithString:tweet.profilePicUrl placeholderImage:nil];
    if (tweet.pictureOnly) {
        [_imgBigPic setImageWithString:tweet.imageUrl placeholderImage:nil];
    }
    else {
        bool hasImage = (tweet.imageUrl.length != 0);
        if (hasImage) {
            [_imgUrlPic setImageWithString:tweet.imageUrl placeholderImage:nil];
        }
    }
    
    [self repositionSubviewsWithTweet:tweet];
}

- (void)reconfigureForHeightChange:(Tweet*)tweet {
    [self populateUIWithTweet:tweet];
    [self createLinks];
    [self repositionSubviewsWithTweet:tweet];
}

- (void)resetUI {
    _imgUrlPic.image = nil;
    _lblUrlDomain.text = @"";
    _lblUrlText.text = @"";
    _lblUrlDescription.text = @"";
    _btnToTweeter.enabled = true;
    _btnToTweet.enabled = true;
    _viewLinkyLooCover.height = 0.0f;
}

- (void)populateUIWithTweet:(Tweet*)tweet {
    _cachedTweet = tweet;
    _bigPicOpen = tweet.bigPicOpenedCache;
    _lblDisplayName.text = tweet.displayName;
    _lblUserName.text = [NSString stringWithFormat:@"@%@", tweet.userName];
    _lblDatePosted.text = [tweet simpleTimeAgo];
    _lblPostText.text = tweet.text;
    [_lblPostText setText:tweet.text afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
    [_btnRetweet setTitle:[@(tweet.retweetCount) stringValue] forState:UIControlStateNormal];
    [_btnFavorite setTitle:[@(tweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    
    bool disableRetweet = (tweet.retweeted);
    bool disableFavorite = (tweet.favorited);
    [_btnRetweet setEnabled:!disableRetweet];
    [_btnFavorite setEnabled:!disableFavorite];
    [_btnFollow setEnabled:!tweet.followed];
    [_viewFollow setHidden:!tweet.showFollowButton];
    
    if (tweet.linkOnly) {
        _btnToTweeter.enabled = false;
        _btnToTweet.enabled = false;
    }
    
    if (tweet.pictureOnly) {
        [self configureBigPic:tweet];
    }
    else {
        _btnBigPic.hidden = true;
        _imgBigPic.hidden = true;
        [self configureLinkDetails:tweet];
    }
}

- (void)createLinks {
    NSRegularExpression *regexp = HashTagRegex();
    NSArray* matches = [regexp matchesInString:_lblPostText.text options:0 range:NSMakeRange(0, [_lblPostText.text length])];
    for (NSTextCheckingResult* match in matches)
    {
        NSRange hashRange = [match range];
        hashRange.location += 1;
        hashRange.length -= 1;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/hashtag/%@", [_lblPostText.text substringWithRange:hashRange]]];
        [_lblPostText addLinkToURL:url withRange:[match range]];
    }
    
    regexp = MentionRegex();
    matches = [regexp matchesInString:_lblPostText.text options:0 range:NSMakeRange(0, [_lblPostText.text length])];
    for (NSTextCheckingResult* match in matches)
    {
        NSRange mentionRange = [match range];
        mentionRange.location += 1;
        mentionRange.length -= 1;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", [_lblPostText.text substringWithRange:mentionRange]]];
        [_lblPostText addLinkToURL:url withRange:mentionRange];
    }
}

- (CGFloat)calculateHeightWith:(Tweet*)tweet {

    self.width = [[UIScreen mainScreen] bounds].size.width;
    [self layoutIfNeeded];//TODO: This also calls configureWithObj
    [self configureWithObject:tweet]; //This is called on a throwaway object so its ok to reload it from scratch
    return self.height;
}

- (void)configureBigPic:(Tweet*)tweet {
    _btnBigPic.hidden = false;
    _imgBigPic.hidden = false;
    
    _btnToLink.enabled = false;
    
    bool enableTopBarLinks = (_bigPicOpen);
    
    _btnToTweet.enabled = enableTopBarLinks;
    _btnToTweeter.enabled = enableTopBarLinks;
}

- (void)configureLinkDetails:(Tweet*)tweet {
    bool hasUrl         = (tweet.urlLink .length != 0);
    bool hasUrlTitle    = (tweet.urlTitle.length != 0);
    _btnToLink.enabled  = hasUrl;
    
    if (hasUrlTitle) {
        _lblUrlText.text        = tweet.urlTitle;
        _lblUrlDescription.text = tweet.urlDescription;
        _lblUrlDomain.text      = [tweet displayLinkHost];
    }
}

const float cPadding = 16.0f;

- (void)repositionSubviewsWithTweet:(Tweet*)tweet {
    
    bool hasUrl     = (tweet.urlLink .length != 0 && tweet.pictureOnly == false);
    bool hasImage   = (tweet.imageUrl.length != 0 && tweet.pictureOnly == false);
    bool linkOnly   = tweet.linkOnly;
    
    [self repositionUserName];
    
    if (linkOnly) {
        float yOffset = cPadding;
        _viewLinkyLooCover.y = yOffset;
        yOffset = [self repositionURLInfo:hasImage hasUrl:hasUrl fromOffset:yOffset];
        _viewLinkyLooCover.height = yOffset - _viewLinkyLooCover.y;
        self.height = yOffset;
        return;
    }
    else {
        _viewLinkyLooCover.height = 0.0f;
    }
    
    //reposition everything else
    [self fitToHeight:_lblPostText];
    if (_lblPostText.height < 39.0f)
        _lblPostText.height = 39.0f;
    
    float yOffset = _lblPostText.y + _lblPostText.height + cPadding;
    
    yOffset = [self repositionURLInfo:hasImage hasUrl:hasUrl fromOffset:yOffset];
    
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
        self.height = yOffset + _viewBottomBar.height - cPadding;
    }
}

- (void)repositionUserName {
    [self fitToWidth:_lblDisplayName maxWidth:self.width * 0.4f];
    if (_lblDisplayName.width == 0.0f)
        _lblDisplayName.width = self.width * 0.4f;
    _lblUserName.x = _lblDisplayName.x + _lblDisplayName.width + 4.0f;
    
    _lblUserName.width = self.width * 0.89f - _lblUserName.x;
}

- (float)repositionURLInfo:(bool)hasImage hasUrl:(bool)hasUrl fromOffset:(float)yOffset {
    _btnToLink.y = yOffset;
    _btnToLink.height = self.height - _btnToLink.y - _viewBottomBar.height;
    
    if (hasImage) {
        _imgUrlPic.y = yOffset;
        yOffset += _imgUrlPic.height + cPadding;
    }
    
    if (hasUrl && _lblUrlText.text.length > 0) {
        
        [self fitToHeight:_lblUrlText];
        
        _lblUrlText.y = yOffset;
        yOffset += _lblUrlText.height + cPadding;
        
        if (_lblUrlDescription.text.length > 0) {
            [self fitToHeight:_lblUrlDescription];
            _lblUrlDescription.y = yOffset;
            yOffset += _lblUrlDescription.height + cPadding;
        }
        
        _lblUrlDomain.y = yOffset;
        yOffset += _lblUrlDomain.height + cPadding;
    }
    return yOffset;
}

- (void)fitToHeight:(UILabel*)label {
    CGSize spaceToSizeIn = label.size;
    spaceToSizeIn.height = MAXFLOAT;
    
    CGSize newLabelSize = [self boundingSizeInSpace:spaceToSizeIn WithLabel:label];
    
    label.height = newLabelSize.height;
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
    
    RestkitRequest* request = [RestkitRequest retweetRequest:_cachedTweet.tweetId];
    [[ServerWrapper sharedInstance] performRequest:request];
}

- (IBAction)tapFavorite {
    
    _cachedTweet.favorited = true;
    _cachedTweet.favoriteCount += 1;
    _btnFavorite.enabled = false;
    [_btnFavorite setTitle:[@(_cachedTweet.favoriteCount) stringValue] forState:UIControlStateNormal];
    
    RestkitRequest* request = [RestkitRequest favoriteRequest:_cachedTweet.tweetId];
    [[ServerWrapper sharedInstance] performRequest:request];
}

- (IBAction)tapFollow {
    _cachedTweet.followed = true;
    _btnFollow.enabled = false;
    
    RestkitRequest* request = [RestkitRequest followRequest:_cachedTweet.userName];
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
    
    //This *may* be called when the cell height changes. So we need to reconfigure so we can reposition our elements.
    if (_cachedTweet)
        [self reconfigureForHeightChange:_cachedTweet];
}

#pragma mark - Url Link Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_cachedTweet.tappedLink == nil)
        return;
    _cachedTweet.tappedLink([url absoluteString]);
}

static NSRegularExpression *sHashTagRegex;
static inline NSRegularExpression * HashTagRegex() {
    if (!sHashTagRegex) {
        sHashTagRegex = [[NSRegularExpression alloc] initWithPattern:@"[#]+[A-Za-z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return sHashTagRegex;
}

static NSRegularExpression *sMentionRegex;
static inline NSRegularExpression * MentionRegex() {
    if (!sMentionRegex) {
        sMentionRegex = [[NSRegularExpression alloc] initWithPattern:@"[@]+[A-Za-z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return sMentionRegex;
}

@end
