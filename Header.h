#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"

// CercubePlus
@interface YTPlayabilityResolutionUserActionUIController : NSObject // Skips content warning before playing *some videos - @PoomSmart
- (void)confirmAlertDidPressConfirm;
@end 

@interface YTMainAppControlsOverlayView: UIView
@end

@interface YTTransportControlsButtonView : UIView
@end

// Cercube button in Nav bar
@interface MDCButton : UIButton
@end

@interface YTQTMButton : UIButton
@end

@interface YTRightNavigationButtons : UIView
@property (nonatomic, strong, readwrite) MDCButton *cercubeButton;
@property YTQTMButton *notificationButton;
@end

// IAmYouTube
@interface SSOConfiguration : NSObject
@end

// BigYTMiniPlayer
@interface YTMainAppVideoPlayerOverlayView : UIView
- (UIViewController *)_viewControllerForAncestor;
+ (CGFloat)topButtonAdditionalPadding;
@end

@interface YTWatchMiniBarView : UIView
@end

// YTAutoFullscreen
@interface YTPlayerViewController (YTPlayerViewControllerCategory)
- (void)autoFullscreen;
- (id)activeVideoPlayerOverlay;
- (id)playerView;
@end

// YTNoShorts
@interface ELMCellNode
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
- (void)removeShortsCellAtIndexPath:(NSIndexPath *)indexPath;
@end

// OLED Darkmode
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

// DontEatMyContent
@interface YTPlayerView : UIView
- (BOOL)zoomToFill;
- (id)renderingView;
- (id)playerView;
@end

@interface MLHAMSBDLSampleBufferRenderingView : UIView
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (BOOL)isFullscreen;
- (id)videoPlayerOverlayView;
- (id)activeVideoPlayerOverlay;
@end

NSString* deviceName();
BOOL isDeviceSupported();
void activate(); 
void deactivate();
void center();
