//
//  OverlayView.m
//  CBS-iOS
//
//  Created by sirez on 11/05/17.
//  Copyright 2017 MaxPreps Inc. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

-(void)awakeFromNib
{
    [super awakeFromNib];
}

+(void)showCheckmarkOverlayWithMessage:(NSString *)message withDismissHandler:(void(^)(void))completion
{
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    OverlayView *overlay = (OverlayView *)[subviewArray objectAtIndex:0];
    overlay.frame = [UIScreen mainScreen].bounds;
    overlay.overLayLbl.text= message;
    overlay.overLayLbl.font = [UIFont systemFontOfSize:17];
    
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window.rootViewController.view addSubview:overlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [overlay removeFromSuperview];
        completion();
    });

    
}

@end
