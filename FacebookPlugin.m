#import "FacebookPlugin.h"
#import "API/SBJSON.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";
static NSString *Location = @"/User/Library/Preferences/com.homeschooldev.FacebookLocation.plist";

@implementation FacebookPlugin
@synthesize delegate;

- (id)initWithMessage:(NSString *)message images:(NSArray *)images urls:(NSArray *)urls location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)del {
    if ((self = [super init])) {
    
    	self.delegate = del;
        
        facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![facebook isSessionValid]) {
            [delegate postMessage:@"Please go into the facebook plugin settings and authenticate the service"];
        }
        else {
            if ([urls count] != 0) {
                NSString *url = [NSString stringWithFormat:@""];
                for (NSString *u in urls) {
                    url = [url stringByAppendingString:@" "];
                    url = [url stringByAppendingString:u];
                }
                if ([message isEqualToString:@""]) message = url;
                else message = [NSString stringWithFormat:@"%@%@",message,url];
            }
        
            [self postWithMessage:message images:images location:location];
        }
    }
    return self;
}

- (void)postWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location {
   
    if (images.count == 0) {
        //There are no images...
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
        NSString *path = @"feed";
        [params setObject:@"status" forKey:@"type"];
        if (message && ![message isEqualToString:@""]) [params setObject:message forKey:@"message"];
        if (location) {
			SBJSON *jsonWriter = [[SBJSON new] autorelease];
			NSMutableDictionary *coordinatesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat: @"%f", location.coordinate.latitude], @"latitude",
				[NSString stringWithFormat: @"%f", location.coordinate.longitude], @"longitude", nil];
			NSString *coordinates = [jsonWriter stringWithObject:coordinatesDictionary];
			if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
			if (coordinates) [params setObject:coordinates forKey:@"coordinates"];
			path = @"me/checkins";
        }
        
        [locationDict setObject:@"" forKey:@"Venue"];
		[locationDict writeToFile:Location atomically:YES];
        
        [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
    }
    else {
        //There are images...
        for (NSUInteger i = 0; i < images.count; i++ ) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
            NSString *path = @"feed";
            //[params setObject:@"status" forKey:@"type"];
            if (message && ![message isEqualToString:@""]) [params setObject:message forKey:@"message"];
            if ([images objectAtIndex:i]) {
                path = @"me/photos";
                NSData *imageData = UIImagePNGRepresentation([images objectAtIndex:i]);
                if (imageData) [params setObject:imageData forKey:@"source"];
            }            
			
			if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
           
            [locationDict setObject:@"" forKey:@"Venue"];
			[locationDict writeToFile:Location atomically:YES];
    
            [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
        }
    }
}

//*************Facebook delegate methods*************//
- (void)request:(FBRequest *)request didLoad:(id)result {
	//NSLog(@"Results: %@",result);
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"Failed to post with error: %@",error);
}
- (void)fbDidLogin {}
- (void)fbDidLogout {}
- (void)fbDidNotLogin:(BOOL)cancelled {}
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {}
- (void)fbSessionInvalidated {}

//**************************************************//

- (void)dealloc {
	[delegate release];
    [facebook release];
    [super dealloc];
}

@end
