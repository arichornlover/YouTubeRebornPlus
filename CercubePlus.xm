#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Header.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"

BOOL hideHUD() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD_enabled"];
}
BOOL oled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"oled_enabled"];
}
BOOL autoFullScreen() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"];
}
BOOL noHoverCard() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"];
}
BOOL ReExplore() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"reExplore_enabled"];
}
BOOL bigYTMiniPlayer() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bigYTMiniPlayer_enabled"];
}
BOOL hideCC() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCC_enabled"];
}
BOOL hideAutoplaySwitch() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideAutoplaySwitch_enabled"];
}

UIColor* oledColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];

// Hide CC / Autoplay switch
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig;
    if (hideAutoplaySwitch()) {
        MSHookIvar<UIView *>(self, "_autonavSwitch").hidden = YES;
    } 
    if (hideCC()) {
        MSHookIvar<UIView *>(self, "_closedCaptionsOrSubtitlesButton").hidden = YES;
    }
}
%end

// Hide HUD Messages
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return hideHUD() ? nil : %orig;
}
%end

// YTAutoFullScreen: https://github.com/PoomSmart/YTAutoFullScreen/
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig;
    if (autoFullScreen())
        [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(autoFullscreen) userInfo:nil repeats:NO];
}
%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}
%end

// NOYTPremium: - https://github.com/PoomSmart/NoYTPremium
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)frequencyCap { return NO; }
%end

%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

// YTABGoodies - https://poomsmart.github.io/repo/depictions/ytabgoodies.html
// YouAreThere - https://poomsmart.github.io/repo/depictions/youarethere.html
// YouRememberCaption - https://poomsmart.github.io/repo/depictions/youremembercaption.html
// YTSystemAppearance: https://poomsmart.github.io/repo/depictions/ytsystemappearance.html
%hook YTColdConfig
- (BOOL)enableYouthereCommandsOnIos { return NO; }
- (BOOL)respectDeviceCaptionSetting { return NO; }
- (BOOL)shouldUseAppThemeSetting { return YES; }
//- (BOOL)enableDarkerDarkMode { return YES; }
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return NO; }
%end

// YTNOCheckLocalNetWork - https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html
%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled { return NO; }
%end

// YTClassicVideoQuality - https://github.com/PoomSmart/YTClassicVideoQuality
%hook YTVideoQualitySwitchControllerFactory
- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end

// YTNoHoverCards 0.0.3: https://github.com/level3tjg/YTNoHoverCards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
	if (!noHoverCard())
	hidden = YES;
	%orig;
}
%end

// OLED 
// Thanks u/DGh0st for his very well explained comment - https://www.reddit.com/r/jailbreakdevelopers/comments/9uape7/comment/e94sq80/
// Thanks sinfool for his flex patch which brings OLED Dark mode for YouTube - "Color Customizer (YouTube) OLED"
%group gOLED
%hook UIView
-(void)setBackgroundColor:(id)arg1 {
    if ([self.nextResponder isKindOfClass:%c(YTLinkCell)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTCommentsHeaderView)]) 
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTSearchView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTSearchBoxView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTEngagementPanelHeaderView)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTEngagementPanelView)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTPivotBarView)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTHUDMessageView)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTChipCloudCell)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YCHLiveChatTextCell)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YCHLiveChatView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YCHLiveChatViewerEngagementCell)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTSlideForActionsView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTPlaylistHeaderView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTAsyncCollectionView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTFeedHeaderView)])
    arg1 = oledColor;
    if ([self.nextResponder isKindOfClass:%c(YTMessageCell)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTPlaylistPanelProminentThumbnailVideoCell)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(ASWAppSwitcherCollectionViewCell)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTEditSheetControllerHeader)])
    arg1 = oledColor;	
    if ([self.nextResponder isKindOfClass:%c(YTDialogContainerScrollView)])
    arg1 = oledColor;	
    %orig;
}
%end

%hook UIControl // this sucks I know :/
-(void)setBackgroundColor:(id)arg1 {
    if ([self.nextResponder isKindOfClass:%c(YTShareMainView)]) 
    arg1 = oledColor;
    %orig;
}
%end

%hook YTAsyncCollectionView
-(void)setBackgroundColor:(id)arg1 {
    if([self.nextResponder isKindOfClass:%c(YTRelatedVideosCollectionViewController)]) {
        arg1 = [oledColor colorWithAlphaComponent:0.0];
    } else if([self.nextResponder isKindOfClass:%c(YTFullscreenMetadataHighlightsCollectionViewController)]) {
        arg1 = [oledColor colorWithAlphaComponent:0.0];
    } else {
        arg1 = oledColor;
    }
    %orig;
}
%end

%hook YTDialogContainerScrollView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTTopAlignedView 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
-(void)didMoveToWindow {  // Dune - https://github.com/Skittyblock/Dune/blob/9b1df9790230115b7553cc9dbadf36889018d7f9/Tweak.xm#L70
    %orig;
    MSHookIvar<UIView *>(self, "_contentView").backgroundColor = oledColor;
}
%end

%hook MDXQueueView // Cast queue
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTChannelProfileEditorView 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTChannelSubMenuView // 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTChannelListSubMenuView // sub - 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTCommentView 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTCreateCommentAccessoryView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTCreateCommentTextView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
-(void)setTextColor:(id)arg1 {
	arg1 = [UIColor whiteColor];
	%orig;
}
%end

%hook YCHLiveChatActionPanelView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTEmojiTextView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTShareTitleView // Share sheet
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTNavigationBar
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
-(void)setBarTintColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTPrivacyTosFooterView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTWatchMiniBarView 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    %orig;
}
%end

%hook YTPlaylistMiniBarView 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    %orig;
}
%end

