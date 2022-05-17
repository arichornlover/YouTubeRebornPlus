#import "Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"

@interface YTSettingsSectionItemManager (YouPiP)
- (void)updateCercubePlusSectionWithEntry:(id)entry;
@end

static const NSInteger CercubePlusSection = 500;

extern BOOL hideHUD();
extern BOOL oled();
extern BOOL oledKB();
extern BOOL autoFullScreen();
extern BOOL noHoverCard();
extern BOOL ReExplore();
extern BOOL bigYTMiniPlayer();
extern BOOL hideCC();
extern BOOL hideAutoplaySwitch();
extern BOOL hideCercubeButton();
extern BOOL hideCercubePiP();
extern BOOL hideCercubeDownload();
extern BOOL hideCastButton();
extern BOOL hideWatermarks();
extern BOOL ytMiniPlayer();

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
%new - (void)updateCercubePlusSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];

    YTSettingsSectionItem *ytMiniPlayer = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Enable the Miniplayer for all YouTube videos" titleDescription:@""];
    ytMiniPlayer.hasSwitch = YES;
    ytMiniPlayer.switchVisible = YES;
    ytMiniPlayer.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ytMiniPlayer_enabled"];
    ytMiniPlayer.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytMiniPlayer_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideCercubeButton = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Cercube button in the Navigation bar" titleDescription:@""];
    hideCercubeButton.hasSwitch = YES;
    hideCercubeButton.switchVisible = YES;
    hideCercubeButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubeButton_enabled"];
    hideCercubeButton.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubeButton_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideCercubePiP = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Cercube's PiP button" titleDescription:@"Hide the PiP button of Cercube in the video player."];
    hideCercubePiP.hasSwitch = YES;
    hideCercubePiP.switchVisible = YES;
    hideCercubePiP.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubePiP_enabled"];
    hideCercubePiP.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubePiP_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideCercubeDownload = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Cercube's Download button" titleDescription:@"Hide the Download button of Cercube in the video player."];
    hideCercubeDownload.hasSwitch = YES;
    hideCercubeDownload.switchVisible = YES;
    hideCercubeDownload.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubeDownload_enabled"];
    hideCercubeDownload.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubeDownload_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideCastButton = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Cast button" titleDescription:@"App restart is required."];
    hideCastButton.hasSwitch = YES;
    hideCastButton.switchVisible = YES;
    hideCastButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCastButton_enabled"];
    hideCastButton.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCastButton_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideWatermarks = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Watermarks" titleDescription:@"Hide channel watermarks from video controls overlay."];
    hideWatermarks.hasSwitch = YES;
    hideWatermarks.switchVisible = YES;
    hideWatermarks.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideWatermarks_enabled"];
    hideWatermarks.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideWatermarks_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hoverCardItem = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide End screens hover cards (YTNoHoverCards)" titleDescription:@"Hide creator End screens (thumbnails) at the end of videos."];
    hoverCardItem.hasSwitch = YES;
    hoverCardItem.switchVisible = YES;
    hoverCardItem.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"];
    hoverCardItem.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hover_cards_enabled"];
        return YES;
    };

    YTSettingsSectionItem *bigYTMiniPlayer = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"New miniplayer bar style (BigYTMiniPlayer)" titleDescription:@"App restart is required."];
    bigYTMiniPlayer.hasSwitch = YES;
    bigYTMiniPlayer.switchVisible = YES;
    bigYTMiniPlayer.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"bigYTMiniPlayer_enabled"];
    bigYTMiniPlayer.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
        return YES;
    };

    YTSettingsSectionItem *reExplore = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Replace Shorts tab with Explore tab (YTReExplore)" titleDescription:@"App restart is required."];
    reExplore.hasSwitch = YES;
    reExplore.switchVisible = YES;
    reExplore.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"reExplore_enabled"];
    reExplore.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"reExplore_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideCC = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Subtitles button" titleDescription:@"Hide the Subtitles button in video controls overlay. "];
    hideCC.hasSwitch = YES;
    hideCC.switchVisible = YES;
    hideCC.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCC_enabled"];
    hideCC.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCC_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideAutoplaySwitch = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Autoplay switch" titleDescription:@"Hide the Autoplay switch button in video controls overlay."];
    hideAutoplaySwitch.hasSwitch = YES;
    hideAutoplaySwitch.switchVisible = YES;
    hideAutoplaySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideAutoplaySwitch_enabled"];
    hideAutoplaySwitch.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideAutoplaySwitch_enabled"];
        return YES;
    };

    YTSettingsSectionItem *autoFull = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Auto Full Screen (YTAutoFullScreen)" titleDescription:@"Autoplay videos at full screen."];
    autoFull.hasSwitch = YES;
    autoFull.switchVisible = YES;
    autoFull.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"];
    autoFull.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autofull_enabled"];
        return YES;
    };

    YTSettingsSectionItem *hideHUD = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide HUD Messages" titleDescription:@"Example: CC is turned on/off, Video loop is on,..."];
    hideHUD.hasSwitch = YES;
    hideHUD.switchVisible = YES;
    hideHUD.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD_enabled"];
    hideHUD.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHUD_enabled"];
        return YES;
    };

    YTSettingsSectionItem *oledDarkMode = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"OLED Dark mode (Experimental)" titleDescription:@"App restart might be needed after switching between Light/Dark theme to fully apply changes. In case OLED Dark mode doesn't work: just switch between Light/Dark theme, then restart the app."];
    oledDarkMode.hasSwitch = YES;
    oledDarkMode.switchVisible = YES;
    oledDarkMode.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"oled_enabled"];
    oledDarkMode.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oled_enabled"];
        return YES;
    };

    YTSettingsSectionItem *oledKeyBoard = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"OLED Keyboard (Experimental)" titleDescription:@"Might not working properly in some cases. App restart is required."];
    oledKeyBoard.hasSwitch = YES;
    oledKeyBoard.switchVisible = YES;
    oledKeyBoard.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"oledKeyBoard_enabled"];
    oledKeyBoard.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
        return YES;
    };
 
    NSMutableArray <YTSettingsSectionItem *> *sectionItems = [NSMutableArray arrayWithArray:@[autoFull, hideCercubeButton, hideCercubePiP, hideCercubeDownload, ytMiniPlayer, hideCastButton, hideAutoplaySwitch, hideCC, hideHUD, hoverCardItem, hideWatermarks, bigYTMiniPlayer, oledKeyBoard, oledDarkMode,reExplore]];
    [delegate setSectionItems:sectionItems forCategory:CercubePlusSection title:@"CercubePlus" titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == CercubePlusSection) {
        [self updateCercubePlusSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end