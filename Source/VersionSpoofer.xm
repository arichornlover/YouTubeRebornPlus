#import "../Header.h"

//
static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static BOOL version0() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 0;
}
static BOOL version1() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 1;
}
static BOOL version2() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 2;
}
static BOOL version3() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 3;
}
static BOOL version4() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 4;
}
static BOOL version5() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 5;
}
static BOOL version6() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 6;
}
static BOOL version7() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 7;
}
static BOOL version8() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 8;
}
static BOOL version9() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 9;
}
static BOOL version10() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 10;
}
static BOOL version11() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 11;
}
static BOOL version12() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 12;
}
static BOOL version13() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 13;
}
static BOOL version14() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 14;
}
static BOOL version15() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 15;
}
static BOOL version16() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 16;
}
static BOOL version17() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 17;
}
static BOOL version18() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 18;
}
static BOOL version19() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 19;
}
static BOOL version20() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 20;
}
static BOOL version21() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 21;
}
static BOOL version22() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 22;
}
static BOOL version23() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 23;
}
static BOOL version24() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 24;
}
static BOOL version25() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 25;
}

%group gDefault // 18.22.9
%hook YTVersionUtils // 0
+ (NSString *)appVersion { return @"18.22.9"; }
%end
%end

%group gVersion1
%hook YTVersionUtils // 1
+ (NSString *)appVersion { return @"18.20.3"; }
%end
%end

%group gVersion2
%hook YTVersionUtils // 2
+ (NSString *)appVersion { return @"18.14.1"; }
%end
%end

%group gVersion3
%hook YTVersionUtils // 3
+ (NSString *)appVersion { return @"18.08.1"; }
%end
%end

%group gVersion4
%hook YTVersionUtils // 4
+ (NSString *)appVersion { return @"18.01.6"; }
%end
%end

%group gVersion5
%hook YTVersionUtils // 5
+ (NSString *)appVersion { return @"17.49.6"; }
%end
%end

%group gVersion6
%hook YTVersionUtils // 6
+ (NSString *)appVersion { return @"17.39.4"; }
%end
%end

%group gVersion7
%hook YTVersionUtils // 7
+ (NSString *)appVersion { return @"17.38.10"; }
%end
%end

%group gVersion8
%hook YTVersionUtils // 8
+ (NSString *)appVersion { return @"17.30.1"; }
%end
%end

%group gVersion9
%hook YTVersionUtils // 9
+ (NSString *)appVersion { return @"17.11.2"; }
%end
%end

%group gVersion10
%hook YTVersionUtils // 10
+ (NSString *)appVersion { return @"17.01.4"; }
%end
%end

%group gVersion11
%hook YTVersionUtils // 11
+ (NSString *)appVersion { return @"16.46.5"; }
%end
%end

%group gVersion12
%hook YTVersionUtils // 12
+ (NSString *)appVersion { return @"16.42.3"; }
%end
%end

%group gVersion13
%hook YTVersionUtils // 13
+ (NSString *)appVersion { return @"16.30.2"; }
%end
%end

%group gVersion14
%hook YTVersionUtils // 14
+ (NSString *)appVersion { return @"16.29.4"; }
%end
%end

%group gVersion15
%hook YTVersionUtils // 15
+ (NSString *)appVersion { return @"16.20.5"; }
%end
%end

%group gVersion16
%hook YTVersionUtils // 16
+ (NSString *)appVersion { return @"16.16.4"; }
%end
%end

%group gVersion17
%hook YTVersionUtils // 17
+ (NSString *)appVersion { return @"16.16.3"; }
%end
%end

%group gVersion18
%hook YTVersionUtils // 18
+ (NSString *)appVersion { return @"16.05.7"; }
%end
%end

%group gVersion19
%hook YTVersionUtils // 19
+ (NSString *)appVersion { return @"15.49.6"; }
%end
%end

%group gVersion20
%hook YTVersionUtils // 20
+ (NSString *)appVersion { return @"15.49.4"; }
%end
%end

%group gVersion21
%hook YTVersionUtils // 21
+ (NSString *)appVersion { return @"15.39.4"; }
%end
%end

%group gVersion22
%hook YTVersionUtils // 22
+ (NSString *)appVersion { return @"15.33.4"; }
%end
%end

%group gVersion23
%hook YTVersionUtils // 23
+ (NSString *)appVersion { return @"15.25.6"; }
%end
%end

%group gVersion24
%hook YTVersionUtils // 24
+ (NSString *)appVersion { return @"15.22.4"; }
%end
%end

%group gVersion25
%hook YTVersionUtils // 25
+ (NSString *)appVersion { return @"15.18.4"; }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (version0()) { // 0
        %init(gDefault);
    }
    if (version1()) { // 1
        %init(gVersion1);
    }
    if (version2()) { // 2
        %init(gVersion2);
    }
    if (version3()) { // 3
        %init(gVersion3);
    }
    if (version4()) { // 4
        %init(gVersion4);
    }
    if (version5()) { // 5
        %init(gVersion5);
    }
    if (version6()) { // 6
        %init(gVersion6);
    }
    if (version7()) { // 7
        %init(gVersion7);
    }
    if (version8()) { // 8
        %init(gVersion8);
    }
    if (version9()) { // 9
        %init(gVersion9);
    }
    if (version10()) { // 10
        %init(gVersion10);
    }
    if (version11()) { // 11
        %init(gVersion11);
    }
    if (version12()) { // 12
        %init(gVersion12);
    }
    if (version13()) { // 13
        %init(gVersion13);
    }
    if (version14()) { // 14
        %init(gVersion14);
    }
    if (version15()) { // 15
        %init(gVersion15);
    }
    if (version16()) { // 16
        %init(gVersion16);
    }
    if (version17()) { // 17
        %init(gVersion17);
    }
    if (version18()) { // 18
        %init(gVersion18);
    }
    if (version19()) { // 19
        %init(gVersion19);
    }
    if (version20()) { // 20
        %init(gVersion20);
    }
    if (version21()) { // 21
        %init(gVersion21);
    }
    if (version22()) { // 22
        %init(gVersion22);
    }
    if (version23()) { // 23
        %init(gVersion23);
    }
    if (version24()) { // 24
        %init(gVersion24);
    }
    if (version25()) { // 25
        %init(gVersion25);
    }
}
