//
//  TrailConditionImageViewController.h
//  PMBA
//
//  Created by Kris on 3/17/10.
//  Copyright 2010 Siemens. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@interface TrailConditionImageViewController : UIViewController 
{
  UIImageView *wheelImageView;
  UIImageView *backgroundImageView;
  CABasicAnimation *rotationAnimation;
}



#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) IBOutlet UIImageView *wheelImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;



#pragma mark -
#pragma mark Intance Methods
- (void)updateViewWithCondition:(NSString *)condition;
- (void)startRotationAnimation;
- (void)stopRotationAnimation;



@end
