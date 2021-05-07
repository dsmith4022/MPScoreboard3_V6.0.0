//
//  OverlayView.h
//  CBS-iOS
//
//  Created by sirez on 11/05/17.
//  Copyright 2017 MaxPreps Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView

typedef void (^DismissBlock)(void);

@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UILabel *overLayLbl;

+(void)showCheckmarkOverlayWithMessage:(NSString *)message withDismissHandler:(DismissBlock)completion; 
@end
