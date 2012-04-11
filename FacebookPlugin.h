#import <CoreLocation/CoreLocation.h>
#import "API/FBConnect.h"
#import "Fusion.h"

@interface FacebookPlugin : NSObject <FusionPlugin, FBSessionDelegate, FBRequestDelegate> {
    Facebook *facebook;
    id <FusionPluginDelegate> delegate;
}
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
- (void)postWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location;
@end


