#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"
#include <RemoteLog.h>

@interface YTMainAppVideoPlayerOverlayView : UIView
-(UIViewController *)_viewControllerForAncestor;
@end
@interface YTWatchMiniBarView : UIView
@end
@interface YTAsyncCollectionView : UIView
@end
@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
@end

UIColor* oledColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];

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

//Settings
%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *>*)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
	if (category == 1) {
		    NSUInteger statsForNerdsIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) { 
            return item.settingItemId == 265;
		}];
		if (statsForNerdsIndex != NSNotFound) {
	     	//
			YTSettingsSectionItem *hoverCardItem = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Show End screens hover cards (YTNoHoverCards)" titleDescription:@"Allows creator End screens (thumbnails) to appear at the end of videos."];
			hoverCardItem.hasSwitch = YES;
			hoverCardItem.switchVisible = YES;
			hoverCardItem.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"];
			hoverCardItem.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hover_cards_enabled"];
				return YES;
			};
			[sectionItems insertObject:hoverCardItem atIndex:statsForNerdsIndex + 1];
			//
			YTSettingsSectionItem *reExplore = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Replace Shorts tab with Explore tab (YTReExplore)" titleDescription:@"App restart is required."];
			reExplore.hasSwitch = YES;
			reExplore.switchVisible = YES;
			reExplore.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"reExplore_enabled"];
			reExplore.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"reExplore_enabled"];
				return YES;
			};
			[sectionItems insertObject:reExplore atIndex:statsForNerdsIndex + 2];
			//
			YTSettingsSectionItem *bigYTMiniPlayer = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Bigger miniplayer bar (BigYTMiniPlayer)" titleDescription:@"App restart is required."];
			bigYTMiniPlayer.hasSwitch = YES;
			bigYTMiniPlayer.switchVisible = YES;
			bigYTMiniPlayer.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"bigYTMiniPlayer_enabled"];
			bigYTMiniPlayer.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
				return YES;
			};
			[sectionItems insertObject:bigYTMiniPlayer atIndex:statsForNerdsIndex + 2];
			//
			YTSettingsSectionItem *hideHUD = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide HUD Messages" titleDescription:@"Example: CC is turned on/off, Video loop is on,... App restart is required."];
			hideHUD.hasSwitch = YES;
			hideHUD.switchVisible = YES;
			hideHUD.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD_enabled"];
			hideHUD.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHUD_enabled"];
				return YES;
			};
			[sectionItems insertObject:hideHUD atIndex:statsForNerdsIndex + 1];
			//
			YTSettingsSectionItem *autoFUll = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Auto Full Screen (YTAutoFullScreen)" titleDescription:@"Autoplay videos at full screen."];
			autoFUll.hasSwitch = YES;
			autoFUll.switchVisible = YES;
			autoFUll.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"];
			autoFUll.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autofull_enabled"];
				return YES;
			};
			[sectionItems insertObject:autoFUll atIndex:statsForNerdsIndex + 2];
	     	//	
			YTSettingsSectionItem *Oleditem = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"OLED Dark mode (Experimental)" titleDescription:@"WARNING: You must set YouTube's appearance to Dark theme before enabling OLED dark mode (not tested on iPad yet). App restart is required."];
			Oleditem.hasSwitch = YES;
			Oleditem.switchVisible = YES;
			Oleditem.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"oled_enabled"];
			Oleditem.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oled_enabled"];
				return YES;
			};
			[sectionItems insertObject:Oleditem atIndex:statsForNerdsIndex + 1];
		}
	}	
	%orig;
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
	if ([self.nextResponder isKindOfClass:%c(DownloadedVC)])  //uYou
	arg1 = oledColor;
	if ([self.nextResponder isKindOfClass:%c(DownloadsPagerVC)]) //uYou
	arg1 = oledColor;
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

%hook YTTopAlignedView // Example from Dune - https://github.com/Skittyblock/Dune/blob/9b1df9790230115b7553cc9dbadf36889018d7f9/Tweak.xm#L700
-(void)layoutSubviews {
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
- (void)layoutSubviews {}
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

/*
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
    if (oled()) {
		%init(gOLED);
    }
	if (ReExplore()) {
        %init(gReExplore)
	}
	if (bigYTMiniPlayer() && (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)) {
        %init(Main)
	}
}