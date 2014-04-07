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
static float _controlVerticalInsets = 40;
static float _controlWidth = 20;
static int _maxTabSize = 60;

//Tags
static int _controlTag = 900;

//Create Settings .plist, if it doesn't already exist
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

//Brings up the URL UITextFeild
%new
-(void)search {
	NavigationBar *navigationBar = MSHookIvar<NavigationBar *>(self, "_navigationBar");
	[navigationBar _URLTapped:nil];
}

//Called when device rotates, adjusts ScrollControl's frame accordingly
- (void)didRotateFromInterfaceOrientation:(int)fp8 {
	%orig;

	UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
	UIView *view = [scrollView superview];

	ScrollControl *control = nil;
	control = (ScrollControl *)[view viewWithTag:_controlTag];

	int tabs = floor(scrollView.contentSize.height/scrollView.frame.size.height);
	if (tabs < 2) {
		[control setHidden:TRUE];
	}
	else {
		[control setFrame:CGRectMake(scrollView.frame.size.width-_controlWidth, _controlVerticalInsets, _controlWidth, scrollView.frame.size.height-(_controlVerticalInsets*2))];
		[control setMaxHeight:scrollView.frame.size.height-(_controlVerticalInsets*2)];
		[control setFrameWithTabs:tabs];
	}
}

//Show ScrollControl and update index to reflect current page
- (void)scrollViewDidScroll:(id)fp8 {
	%orig;

	UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
	UIView *view = [scrollView superview];

	ScrollControl *control = nil;
	control = (ScrollControl *)[view viewWithTag:_controlTag];

	if (control != nil) {
		int tabs = ceil(scrollView.contentSize.height/scrollView.frame.size.height);
		if (tabs >= 2) {
			[control appear];
			[control updateIndex];
		}
	}
}

//Hide Control when finished scrolling
- (void)didCompleteScrolling {
	%orig;
	
	UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
	UIView *view = [scrollView superview];

	ScrollControl *control = nil;
	control = (ScrollControl *)[view viewWithTag:_controlTag];

	if (control != nil) {
		[control fade];
	}
}

//Called every time the page size changes
- (void)updateScrollViewContentSize {
	%orig;

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	if ([[settings objectForKey:@"enabled"] boolValue]) {
		//Initial Variables
		UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
		UIView *view = [scrollView superview];
		ScrollControl *control = nil;
		control = (ScrollControl *)[view viewWithTag:_controlTag];

		//Settings
		[scrollView setShowsVerticalScrollIndicator:[[settings objectForKey:@"indicator"] boolValue]];

		//Initialze ScrollControl
		if (control == nil) {
			control = [[ScrollControl alloc] initWithFrame:CGRectMake(scrollView.frame.size.width-_controlWidth, _controlVerticalInsets, _controlWidth, scrollView.frame.size.height-(_controlVerticalInsets*2))];
			control._scrollView = scrollView;

			[view addSubview:control];
			[control setMaxTabSize:_maxTabSize];
			[control setMaxHeight:scrollView.frame.size.height-(_controlVerticalInsets*2)];
			[control setHasSearch:[[settings objectForKey:@"hasSearch"] boolValue]];
			[control setAnimated:[[settings objectForKey:@"animated"] boolValue]];
			[control setHasBackdrop:YES];
			control.delegate = self;
		    control.tag = _controlTag;

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

		//Each tab should reflect one "page", defined by scrollviewframe. Extra space should just lead to the bottom
		int tabs = floor(scrollView.contentSize.height/scrollView.frame.size.height);
		if (tabs < 2) {
			[control setHidden:TRUE];
		}
		else {
			[control setFrameWithTabs:tabs];
		}
	}
}

%end