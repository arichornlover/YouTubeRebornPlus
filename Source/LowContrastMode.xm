#import "../Header.h"

//
static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}

%group gLowContrastMode // Low Contrast Mode v1.3.0 (Compatible with only YouTube v16.05.7-v17.38.10)
%hook UIColor
+ (UIColor *)whiteColor { // Dark Theme Color
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)textColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
%end

%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00]; // Light Theme
}
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
    }
        return [UIColor colorWithRed: 0.38 green: 0.38 blue: 0.38 alpha: 1.00]; // Light Theme
}
%end

%hook YTCollectionView
 - (void)setTintColor:(UIColor *)color { 
     return isDarkMode() ? %orig([UIColor whiteColor]) : %orig;
}
%end

%hook LOTAnimationView
- (void) setTintColor:(UIColor *)tintColor {
    tintColor = [UIColor whiteColor];
    %orig(tintColor);
}
%end

%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;

    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];

    return newAttributedString;
}
%end

%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end

%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end

%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end

%hook UIButton 
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %log;
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end

%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook UILabel
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end

%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end

%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end

%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end

%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end

%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (lowContrastMode()) {
        %init(gLowContrastMode);
    }
}
