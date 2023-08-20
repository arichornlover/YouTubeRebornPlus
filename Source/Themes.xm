#import "../Header.h"

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}
static BOOL defaultDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 0);
}
static BOOL oledDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 1);
}
static BOOL oldDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 2);
}

// Themes.xm - Theme Options
// Default Dark theme
%group gDefaultDarkTheme
UIColor *defaultColor = [UIColor colorWithRed: 0.06 green: 0.06 blue: 0.06 alpha: 1.00];
%hook YTCommonColorPalette
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? defaultColor : %orig;
}
%end
%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTSettingsCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTEngagementPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(defaultColor) : %orig;
}
%end
%end

// Old dark theme (gray)
%group gOldDarkTheme
UIColor *originalColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
%hook YTCommonColorPalette
- (UIColor *)background1 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)background2 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)background3 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [originalColor colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)generalBackgroundB {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)menuBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
%end

%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = originalColor;
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = originalColor;
    } else { return %orig; }
}
%end

%hook ELMView
- (void)didMoveToWindow {
    %orig;
        self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end

%hook YTAsyncCollectionView
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        if (isDarkMode()) {
            self.subviews[0].subviews[0].backgroundColor = originalColor;
        }
    }
}
%end

%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSettingsCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTEngagementPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = originalColor;
    }
}
%end

%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
- (void)setBarTintColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(originalColor) : %orig;
}
%end

%hook YTShareMainView
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = originalColor;
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = originalColor;
  }
}
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    if (isDarkMode()) {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = originalColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = originalColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = originalColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = originalColor;
        }
        responder = [responder nextResponder];
      }
   }
}
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"brand.promo_view"]) { self.superview.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.filter_chip_bar"]) { self.superview.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = originalColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = originalColor; }
	if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end
%end

// OLED dark mode by @BandarHL and modified by @arichorn
UIColor* raisedColor = [UIColor blackColor];
%group gOLED
%hook YTCommonColorPalette
- (UIColor *)background1 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)background2 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)background3 {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [[UIColor blackColor] colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundB {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)menuBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook UITableViewCell
- (void)_layoutSystemBackgroundView {
    %orig;
    NSString *backgroundViewKey = class_getInstanceVariable(self.class, "_colorView") ? @"_colorView" : @"_backgroundView";
    ((UIView *)[[self valueForKey:@"_systemBackgroundView"] valueForKey:backgroundViewKey]).backgroundColor = [UIColor blackColor];
}
- (void)_layoutSystemBackgroundView:(BOOL)arg1 {
    %orig;
    ((UIView *)[[self valueForKey:@"_systemBackgroundView"] valueForKey:@"_colorView"]).backgroundColor = [UIColor blackColor];
}
%end

%hook settingsReorderTable
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

%hook FRPSelectListTable
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

%hook FRPreferences
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

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
%hook ELMView
- (void)didMoveToWindow {
    %orig;
        self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end

%hook YTAsyncCollectionView
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        if (isDarkMode()) {
            self.subviews[0].subviews[0].backgroundColor = [UIColor blackColor];
        }
    }
}
%end

%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSettingsCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTEngagementPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = [UIColor blackColor];
    }
}
%end

%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)setBarTintColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTShareMainView
- (void)layoutSubviews {
    %orig();
    if (isDarkMode()) {
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = [UIColor blackColor];
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = [UIColor blackColor];
  }
}
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    if (isDarkMode()) {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        responder = [responder nextResponder];
      }
   }
}
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"brand.promo_view"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.filter_chip_bar"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
	if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
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

# pragma mark - ctor
%ctor {
    %init;
    if (IsEnabled(@"oledKeyBoard_enabled")) {
        %init(gOLEDKB);
    }
    if (oledDarkTheme()) {
        %init(gOLED);
    }
    if (oldDarkTheme()) {
        %init(gOldDarkTheme);
    }
    if (defaultDarkTheme()) {
        %init(gDefaultDarkTheme);
    }
}
