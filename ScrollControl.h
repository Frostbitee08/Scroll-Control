//
//  ScrollControl.h
//
//  Created by Rocco Del Priore on 3/29/14.
//  Copyright (c) 2014 Rocco Del Priore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	SCIndicatorTypeBullet,
	SCIndicatorTypeAlphabetical,
	SCIndicatorTypeNumerical,
} SCIndicatorType;

@protocol ScrollControlDelegate <NSObject>
-(void)search;
@end

@interface ScrollControl : UIControl {
    int _currentPage;
    int _tabs;
    float _tabSize;
    float _maxTabSize;
    float _maxHeight;
    bool _animated;
    bool _hasSearch;
    bool _shouldFade;
    bool _addBackdrop;
    SCIndicatorType _indicatorType;
    NSMutableArray *_alphabet;
    NSMutableArray *_labels;
    UIImage *_searchImage;
    UIImage *_searchImageWhite;
    UIView *_backdrop;
    UIImageView *_searchView;
}

@property (nonatomic, assign) id<ScrollControlDelegate> delegate;
@property (nonatomic, retain) UIScrollView *_scrollView;

- (void)fade;
- (void)appear;
- (void)updateIndex;
- (void)setHasBackdrop:(bool)hasBackdrop;
- (void)setHasSearch:(bool)hasSearch;
- (void)setIndicatorType:(SCIndicatorType)type;
- (void)setMaxHeight:(float)maxHeight;
- (void)setMaxTabSize:(float)tileSize;
- (void)setTabs:(int)tabs;
- (void)setFrameWithTabs:(int)tabs;
- (void)setAnimated:(BOOL)animate;

@end
