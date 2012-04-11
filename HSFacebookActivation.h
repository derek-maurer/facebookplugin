#import <Preferences/PSDetailController.h>
#import "API/FBConnect.h"

@interface HSFacebookActivation : PSDetailController <FBSessionDelegate> {
    Facebook *facebook;
    UIButton *loginButton;
    UIButton *logoutButton;
    BOOL loggedIn;
}

- (void)login;
- (void)logout;

@end
