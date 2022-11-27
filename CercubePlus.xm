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

NSBundle *CercubePlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"CercubePlus" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else {
            bundle = [NSBundle bundleWithPath:@"/Library/Application Support/CercubePlus.bundle"];
            if (!bundle)
                bundle = [NSBundle bundleWithPath:@"/var/jb/Library/Application Support/CercubePlus.bundle"];
        }
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
BOOL hideHUD() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHUD_enabled"];
}
BOOL oled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"oled_enabled"];
}
BOOL oledKB() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"oledKeyBoard_enabled"];
}
BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}
BOOL autoFullScreen() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoFull_enabled"];
}
BOOL hideHoverCard() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideHoverCard_enabled"];
}
BOOL reExplore() {
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
BOOL hideCercubeButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubeButton_enabled"];
}
BOOL hideCercubePiP() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubePiP_enabled"];
}
BOOL hideCercubeDownload() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCercubeDownload_enabled"];
}
BOOL hideCastButton () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideCastButton_enabled"];
}
BOOL hideWatermarks() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideWatermarks_enabled"];
}
BOOL ytMiniPlayer() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ytMiniPlayer_enabled"];
}
BOOL hideShorts() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideShorts_enabled"];
}
BOOL hidePreviousAndNextButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hidePreviousAndNextButton_enabled"];
}
BOOL hidePaidPromotionCard() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hidePaidPromotionCard_enabled"];
}
BOOL hideNotificationButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideNotificationButton_enabled"];
}
BOOL fixGoogleSignIn() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fixGoogleSignIn_enabled"];
}
BOOL replacePreviousAndNextButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"replacePreviousAndNextButton_enabled"];
}
BOOL dontEatMyContent() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dontEatMyContent_enabled"];
}
BOOL lowContrastMode () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"lowContrastMode_enabled"];
}
BOOL BlueUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"BlueUI_enabled"];
}
BOOL RedUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"RedUI_enabled"];
}
BOOL OrangeUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"OrangeUI_enabled"];
}
BOOL PinkUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"PinkUI_enabled"];
}
BOOL PurpleUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"PurpleUI_enabled"];
}
BOOL GreenUI () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"GreenUI_enabled"];
}

# pragma mark - Tweaks
// Skips content warning before playing *some videos - @PoomSmart
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { [self confirmAlertDidPressConfirm]; }
%end

// YTMiniPlayerEnabler: https://github.com/level3tjg/YTMiniplayerEnabler/
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer {
    if (ytMiniPlayer()) {}
    else { return %orig; }
}
%end

# pragma mark - Hide Cercube Button && Notification Button
%hook YTRightNavigationButtons
- (void)didMoveToWindow {
    %orig;
    if (hideCercubeButton()) { 
        self.cercubeButton.hidden = YES; 
    }
}
- (void)layoutSubviews {
    %orig;
    if (hideNotificationButton()) {
        self.notificationButton.hidden = YES;
    }
}
%end

// Hide Cercube PiP & Download button
%hook UIStackView
- (void)didMoveToWindow {
    %orig;
    if (hideCercubePiP() && ([self.nextResponder isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)])) {
        self.subviews[0].hidden = YES;
    }
    if (hideCercubeDownload() && ([self.nextResponder isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)])) {
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

// Hide Watermarks
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
    if (hideWatermarks()) {}
    else { return %orig; }
}
%end

// Hide CC / Autoplay switch
%hook YTMainAppControlsOverlayView
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 { // hide CC button
    if (hideCC()) { return %orig(NO); }   
    else { return %orig; }
}
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { // hide Autoplay
    if (hideAutoplaySwitch()) {}
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

// Disabled App Breaking Dialog Flags - @PoomSmart
%hook YTColdConfig
- (BOOL)commercePlatformClientEnablePopupWebviewInWebviewDialogController { return NO;}
- (BOOL)isQuickPreviewDialogEnabled { return NO;}
%end

%hook YTHotConfig
- (BOOL)iosEnableShortsPlayerSplitViewController { return NO;} // uYou Buttons in Shorts Fix
%end

// Hide Update Dialog: https://github.com/PoomSmart/YouTubeHeader/blob/main/YTGlobalConfig.h
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

// YTNoHoverCards 0.0.3: https://github.com/level3tjg/YTNoHoverCards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
    if (hideHoverCard()) {
        hidden = YES;
        %orig;
    }
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

// Hide Paid Promotion Card
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (hidePaidPromotionCard()) {}
    else { return %orig; }
}
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && hidePaidPromotionCard()) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (hidePaidPromotionCard()) {}
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

