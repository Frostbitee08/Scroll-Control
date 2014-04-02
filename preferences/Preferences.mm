#import <Preferences/Preferences.h>

@interface PreferencesListController: PSListController {
}
@end

@implementation PreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Preferences" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
