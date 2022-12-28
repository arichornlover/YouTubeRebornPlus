#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/utsname.h>
#import <substrate.h>
#import "Header.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"
#import "Tweaks/YouTubeHeader/YTColorPalette.h"
#import "Tweaks/YouTubeHeader/YTCommonColorPalette.h"
#import "Tweaks/YouTubeHeader/ASCollectionView.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlay.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlayProvider.h"
#import "Tweaks/YouTubeHeader/YTIElementRenderer.h"

NSBundle *CercubePlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"CercubePlus" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:@"/Library/Application Support/CercubePlus.bundle"];
    });
    return bundle;
}
NSBundle *tweakBundle = CercubePlusBundle();

// Keychain fix
static NSString *accessGroupID() {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];

    return accessGroup;
}

//
static BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}
static BOOL oledDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 1);
}
static BOOL oldDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 2);
}

# pragma mark - Tweaks
// Skips content warning before playing *some videos - @PoomSmart
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { [self confirmAlertDidPressConfirm]; }
%end

// YTMiniPlayerEnabler: https://github.com/level3tjg/YTMiniplayerEnabler/
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer {
    if (IsEnabled(@"ytMiniPlayer_enabled")) {}
    else { return %orig; }
}
%end

# pragma mark - Hide Cercube Button && Notification Button
%hook YTRightNavigationButtons
- (void)didMoveToWindow {
    %orig;
    if (IsEnabled(@"hideCercubeButton_enabled")) { 
        self.cercubeButton.hidden = YES; 
    }
}
- (void)layoutSubviews {
    %orig;
    if (IsEnabled(@"hideNotificationButton_enabled")) {
        self.notificationButton.hidden = YES;
    }
}
%end

// Hide Cercube PiP & Download button
%hook UIStackView
- (void)didMoveToWindow {
    %orig;
    if (IsEnabled(@"hideCercubePiP_enabled")) && ([self.nextResponder isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)])) {
        self.subviews[0].hidden = YES;
    }
    if (IsEnabled(@"hideCercubeDownload_enabled")) && ([self.nextResponder isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)])) {
        self.subviews[1].hidden = YES;
    }
}
%end

//Hide Cast Button since Cercube's option is not working
%group gHideCastButton
%hook MDXPlaybackRouteButtonController
- (BOOL)isPersistentCastIconEnabled { return NO; }
- (void)updateRouteButton:(id)arg1 {} // hide Cast button in video controls overlay
- (void)updateAllRouteButtons {} // hide Cast button in Nav bar
%end

%hook YTSettings
- (void)setDisableMDXDeviceDiscovery:(BOOL)arg1 { %orig(YES); }
%end
%end

// Hide Watermark
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
    if (IsEnabled(@"hideChannelWatermark_enabled")) {}
    else { return %orig; }
}
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
      if ((IsEnabled(@"hideBuySuperThanks_enabled")) && ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.suggested_action"])) { self.hidden = YES; }
}
%end

// Hide CC / Autoplay switch
%hook YTMainAppControlsOverlayView
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 { // hide CC button
    if (IsEnabled(@"hideCC_enabled")) { 
        return %orig(NO); 
    }   
    else { return %orig; }
}
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { // hide Autoplay
    if (IsEnabled(@"hideAutoplaySwitch_enabled")) {}
    else { return %orig; }
}
%end

// Hide Next & Previous button
%group gHidePreviousAndNextButton
%hook YTColdConfig
- (BOOL)removeNextPaddleForSingletonVideos { return YES; }
- (BOOL)removePreviousPaddleForSingletonVideos { return YES; }
%end
%end

// Old dark theme (gray)
%group gOldDarkTheme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative { return NO; }
- (BOOL)enableCinematicContainerOnClient { return NO; }
%end
%end

// Disabled App Breaking Dialog Flags - @PoomSmart
%hook YTColdConfig
- (BOOL)commercePlatformClientEnablePopupWebviewInWebviewDialogController { return NO;}
%end

%hook YTHotConfig
- (BOOL)iosEnableShortsPlayerSplitViewController { return NO;} // uYou Buttons in Shorts Fix
%end

// Hide Upgrade Dialog
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES;}
- (BOOL)shouldForceUpgrade { return NO;}
- (BOOL)shouldShowUpgrade { return NO;}
- (BOOL)shouldShowUpgradeDialog { return NO;}
%end

