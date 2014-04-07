//
//  ScrollControl.m
//  TestMe
//
//  Created by Rocco Del Priore on 3/29/14.
//  Copyright (c) 2014 Rocco Del Priore. All rights reserved.
//

#import "ScrollControl.h"

@implementation UIView (AnimateHidden)

-(void)setHiddenAnimated:(BOOL)hide
{
    [UIView animateWithDuration:0.5
            delay:0.3
            options:UIViewAnimationOptionCurveEaseOut
            animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
         if (hide)
             self.alpha=0;
         else {
            self.hidden= NO;
            self.alpha=1;
         }
     }
     completion:^(BOOL b) {
         if (hide)
            self.hidden= YES;
         }
     ];
}

@end

@implementation ScrollControl
@synthesize _scrollView;

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPage = 0;
        _tabs = 0;
        _tabSize = 0;
        _maxTabSize = 0;
        _maxHeight = 0;
        _animated = NO;
        _hasSearch = NO;
        _addBackdrop = YES;
        _shouldFade = YES;
        _indicatorType = SCIndicatorTypeBullet;
        _alphabet = [[NSMutableArray alloc] init];
        _labels =  [[NSMutableArray alloc] init];
        _searchImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/ScrollControl/search_icon@2x.png"];
        _searchImageWhite = [UIImage imageWithContentsOfFile:@"/Library/Application Support/ScrollControl/search_icon_white@2x.png"];
        _searchView = [[UIImageView alloc] init];
        _backdrop = [[UIView alloc] init];
        [_backdrop setBackgroundColor:[UIColor blackColor]];
        [_backdrop setAlpha:.5];
        _backdrop.layer.cornerRadius = 10;
        _backdrop.layer.masksToBounds = YES;

        for (int a = 65; a < 91; a++) {
            [_alphabet addObject:[NSString stringWithFormat:@"%c", (char)a]];
        }

        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _currentPage = 0;
        _tabs = 0;
        _tabSize = 0;
        _maxTabSize = 0;
        _maxHeight = 0;
        _animated = NO;
        _hasSearch = NO;
        _addBackdrop = YES;
        _shouldFade = YES;
        _indicatorType = SCIndicatorTypeBullet;
        _alphabet = [[NSMutableArray alloc] init];
        _labels =  [[NSMutableArray alloc] init];
        _searchImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/ScrollControl/search_icon@2x.png"];
        _searchImageWhite = [UIImage imageWithContentsOfFile:@"/Library/Application Support/ScrollControl/search_icon_white@2x.png"];
        _searchView = [[UIImageView alloc] init];
        _backdrop = [[UIView alloc] init];
        [_backdrop setBackgroundColor:[UIColor blackColor]];
        [_backdrop setAlpha:.5];
        _backdrop.layer.cornerRadius = 10;
        _backdrop.layer.masksToBounds = YES;

        for (int a = 65; a < 91; a++) {
            [_alphabet addObject:[NSString stringWithFormat:@"%c", (char)a]];
        }

        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - UIControl Subclass

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    _shouldFade = NO;
    [_backdrop setHidden:NO];

    for (int i = 0; i < self.subviews.count; ++i) {
        if ([[self.subviews objectAtIndex:i] isMemberOfClass:[UILabel class]]) {
            UILabel *temp = (UILabel *)[self.subviews objectAtIndex:i];
            [temp setTextColor:[UIColor whiteColor]];
        }
    }
    //[_searchView setImage:_searchImageWhite]; //Why does this Crash? Bad white Search image obviously, but why? Possibly something to do with Photoshop
    return TRUE;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    return TRUE;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
}

#pragma mark - Actions

- (void)appear {
    [self setAlpha:1];
    [self setHidden:FALSE];
}

- (void)nowFade {
    _shouldFade = YES;
    [self fade];
}

- (void)fade {
    if (_shouldFade) {
        [_backdrop setHidden:YES];
        for (int i = 0; i < self.subviews.count; ++i) {
            if ([[self.subviews objectAtIndex:i] isMemberOfClass:[UILabel class]]) {
                UILabel *temp = (UILabel *)[self.subviews objectAtIndex:i];
                [temp setTextColor:[UIColor darkGrayColor]];
            }
        }
        if (_hasSearch) {
            [_searchView setImage:_searchImage];
        }

        [self setHiddenAnimated:TRUE];
    }
}

