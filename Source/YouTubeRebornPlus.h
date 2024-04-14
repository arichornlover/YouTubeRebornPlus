#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/utsname.h>
#import <substrate.h>
#import <rootless.h>

#import <YouTubeHeader/YTAppDelegate.h>
#import <YouTubeHeader/YTPlayerViewController.h>
#import <YouTubeHeader/YTQTMButton.h>
#import <YouTubeHeader/YTVideoQualitySwitchOriginalController.h>
#import <YouTubeHeader/YTPlayerViewController.h>
#import <YouTubeHeader/YTWatchController.h>
#import <YouTubeHeader/YTIGuideResponse.h>
#import <YouTubeHeader/YTIGuideResponseSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarItemRenderer.h>
#import <YouTubeHeader/YTIPivotBarRenderer.h>
#import <YouTubeHeader/YTIBrowseRequest.h>
#import <YouTubeHeader/YTIButtonRenderer.h>
#import <YouTubeHeader/YTISectionListRenderer.h>
#import <YouTubeHeader/YTColorPalette.h>
#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/ASCollectionView.h>
#import <YouTubeHeader/YTPlayerOverlay.h>
#import <YouTubeHeader/YTPlayerOverlayProvider.h>
#import <YouTubeHeader/YTReelWatchPlaybackOverlayView.h>
#import <YouTubeHeader/YTReelPlayerBottomButton.h>
#import <YouTubeHeader/YTReelPlayerViewController.h>
#import <YouTubeHeader/YTAlertView.h>
#import <YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h>
#import <YouTubeHeader/YTPivotBarItemView.h>
#import <YouTubeHeader/YTCollectionViewCell.h>
#import <YouTubeHeader/YTVideoWithContextNode.h> // YouTube-X
#import <YouTubeHeader/ELMCellNode.h> // YouTube-X
#import <YouTubeHeader/ELMNodeController.h> // YouTube-X

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define IS_ENABLED(k) [[NSUserDefaults standardUserDefaults] boolForKey:k]
#define APP_THEME_IDX [[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"]
#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"
#define DEFAULT_RATE 1.0f // YTSpeed
#define LOWCONTRASTMODE_CUTOFF_VERSION @"17.38.10" // LowContrastMode

@interface YTSingleVideoController ()
- (float)playbackRate;
- (void)setPlaybackRate:(float)arg1;
@end

@interface YTPlayerViewController ()
- (YTSingleVideoController *)activeVideo;
@end

// IAmYouTube
@interface SSOConfiguration : NSObject
@end

// YouTubeRebornPlus
@interface YTHeaderLogoController : UIView
@property(readonly, nonatomic) long long pageStyle;
@end

@interface YTNavigationBarTitleView : UIView
@end

@interface YTChipCloudCell : UIView
@end

@interface YTPlayabilityResolutionUserActionUIController : NSObject // Skips content warning before playing *some videos - @PoomSmart
- (void)confirmAlertDidPressConfirm;
@end 

@interface YTMainAppControlsOverlayView: UIView
@end

@interface YTTransportControlsButtonView : UIView
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
- (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface FRPSliderCell : UITableViewCell
@end

@interface YTPlaybackButton : UIControl
@end

@interface PlayerManager : NSObject
- (float)progress;
@end

@interface YTSegmentableInlinePlayerBarView
@property (nonatomic, assign, readwrite) BOOL enableSnapToChapter;
@end

@interface YTPlaylistHeaderViewController: UIViewController
@property UIButton *downloadsButton;
@end

// Buttons
@interface YTRightNavigationButtons : UIView
@property YTQTMButton *notificationButton;
@property YTQTMButton *sponsorBlockButton;
@property YTQTMButton *youtubeRebornButton;
@end

@interface YTISlimMetadataButtonSupportedRenderers : NSObject
- (id)slimButton_buttonRenderer;
- (id)slimMetadataButtonRenderer;
@end

// YTSpeed
@interface YTVarispeedSwitchControllerOption : NSObject
- (id)initWithTitle:(id)title rate:(float)rate;
@end

@interface MLHAMQueuePlayer : NSObject
@property id playerEventCenter;
@property id delegate;
- (void)setRate:(float)rate;
- (void)internalSetRate;
@end

@interface MLPlayerEventCenter : NSObject
- (void)broadcastRateChange:(float)rate;
@end

@interface HAMPlayerInternal : NSObject
- (void)setRate:(float)rate;
@end

@interface YTLocalPlaybackController : NSObject
- (void)setPlaybackRate:(float)rate;
- (id)activeVideo;
@end

// BigYTMiniPlayer
@interface YTMainAppVideoPlayerOverlayView : UIView
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTWatchMiniBarView : UIView
@end

// YTAutoFullscreen
@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
// YTSpeed
@property id activeVideo;
@property float playbackRate;
- (void)singleVideo:(id)video playbackRateDidChange:(float)rate;
- (YTSingleVideoController *)activeVideo;
@end

// App Theme
@interface YTColor : NSObject
+ (UIColor *)white1;
+ (UIColor *)white2;
+ (UIColor *)white3;
+ (UIColor *)white4;
+ (UIColor *)white5;
+ (UIColor *)black0;
+ (UIColor *)black1;
+ (UIColor *)black2;
+ (UIColor *)black3;
+ (UIColor *)black4;
+ (UIColor *)blackPure;
+ (UIColor *)grey1;
+ (UIColor *)grey2;
+ (UIColor *)white1Alpha98;
+ (UIColor *)white1Alpha95;
@end

@interface YCHLiveChatView : UIView
@end

@interface YTFullscreenEngagementOverlayView : UIView
@end

@interface YTRelatedVideosView : UIView
@end

@interface YTTopAlignedView : UIView
@end

@interface ELMView: UIView
@end

@interface ASWAppSwitcherCollectionViewCell: UIView
@end

@interface ASScrollView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface UIKeyboardDockView : UIView
@end

@interface _ASDisplayView : UIView
@end

@interface ELMContainerNode : NSObject
@end

@interface YTAutonavEndscreenView : UIView
@end

@interface YTPivotBarIndicatorView : UIView
@end

@interface YTCommentDetailHeaderCell : UIView
@end

@interface SponsorBlockSettingsController : UITableViewController 
@end

@interface SponsorBlockViewController : UIViewController
@end

@interface UICandidateViewController : UIViewController
@end

@interface UIPredictionViewController : UIViewController
@end

@interface TUIEmojiSearchView : UIView
@end

@interface FRPreferences : UITableViewController
@end

@interface FRPSelectListTable : UITableViewController
@end

@interface settingsReorderTable : UIViewController
@property(nonatomic, strong) UITableView *tableView;
@end

// Snack bar
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
- (void)setAction:(id)action;
@end

@interface GOOHUDMessageAction : NSObject
- (void)setTitle:(NSString *)title;
- (void)setHandler:(void (^)(id))handler;
@end

@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end