// Disabled Rounded & Modernize Flags (Disabled by Default for uYouPlusExtra to fix Low Contrast Mode) only works with YouTube v17.40.5-present
%hook YTGlobalConfig
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNativeLongTail { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedTimestampForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedDialogForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernButtonsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernButtonsForNativeLongTail { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernTabsForNative { return NO; }
- (BOOL)modernizeElementsTextColor { return NO; }
- (BOOL)modernizeElementsBgColor { return NO; }
- (BOOL)modernizeCollectionLockups { return NO; }
%end

// Replace Next & Previous button with Fast forward & Rewind button
%group gReplacePreviousAndNextButton
%hook YTColdConfig
- (BOOL)replaceNextPaddleWithFastForwardButtonForSingletonVods { return YES; }
- (BOOL)replacePreviousPaddleWithRewindButtonForSingletonVods { return YES; }
%end
%end

// Hide HUD Messages
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return IsEnabled(@"hideHUD_enabled") ? nil : %orig;
}
%end

// YTAutoFullScreen: https://github.com/PoomSmart/YTAutoFullScreen/
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig;
    if (IsEnabled(@"autoFull_enabled"))
        [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(autoFullscreen) userInfo:nil repeats:NO];
}
%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}
%end

// YTABGoodies - https://poomsmart.github.io/repo/depictions/ytabgoodies.html
// YouAreThere - https://poomsmart.github.io/repo/depictions/youarethere.html
// YouRememberCaption - https://poomsmart.github.io/repo/depictions/youremembercaption.html
%hook YTColdConfig
- (BOOL)enableYouthereCommandsOnIos { return NO; }
- (BOOL)respectDeviceCaptionSetting { return NO; }
- (BOOL)isLandscapeEngagementPanelSwipeRightToDismissEnabled { return YES; }
- (BOOL)enableSwipeToRemoveInPlaylistWatchEp { return YES; } // Enable swipe right to remove video in Playlist. 
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return NO; }
%end

// Alert
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

// Full-screen
%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
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

// YTNoHoverCards: https://github.com/level3tjg/YTNoHoverCards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
    if (IsEnabled(@"hideHoverCards_enabled"))
        hidden = YES;
    %orig;
}
%end

// YTShortsProgress - @PoomSmart - https://github.com/PoomSmart/YTShortsProgress
%hook YTReelPlayerViewController
- (BOOL)shouldEnablePlayerBar { return YES; }
- (BOOL)shouldAlwaysEnablePlayerBar { return YES; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return NO; }
%end

%hook YTReelPlayerViewControllerSub
- (BOOL)shouldEnablePlayerBar { return YES; }
- (BOOL)shouldAlwaysEnablePlayerBar { return YES; }
- (BOOL)shouldEnablePlayerBarOnlyOnPause { return NO; }
%end

%hook YTColdConfig
- (BOOL)iosEnableVideoPlayerScrubber { return YES; }
- (BOOL)mobileShortsTabInlined { return YES; }
%end

%hook YTHotConfig
- (BOOL)enablePlayerBarForVerticalVideoWhenControlsHiddenInFullscreen { return YES; }
%end

/// YTNoPaidPromo: https://github.com/PoomSmart/YTNoPaidPromo
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IsEnabled(@"hidePaidPromotionCard_enabled")) {}
    else { return %orig; }
}
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && IsEnabled(@"hidePaidPromotionCard_enabled")) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IsEnabled(@"hidePaidPromotionCard_enabled")) {}
    else { return %orig; }
}
%end

# pragma mark - IAmYouTube - https://github.com/PoomSmart/IAmYouTube/
%hook YTVersionUtils
+ (NSString *)appName { return YT_NAME; }
+ (NSString *)appID { return YT_BUNDLE_ID; }
%end

%hook GCKBUtils
+ (NSString *)appIdentifier { return YT_BUNDLE_ID; }
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook OGLBundle
+ (NSString *)shortAppName { return YT_NAME; }
%end

%hook GVROverlayView
+ (NSString *)appName { return YT_NAME; }
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook APMAEU
+ (BOOL)isFAS { return YES; }
%end

