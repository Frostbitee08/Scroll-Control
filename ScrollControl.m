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
        // Initialization code
        _currentPage = 0;
        _tabs = 0;
        _animated = NO;
        _tabSize = 0;
        _maxTabSize = 0;
        _maxHeight = 0;
        _hasSearch = NO;
        _addBackdrop = YES;
        _indicatorType = SCIndicatorTypeBullet;
        _shouldFade = YES;
        _alphabet = [[NSMutableArray alloc] init];
        int a = 65;
        for (; a < 91; a++) {
            [_alphabet addObject:[NSString stringWithFormat:@"%c", (char)a]];
        }

        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchUpInside];

        _backdrop = [[UIView alloc] init];
        [_backdrop setBackgroundColor:[UIColor blackColor]];
        [_backdrop setAlpha:.5];
        _backdrop.layer.cornerRadius = 10;
        _backdrop.layer.masksToBounds = YES;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        _currentPage = 0;
        _tabs = 0;
        _animated = NO;
        _tabSize = 0;
        _maxTabSize = 0;
        _maxHeight = 0;
        _hasSearch = NO;
        _addBackdrop = YES;
        _indicatorType = SCIndicatorTypeBullet;
        _shouldFade = YES;
        _alphabet = [[NSMutableArray alloc] init];
        int a = 65;
        for (; a < 91; a++) {
            [_alphabet addObject:[NSString stringWithFormat:@"%c", (char)a]];
        }


        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(nowFade) forControlEvents:UIControlEventTouchUpInside];

        _backdrop = [[UIView alloc] init];
        [_backdrop setBackgroundColor:[UIColor blackColor]];
        [_backdrop setAlpha:.5];
        _backdrop.layer.cornerRadius = 10;
        _backdrop.layer.masksToBounds = YES;
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
        [self setHiddenAnimated:TRUE];
    }
}

- (void)handleTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    int answer = floor(point.y/_tabSize);
    if (answer != _currentPage && answer >=0 && answer<=_tabs) {
        [self setPage:answer];
    }
}

- (void)setPage:(int)page {
    if (page == 0 && _hasSearch) {
        [self.delegate search];
    }
    else if (_hasSearch) {
        page -= 1;
    }

    float offset = _scrollView.frame.size.height*page;
    if (offset > _scrollView.contentSize.height-_scrollView.frame.size.height) {
        offset = _scrollView.contentSize.height-_scrollView.frame.size.height;
    }
    
    else {
        [_scrollView setContentOffset:CGPointMake(0, offset) animated:_animated];
        _currentPage = page;
    }
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

        _currentPage = -1;
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
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2)-5, (_tabSize/2)-5,10,10)];
            [imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/ScrollControl/search_icon@2x.png"]];
            [view addSubview:imageView];

            [self addSubview:view];
            iter+=_tabSize;
        }
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