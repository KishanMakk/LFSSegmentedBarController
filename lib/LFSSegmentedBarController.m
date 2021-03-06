//
//  LFSSegmentedBarController.m
//
// Copyright (c) 2015 Lafosca (http://lafosca.cat/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "LFSSegmentedBarController.h"

#define kStatusBarHeight 20.0f

@interface LFSSegmentedBarController() <LFSSegmentedControlDataSource, LFSSegmentedControlDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger selectedViewControllerIndex;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation LFSSegmentedBarController

- (instancetype)init {
    if (self = [super init]){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.segmentedControl = [[LFSSegmentedControl alloc] initWithFrame:CGRectMake(0, 15, screenRect.size.width, 44)];
    
        [self.segmentedControl setDatasource:self];
        [self.segmentedControl setDelegate:self];
        
        [self.view addSubview:self.segmentedControl];

    }
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    
    [self updateScrollView];
    [self.segmentedControl reloadData];
    
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        LFSSegmentedBarItem *barButtonItem = vc.segmentedBarItem;
        if (barButtonItem.tintColor){
        [self.segmentedControl setSelectedSectionLineTintColor:barButtonItem.tintColor forItemAtIndex:idx];
        }
    }];
    
    [self.segmentedControl setScrollView:self.scrollView];
    [self.view bringSubviewToFront:self.segmentedControl];
}

- (void)updateScrollView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGFloat offset = CGRectGetHeight(self.segmentedControl.frame) + kStatusBarHeight;;
    screenRect.origin.y += offset;
    screenRect.size.height -= offset;
    
    [self.view setFrame:screenRect];
    self.scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelaysContentTouches:NO];
    
    NSUInteger numberOfItems = [self.viewControllers count];
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberOfItems, self.scrollView.frame.size.height)];

    for (int i=0; i < [self.viewControllers count]; i++){
        UIViewController *viewController = [self.viewControllers objectAtIndex:i];
        [viewController.view setFrame:CGRectMake(screenRect.size.width * i, 0 , self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView addSubview:viewController.view];
    }
    
    [self.view addSubview:self.scrollView];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated {
    if (self.selectedIndex != index){
        _selectedIndex = index;
        [self.segmentedControl selectButtonAtIndex:index animated:animated];
    }
}

- (void)moveScrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    CGFloat pageSize = self.scrollView.frame.size.width;
    
    [self.scrollView setContentOffset:CGPointMake(pageSize * index, 0) animated:animated];
}

#pragma mark - LFSSegmentedControl Data Source

- (NSString *)segmentedControl:(LFSSegmentedControl *)segmentedControl titleForButtonAtIndex:(NSUInteger)index {
    UIViewController *viewController = [self.viewControllers objectAtIndex:index];
    return [[viewController segmentedBarItem] title];
}

-(NSUInteger)selectedIndexForSegmentedControl:(LFSSegmentedControl *)segmentedControl {
    return self.selectedIndex;
}

-(NSUInteger)numberOfButtonsInSegmentedControl:(LFSSegmentedControl *)segmentedControl {
    return [self.viewControllers count];
}

-(void)segmentedControl:(LFSSegmentedControl *)segmentedControl didSelectItemAtIndex:(NSUInteger)index animated:(BOOL)animated moveScrollView:(BOOL)moveScrollView{
    UIViewController *oldViewController = [self.viewControllers objectAtIndex:self.selectedViewControllerIndex];
    UIViewController *newViewController = [self.viewControllers objectAtIndex:index];
    [oldViewController viewWillDisappear:animated];
    [newViewController viewWillAppear:animated];
    if (moveScrollView){
        [self moveScrollToIndex:index animated:animated];
    }
    [oldViewController viewDidDisappear:animated];
    [newViewController viewDidAppear:animated];
    self.selectedViewControllerIndex = index;
}

-(UIFont *)preferredFontForSegmentedControl:(LFSSegmentedControl *)segmentedControl {
    if (self.font){
        return self.font;
    }
    return [UIFont systemFontOfSize:17.0f];
}
-(UIFont *)preferredFontForSelectedSegmentedControl:(LFSSegmentedControl *)segmentedControl {    
    if (self.selectedFont){
        return self.selectedFont;
    }
    return [UIFont boldSystemFontOfSize:17.0f];
}

@end
