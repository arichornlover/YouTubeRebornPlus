#import "../CercubePlus.h"

typedef struct {
    int version;
    NSString *appVersion;
} VersionMapping;

static VersionMapping versionMappings[] = {
    {0, @"20.23.3"},
    {1, @"20.22.1"},
    {2, @"20.21.6"},
    {3, @"20.20.7"},
    {4, @"20.20.5"},
    {5, @"20.19.3"},
    {6, @"20.19.2"},
    {7, @"20.18.5"},
    {8, @"20.18.4"},
    {9, @"20.16.7"},
    {10, @"20.15.1"},
    {11, @"20.14.2"},
    {12, @"20.13.5"},
    {13, @"20.12.4"},
    {14, @"20.11.6"},
    {15, @"20.10.4"},
    {16, @"20.10.3"},
    {17, @"20.09.3"},
    {18, @"20.08.3"},
    {19, @"20.07.6"},
    {20, @"20.06.03"},
    {21, @"20.05.4"},
    {22, @"20.03.1"},
    {23, @"20.03.02"},
    {24, @"20.02.3"},
    {25, @"19.49.7"},
    {26, @"19.49.5"},
    {27, @"19.49.3"},
    {28, @"19.47.7"},
    {29, @"19.46.3"},
    {30, @"19.45.4"},
    {31, @"19.44.4"},
    {32, @"19.43.2"},
    {33, @"19.42.1"},
    {34, @"19.41.3"},
    {35, @"19.40.4"},
    {36, @"19.39.1"},
    {37, @"19.38.2"},
    {38, @"19.37.2"},
    {39, @"19.36.1"},
    {40, @"19.35.3"},
    {41, @"19.34.2"},
    {42, @"19.33.2"},
    {43, @"19.32.8"},
    {44, @"19.32.6"},
    {45, @"19.31.4"},
    {46, @"19.30.2"},
    {47, @"19.29.1"},
    {48, @"19.28.1"},
    {49, @"19.26.5"},
    {50, @"19.25.4"},
    {51, @"19.25.3"},
    {52, @"19.24.3"},
    {53, @"19.24.2"},
    {54, @"19.23.3"},
    {55, @"19.22.6"},
    {56, @"19.22.3"},
    {57, @"19.21.3"},
    {58, @"19.21.2"},
    {59, @"19.20.2"},
    {60, @"19.19.7"},
    {61, @"19.19.5"},
    {62, @"19.18.2"},
    {63, @"19.17.2"},
    {64, @"19.16.3"},
    {65, @"19.15.1"},
    {66, @"19.14.3"},
    {67, @"19.14.2"},
    {68, @"19.13.1"},
    {69, @"19.12.3"},
    {70, @"19.10.7"},
    {71, @"19.10.6"},
    {72, @"19.10.5"},
    {73, @"19.09.4"},
    {74, @"19.09.3"},
    {75, @"19.08.2"},
    {76, @"19.07.5"},
    {77, @"19.07.4"},
    {78, @"19.06.2"},
    {79, @"19.05.5"},
    {80, @"19.05.3"},
    {81, @"19.04.3"},
    {82, @"19.03.2"},
    {83, @"19.02.1"},
    {84, @"19.01.1"}
};

static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

static BOOL isVersionSpooferEnabled() {
    return IS_ENABLED(@"enableVersionSpoofer_enabled");
}

static NSString* getAppVersionForSpoofedVersion(int spoofedVersion) {
    for (int i = 0; i < sizeof(versionMappings) / sizeof(versionMappings[0]); i++) {
        if (versionMappings[i].version == spoofedVersion) {
            return versionMappings[i].appVersion;
        }
    }
    return nil;
}

%hook YTVersionUtils
+ (NSString *)appVersion {
    if (!isVersionSpooferEnabled()) {
        return %orig;
    }
    int spoofedVersion = appVersionSpoofer();
    NSString *appVersion = getAppVersionForSpoofedVersion(spoofedVersion);
    return appVersion ? appVersion : %orig;
}
%end
