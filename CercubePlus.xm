#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "Header.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"
#import "Tweaks/YouTubeHeader/YTCommonColorPalette.h"
#import "Tweaks/YouTubeHeader/ASCollectionView.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlay.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlayProvider.h"

NSBundle *CercubePlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"CercubePlus" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath];
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
BOOL fixGoogleSigin() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fixGoogleSigin_enabled"];
}
BOOL replacePreviousAndNextButton() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"replacePreviousAndNextButton_enabled"];
}

# pragma mark - Tweaks
// Enable Reorder videos from playlist while on the Watch page - @PoomSmart
%hook YTIPlaylistPanelVideoRenderer 
%new 
- (BOOL)canReorder { return YES; }
%end

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

// Enable Shorts scroll bar - @PoomSmart & @level3tjg
%hook YTReelPlayerViewController
- (BOOL)shouldAlwaysEnablePlayerBar { return YES; }
%end

%hook YTInlinePlayerBarContainerView
- (void)setUserInteractionEnabled:(BOOL)enabled { %orig(YES); }
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

// Fix "You can't sign in to this app because Google can't confirm that it's safe" warning when signing in. by julioverne & PoomSmart
// https://gist.github.com/PoomSmart/ef5b172fd4c5371764e027bea2613f93
// https://github.com/qnblackcat/uYouPlus/pull/398
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
        self.subviews[1].backgroundColor = raisedColor;
        self.superview.backgroundColor = raisedColor;
    }
}
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
    if (!fixGoogleSigin()) {
        %init(gDevice_challenge_request_hack);
    }
}