%hook GULAppEnvironmentUtil
+ (BOOL)isFromAppStore { return YES; }
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook NSBundle
- (NSString *)bundleIdentifier {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}
%end

// Fix "Google couldn't confirm this attempt to sign in is safe. If you think this is a mistake, you can close and try again to sign in" - qnblackcat/uYouPlus#420
// Thanks to @AhmedBafkir and @kkirby - https://github.com/qnblackcat/uYouPlus/discussions/447#discussioncomment-3672881
%group gFixGoogleSignIn
%hook SSORPCService
+ (id)URLFromURL:(id)arg1 withAdditionalFragmentParameters:(NSDictionary *)arg2 {
    NSURL *orig = %orig;
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:orig resolvingAgainstBaseURL:NO];
    NSMutableArray *newQueryItems = [urlComponents.queryItems mutableCopy];
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"system_version"]
         || [queryItem.name isEqualToString:@"app_version"]
         || [queryItem.name isEqualToString:@"kdlc"]
         || [queryItem.name isEqualToString:@"kss"]
         || [queryItem.name isEqualToString:@"lib_ver"]
         || [queryItem.name isEqualToString:@"device_model"]) {
            [newQueryItems removeObject:queryItem];
        }
    }
    urlComponents.queryItems = [newQueryItems copy];
    return urlComponents.URL;
}
%end
%end

// Fix "You can't sign in to this app because Google can't confirm that it's safe" warning when signing in. by julioverne & PoomSmart
// https://gist.github.com/PoomSmart/ef5b172fd4c5371764e027bea2613f93
// https://github.com/qnblackcat/uYouPlus/pull/398
/* 
%group gDevice_challenge_request_hack
%hook SSOService
+ (id)fetcherWithRequest:(NSMutableURLRequest *)request configuration:(id)configuration {
    if ([request isKindOfClass:[NSMutableURLRequest class]] && request.HTTPBody) {
        NSError *error = nil;
        NSMutableDictionary *body = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingMutableContainers error:&error];
        if (!error && [body isKindOfClass:[NSMutableDictionary class]]) {
            [body removeObjectForKey:@"device_challenge_request"];
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error];
        }
    }
    return %orig;
}
%end
%end
*/ 

// Fix login for YouTube 17.33.2 and higher - @BandarHL
// https://gist.github.com/BandarHL/492d50de46875f9ac7a056aad084ac10
%hook SSOKeychainCore
+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

// Fix App Group Directory by move it to document directory
%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end

// OLED dark mode by BandarHL
UIColor* raisedColor = [UIColor colorWithRed:0.035 green:0.035 blue:0.035 alpha:1.0];
%group gOLED
%hook YTCommonColorPalette
- (UIColor *)brandBackgroundSolid {
    if (self.pageStyle == 1) {
        return [UIColor blackColor];
    }
        return %orig;
}
- (UIColor *)brandBackgroundPrimary {
    if (self.pageStyle == 1) {
        return [UIColor blackColor];
    }
        return %orig;
}
- (UIColor *)brandBackgroundSecondary {
    if (self.pageStyle == 1) {
        return [[UIColor blackColor] colorWithAlphaComponent:0.9];
    }
        return %orig;
}
- (UIColor *)raisedBackground {
    if (self.pageStyle == 1) {
        return [UIColor blackColor];
    }
        return %orig;
}
- (UIColor *)staticBrandBlack {
    if (self.pageStyle == 1) {
        return [UIColor blackColor];
    }
        return %orig;
}
- (UIColor *)generalBackgroundA {
    if (self.pageStyle == 1) {
        return [UIColor blackColor];
    }
        return %orig;
}
%end

// Account view controller
%hook YTAccountPanelBodyViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    if (pageStyle == 1) { 
        return [UIColor blackColor]; 
    }
        return %orig;
}
%end

// Explore
%hook ASScrollView 
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) { 
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// Your videos
%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode() && [self.nextResponder isKindOfClass:%c(_ASDisplayView)]) { 
        self.superview.backgroundColor = [UIColor blackColor];
    }
}
%end

// Sub?
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].backgroundColor = [UIColor blackColor];
    }
}
%end

// iSponsorBlock
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

// Search View
%hook YTSearchBarView 
- (void)setBackgroundColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