# pragma mark - OLED dark mode by BandarHL
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

# pragma mark - OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
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

%group gLowContrastMode // Low Contrast Mode v1.0.6 (Compatible with only v15.49.6-v17.39.5)
%hook YTColorPalette // Changes Texts & Icons in YouTube Bottom Bar + Text Icons under Video Player
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
- (UIColor *)overlayTextPrimary {
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
- (UIColor *)overlayTextPrimary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00];
}
- (UIColor *)outline {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00];
}
%end

%hook UIColor // Changes the Icons & Text under Videos, Comment Section & Shorts
+ (UIColor *)whiteColor { // Deprecated by YouTube as of v17.40.5-Newer
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
%end

%hook UIInterface
+ (UIColor *)labelColor { // For New YouTube UI v17.40.5-present
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}	 
+ (UIColor *)secondaryLabelColor { // For New YouTube UI v17.40.5-present
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}	 
+ (UIColor *)tertiaryLabelColor { // For New YouTube UI v17.40.5-present
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}	
+ (UIColor *)quaternaryLabelColor { // For New YouTube UI v17.40.5-present
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}	 
%end

%hook ELMView // Changes the Texts in the Sub Menu
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].tintColor = [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
    }
}
%end
%end

%group gBlueUI
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithRed: 0.26 green: 0.43 blue: 0.48 alpha: 1.00];
     }
         return [UIColor colorWithRed: 0.36 green: 0.56 blue: 0.62 alpha: 1.00];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithRed: 0.26 green: 0.43 blue: 0.48 alpha: 1.00];
     }
        return [UIColor colorWithRed: 0.36 green: 0.56 blue: 0.62 alpha: 1.00];
 }
%end

%hook UIColor 
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 0.26 green: 0.43 blue: 0.48 alpha: 1.00];
}
%end
%end

%group gRedUI
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

%hook UIColor
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
%end
%end

%group gOrangeUI
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

%hook UIColor
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
%end
%end

%group gPinkUI
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

%hook UIColor
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
%end
%end

%group gPurpleUI
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

%hook UIColor
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 0.62 green: 0.01 blue: 0.73 alpha: 1.00];
}
%end
%end

%group gGreenUI
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

%hook UIColor
+ (UIColor *)whiteColor { // Deprecated by YouTube
        return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
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
static bool isZoomedToFill = false, isFullscreen = false, isNewVideo = true;

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

    CGFloat constant = 23; // Make renderingView a bit larger since safe area has sizeable margins from the notch and side borders; tested on iPhone 13 mini

    widthConstraint = [renderingView.widthAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.widthAnchor constant:constant];
    heightConstraint = [renderingView.heightAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.heightAnchor constant:constant];
    centerXConstraint = [renderingView.centerXAnchor constraintEqualToAnchor:renderingViewContainer.centerXAnchor];
    centerYConstraint = [renderingView.centerYAnchor constraintEqualToAnchor:renderingViewContainer.centerYAnchor];
    
    // playerView.backgroundColor = [UIColor greenColor];
    // renderingViewContainer.backgroundColor = [UIColor redColor];
    // renderingView.backgroundColor = [UIColor blueColor];

    YTMainAppVideoPlayerOverlayViewController *activeVideoPlayerOverlay = [self activeVideoPlayerOverlay];

    // Must check class since YTInlineMutedPlaybackPlayerOverlayViewController doesn't have -(BOOL)isFullscreen
    if ([NSStringFromClass([activeVideoPlayerOverlay class]) isEqualToString:@"YTMainAppVideoPlayerOverlayViewController"] 
    && [activeVideoPlayerOverlay isFullscreen]) {
        if (!isZoomedToFill) DEMC_activate();
        isFullscreen = true;
    } else {
        DEMC_centerRenderingView();
        isFullscreen = false;
    }

    %orig(animated);
}
- (void)didPressToggleFullscreen {
    %orig;
    YTMainAppVideoPlayerOverlayViewController *activeVideoPlayerOverlay = [self activeVideoPlayerOverlay];
    if (![activeVideoPlayerOverlay isFullscreen]) { // Entering full screen
        if (!isZoomedToFill) DEMC_activate();
    } else { // Exiting full screen
        DEMC_deactivate();
    }
    
    %orig;
}
- (void)didSwipeToEnterFullscreen {
    %orig; 
    if (!isZoomedToFill) DEMC_activate();
}
- (void)didSwipeToExitFullscreen { 
    %orig; 
    DEMC_deactivate(); 
}
%end

