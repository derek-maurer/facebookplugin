#import "FacebookPluginPrefs.h"

@implementation FacebookPluginPrefsListController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FacebookPluginPrefs" target:self] retain];
	}
	return _specifiers;
}

-(void)auth:(id)sender {
	HSFacebookActivation *facebook = [[HSFacebookActivation alloc] init];
	[facebook setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)facebook animated:YES];
    [facebook release];
}

@end