// History Search view
%hook YTSearchBoxView 
- (void)setBackgroundColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

// Comment view
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
- (void)setTextColor:(UIColor *)color { // fix black text in #Shorts video's comment
    if (isDarkMode()) { 
        return %orig([UIColor whiteColor]); 
    }
        return %orig;
}
%end

%hook YTCommentDetailHeaderCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[2].backgroundColor = [UIColor blackColor];
    }
}
%end

%hook YTFormattedStringLabel  // YT is werid...
- (void)setBackgroundColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor clearColor]);
    }
        return %orig;
}
%end

// Live chat comment
%hook YCHLiveChatActionPanelView 
- (void)setBackgroundColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor blackColor]);
    }
        return %orig;
}
%end

// Others
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
    }
}
%end

// Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig(raisedColor);
    }
        return %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig(raisedColor);
    }
        return %orig;
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) { 
        self.backgroundColor = raisedColor;
        self.subviews[1].backgroundColor = raisedColor;
        self.superview.backgroundColor = raisedColor;
    }
}
%end

// Incompatibility with the new YT Dark theme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
%end
%end

// OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
%group gOLEDKB 
%hook UIPredictionViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end
%end

%group gLowContrastMode // Low Contrast Mode v1.2.0 (Compatible with only v15.02.1-present)
%hook UIColor // Changes the whiteColor Method to be YouTube's old ui and also effects Icons & Text under Videos, Comment Section & Shorts caused by whiteColor (Deprecated by YouTube as of v17.40.5-Newer)
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
%end

%hook YTColorPalette // Changes Texts & Icons in YouTube Bottom Bar + Text Icons under Video Player
- (UIColor *)textPrimary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00]; // Dark Mode
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00]; // Light Mode
}
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00];
}
%end

%hook YTCommonColorPalette // Changes Texts & Icons in YouTube Bottom Bar (Doesn't change Texts & Icons under the video player)
- (UIColor *)textPrimary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00];
}
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00];
}
%end

%hook UIView // changes some of the texts around the YouTube App.
- (UIColor *)tintColor {
         return [UIColor whiteColor];
}
%end

%hook UIInterface // this is only used if YouTube uses these methods in the future.
- (UIColor *)labelColor {
            return [UIColor whiteColor];
}
- (UIColor *)secondaryLabelColor {
         return [UIColor whiteColor];
}
- (UIColor *)tertiaryLabelColor {
         return [UIColor whiteColor];
}
- (UIColor *)quaternaryLabelColor {
         return [UIColor whiteColor];
}
- (UIColor *)textColor {
         return [UIColor whiteColor];
}
%end

// LowContrastMode - Comment view
%hook YTCommentView
- (void)setTintColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end

// LowContrastMode - Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setTintColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end

%hook YTBackstageCreateRepostDetailView
- (void)setTintColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end

%hook YTFormattedStringLabel
- (void)setTintColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end

%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.tintColor = [UIColor whiteColor];
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.tintColor = [UIColor whiteColor];
    } else { return %orig; }
}
%end

%hook MBProgressHUD // changes texts and buttons exclusively on the iSponsorBlock Tweak.
- (UIColor *)contentColor {
         return [UIColor whiteColor];
}
- (UIColor *)tintColor {
         return [UIColor whiteColor];
}
- (UIColor *)textColor {
         return [UIColor whiteColor];
}
- (UIColor *)whiteColor {
         return [UIColor whiteColor];
}
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.tintColor = [UIColor whiteColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.tintColor = [UIColor whiteColor]; }
    }
}
%end

%hook YTCreateCommentTextView
- (void)setTintColor:(UIColor *)color { 
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
- (void)setTextColor:(UIColor *)color {
    if (isDarkMode()) { 
        return %orig([UIColor whiteColor]); 
    }
        return %orig;
}
%end
%end

%group gBlueUI
%hook UIColor 
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00]; // Dark Mode
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Light Mode
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00]; // Dark Mode
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Light Mode
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end

%hook YTBackstageCreateRepostDetailView
- (void)setTintColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end

%hook YTFormattedStringLabel
- (void)setTintColor:(UIColor *)color {
    if (isDarkMode()) {
        return %orig([UIColor whiteColor]);
    }
        return %orig;
}
%end
%end

