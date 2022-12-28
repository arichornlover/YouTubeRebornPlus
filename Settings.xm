#import "Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "Tweaks/YouTubeHeader/YTUIUtils.h"
#import "Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
#import "Header.h"

static const NSInteger CercubePlusSection = 500;

@interface YTSettingsSectionItemManager (CercubePlus)
- (void)updateTweakSectionWithEntry:(id)entry;
@end

extern NSBundle *CercubePlusBundle();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(CercubePlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateTweakSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = CercubePlusBundle();
	Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/arichorn/CercubePlusExtra/releases/latest"]];
    }];
	[sectionItems addObject:version];

# pragma mark - VideoPlayer
    YTSettingsSectionItem *videoPlayerGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_PLAYER_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"AUTO_FULLSCREEN")
                titleDescription:LOC(@"AUTO_FULLSCREEN_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"autoFull_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autoFull_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"SNAP_TO_CHAPTER")
                titleDescription:LOC(@"SNAP_TO_CHAPTER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"snapToChapter_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"snapToChapter_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"PINCH_TO_ZOOM")
                titleDescription:LOC(@"PINCH_TO_ZOOM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"pinchToZoom_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"pinchToZoom_enabled"];
                    return YES;
                }
                settingItemId:0],   

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_MINIPLAYER")
                titleDescription:LOC(@"YT_MINIPLAYER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytMiniPlayer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytMiniPlayer_enabled"];
                    return YES;
                }
                settingItemId:0],
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_PLAYER_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
		return YES;
		    }];
    [sectionItems addObject:videoPlayerGroup];

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_AUTOPLAY_SWITCH")
                titleDescription:LOC(@"HIDE_AUTOPLAY_SWITCH_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideAutoplaySwitch_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideAutoplaySwitch_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBTITLES_BUTTON")
                titleDescription:LOC(@"HIDE_SUBTITLES_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCC_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCC_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HUD_MESSAGES")
                titleDescription:LOC(@"HIDE_HUD_MESSAGES_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHUD_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHUD_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PAID_PROMOTION_CARDS")
                titleDescription:LOC(@"HIDE_PAID_PROMOTION_CARDS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hidePaidPromotionCard_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hidePaidPromotionCard_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CHANNEL_WATERMARK")
                titleDescription:LOC(@"HIDE_CHANNEL_WATERMARK_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideChannelWatermark_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideChannelWatermark_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON")
                titleDescription:LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hidePreviousAndNextButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hidePreviousAndNextButton_enabled"];
                    return YES;
                }
                settingItemId:0],            

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON")
                titleDescription:LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"replacePreviousAndNextButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"replacePreviousAndNextButton_enabled"];
                    return YES;
                }
                settingItemId:0],    

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RED_PROGRESS_BAR")
                titleDescription:LOC(@"RED_PROGRESS_BAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"redProgressBar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"redProgressBar_enabled"];
                    return YES;
                }
                settingItemId:0],    

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HOVER_CARD")
                titleDescription:LOC(@"HIDE_HOVER_CARD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHoverCards_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHoverCards_enabled"];
                    return YES;
                }
                settingItemId:0],  

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DONT_EAT_MY_CONTENT")
                titleDescription:LOC(@"DONT_EAT_MY_CONTENT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"dontEatMyContent_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"dontEatMyContent_enabled"];
                    return YES;
                }
                settingItemId:0],  

        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - Shorts Controls Overlay Options
    YTSettingsSectionItem *shortsControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_CHANNEL_AVATAR")
                titleDescription:LOC(@"HIDE_SHORTS_CHANNEL_AVATAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsChannelAvatar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsChannelAvatar_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_VIDEOS")
                titleDescription:LOC(@"HIDE_SHORTS_VIDEOS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShorts_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShorts_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_DISLIKE_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_DISLIKE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsDislikeButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsDislikeButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_COMMENT_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_COMMENT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsCommentButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsCommentButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_REMIX_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_REMIX_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsRemixButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsRemixButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_SHARE_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_SHARE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsShareButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsShareButton_enabled"];
                    return YES;
                }
                settingItemId:0],            
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:shortsControlOverlayGroup];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"appTheme")) {
                case 1:
                    return LOC(@"OLED_DARK_THEME_2");
                case 2:
                    return LOC(@"OLD_DARK_THEME");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_THEME") titleDescription:LOC(@"DEFAULT_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME") titleDescription:LOC(@"OLED_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"oledKeyBoard_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
                    return YES;
                }
                settingItemId:0]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];
	
# pragma mark - LowContrastMode Options
    YTSettingsSectionItem *LowContrastModeGroup = [YTSettingsSectionItemClass itemWithTitle:@"LowContrastMode Options" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Low Contrast Mode")
                titleDescription:LOC(@"this will Low Contrast texts and buttons just like how the old YouTube Interface did. App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"lowContrastMode_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"lowContrastMode_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Red UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"RedUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"RedUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Blue UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"BlueUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"BlueUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Green UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"GreenUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"GreenUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Yellow UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"YellowUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"YellowUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Orange UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"OrangeUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"OrangeUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Purple UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"PurpleUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"PurpleUI_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"Pink UI")
                titleDescription:LOC(@"(turn other UI Options off) App restart is required.")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"PinkUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"PinkUI_enabled"];
                    return YES;
                }
                settingItemId:0],
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:@"LowContrastMode Options" pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"UITheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:LowContrastModeGroup];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CAST_CONFIRM")
                titleDescription:LOC(@"CAST_CONFIRM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"castConfirm_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"castConfirm_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_HINTS")
                titleDescription:LOC(@"DISABLE_HINTS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableHints_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableHints_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"FIX_GOOGLE_SIGNIN")
                titleDescription:LOC(@"FIX_GOOGLE_SIGNIN_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"fixGoogleSignIn_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"fixGoogleSignIn_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"NEW_MINIPLAYER_STYLE")
                titleDescription:LOC(@"NEW_MINIPLAYER_STYLE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"bigYTMiniPlayer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATION_BUTTON")
                titleDescription:LOC(@"HIDE_NOTIFICATION_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideNotificationButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideNotificationButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_BUTTON")
                titleDescription:LOC(@"")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCercubeButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubeButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_PIP_BUTTON")
                titleDescription:LOC(@"HIDE_CERCUBE_PIP_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCercubePiP_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubePiP_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_DOWNLOAD_BUTTON")
                titleDescription:LOC(@"HIDE_CERCUBE_DOWNLOAD_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsDisabled(@"hideCercubeDownload_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL YES) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideCercubeDownload_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_RE_EXPLORE")
                titleDescription:LOC(@"YT_RE_EXPLORE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"reExplore_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"reExplore_enabled"];
                    return YES;
                }
                settingItemId:0], 
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];
	
    [settingsViewController setSectionItems:sectionItems forCategory:CercubePlusSection title:@"CercubePlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == CercubePlusSection) {
        [self updateTweakSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