%hook YTEngagementPanelHeaderView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTChannelMobileHeaderView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTInlineSignInView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTHeaderView //Stt bar
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTTabTitlesView // Tab bar - mychannel
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTSettingsCell // Settings 
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook GOODialogView // 3 dots menu
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTCollectionView //sharesheet
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook ASWAppSwitchingSheetHeaderView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTCollectionSeparatorView
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
- (void)didMoveToWindow {}
%end

%hook YTLightweightQTMButton
-(void)setBackgroundColor:(id)arg1 {
    if([self.nextResponder isKindOfClass:%c(YTShareMainView)]) {
    arg1 = oledColor;
    %orig;
    }
}
-(void)setCustomTitleColor:(id)arg1 {
    arg1 = [UIColor whiteColor];
    %orig;
}
%end

%hook YTShareBusyView // sharesheet load
-(void)setBackgroundColor:(id)arg1 { 
    arg1 = oledColor;
    %orig;
}
%end

%hook YTPageView
-(void)setBackgroundColor:(id)arg1 { 
    arg1 = oledColor;
    %orig;
}
%end

%hook YTWatchView
-(void)setBackgroundColor:(id)arg1 { 
    arg1 = oledColor;
    %orig;
}
%end

%hook YTSearchBarView
-(void)setBackgroundColor:(id)arg1 { 
    arg1 = oledColor;
    %orig;
}
%end

%hook YTSearchSuggestionCollectionViewCell
-(void)updateColors {}
%end

%hook UISearchBarBackground
-(void)setBarTintColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTMealBarPromoView
-(void)setBackgroundColor:(id)arg1 { // Offline
    arg1 = oledColor;
    %orig;
}
%end

%hook NIAttributedLabel
-(void)setBackgroundColor:(id)arg1 {
    if ([self.nextResponder isKindOfClass:%c(UIScrollView)])
    arg1 = oledColor;
    %orig;
}
%end

%hook ASScrollView  // Explore
-(void)didMoveToWindow { 
    self.backgroundColor = oledColor;
    %orig;
}
%end

%hook ASCollectionView  // your videos
-(void)didMoveToWindow {
    self.backgroundColor = oledColor;
    %orig;
}
%end

////
/*
%hook UICollectionView
-(void)setBackgroundColor:(id)arg1 {
    if ([self.nextResponder isKindOfClass:%c(UICollectionViewControllerWrapperView)])
    arg1 = oledColor;
    %orig;
}
%end

%hook YTShortsGalleryHeaderView  // upload videos heaer (gallery)
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook _ASDisplayView // edit your videos
-(void)layoutSubviews {
    if ([self.nextResponder isKindOfClass:%c(ELMView)])
    self.backgroundColor = oledColor;
}
%end

%hook YTChannelProfileDescriptionEditorView // edit profile Description
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

%hook YTChannelProfileNameEditorView  // edit profile Name
-(void)setBackgroundColor:(id)arg1 {
    arg1 = oledColor;
    %orig;
}
%end

hook GOOTextField 
-(void)setBackgroundColor:(id)arg1 {  // edit profile Description
    arg1 = oledColor;
    %orig;
}
%end

%hook GOOMultilineTextField// 
-(void)setBackgroundColor:(id)arg1 { // edit profile Name
    arg1 = oledColor;
    %orig;
}
%end
*/
%end

// YTReExplore: https://github.com/PoomSmart/YTReExplore/
%group gReExplore
static void replaceTab(YTIGuideResponse *response) {
    NSMutableArray <YTIGuideResponseSupportedRenderers *> *renderers = [response itemsArray];
    for (YTIGuideResponseSupportedRenderers *guideRenderers in renderers) {
        YTIPivotBarRenderer *pivotBarRenderer = [guideRenderers pivotBarRenderer];
        NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [pivotBarRenderer itemsArray];
        NSUInteger shortIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEshorts"];
        }];
        if (shortIndex != NSNotFound) {
            [items removeObjectAtIndex:shortIndex];
            NSUInteger exploreIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
                return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:[%c(YTIBrowseRequest) browseIDForExploreTab]];
            }];
            if (exploreIndex == NSNotFound) {
                YTIPivotBarSupportedRenderers *exploreTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:[%c(YTIBrowseRequest) browseIDForExploreTab] title:@"Explore" iconType:292];
                [items insertObject:exploreTab atIndex:1];
            }
        }
    }
}
%hook YTGuideServiceCoordinator
- (void)handleResponse:(YTIGuideResponse *)response withCompletion:(id)completion {
    replaceTab(response);
    %orig(response, completion);
}
- (void)handleResponse:(YTIGuideResponse *)response error:(id)error completion:(id)completion {
    replaceTab(response);
    %orig(response, error, completion);
}
%end
%end

// BigYTMiniPlayer: https://github.com/Galactic-Dev/BigYTMiniPlayer
%group Main
%hook YTWatchMiniBarView
-(void)setWatchMiniPlayerLayout:(int)arg1 {
    %orig(1);
}
-(int)watchMiniPlayerLayout {
    return 1;
}
-(void)layoutSubviews {
    %orig;
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
%end

%hook YTMainAppVideoPlayerOverlayView
-(BOOL)isUserInteractionEnabled {
    if([[self _viewControllerForAncestor].parentViewController.parentViewController isKindOfClass:%c(YTWatchMiniBarViewController)]) {
        return NO;
    }
    return %orig;
}
%end
%end

%ctor {
    %init;
    if (oled() && ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1)) {
		%init(gOLED);
    }
	if (ReExplore()) {
        %init(gReExplore)
	}
	if (bigYTMiniPlayer() && (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)) {
        %init(Main)
	}
}