%group gRedUI
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
%end

%group gOrangeUI
%hook UIColor
+ (UIColor *)whiteColor {
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
%end

%group gPinkUI
%hook UIColor
+ (UIColor *)whiteColor {
        return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
%end

%group gPurpleUI
%hook UIColor
+ (UIColor *)whiteColor {
        return [UIColor colorWithRed: 0.62 green: 0.01 blue: 0.73 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.62 green: 0.01 blue: 0.73 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.44 green: 0.00 blue: 0.52 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.62 green: 0.01 blue: 0.73 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.44 green: 0.00 blue: 0.52 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
%end

%group gGreenUI
%hook UIColor
+ (UIColor *)whiteColor {
        return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
%end

%group gYellowUI
%hook UIColor
+ (UIColor *)whiteColor {
        return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
%end

%hook YTColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00];
 }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00];
 }
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor whiteColor];
    }
}
%end
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
- (void)setWatchMiniPlayerLayout:(int)arg1 {
    %orig(1);
}
- (int)watchMiniPlayerLayout {
    return 1;
}
- (void)layoutSubviews {
    %orig;
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
%end

%hook YTMainAppVideoPlayerOverlayView
- (BOOL)isUserInteractionEnabled {
    if([[self _viewControllerForAncestor].parentViewController.parentViewController isKindOfClass:%c(YTWatchMiniBarViewController)]) {
        return NO;
    }
    return %orig;
}
%end
%end

// DontEatMyContent - @therealFoxster: https://github.com/therealFoxster/DontEatMyContent
static double videoAspectRatio = 16/9;
static bool zoomedToFill = false;
static bool engagementPanelIsVisible = false, removeEngagementPanelViewControllerWithIdentifierCalled = false;

static MLHAMSBDLSampleBufferRenderingView *renderingView;
static NSLayoutConstraint *widthConstraint, *heightConstraint, *centerXConstraint, *centerYConstraint;

%group gDontEatMyContent

// Retrieve video aspect ratio 
%hook YTPlayerView
- (void)setAspectRatio:(CGFloat)aspectRatio {
    %orig(aspectRatio);
    videoAspectRatio = aspectRatio;
}
%end

%hook YTPlayerViewController
- (void)viewDidAppear:(BOOL)animated {
    YTPlayerView *playerView = [self playerView];
    UIView *renderingViewContainer = MSHookIvar<UIView *>(playerView, "_renderingViewContainer");
    renderingView = [playerView renderingView];

    // Making renderingView a bit larger since constraining to safe area leaves a gap between the notch and video
    CGFloat constant = 24.5; // Tested on iPhone 13 mini

    widthConstraint = [renderingView.widthAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.widthAnchor constant:constant];
    heightConstraint = [renderingView.heightAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.heightAnchor constant:constant];
    centerXConstraint = [renderingView.centerXAnchor constraintEqualToAnchor:renderingViewContainer.centerXAnchor];
    centerYConstraint = [renderingView.centerYAnchor constraintEqualToAnchor:renderingViewContainer.centerYAnchor];
    
    // playerView.backgroundColor = [UIColor blueColor];
    // renderingViewContainer.backgroundColor = [UIColor greenColor];
    // renderingView.backgroundColor = [UIColor redColor];

    YTMainAppVideoPlayerOverlayViewController *activeVideoPlayerOverlay = [self activeVideoPlayerOverlay];

    // Must check class since YTInlineMutedPlaybackPlayerOverlayViewController doesn't have -(BOOL)isFullscreen
    if ([NSStringFromClass([activeVideoPlayerOverlay class]) isEqualToString:@"YTMainAppVideoPlayerOverlayViewController"] // isKindOfClass doesn't work for some reason
    && [activeVideoPlayerOverlay isFullscreen]) {
        if (!zoomedToFill && !engagementPanelIsVisible) DEMC_activate();
    } else {
        DEMC_centerRenderingView();
    }

    %orig(animated);
}
- (void)didPressToggleFullscreen {
    %orig;
    if (![[self activeVideoPlayerOverlay] isFullscreen]) { // Entering full screen
        if (!zoomedToFill && !engagementPanelIsVisible) DEMC_activate();
    } else { // Exiting full screen
        DEMC_deactivate();
    }
    
    %orig;
}
- (void)didSwipeToEnterFullscreen {
    %orig; 
    if (!zoomedToFill && !engagementPanelIsVisible) DEMC_activate();
}
- (void)didSwipeToExitFullscreen { 
    %orig; 
    DEMC_deactivate(); 
}
// New video played
-(void)playbackController:(id)playbackController didActivateVideo:(id)video withPlaybackData:(id)playbackData {
    %orig(playbackController, video, playbackData);
    if ([[self activeVideoPlayerOverlay] isFullscreen]) // New video played while in full screen (landscape)
        // Activate since new videos played in full screen aren't zoomed-to-fill by default
        // (i.e. the notch/Dynamic Island will cut into content when playing a new video in full screen)
        DEMC_activate(); 
    engagementPanelIsVisible = false;
    removeEngagementPanelViewControllerWithIdentifierCalled = false;
}
%end

// Pinch to zoom
%hook YTVideoFreeZoomOverlayView
- (void)didRecognizePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DEMC_deactivate();
    %orig(pinchGestureRecognizer);
}
// Detect zoom to fill
- (void)showLabelForSnapState:(NSInteger)snapState {
    if (snapState == 0) { // Original
        zoomedToFill = false;
        DEMC_activate();
    } else if (snapState == 1) { // Zoomed to fill
        zoomedToFill = true;
        // No need to deactivate constraints as it's already done in -(void)didRecognizePinch:(UIPinchGestureRecognizer *)
    }
    %orig(snapState);
}
%end

