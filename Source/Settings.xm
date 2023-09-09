#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
#import "../Header.h"

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int GetSelection(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static const NSInteger YouTubeRebornPlusSection = 500;

@interface YTSettingsSectionItemManager (YouTubeRebornPlus)
- (void)updateYouTubeRebornPlusSectionWithEntry:(id)entry;
@end

extern NSBundle *YouTubeRebornPlusBundle();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YouTubeRebornPlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateYouTubeRebornPlusSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouTubeRebornPlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *main = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/arichorn/YouTubeRebornPlus/releases/latest"]];
    }];
    [sectionItems addObject:main];

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

           [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_DOUBLE_TAP_TO_SKIP")
               titleDescription:LOC(@"DISABLE_DOUBLE_TAP_TO_SKIP_DESC")
               accessibilityIdentifier:nil
               switchOn:IsEnabled(@"disableDoubleTapToSkip_enabled")
               switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                   [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableDoubleTapToSkip_enabled"];
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

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"STOCK_VOLUME_HUD")
                titleDescription:LOC(@"STOCK_VOLUME_HUD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"stockVolumeHUD_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"stockVolumeHUD_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_PLAYER_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoPlayerGroup];

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SHARE_BUTTON")
                titleDescription:LOC(@"ENABLE_SHARE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableShareButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableShareButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON")
                titleDescription:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableSaveToButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableSaveToButton_enabled"];
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
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS")
                titleDescription:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideVideoPlayerShadowOverlayButtons_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideVideoPlayerShadowOverlayButtons_enabled"];
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
				
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_VIDEO_PLAYER_ZOOM")
                titleDescription:LOC(@"DISABLE_VIDEO_PLAYER_ZOOM")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableVideoPlayerZoom_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableVideoPlayerZoom_enabled"];
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

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_RIGHT_PANEL")
                titleDescription:LOC(@"HIDE_RIGHT_PANEL_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideRightPanel_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideRightPanel_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HEATWAVES")
                titleDescription:LOC(@"HIDE_HEATWAVES_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHeatwaves_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHeatwaves_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - Shorts Options
    YTSettingsSectionItem *shortsControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"SHORTS_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_VIDEOS")
                titleDescription:LOC(@"HIDE_SHORTS_VIDEOS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShorts_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShorts_enabled"];
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
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"SHORTS_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:shortsControlOverlayGroup];

# pragma mark - App Settings Overlay Options
    YTSettingsSectionItem *appSettingsOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"App Settings Overlay Options") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_DONTEATMYCONTENT_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableDontEatMyContentSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableDontEatMyContentSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YOUTUBERETURNDISLIKE_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableReturnYouTubeDislikeSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableReturnYouTubeDislikeSection_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YOUPIP_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableYouPiPSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableYouPiPSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_TRYNEWFEATURES_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableTryNewFeaturesSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableTryNewFeaturesSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_AUTOPLAY_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableAutoplaySection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableAutoplaySection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATIONS_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableNotificationsSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableNotificationsSection_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HISTORYANDPRIVACY_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableHistoryAndPrivacySection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableHistoryAndPrivacySection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_LIVECHAT_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableLiveChatSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableLiveChatSection_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"App Settings Overlay Options") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:appSettingsOverlayGroup];

    # pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"LCM_SELECTOR")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (contrastMode()) {
                case 1:
                    return LOC(@"CUSTOM_LOWCONTRASTMODE");
                case 0:
                default:
                    return LOC(@"DEFAULT_LOWCONTRASTMODE");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_LOWCONTRASTMODE") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"CUSTOM_LOWCONTRASTMODE") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Low Contrast Mode") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - VersionSpoofer
    YTSettingsSectionItem *versionSpooferSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v18.28.3";
                case 2:
                    return @"v18.27.3";
                case 3:
                    return @"v18.25.1";
                case 4:
                    return @"v18.23.3";
                case 5:
                    return @"v18.22.9";
                case 6:
                    return @"v18.21.3";
                case 7:
                    return @"v18.20.3";
                case 8:
                    return @"v18.19.1";
                case 9:
                    return @"v18.18.2";
                case 10:
                    return @"v18.17.2";
                case 11:
                    return @"v18.16.2";
                case 12:
                    return @"v18.15.1";
                case 13:
                    return @"v18.14.1";
                case 14:
                    return @"v18.13.4";
                case 15:
                    return @"v18.12.2";
                case 16:
                    return @"v18.11.2";
                case 17:
                    return @"v18.10.1";
                case 18:
                    return @"v18.09.4";
                case 19:
                    return @"v18.08.1";
                case 20:
                    return @"v18.07.5";
                case 21:
                    return @"v18.05.2";
                case 22:
                    return @"v18.04.3";
                case 23:
                    return @"v18.03.3";
                case 24:
                    return @"v18.02.03";
                case 25:
                    return @"v18.01.6";
                case 26:
                    return @"v18.01.4";
                case 27:
                    return @"v18.01.2";
                case 28:
                    return @"v17.49.6";
                case 29:
                    return @"v17.49.4";
                case 30:
                    return @"v17.46.4";
                case 31:
                    return @"v17.45.1";
                case 32:
                    return @"v17.44.4";
                case 33:
                    return @"v17.43.1";
                case 34:
                    return @"v17.42.7";
                case 35:
                    return @"v17.42.6";
                case 36:
                    return @"v17.41.2";
                case 37:
                    return @"v17.40.5";
                case 38:
                    return @"v17.39.4";
                case 39:
                    return @"v17.38.10";
                case 40:
                    return @"v17.38.9";
                case 41:
                    return @"v17.37.2";
                case 42:
                    return @"v17.36.4";
                case 43:
                    return @"v17.36.3";
                case 44:
                    return @"v17.35.3";
                case 45:
                    return @"v17.34.3";
                case 46:
                    return @"v17.33.2";
                case 47:
                    return @"v17.32.2";
                case 48:
                    return @"v17.31.4";
                case 49:
                    return @"v17.30.3";
                case 50:
                    return @"v17.30.1";
                case 51:
                    return @"v17.29.3";
                case 52:
                    return @"v17.29.2";
                case 53:
                    return @"v17.28.2";
                case 54:
                    return @"v17.26.2";
                case 55:
                    return @"v17.25.1";
                case 56:
                    return @"v17.24.4";
                case 57:
                    return @"v17.23.6";
                case 58:
                    return @"v17.22.3";
                case 59:
                    return @"v17.21.3";
                case 60:
                    return @"v17.20.3";
                case 61:
                    return @"v17.19.3";
                case 62:
                    return @"v17.19.2";
                case 63:
                    return @"v17.18.4";
                case 64:
                    return @"v17.17.4";
                case 65:
                    return @"v17.16.4";
                case 66:
                    return @"v17.15.2";
                case 67:
                    return @"v17.15.1";
                case 68:
                    return @"v17.14.2";
                case 69:
                    return @"v17.13.3";
                case 70:
                    return @"v17.12.5";
                case 71:
                    return @"v17.12.4";
                case 72:
                    return @"v17.11.2";
                case 73:
                    return @"v17.10.2";
                case 74:
                    return @"v17.09.1";
                case 75:
                    return @"v17.08.2";
                case 76:
                    return @"v17.07.2";
                case 77:
                    return @"v17.06.3";
                case 78:
                    return @"v17.05.2";
                case 79:
                    return @"v17.04.3";
                case 80:
                    return @"v17.03.3";
                case 81:
                    return @"v17.03.2";
                case 82:
                    return @"v17.01.4";
                case 83:
                    return @"v16.46.5";
                case 84:
                    return @"v16.46.4";
                case 85:
                    return @"v16.45.4";
                case 86:
                    return @"v16.44.5";
                case 87:
                    return @"v16.44.4";
                case 88:
                    return @"v16.43.2";
                case 89:
                    return @"v16.42.3";
                case 90:
                    return @"v16.41.2";
                case 91:
                    return @"v16.40.3";
                case 92:
                    return @"v16.39.6";
                case 93:
                    return @"v16.38.2";
                case 94:
                    return @"v16.37.3";
                case 95:
                    return @"v16.36.4";
                case 96:
                    return @"v16.35.5";
                case 97:
                    return @"v16.35.4";
                case 98:
                    return @"v16.34.7";
                case 99:
                    return @"v16.34.3";
                case 100:
                    return @"v16.33.3";
                case 101:
                    return @"v16.32.6";
                case 102:
                    return @"v16.31.4";
                case 103:
                    return @"v16.30.2";
                case 104:
                    return @"v16.29.4";
                case 105:
                    return @"v16.28.2";
                case 106:
                    return @"v16.27.3";
                case 107:
                    return @"v16.26.6";
                case 108:
                    return @"v16.25.2";
                case 109:
                    return @"v16.24.2";
                case 110:
                    return @"v16.23.3";
                case 111:
                    return @"v16.23.2";
                case 112:
                    return @"v16.22.5";
                case 113:
                    return @"v16.20.5";
                case 114:
                    return @"v16.19.6";
                case 115:
                    return @"v16.18.5";
                case 116:
                    return @"v16.17.4";
                case 117:
                    return @"v16.16.4";
                case 118:
                    return @"v16.16.3";
                case 119:
                    return @"v16.15.4";
                case 120:
                    return @"v16.14.2";
                case 121:
                    return @"v16.13.1";
                case 122:
                    return @"v16.12.3";
                case 123:
                    return @"v16.11.3";
                case 124:
                    return @"v16.10.3";
                case 125:
                    return @"v16.09.3";
                case 126:
                    return @"v16.09.2";
                case 127:
                    return @"v16.08.2";
                case 128:
                    return @"v16.05.9";
                case 129:
                    return @"v16.05.8";
                case 130:
                    return @"v16.05.7";
                case 0:
                default:
                    return @"Latest Version";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"Latest Version" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.28.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.27.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.25.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.23.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.22.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.21.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.20.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.19.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.17.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.16.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;      
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.15.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.14.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.13.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.12.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:15 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.11.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.10.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:17 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.09.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:18 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.08.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:19 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.07.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.05.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:21 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:22 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.03.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:23 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.02.03" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:24 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:25 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:26 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:27 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:28 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:29 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.46.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.45.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:31 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.44.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:32 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.43.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:33 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:34 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:35 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:36 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.40.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:37 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.39.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:38 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:39 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.37.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:41 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:42 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:43 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.35.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:44 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.34.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:45 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:46 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.32.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:47 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.31.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:48 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.30.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:49 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.30.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:50 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.29.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:51 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.29.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:52 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.28.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:53 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.26.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:54 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.25.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.24.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:56 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.23.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:57 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.22.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:58 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.21.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:59 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.20.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:60 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.19.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:61 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.19.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:62 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.18.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:63 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.17.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:64 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.16.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:65 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.15.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:66 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.15.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:67 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.14.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:68 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.13.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:69 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.12.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:70 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.12.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:71 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.11.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:72 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.10.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:73 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.09.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:74 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.08.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:75 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.07.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:76 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.06.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:77 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.05.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:78 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:79 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.03.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:80 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.03.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:81 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.01.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:82 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.46.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:83 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.46.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:84 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.45.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:85 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.44.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:86 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.44.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:87 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.43.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:88 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.42.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:89 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:90 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.40.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:91 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.39.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:92 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.38.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:93 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.37.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:94 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.36.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:95 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.35.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:96 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.35.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:97 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.34.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:98 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.34.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.33.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:100 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.32.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:101 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.31.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:102 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.30.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:103 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.29.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:104 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.28.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:105 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.27.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:106 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.26.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:107 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.25.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:108 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.24.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:109 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.23.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:110 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.23.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:111 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.22.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:112 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.20.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:113 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.19.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:114 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.18.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:115 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.17.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:116 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.16.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:117 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.16.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:118 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.15.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:119 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.14.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:120 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.13.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:121 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.12.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:122 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.11.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:123 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.10.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:124 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.09.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:125 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.09.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:126 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.08.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:127 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:128 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.8" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:129 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:130 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VERSION_SPOOFER_TITLE") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

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
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"LOW_CONTRAST_MODE")
                titleDescription:LOC(@"LOW_CONTRAST_MODE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"lowContrastMode_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"lowContrastMode_enabled"];
                    return YES;
                }
                settingItemId:0], lowContrastModeSection];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_YT_STARTUP_ANIMATION")
                titleDescription:LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytStartupAnimation_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytStartupAnimation_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"STICK_NAVIGATION_BAR")
                titleDescription:LOC(@"STICK_NAVIGATION_BAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"stickNavigationBar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"stickNavigationBar_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CHIP_BAR")
                titleDescription:LOC(@"HIDE_CHIP_BAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideChipBar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideChipBar_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MODERN_INTERFACE")
                titleDescription:LOC(@"HIDE_MODERN_INTERFACE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytNoModernUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytNoModernUI_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPAD_LAYOUT")
                titleDescription:LOC(@"IPAD_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPadLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPadLayout_enabled"];
                    return YES;
                }
                settingItemId:0], 

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPHONE_LAYOUT")
                titleDescription:LOC(@"IPHONE_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPhoneLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPhoneLayout_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CAST_CONFIRM")
                titleDescription:LOC(@"CAST_CONFIRM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"castConfirm_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"castConfirm_enabled"];
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

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SPONSORBLOCK_BUTTON")
                titleDescription:LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideSponsorBlockButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideSponsorBlockButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YOUTUBE_REBORN_BUTTON")
                titleDescription:LOC(@"HIDE_YOUTUBE_REBORN_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideYouTubeRebornButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideYouTubeRebornButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_SPEED")
                titleDescription:LOC(@"YT_SPEED_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytSpeed_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytSpeed_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_FLEX")
                titleDescription:LOC(@"ENABLE_FLEX_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"flex_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"flex_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"APP_VERSION_SPOOFER")
                titleDescription:LOC(@"APP_VERSION_SPOOFER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableVersionSpoofer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableVersionSpoofer_enabled"];
                    return YES;
                }
                settingItemId:0], versionSpooferSection];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];

    [settingsViewController setSectionItems:sectionItems forCategory:YouTubeRebornPlusSection title:@"YouTubeRebornPlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouTubeRebornPlusSection) {
        [self updateYouTubeRebornPlusSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
