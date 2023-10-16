// Extractor.xm was made by @LillieH1000 from https://www.github.com/LillieH1000/YouTube-Reborn

#import "Extractor.h"

@implementation Extractor

+ (NSDictionary *)youtubePlayerRequest :(NSString *)client :(NSString *)videoID {
    NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSURL *requestURL;
    if ([client isEqual:@"android"]) {
        requestURL = [NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w&prettyPrint=false"];
    } else if ([client isEqual:@"ios"]) {
        requestURL = [NSURL URLWithString:@"https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false"];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([client isEqual:@"android"]) {
        [request setValue:@"com.google.android.youtube/17.31.35 (Linux; U; Android 11) gzip" forHTTPHeaderField:@"User-Agent"];
        NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"%@\",\"clientName\":\"ANDROID\",\"clientVersion\":\"17.31.35\",\"androidSdkVersion\":30,\"playbackContext\":{\"contentPlaybackContext\":{\"vis\":0,\"splay\":false,\"autoCaptionsDefaultOn\":false,\"autonavState\":\"STATE_OFF\",\"signatureTimestamp\":\"sts\",\"html5Preference\":\"HTML5_PREF_WANTS\",\"lactMilliseconds\":\"-1\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"%@\"}", countryCode, videoID];
        [request setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    } else if ([client isEqual:@"ios"]) {
        [request setValue:@"com.google.ios.youtube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];
        NSString *jsonBody = [NSString stringWithFormat:@"{\"context\":{\"client\":{\"hl\":\"en\",\"gl\":\"%@\",\"clientName\":\"IOS\",\"clientVersion\":\"17.33.2\",\"deviceModel\":\"iPhone14,3\",\"playbackContext\":{\"contentPlaybackContext\":{\"vis\":0,\"splay\":false,\"autoCaptionsDefaultOn\":false,\"autonavState\":\"STATE_OFF\",\"signatureTimestamp\":\"sts\",\"html5Preference\":\"HTML5_PREF_WANTS\",\"lactMilliseconds\":\"-1\"}}}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"%@\"}", countryCode, videoID];
        [request setHTTPBody:[jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    }
    
    __block NSData *requestData;
    __block BOOL requestFinished = NO;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        requestData = data;
        requestFinished = YES;
    }] resume];

    while (!requestFinished) {
        [NSThread sleepForTimeInterval:0.02];
    }

    return [NSJSONSerialization JSONObjectWithData:requestData options:0 error:nil];
}

@end