// Mini bar dismiss
%hook YTWatchMiniBarViewController
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType {
    %orig(velocity, gestureType);
    zoomedToFill = false; // Setting to false since YouTube undoes zoom-to-fill when mini bar is dismissed
}
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType skipShouldDismissCheck:(BOOL)skipShouldDismissCheck {
    %orig(velocity, gestureType, skipShouldDismissCheck);
    zoomedToFill = false;
}
%end

%hook YTMainAppEngagementPanelViewController
// Engagement panel (comment, description, etc.) about to show up
- (void)viewWillAppear:(BOOL)animated {
    if ([self isPeekingSupported]) {
        // Shorts (only Shorts support peeking, I think)
    } else {
        // Everything else
        engagementPanelIsVisible = true;
        if ([self isLandscapeEngagementPanel]) {
            DEMC_deactivate();
        }
    }
    %orig(animated);
}
// Engagement panel about to dismiss
// - (void)viewDidDisappear:(BOOL)animated { %orig; %log; } // Called too late & isn't reliable so sometimes constraints aren't activated even when engagement panel is closed
%end

%hook YTEngagementPanelContainerViewController
// Engagement panel about to dismiss
- (void)notifyEngagementPanelContainerControllerWillHideFinalPanel { // Called in time but crashes if plays new video while in full screen causing engagement panel dismissal
    // Must check if engagement panel was dismissed because new video played
    // (i.e. if -(void)removeEngagementPanelViewControllerWithIdentifier:(id) was called prior)
    if (![self isPeekingSupported] && !removeEngagementPanelViewControllerWithIdentifierCalled) {
        engagementPanelIsVisible = false;
        if ([self isLandscapeEngagementPanel] && !zoomedToFill) {
            DEMC_activate();
        }
    }
    %orig;
}
- (void)removeEngagementPanelViewControllerWithIdentifier:(id)identifier {
    // Usually called when engagement panel is open & new video is played or mini bar is dismissed
    removeEngagementPanelViewControllerWithIdentifierCalled = true;
    %orig(identifier);
}
%end

%end// group gDontEatMyContent

