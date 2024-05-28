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
                case 1:
                    return @"v19.20.2";
                case 2:
                    return @"v19.19.7";
                case 3:
                    return @"v19.19.5";
                case 4:
                    return @"v19.18.2";
                case 5:
                    return @"v19.17.2";
                case 6:
                    return @"v19.16.3";
                case 7:
                    return @"v19.15.1";
                case 8:
                    return @"v19.14.3";
                case 9:
                    return @"v19.14.2";
                case 10:
                    return @"v19.13.1";
                case 11:
                    return @"v19.12.3";
                case 12:
                    return @"v19.10.7";
                case 13:
                    return @"v19.10.6";
                case 14:
                    return @"v19.10.5";
                case 15:
                    return @"v19.09.4";
                case 16:
                    return @"v19.09.3";
                case 17:
                    return @"v19.08.2";
                case 18:
                    return @"v19.07.5";
                case 19:
                    return @"v19.07.4";
                case 20:
                    return @"v19.06.2";
                case 21:
                    return @"v19.05.5";
                case 22:
                    return @"v19.05.3";
                case 23:
                    return @"v19.04.3";
                case 24:
                    return @"v19.03.2";
                case 25:
                    return @"v19.02.1";
                case 26:
                    return @"v19.01.1";
                case 27:
                    return @"v18.49.3";
                case 28:
                    return @"v18.48.3";
                case 29:
                    return @"v18.46.3";
                case 30:
                    return @"v18.45.2";
                case 31:
                    return @"v18.44.3";
                case 32:
                    return @"v18.43.4";
                case 33:
                    return @"v18.41.5";
                case 34:
                    return @"v18.41.3";
                case 35:
                    return @"v18.41.2";
                case 36:
                    return @"v18.40.1";
                case 37:
                    return @"v18.39.1";
                case 38:
                    return @"v18.38.2";
                case 39:
                    return @"v18.35.4";
                case 40:
                    return @"v18.34.5";
                case 41:
                    return @"v18.33.3";
                case 42:
                    return @"v18.33.2";
                case 43:
                    return @"v18.32.2";
                case 44:
                    return @"v18.31.3";
                case 45:
                    return @"v18.30.7";
                case 46:
                    return @"v18.30.6";
                case 47:
                    return @"v18.29.1";
                case 48:
                    return @"v18.28.3";
                case 49:
                    return @"v18.27.3";
                case 50:
                    return @"v18.25.1";
                case 51:
                    return @"v18.23.3";
                case 52:
                    return @"v18.22.9";
                case 53:
                    return @"v18.21.3";
                case 54:
                    return @"v18.20.3";
                case 55:
                    return @"v18.19.1";
                case 56:
                    return @"v18.18.2";
                case 57:
                    return @"v18.17.2";
                case 58:
                    return @"v18.16.2";
                case 59:
                    return @"v18.15.1";
                case 60:
                    return @"v18.14.1";
                case 61:
                    return @"v18.13.4";
                case 62:
                    return @"v18.12.2";
                case 63:
                    return @"v18.11.2";
                case 64:
                    return @"v18.10.1";
                case 65:
                    return @"v18.09.4";
                case 66:
                    return @"v18.08.1";
                case 67:
                    return @"v18.07.5";
                case 68:
                    return @"v18.05.2";
                case 69:
                    return @"v18.04.3";
                case 70:
                    return @"v18.03.3";
                case 71:
                    return @"v18.02.03";
                case 72:
                    return @"v18.01.6";
                case 73:
                    return @"v18.01.4";
                case 74:
                    return @"v18.01.2";
                case 75:
                    return @"v17.49.6";
                case 76:
                    return @"v17.49.4";
                case 77:
                    return @"v17.46.4";
                case 78:
                    return @"v17.45.1";
                case 79:
                    return @"v17.44.4";
                case 80:
                    return @"v17.43.1";
                case 81:
                    return @"v17.42.7";
                case 82:
                    return @"v17.42.6";
                case 83:
                    return @"v17.41.2";
                case 84:
                    return @"v17.40.5";
                case 85:
                    return @"v17.39.4";
                case 86:
                    return @"v17.38.10";
                case 87:
                    return @"v17.38.9";
                case 88:
                    return @"v17.37.2";
                case 89:
                    return @"v17.36.4";
                case 90:
                    return @"v17.36.3";
                case 91:
                    return @"v17.35.3";
                case 92:
                    return @"v17.34.3";
                case 93:
                    return @"v17.33.2";
                case 0:
                default:
                    return @"v19.21.2";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.21.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.20.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.19.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.19.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.18.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.17.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.16.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.15.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.14.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.14.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.13.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.12.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.10.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.09.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:15 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.09.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.08.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:17 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.07.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:18 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.07.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:19 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.06.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.05.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:21 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.05.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:22 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:23 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.03.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:24 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.02.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:25 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v19.01.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:26 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.49.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:27 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.48.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:28 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.46.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:29 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.45.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.44.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:31 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.43.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:32 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:33 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:34 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:35 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.40.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:36 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.39.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:37 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.38.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:38 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.35.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:39 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.34.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:41 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:42 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.32.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:43 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.31.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:44 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.30.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:45 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.30.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:46 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.29.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:47 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.28.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:48 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.27.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:49 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.25.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:50 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.23.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:51 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.22.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:52 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.21.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:53 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.20.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:54 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.19.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:56 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.17.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:57 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.16.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:58 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;      
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.15.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:59 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.14.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:60 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.13.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:61 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.12.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:62 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.11.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:63 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.10.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:64 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.09.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:65 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.08.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:66 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.07.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:67 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.05.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:68 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.04.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:69 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.03.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:70 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.02.03" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:71 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:72 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:73 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:74 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:75 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:76 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.46.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:77 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.45.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:78 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.44.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:79 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.43.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:80 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:81 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.42.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:82 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.41.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:83 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.40.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:84 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.39.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:85 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:86 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:87 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.37.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:88 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:89 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.36.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:90 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.35.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:91 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.34.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:92 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:93 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VERSION_SPOOFER_TITLE") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
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