%hook MLHAMSBDLSampleBufferRenderingView
- (void)setVideo:(id)video playerConfig:(id)playerConfig {
    %orig(video, playerConfig);
    isNewVideo = true;
}
%end

%hook YTVideoFreeZoomOverlayView
- (void)didRecognizePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    // Pinched to zoom in/out
    DEMC_deactivate();
    %orig(pinchGestureRecognizer);
}
// Detect zoom to fill
- (void)showLabelForSnapState:(NSInteger)snapState {
    if (snapState == 0) { // Original
        isZoomedToFill = false;
        DEMC_activate();
    } else if (snapState == 1) { // Zoomed to fill
        isZoomedToFill = true;
        // No need to deactivate constraints as it's already done in -(void)didRecognizePinch:(UIPinchGestureRecognizer *)
    }
    %orig(snapState);
}
- (void)setEnabled:(BOOL)enabled {
    %orig(enabled);
    if (enabled && isNewVideo && isFullscreen) { // New video played while in full screen (landscape)
        DEMC_activate(); // Activate since new videos played in full screen aren't zoomed-to-fill for first play (i.e. the notch/Dynamic Island will cut into content when playing a new video in full screen)
        isNewVideo = false;
    }
}
%end

%hook YTWatchMiniBarViewController
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType {
    %orig(velocity, gestureType);
    isZoomedToFill = false; // Setting to false since YouTube undoes zoom-to-fill when mini bar is dismissed
}
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType skipShouldDismissCheck:(BOOL)skipShouldDismissCheck {
    %orig(velocity, gestureType, skipShouldDismissCheck);
    isZoomedToFill = false;
}
%end
%end// gDontEatMyContent

// https://stackoverflow.com/a/11197770/19227228
NSString* DEMC_getDeviceModelIdentifier() {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

BOOL DEMC_deviceIsSupported() {
    NSString *identifier = DEMC_getDeviceModelIdentifier();
    NSArray *unsupportedDevices = UNSUPPORTED_DEVICES;
    
    for (NSString *device in unsupportedDevices) {
        if ([device isEqualToString:identifier]) {
            return NO;
        }
    }

    if ([identifier containsString:@"iPhone"]) {
        NSString *model = [identifier stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        model = [model stringByReplacingOccurrencesOfString:@"," withString:@"."];
        if ([identifier isEqualToString:@"iPhone13,1"]) { // iPhone 12 mini
            return YES; 
        } else if ([model floatValue] >= 14.0) { // iPhone 13 series and newer
            return YES;
        } else return NO;
    } else return NO;
}

void DEMC_activate() {
    if (videoAspectRatio < THRESHOLD) DEMC_deactivate();
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
        } else if ([cell isKindOfClass:NSClassFromString(@"YTReelShelfCell")] && hideShorts()) {
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

# pragma mark - ctor
%ctor {
    %init;
    if (oled()) {
       %init(gOLED);
    }
    if (oledKB()) {
       %init(gOLEDKB);
    }
    if (reExplore()) {
       %init(gReExplore);
    }
    if (bigYTMiniPlayer() && (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)) {
       %init(Main);
    }
    if (hideCastButton()) {
       %init(gHideCastButton);
    }
    if (hidePreviousAndNextButton()) {
       %init(gHidePreviousAndNextButton);
    }
    if (replacePreviousAndNextButton()) {
       %init(gReplacePreviousAndNextButton);
    }
    if (dontEatMyContent() && DEMC_deviceIsSupported()) {
       %init(gDontEatMyContent);
    }
    if (!fixGoogleSignIn()) {
       %init(gFixGoogleSignIn);
    }
    if (lowContrastMode()) {
       %init(gLowContrastMode);
    }
    if (BlueUI()) {
       %init(gBlueUI);
    }
    if (RedUI()) {
       %init(gRedUI);
    }
    if (OrangeUI()) {
       %init(gOrangeUI);
    }
    if (PinkUI()) {
       %init(gPinkUI);
    }
    if (PurpleUI()) {
       %init(gPurpleUI);
    }
    if (GreenUI()) {
       %init(gGreenUI);
    }
}
