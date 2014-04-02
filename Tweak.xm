#import <UIKit/UIKit.h>
#import "ScrollControl.h"

@interface BrowserController <ScrollControlDelegate>
- (void)_doSearch:(id)fp8;
- (void)updateSearchText:(id)fp8;
@end

@interface NavigationBar
- (void)_URLTapped:(id)fp8;
@end

//Variables
static NSString *settingsPath = @"/var/mobile/Library/Preferences/com.frostbitee08.ScrollControl.plist";
static int maxHeight = 370;
static int maxTabSize = 60;

//Tags
static int controlTag = 900;

%ctor {
    if (![[NSFileManager defaultManager] fileExistsAtPath:settingsPath]) {
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

        NSString *indicatorType = @"Bullet";
        NSNumber *indicator = [NSNumber numberWithBool:FALSE];
        NSNumber *enabled = [NSNumber numberWithBool:TRUE];
        NSNumber *animated = [NSNumber numberWithBool:TRUE];
        NSNumber *hasSearch = [NSNumber numberWithBool:FALSE];

        [settings setObject:indicatorType forKey:@"indicatorType"];
        [settings setObject:indicator forKey:@"indicator"];
        [settings setObject:enabled forKey:@"enabled"];
        [settings setObject:animated forKey:@"animated"];
        [settings setObject:hasSearch forKey:@"hasSearch"];

        [settings writeToFile:settingsPath atomically:YES];
    }
}

%hook BrowserController

%new
-(void)search {
	NavigationBar *navigationBar = MSHookIvar<NavigationBar *>(self, "_navigationBar");
	[navigationBar _URLTapped:nil];
}

- (void)scrollViewDidScroll:(id)fp8 {
	%orig;

	UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
	UIView *view = [scrollView superview];

	ScrollControl *control = nil;
	control = (ScrollControl *)[view viewWithTag:controlTag];

	if (control != nil) {
		int tabs = ceil(scrollView.contentSize.height/scrollView.frame.size.height);
		if (tabs >= 3) {
			[control appear];
		}
	}
}

- (void)didCompleteScrolling {
	%orig;
	
	UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
	UIView *view = [scrollView superview];

	ScrollControl *control = nil;
	control = (ScrollControl *)[view viewWithTag:controlTag];

	if (control != nil) {
		[control fade];
	}
}

- (void)updateScrollViewContentSize {
	%orig;

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	if ([[settings objectForKey:@"enabled"] boolValue]) {
		UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
		UIView *view = [scrollView superview];

		[scrollView setShowsVerticalScrollIndicator:[[settings objectForKey:@"indicator"] boolValue]];
		ScrollControl *control = nil;
		control = (ScrollControl *)[view viewWithTag:controlTag];

		if (control == nil) {
			control = [[ScrollControl alloc] initWithFrame:CGRectMake(300, 40, 20, 461)];
			control._scrollView = scrollView;

			[view addSubview:control];
			[control setMaxTabSize:maxTabSize];
			[control setMaxHeight:maxHeight];
			[control setHasSearch:[[settings objectForKey:@"hasSearch"] boolValue]];
			[control setAnimated:[[settings objectForKey:@"animated"] boolValue]];
			control.delegate = self;
		    control.tag = controlTag;

		    NSString *indicatorType = [settings objectForKey:@"indicatorType"];
		    if ([indicatorType isEqualToString:@"Bullet"]) {
		    	[control setIndicatorType:SCIndicatorTypeBullet];
		    }
		    else if ([indicatorType isEqualToString:@"Alphabetical"]) {
		    	[control setIndicatorType:SCIndicatorTypeAlphabetical];
		    }
		    else if ([indicatorType isEqualToString:@"Numerical"]) {
		    	[control setIndicatorType:SCIndicatorTypeNumerical];
		    }
		}

		int tabs = ceil(scrollView.contentSize.height/scrollView.frame.size.height);
		if (tabs < 3) {
			[control setHidden:TRUE];
		}
		else {
			[control setFrameWithTabs:tabs];
		}
	}
}

%end