BOOL DEMC_deviceIsSupported() {
    // Get device model identifier (e.g. iPhone14,4)
    // https://stackoverflow.com/a/11197770/19227228
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModelID = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSArray *unsupportedModelIDs = DEMC_UNSUPPORTED_DEVICES;
    for (NSString *identifier in unsupportedModelIDs) {
        if ([deviceModelID isEqualToString:identifier]) {
            return NO;
        }
    }

    if ([deviceModelID containsString:@"iPhone"]) {
        if ([deviceModelID isEqualToString:@"iPhone13,1"]) {
            // iPhone 12 mini
            return YES; 
        } 
        NSString *modelNumber = [[deviceModelID stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@"."];
        if ([modelNumber floatValue] >= 14.0) {
            // iPhone 13 series and newer
            return YES;
        } else return NO;
    } else return NO;
}

void DEMC_activate() {
    if (videoAspectRatio < DEMC_THRESHOLD) {
        DEMC_deactivate();
        return;
    }
    // NSLog(@"activate");
    DEMC_centerRenderingView();
    renderingView.translatesAutoresizingMaskIntoConstraints = NO;
    widthConstraint.active = YES;
    heightConstraint.active = YES;
}

void DEMC_deactivate() {
    // NSLog(@"deactivate");
    DEMC_centerRenderingView();
    renderingView.translatesAutoresizingMaskIntoConstraints = YES;
    widthConstraint.active = NO;
    heightConstraint.active = NO;
}

void DEMC_centerRenderingView() {
    centerXConstraint.active = YES;
    centerYConstraint.active = YES;
}

// YTNoShorts: https://github.com/MiRO92/YTNoShorts
%hook YTAsyncCollectionView
- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        UICollectionViewCell *cell = %orig;
        if ([cell isKindOfClass:NSClassFromString(@"_ASCollectionViewCell")]) {
            _ASCollectionViewCell *cell = %orig;
            if ([cell respondsToSelector:@selector(node)]) {
                if ([[[cell node] accessibilityIdentifier] isEqualToString:@"eml.shorts-shelf"] && hideShorts()) { [self removeShortsCellAtIndexPath:indexPath]; }
                if ([[[cell node] accessibilityIdentifier] isEqualToString:@"statement_banner.view"]) { [self removeShortsCellAtIndexPath:indexPath]; }
                if ([[[cell node] accessibilityIdentifier] isEqualToString:@"compact.view"]) { [self removeShortsCellAtIndexPath:indexPath]; }            
            }
        } else if ([cell isKindOfClass:NSClassFromString(@"YTReelShelfCell")] && (IsEnabled(@"hideShorts_enabled")) {
            [self removeShortsCellAtIndexPath:indexPath];
        }
        return %orig;
}
%new
- (void)removeShortsCellAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}
%end

// YTSpeed - https://github.com/Lyvendia/YTSpeed
%hook YTVarispeedSwitchController
- (id)init {
	id result = %orig;

	const int size = 12;
	float speeds[] = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0};
	id varispeedSwitchControllerOptions[size];

	for (int i = 0; i < size; ++i) {
		id title = [NSString stringWithFormat:@"%.2fx", speeds[i]];
		varispeedSwitchControllerOptions[i] = [[%c(YTVarispeedSwitchControllerOption) alloc] initWithTitle:title rate:speeds[i]];
	}

	NSUInteger count = sizeof(varispeedSwitchControllerOptions) / sizeof(id);
	NSArray *varispeedArray = [NSArray arrayWithObjects:varispeedSwitchControllerOptions count:count];
	MSHookIvar<NSArray *>(self, "_options") = varispeedArray;

	return result;
}
%end

%hook MLHAMQueuePlayer
- (void)setRate:(float)rate {
	MSHookIvar<float>(self, "_rate") = rate;
	MSHookIvar<float>(self, "_preferredRate") = rate;

	id player = MSHookIvar<HAMPlayerInternal *>(self, "_player");
	[player setRate: rate];
	
	id stickySettings = MSHookIvar<MLPlayerStickySettings *>(self, "_stickySettings");
	[stickySettings setRate: rate];

	[self.playerEventCenter broadcastRateChange: rate];

	YTSingleVideoController *singleVideoController = self.delegate;
	[singleVideoController playerRateDidChange: rate];
}
%end 

%hook YTPlayerViewController
%property float playbackRate;
- (void)singleVideo:(id)video playbackRateDidChange:(float)rate {
	%orig;
}
%end

// Old dark theme (gray)
%group gOldDarkTheme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative { return NO; }
- (BOOL)enableCinematicContainerOnClient { return NO; }
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor clearColor]; }
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor clearColor]; }
}
%end

%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    self.superview.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
}
%end
%end

// Disable Pinch to zoom
%hook YTColdConfig
- (BOOL)videoZoomFreeZoomEnabledGlobalConfig { 
    if (IsEnabled(@"pinchToZoom_enabled")) { return NO; }
    else { return %orig; }
}
%end

