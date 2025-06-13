#import "YouTubeRebornPlus.h"
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSearchableSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTUIUtils.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>

#define VERSION_STRING [[NSString stringWithFormat:@"%@", @(OS_STRINGIFY(TWEAK_VERSION))] stringByReplacingOccurrencesOfString:@"\"" withString:@""]
#define SHOW_RELAUNCH_YT_SNACKBAR [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"RESTART_YOUTUBE")]]

#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"\t" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]

#define SWITCH_ITEM(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];return YES;} settingItemId:0]]

#define SWITCH_ITEM2(t, d, k) [sectionItems addObject:[YTSettingsSectionItemClass switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];SHOW_RELAUNCH_YT_SNACKBAR;return YES;} settingItemId:0]]

#define SPOOFER_VERSION(version, index) \
    [YTSettingsSectionItemClass checkmarkItemWithTitle:version titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) { \
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"versionSpoofer"]; \
        [settingsViewController reloadData]; \
        return YES; \
    }]

static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static const NSInteger YouTubeRebornPlusSection = 500;

@interface YTSettingsSectionItemManager (YouTubeRebornPlus)
- (void)updateYouTubeRebornPlusSectionWithEntry:(id)entry;
@end

extern NSBundle *YouTubeRebornPlusBundle();

// Settings Search Bar
%hook YTSettingsViewController
- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == YouTubeRebornPlusSection)
        MSHookIvar<BOOL>(self, "_shouldShowSearchBar") = YES;
}
- (void)setSectionControllers {
    %orig;
    if (MSHookIvar<BOOL>(self, "_shouldShowSearchBar")) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        if (settingsSectionController)
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    }
}
%end

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

    # pragma mark - About
    // SECTION_HEADER(LOC(@"ABOUT"));

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/arichornlover/YouTubeRebornPlus/releases/latest"]];
        }
    ];
    [sectionItems addObject:version];

    YTSettingsSectionItem *bug = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"REPORT_AN_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSString *url = [NSString stringWithFormat:@"https://github.com/arichorn/uYouEnhanced/issues/new?assignees=&labels=bug&projects=&template=bug.yaml&title=[v%@] %@", VERSION_STRING, LOC(@"ADD_TITLE")];

            return [%c(YTUIUtils) openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
        }
    ];
    [sectionItems addObject:bug];

    YTSettingsSectionItem *exitYT = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"QUIT_YOUTUBE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // https://stackoverflow.com/a/17802404/19227228
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }
    ];
    [sectionItems addObject:exitYT];

    # pragma mark - App theme
    SECTION_HEADER(LOC(@"THEME_OPTIONS"));

    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass
        itemWithTitle:LOC(@"DARK_THEME")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (APP_THEME_IDX) {
                case 1:
                    return LOC(@"OLD_DARK_THEME");
                case 2:
                    return LOC(@"OLED_DARK_THEME_2");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"DEFAULT_THEME")
                    titleDescription:LOC(@"DEFAULT_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME")
                    titleDescription:LOC(@"OLD_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME")
                    titleDescription:LOC(@"OLED_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                    titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                    accessibilityIdentifier:nil
                    switchOn:IS_ENABLED(@"oledKeyBoard_enabled")
                    switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                    settingItemId:0
                ]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc]
                initWithNavTitle:LOC(@"THEME_OPTIONS")
                pickerSectionTitle:[LOC(@"THEME_OPTIONS") uppercaseString]
                rows:rows selectedItemIndex:APP_THEME_IDX
                parentResponder:[self parentResponder]
            ];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:themeGroup];

# pragma mark - Video player options
    SECTION_HEADER(LOC(@"VIDEO_PLAYER_OPTIONS"));

//  SWITCH_ITEM2(LOC(@"SNAP_TO_CHAPTER"), LOC(@"SNAP_TO_CHAPTER_DESC"), @"snapToChapter_enabled");
    SWITCH_ITEM2(LOC(@"PINCH_TO_ZOOM"), LOC(@"PINCH_TO_ZOOM_DESC"), @"pinchToZoom_enabled");
    SWITCH_ITEM(LOC(@"YT_MINIPLAYER"), LOC(@"YT_MINIPLAYER_DESC"), @"ytMiniPlayer_enabled");

