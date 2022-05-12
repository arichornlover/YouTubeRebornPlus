@interface UIView ()
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTQTMButton : UIButton
@end

@interface ABCSwitch : UISwitch
@end

@interface YTPivotBarItemView : UIView
@property(readonly, nonatomic) YTQTMButton *navigationButton;
@end

@interface YTTopAlignedView : UIView
@end

@interface YTAsyncCollectionView : UICollectionView
@end

@interface YTRightNavigationButtons
@property(readonly, nonatomic) YTQTMButton *MDXButton;
@property(readonly, nonatomic) YTQTMButton *searchButton;
@property(readonly, nonatomic) YTQTMButton *notificationButton;
@end

@interface YTMainAppControlsOverlayView : UIView
@property(readonly, nonatomic) YTQTMButton *playbackRouteButton;
@property(readonly, nonatomic) YTQTMButton *previousButton;
@property(readonly, nonatomic) YTQTMButton *nextButton;
@property(readonly, nonatomic) ABCSwitch *autonavSwitch;
@property(readonly, nonatomic) YTQTMButton *closedCaptionsOrSubtitlesButton;
@end

@interface YTMainAppSkipVideoButton
@property(readonly, nonatomic) UIImageView *imageView;
@end


@interface YTUserDefaults : NSObject
- (long long)appThemeSetting;
@end

@interface YTPivotBarViewController : UIViewController
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTWrapperView : UIView
- (void)rootOptionsAction:(id)sender;
@end