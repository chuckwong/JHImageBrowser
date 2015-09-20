//
//  JHImageBrowser.m
//  RoundabuyUI
//
//  Created by JunhaoWang on 9/18/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.

#import "JHImageBrowser.h"
#import "MBProgressHUD.h"

//static CGRect oldFrame;
//static CGRect largeFrame;

@interface JHImageBrowser ()<UIScrollViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *displayImageView;
@end

@implementation JHImageBrowser

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        _scrollView.backgroundColor = [UIColor blackColor];
        
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [_scrollView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToZoom:)];
        doubleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.5;
        [_scrollView addGestureRecognizer:longPress];
    }
    return _scrollView;
}

- (UIImageView *)displayImageView
{
    if (!_displayImageView) {
        _displayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.width)];
        _displayImageView.center = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
        [_scrollView addSubview:_displayImageView];
    }
    return _displayImageView;
}


- (void)showImageView:(UIImageView *)imageView {
    
    UIImage *image = imageView.image;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.scrollView.alpha = 0;
    self.scrollView.contentSize = image.size;
    self.scrollView.zoomScale = 1.0;
    
    self.displayImageView.image = image;
    
    [window addSubview:self.scrollView];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)hideImage:(UITapGestureRecognizer *)tap {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.scrollView removeFromSuperview];
        self.scrollView.contentSize = CGSizeMake(0, 0);
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.displayImageView;
}

- (void)tapToZoom:(UITapGestureRecognizer *)tap {
    
    if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    else
        [self.scrollView zoomToRect:[self zoomRectForScrollView:self.scrollView withScale:3.0 withCenter:[tap locationInView:self.scrollView]] animated:YES];
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", nil];
        [actionSheet showInView:self.scrollView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.displayImageView.image, nil, nil, nil);
        [self saveComleted];
    }
}

- (void)saveComleted
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scrollView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Saved to Album";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0];
}

@end