- (void)updateIndex {
    int answer = floor(_scrollView.contentOffset.y/_scrollView.frame.size.height);

    [_labels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14]];
    if (answer < _labels.count) {
        UILabel *highlightedLabel = (UILabel *)[_labels objectAtIndex:answer];
        [highlightedLabel setFont:[UIFont boldSystemFontOfSize:20]];
    }
    else {
        UILabel *highlightedLabel = (UILabel *)[_labels objectAtIndex:0];
        [highlightedLabel setFont:[UIFont boldSystemFontOfSize:20]];
    }
}

- (void)handleTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    int answer = floor(point.y/_tabSize);

    if (answer == 0 && _hasSearch) {
        [self.delegate search];
    }
    else if (_hasSearch) {
        answer -=1;
    }
    if (answer != _currentPage && answer >=0 && answer<=_tabs) {
        [_labels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14]];
        if (answer < _labels.count) {
            UILabel *highlightedLabel = (UILabel *)[_labels objectAtIndex:answer];
            [highlightedLabel setFont:[UIFont boldSystemFontOfSize:20]];
        }

        [self setPage:answer];
    }
}

- (void)setPage:(int)page {
    float offset = _scrollView.frame.size.height*page;
    if (offset > _scrollView.contentSize.height-_scrollView.frame.size.height) {
        offset = _scrollView.contentSize.height-_scrollView.frame.size.height;
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, offset) animated:_animated];
    _currentPage = page;
}

#pragma mark - Modifiers

- (void)setMaxHeight:(float)maxHeight {
    _maxHeight = maxHeight;
}

- (void)setMaxTabSize:(float)tileSize {
    _maxTabSize = tileSize;
}

- (void)setTabs:(int)tabs {
    _tabs = tabs;
}

- (void)setFrameWithTabs:(int)tabs {
    if (_hasSearch) {
        tabs = tabs + 1;
    }
    if (tabs != _tabs){
        if (tabs < 2) {
            [self setHidden:TRUE];
        }
        else {
            [self setHidden:FALSE];
        }

        _currentPage = 0;
        _tabs = tabs;
        CGRect frame = self.frame;
        float height = _maxTabSize * tabs;
        if (height > _maxHeight) {
            height = _maxHeight;
            _tabSize = height/tabs;
        }
        else  {
            _tabSize = _maxTabSize;
        }
        frame.size.height = height;
        frame.origin.y = ([self superview].frame.size.height-frame.size.height)/2;
        [self setFrame:frame];

        //Add Tab Labels
        int iter = 0;
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setBackgroundColor:[UIColor clearColor]];

        int increment = tabs;
        if (_hasSearch) {
            increment -= 1;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, iter, frame.size.width, _tabSize)];
            [view setBackgroundColor:[UIColor clearColor]];

            _searchView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2)-5, (_tabSize/2)-5,10,10)];
            [_searchView setImage:_searchImage];
            [view addSubview:_searchView];

            [self addSubview:view];
            iter+=_tabSize;
        }

        [_labels removeAllObjects];
        for (unsigned int i = 0; i < increment; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, iter, frame.size.width, _tabSize)];
            if (_indicatorType == SCIndicatorTypeBullet) {
                [label setText:[NSString stringWithUTF8String:"•"]];
            }
            else if (_indicatorType == SCIndicatorTypeAlphabetical) {
                if (i < _alphabet.count) {
                    [label setText:[_alphabet objectAtIndex:i]];
                }
            }
            else if (_indicatorType == SCIndicatorTypeNumerical) {
                [label setText:[NSString stringWithFormat:@"%i", i+1]];
            }   
            [label setTextColor:[UIColor darkGrayColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [_labels insertObject:label atIndex:i];
            [self addSubview:label];
            iter+=_tabSize;
        }

        if (_addBackdrop) {
            frame.origin.x = 0;
            frame.origin.y = 0;

            [_backdrop setFrame:frame];
            [_backdrop setHidden:YES];
            [self addSubview:_backdrop];
            [self sendSubviewToBack:_backdrop];
        }
        else {
            [_backdrop removeFromSuperview];
        }
    }
}

- (void)setAnimated:(BOOL)animate {
    _animated = animate;
}

- (void)setIndicatorType:(SCIndicatorType)type {
    _indicatorType = type;
}

- (void)setHasSearch:(bool)hasSearch {
    _hasSearch = hasSearch;
    [self setFrameWithTabs:_tabs];
}

- (void)setHasBackdrop:(bool)hasBackdrop {
    _addBackdrop = hasBackdrop;
}

@end