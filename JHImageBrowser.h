//
//  JHImageBrowser.h
//  RoundabuyUI
//
//  Created by JunhaoWang on 9/18/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.

#import <UIKit/UIKit.h>

@interface JHImageBrowser : NSObject

+ (instancetype)sharedInstance;

- (void)showImageView:(UIImageView *)displayImageView;

@end
