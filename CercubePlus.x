#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//YTNOCheckLocalNetWork
%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled {
    return NO;
}
%end


//YouRememberCaption
%hook YTColdConfig
- (BOOL)respectDeviceCaptionSetting {
    return NO;
}
%end

//NOYTPremium
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


//YTClassicVideoQuality

@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end


//YTNoHoverCards 0.0.3
@interface YTCollectionViewCell : UICollectionViewCell
@end

@interface YTSettingsCell : YTCollectionViewCell
@end

@interface YTSettingsSectionItem : NSObject
@property BOOL hasSwitch;
@property BOOL switchVisible;
@property BOOL on;
@property BOOL (^switchBlock)(YTSettingsCell *, BOOL);
@property int settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription;
@end

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *>*)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
	if (category == 1) {
		NSInteger appropriateIdx = [sectionItems indexOfObjectPassingTest:^BOOL(YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
			return item.settingItemId == 294;
		}];
		if (appropriateIdx != NSNotFound) {
			YTSettingsSectionItem *hoverCardItem = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Show End screens hover cards" titleDescription:@"Allows creator End screens (thumbnails) to appear at the end of videos"];
			hoverCardItem.hasSwitch = YES;
			hoverCardItem.switchVisible = YES;
			hoverCardItem.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"];
			hoverCardItem.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
				[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hover_cards_enabled"];
				return YES;
			};
			[sectionItems insertObject:hoverCardItem atIndex:appropriateIdx + 1];
		}
	}
	%orig;
}
%end

%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"])
		hidden = YES;
	%orig;
}
%end


//YTSystemAppearance
%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
%end


//YouAreThere
//%hook YTColdConfig
//- (bool)enableYouthereCommandsOnIos {
//    return NO;
//}
//%end

%hook YTYouThereController
- (bool)shouldShowYouTherePrompt {
    return NO;
}
%end


//YTNoShorts

//YTNoShortsHeader
//@interface ELMCellNode
//@end

//@interface _ASCollectionViewCell : UICollectionViewCell
//- (id)node;
//@end

//@interface YTAsyncCollectionView : UICollectionView
//- (void)removeShortsCellAtIndexPath:(NSIndexPath *)indexPath;
//@end
//------

//#pragma mark - Hooks
//%hook YTAsyncCollectionView
//- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = %orig;
//
//    if ([cell isKindOfClass:NSClassFromString(@"_ASCollectionViewCell")]) {
//        _ASCollectionViewCell *cell = %orig;
//        if ([cell respondsToSelector:@selector(node)]) {
//            if ([[[cell node] accessibilityIdentifier] isEqualToString:@"eml.shorts-shelf"]) {
//                [self removeShortsCellAtIndexPath:indexPath];
//            }
//        }
//    } else if ([cell isKindOfClass:NSClassFromString(@"YTReelShelfCell")]) {
//        [self removeShortsCellAtIndexPath:indexPath];
//    }
//    return %orig;
//}

//%new
//- (void)removeShortsCellAtIndexPath:(NSIndexPath *)indexPath {
//    [self performBatchUpdates:^{
//        [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//    } completion:nil];
//}
//%end

//#pragma mark - ctor
//%ctor {
//    @autoreleasepool {
//        if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.miro.ytnoshorts.list"]) return;
//        [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Frameworks/Module_Framework.framework", [[NSBundle mainBundle] bundlePath]]] load];
//    }
//}