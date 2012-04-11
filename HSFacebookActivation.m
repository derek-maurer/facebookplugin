#import "HSFacebookActivation.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";

@implementation HSFacebookActivation

- (id)init {
    
    if ((self = [super init])) {
        facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
        }
    
        loggedIn = [facebook isSessionValid];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.title = @"Activation";
    loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutButton.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (103/2), (self.view.frame.size.height / 2) - (103/2),103,103)];
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Fusion/Plugins/FacebookPlugin.bundle/Icon.png"];
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    if (loggedIn) loginButton.hidden = YES;
    else logoutButton.hidden = YES;
}

- (void)login {
    if (![facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_photos",@"user_videos",@"publish_stream",@"offline_access",@"user_checkins",@"friends_checkins",@"email",@"user_location",@"publish_checkins" ,nil];
        [facebook authorize:permissions];
    }
}

- (void)logout {
    [facebook logout];
}

//******* Facebook delegate crap*******//

- (void)fbDidLogin {
    loginButton.hidden = YES;
    logoutButton.hidden = NO;
    
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
    	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    else 
    	prefs = [NSMutableDictionary dictionary];
    [prefs setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [prefs setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [prefs writeToFile:PREFS_FILE atomically:YES];
}

- (void)fbDidLogout {
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    [prefs removeObjectForKey:@"FBAccessTokenKey"];
    [prefs removeObjectForKey:@"FBExpirationDateKey"];
    [prefs writeToFile:PREFS_FILE atomically:YES];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Facebook: did not login");
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    NSLog(@"Facebook: extended token");
}

- (void)fbSessionInvalidated {
    NSLog(@"Facebook: session validaded");
}

//************************************//

- (void)dealloc {
    [facebook release];
    [super dealloc];
}

@end
