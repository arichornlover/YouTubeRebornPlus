#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"

@interface YTMainAppVideoPlayerOverlayView : UIView
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTWatchMiniBarView : UIView
@end

@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
@end

@interface ASScrollView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface UIKeyboardDockView : UIView
@end

@interface UICandidateViewController : UIViewController
@end

@interface UIPredictionViewController : UIViewController
@end

@interface SponsorBlockSettingsController : UITableViewController 
@end