// Disable snap to chapter
%hook YTSegmentableInlinePlayerBarView
- (void)didMoveToWindow {
    %orig;
    if (IsEnabled(@"snapToChapter_enabled")) {
        self.enableSnapToChapter = NO;
    }
}
%end

// Hide Watermark
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
    if (IsEnabled(@"hideChannelWatermark_enabled")) {}
    else { return %orig; }
}
%end

// Disable hints - https://github.com/LillieH001/YouTube-Reborn/blob/v4/
%group gDisableHints
%hook YTSettings
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    %orig(YES);
}
%end
%hook YTUserDefaults
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    %orig(YES);
}
%end
%end

// Bring back the red progress bar
%hook YTColdConfig
- (BOOL)segmentablePlayerBarUpdateColors { 
    if (IsEnabled(@"redProgressBar_enabled")) { return NO; }
    else { return %orig; }
}
%end

// Shorts options
%hook YTReelWatchPlaybackOverlayView
- (void)setNativePivotButton:(id)arg1 {
    if (IsEnabled(@"hideShortsChannelAvatar_enabled")) {}
    else { return %orig; }
}
- (void)setReelDislikeButton:(id)arg1 {
    if (IsEnabled(@"hideShortsDislikeButton_enabled")) {}
    else { return %orig; }
}
- (void)setViewCommentButton:(id)arg1 {
    if (IsEnabled(@"hideShortsCommentButton_enabled")) {}
    else { return %orig; }
}
- (void)setRemixButton:(id)arg1 {
    if (IsEnabled(@"hideShortsRemixButton_enabled")) {}
    else { return %orig; }
}
- (void)setShareButton:(id)arg1 {
    if (IsEnabled(@"hideShortsShareButton_enabled")) {}
    else { return %orig; }
}
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
      if ((IsEnabled(@"hideBuySuperThanks_enabled")) && ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.suggested_action"])) { self.hidden = YES; }
}
%end

%hook YTColdConfig
- (BOOL)enableResumeToShorts {
    if (IsEnabled(@"disableResumeToShorts")) { return NO; }
    else { return %orig; }
}
%end

# pragma mark - ctor
%ctor {
    %init;
    if (!IsEnabled(@"fixGoogleSignIn_enabled")) {
       %init(gFixGoogleSignIn);
    }
    if (IsEnabled(@"hideCastButton_enabled")) {
       %init(gHideCastButton);
    }
    if (IsEnabled(@"reExplore_enabled")) {
       %init(gReExplore);
    }
    if (IsEnabled(@"bigYTMiniPlayer_enabled") && (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)) {
       %init(Main);
    }
    if (IsEnabled(@"dontEatMyContent_enabled") && DEMC_deviceIsSupported()) {
       %init(gDontEatMyContent);
    }
    if (IsEnabled(@"hidePreviousAndNextButton_enabled")) {
       %init(gHidePreviousAndNextButton);
    }
    if (IsEnabled(@"replacePreviousAndNextButton_enabled")) {
       %init(gReplacePreviousAndNextButton);
    }
    if (IsEnabled(@"lowContrastMode_enabled")) {
       %init(gLowContrastMode);
    }
    if (IsEnabled(@"RedUI_enabled")) {
       %init(gRedUI);
    }
    if (IsEnabled(@"BlueUI_enabled")) {
       %init(gBlueUI);
    }
    if (IsEnabled(@"GreenUI_enabled")) {
       %init(gGreenUI);
    }
    if (IsEnabled(@"YellowUI_enabled")) {
       %init(gYellowUI);
    }
    if (IsEnabled(@"OrangeUI_enabled")) {
       %init(gOrangeUI);
    }
    if (IsEnabled(@"PurpleUI_enabled")) {
       %init(gPurpleUI);
    }
    if (IsEnabled(@"PinkUI_enabled")) {
       %init(gPinkUI);
    }
    if (oldDarkTheme()) {
        %init(gOldDarkTheme)
    }
    if (oledDarkTheme()) {
        %init(gOLED)
    }
    if (IsEnabled(@"oledKeyBoard_enabled")) {
       %init(gOLEDKB);
    }
    if (IsEnabled(@"disableHints_enabled")) {
        %init(gDisableHints);
    }
}
