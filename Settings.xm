#import "Tweaks/YouTubeHeader/YTSettingsSectionItem.h"

extern BOOL hideHUD();
extern BOOL oled();
extern BOOL autoFullScreen();
extern BOOL noHoverCard();
extern BOOL ReExplore();
extern BOOL bigYTMiniPlayer();
extern BOOL hideCC();
extern BOOL hideAutoplaySwitch();

// Settings
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
            YTSettingsSectionItem *bigYTMiniPlayer = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"New miniplayer bar style (BigYTMiniPlayer)" titleDescription:@"App restart is required."];
            bigYTMiniPlayer.hasSwitch = YES;
            bigYTMiniPlayer.switchVisible = YES;
            bigYTMiniPlayer.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"bigYTMiniPlayer_enabled"];
            bigYTMiniPlayer.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
                return YES;
            };
            [sectionItems insertObject:bigYTMiniPlayer atIndex:statsForNerdsIndex + 2];
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
            YTSettingsSectionItem *hideCC = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Subtitles button" titleDescription:@"Hide the Subtitles button in video controls overlay. "];
            hideCC.hasSwitch = YES;
            hideCC.switchVisible = YES;
            hideCC.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCC_enabled"];
            hideCC.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCC_enabled"];
                return YES;
            };
            [sectionItems insertObject:hideCC atIndex:statsForNerdsIndex + 1];	
            //
            YTSettingsSectionItem *hideAutoplaySwitch = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide Autoplay switch" titleDescription:@"Hide the Autoplay switch button in video controls overlay."];
            hideAutoplaySwitch.hasSwitch = YES;
            hideAutoplaySwitch.switchVisible = YES;
            hideAutoplaySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideAutoplaySwitch_enabled"];
            hideAutoplaySwitch.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideAutoplaySwitch_enabled"];
                return YES;
            };
            [sectionItems insertObject:hideAutoplaySwitch atIndex:statsForNerdsIndex + 1];
            //
            YTSettingsSectionItem *autoFUll = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Auto Full Screen (YTAutoFullScreen)" titleDescription:@"Autoplay videos at full screen."];
            autoFUll.hasSwitch = YES;
            autoFUll.switchVisible = YES;
            autoFUll.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autofull_enabled"];
            autoFUll.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autofull_enabled"];
                return YES;
            };
            [sectionItems insertObject:autoFUll atIndex:statsForNerdsIndex + 3];
            //
            YTSettingsSectionItem *hideHUD = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Hide HUD Messages" titleDescription:@"Example: CC is turned on/off, Video loop is on,..."];
            hideHUD.hasSwitch = YES;
            hideHUD.switchVisible = YES;
            hideHUD.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD_enabled"];
            hideHUD.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHUD_enabled"];
                return YES;
            };
            [sectionItems insertObject:hideHUD atIndex:statsForNerdsIndex + 1];
            //	
            YTSettingsSectionItem *Oleditem = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"OLED Dark mode (Experimental)" titleDescription:@"WARNING: OLED Dark mode only works when YouTube is in Dark theme. App restart is required (In case OLED dark mode doesn't work: just switch between Light/Dark theme, then restart the app)."];
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