# pragma mark - Video controls overlay options
    SECTION_HEADER(LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS"));

    SWITCH_ITEM(LOC(@"ENABLE_SHARE_BUTTON"), LOC(@"ENABLE_SHARE_BUTTON_DESC"), @"enableShareButton_enabled");
    SWITCH_ITEM(LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON"), LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC"), @"enableSaveToButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_HUD_MESSAGES"), LOC(@"HIDE_HUD_MESSAGES_DESC"), @"hideHUD_enabled");
    SWITCH_ITEM(LOC(@"HIDE_PAID_PROMOTION_CARDS"), LOC(@"HIDE_PAID_PROMOTION_CARDS_DESC"), @"hidePaidPromotionCard_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS"), LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC"), @"hideVideoPlayerShadowOverlayButtons_enabled");
    SWITCH_ITEM(LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON"), LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON_DESC"), @"hidePreviousAndNextButton_enabled");
    SWITCH_ITEM2(LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON"), LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON_DESC"), @"replacePreviousAndNextButton_enabled");
    SWITCH_ITEM(LOC(@"HIDE_HOVER_CARD"), LOC(@"HIDE_HOVER_CARD_DESC"), @"hideHoverCards_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), @"hideRightPanel_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_HEATWAVES"), LOC(@"HIDE_HEATWAVES_DESC"), @"hideHeatwaves_enabled");

# pragma mark - App settings overlay options
    SECTION_HEADER(LOC(@"APP_SETTINGS_OVERLAY_OPTIONS"));

    SWITCH_ITEM2(LOC(@"HIDE_ACCOUNT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAccountSection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_AUTOPLAY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAutoplaySection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_TRYNEWFEATURES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableTryNewFeaturesSection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_VIDEOQUALITYPREFERENCES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableVideoQualityPreferencesSection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_NOTIFICATIONS_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableNotificationsSection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_MANAGEALLHISTORY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableManageAllHistorySection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_YOURDATAINYOUTUBE_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableYourDataInYouTubeSection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_PRIVACY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disablePrivacySection_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_LIVECHAT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableLiveChatSection_enabled");

    # pragma mark - UI interface options
    SECTION_HEADER(LOC(@"UI_INTERFACE_OPTIONS"));

    SWITCH_ITEM2(LOC(@"LOW_CONTRAST_MODE"), LOC(@"LOW_CONTRAST_MODE_DESC"), @"lowContrastMode_enabled");
    SWITCH_ITEM2(LOC(@"FIX_LOW_CONTRAST_MODE"), LOC(@"FIX_LOW_CONTRAST_MODE_DESC"), @"fixLowContrastMode_enabled");
    SWITCH_ITEM2(LOC(@"DISABLE_MODERN_BUTTONS"), LOC(@"DISABLE_MODERN_BUTTONS_DESC"), @"disableModernButtons_enabled");
    SWITCH_ITEM2(LOC(@"DISABLE_ROUNDED_CORNERS_ON_HINTS"), LOC(@"DISABLE_ROUNDED_CORNERS_ON_HINTS_DESC"), @"disableRoundedHints_enabled");
    SWITCH_ITEM2(LOC(@"DISABLE_MODERN_FLAGS"), LOC(@"DISABLE_MODERN_FLAGS_DESC"), @"disableModernFlags_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_MODERN_INTERFACE"), LOC(@"HIDE_MODERN_INTERFACE_DESC"), @"ytNoModernUI_enabled");
    SWITCH_ITEM2(LOC(@"APP_VERSION_SPOOFER"), LOC(@"APP_VERSION_SPOOFER_DESC"), @"enableVersionSpoofer_enabled");
    YTSettingsSectionItem *versionSpoofer = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 0:
                    return @"v20.23.3";
                case 1:
                    return @"v20.22.1";
                case 2:
                    return @"v20.21.6";
                case 3:
                    return @"v20.20.7";
                case 4:
                    return @"v20.20.5";
                case 5:
                    return @"v20.19.3";
                case 6:
                    return @"v20.19.2";
                case 7:
                    return @"v20.18.5";
                case 8:
                    return @"v20.18.4";
                case 9:
                    return @"v20.16.7";
                case 10:
                    return @"v20.15.1";
                case 11:
                    return @"v20.14.2";
                case 12:
                    return @"v20.13.5";
                case 13:
                    return @"v20.12.4";
                case 14:
                    return @"v20.11.6";
                case 15:
                    return @"v20.10.4";
                case 16:
                    return @"v20.10.3";
                case 17:
                    return @"v20.09.3";
                case 18:
                    return @"v20.08.3";
                case 19:
                    return @"v20.07.6";
                case 20:
                    return @"v20.06.03";
                case 21:
                    return @"v20.05.4";
                case 22:
                    return @"v20.03.1";
                case 23:
                    return @"v20.03.02";
                case 24:
                    return @"v20.02.3";
                case 25:
                    return @"v19.49.7";
                case 26:
                    return @"v19.49.5";
                case 27:
                    return @"v19.49.3";
                case 28:
                    return @"v19.47.7";
                case 29:
                    return @"v19.46.3";
                case 30:
                    return @"v19.45.4";
                case 31:
                    return @"v19.44.4";
                case 32:
                    return @"v19.43.2";
                case 33:
                    return @"v19.42.1";
                case 34:
                    return @"v19.41.3";
                case 35:
                    return @"v19.40.4";
                case 36:
                    return @"v19.39.1";
                case 37:
                    return @"v19.38.2";
                case 38:
                    return @"v19.37.2";
                case 39:
                    return @"v19.36.1";
                case 40:
                    return @"v19.35.3";
                case 41:
                    return @"v19.34.2";
                case 42:
                    return @"v19.33.2";
                case 43:
                    return @"v19.32.8";
                case 44:
                    return @"v19.32.6";
                case 45:
                    return @"v19.31.4";
                case 46:
                    return @"v19.30.2";
                case 47:
                    return @"v19.29.1";
                case 48:
                    return @"v19.28.1";
                case 49:
                    return @"v19.26.5";
                case 50:
                    return @"v19.25.4";
                case 51:
                    return @"v19.25.3";
                case 52:
                    return @"v19.24.3";
                case 53:
                    return @"v19.24.2";
                case 54:
                    return @"v19.23.3";
                case 55:
                    return @"v19.22.6";
                case 56:
                    return @"v19.22.3";
                case 57:
                    return @"v19.21.3";
                case 58:
                    return @"v19.21.2";
                case 59:
                    return @"v19.20.2";
                case 60:
                    return @"v19.19.7";
                case 61:
                    return @"v19.19.5";
                case 62:
                    return @"v19.18.2";
                case 63:
                    return @"v19.17.2";
                case 64:
                    return @"v19.16.3";
                case 65:
                    return @"v19.15.1";
                case 66:
                    return @"v19.14.3";
                case 67:
                    return @"v19.14.2";
                case 68:
                    return @"v19.13.1";
                case 69:
                    return @"v19.12.3";
                case 70:
                    return @"v19.10.7";
                case 71:
                    return @"v19.10.6";
                case 72:
                    return @"v19.10.5";
                case 73:
                    return @"v19.09.4";
                case 74:
                    return @"v19.09.3";
                case 75:
                    return @"v19.08.2";
                case 76:
                    return @"v19.07.5";
                case 77:
                    return @"v19.07.4";
                case 78:
                    return @"v19.06.2";
                case 79:
                    return @"v19.05.5";
                case 80:
                    return @"v19.05.3";
                case 81:
                    return @"v19.04.3";
                case 82:
                    return @"v19.03.2";
                case 83:
                    return @"v19.02.1";
                case 84:
                    return @"v19.01.1";
                default:
                    return @"v20.23.3";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                SPOOFER_VERSION(@"v20.23.3", 0),
                SPOOFER_VERSION(@"v20.22.1", 1),
                SPOOFER_VERSION(@"v20.21.6", 2),
                SPOOFER_VERSION(@"v20.20.7", 3),
                SPOOFER_VERSION(@"v20.20.5", 4),
                SPOOFER_VERSION(@"v20.19.3", 5),
                SPOOFER_VERSION(@"v20.19.2", 6),
                SPOOFER_VERSION(@"v20.18.5", 7),
                SPOOFER_VERSION(@"v20.18.4", 8),
                SPOOFER_VERSION(@"v20.16.7", 9),
                SPOOFER_VERSION(@"v20.15.1", 10),
                SPOOFER_VERSION(@"v20.14.2", 11),
                SPOOFER_VERSION(@"v20.13.5", 12),
                SPOOFER_VERSION(@"v20.12.4", 13),
                SPOOFER_VERSION(@"v20.11.6", 14),
                SPOOFER_VERSION(@"v20.10.4", 15),
                SPOOFER_VERSION(@"v20.10.3", 16),
                SPOOFER_VERSION(@"v20.09.3", 17),
                SPOOFER_VERSION(@"v20.08.3", 18),
                SPOOFER_VERSION(@"v20.07.6", 19),
                SPOOFER_VERSION(@"v20.06.03", 20),
                SPOOFER_VERSION(@"v20.05.4", 21),
                SPOOFER_VERSION(@"v20.03.1", 22),
                SPOOFER_VERSION(@"v20.03.02", 23),
                SPOOFER_VERSION(@"v20.02.3", 24),
                SPOOFER_VERSION(@"v19.49.7", 25),
                SPOOFER_VERSION(@"v19.49.5", 26),
                SPOOFER_VERSION(@"v19.49.3", 27),
                SPOOFER_VERSION(@"v19.47.7", 28),
                SPOOFER_VERSION(@"v19.46.3", 29),
                SPOOFER_VERSION(@"v19.45.4", 30),
                SPOOFER_VERSION(@"v19.44.4", 31),
                SPOOFER_VERSION(@"v19.43.2", 32),
                SPOOFER_VERSION(@"v19.42.1", 33),
                SPOOFER_VERSION(@"v19.41.3", 34),
                SPOOFER_VERSION(@"v19.40.4", 35),
                SPOOFER_VERSION(@"v19.39.1", 36),
                SPOOFER_VERSION(@"v19.38.2", 37),
                SPOOFER_VERSION(@"v19.37.2", 38),
                SPOOFER_VERSION(@"v19.36.1", 39),
                SPOOFER_VERSION(@"v19.35.3", 40),
                SPOOFER_VERSION(@"v19.34.2", 41),
                SPOOFER_VERSION(@"v19.33.2", 42),
                SPOOFER_VERSION(@"v19.32.8", 43),
                SPOOFER_VERSION(@"v19.32.6", 44),
                SPOOFER_VERSION(@"v19.31.4", 45),
                SPOOFER_VERSION(@"v19.30.2", 46),
                SPOOFER_VERSION(@"v19.29.1", 47),
                SPOOFER_VERSION(@"v19.28.1", 48),
                SPOOFER_VERSION(@"v19.26.5", 49),
                SPOOFER_VERSION(@"v19.25.4", 50),
                SPOOFER_VERSION(@"v19.25.3", 51),
                SPOOFER_VERSION(@"v19.24.3", 52),
                SPOOFER_VERSION(@"v19.24.2", 53),
                SPOOFER_VERSION(@"v19.23.3", 54),
                SPOOFER_VERSION(@"v19.22.6", 55),
                SPOOFER_VERSION(@"v19.22.3", 56),
                SPOOFER_VERSION(@"v19.21.3", 57),
                SPOOFER_VERSION(@"v19.21.2", 58),
                SPOOFER_VERSION(@"v19.20.2", 59),
                SPOOFER_VERSION(@"v19.19.7", 60),
                SPOOFER_VERSION(@"v19.19.5", 61),
                SPOOFER_VERSION(@"v19.18.2", 62),
                SPOOFER_VERSION(@"v19.17.2", 63),
                SPOOFER_VERSION(@"v19.16.3", 64),
                SPOOFER_VERSION(@"v19.15.1", 65),
                SPOOFER_VERSION(@"v19.14.3", 66),
                SPOOFER_VERSION(@"v19.14.2", 67),
                SPOOFER_VERSION(@"v19.13.1", 68),
                SPOOFER_VERSION(@"v19.12.3", 69),
                SPOOFER_VERSION(@"v19.10.7", 70),
                SPOOFER_VERSION(@"v19.10.6", 71),
                SPOOFER_VERSION(@"v19.10.5", 72),
                SPOOFER_VERSION(@"v19.09.4", 73),
                SPOOFER_VERSION(@"v19.09.3", 74),
                SPOOFER_VERSION(@"v19.08.2", 75),
                SPOOFER_VERSION(@"v19.07.5", 76),
                SPOOFER_VERSION(@"v19.07.4", 77),
                SPOOFER_VERSION(@"v19.06.2", 78),
                SPOOFER_VERSION(@"v19.05.5", 79),
                SPOOFER_VERSION(@"v19.05.3", 80),
                SPOOFER_VERSION(@"v19.04.3", 81),
                SPOOFER_VERSION(@"v19.03.2", 82),
                SPOOFER_VERSION(@"v19.02.1", 83),
                SPOOFER_VERSION(@"v19.01.1", 84)
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VERSION_SPOOFER_SELECTOR") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:versionSpoofer];

    # pragma mark - Miscellaneous
    SECTION_HEADER(LOC(@"MISCELLANEOUS"));

    SWITCH_ITEM(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), @"ytStartupAnimation_enabled");
    SWITCH_ITEM(LOC(@"STICK_NAVIGATION_BAR"), LOC(@"STICK_NAVIGATION_BAR_DESC"), @"stickNavigationBar_enabled");
    SWITCH_ITEM(LOC(@"HIDE_CHIP_BAR"), LOC(@"HIDE_CHIP_BAR_DESC"), @"hideChipBar_enabled");
    SWITCH_ITEM(LOC(@"CAST_CONFIRM"), LOC(@"CAST_CONFIRM_DESC"), @"castConfirm_enabled");
    SWITCH_ITEM2(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), @"bigYTMiniPlayer_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_SPONSORBLOCK_BUTTON"), LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC"), @"hideSponsorBlockButton_enabled");
    SWITCH_ITEM2(LOC(@"HIDE_YOUTUBE_REBORN_BUTTON"), LOC(@"HIDE_YOUTUBE_REBORN_BUTTON_DESC"), @"hideYouTubeRebornButton_enabled");
    SWITCH_ITEM2(LOC(@"YT_SPEED"), LOC(@"YT_SPEED_DESC"), @"ytSpeed_enabled");
    SWITCH_ITEM2(LOC(@"YT_RE_EXPLORE"), LOC(@"YT_RE_EXPLORE_DESC"), @"reExplore_enabled");
    SWITCH_ITEM(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), @"flex_enabled");

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:YouTubeRebornPlusSection title:@"YouTubeRebornPlus" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
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
