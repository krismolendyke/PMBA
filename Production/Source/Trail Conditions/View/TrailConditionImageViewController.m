//
//  TrailConditionImageViewController.m
//  PMBA
//
//  Created by Kris on 3/17/10.
//  Copyright 2010 Siemens. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import "TrailConditionImageViewController.h"



@implementation TrailConditionImageViewController



#pragma mark -
#pragma mark Constants
#define kRotationAnimationKey @"rotationAnimation"

#pragma mark Condition Strings
#define kRideConditionString @"Good"
// Caution will be any condition in-between
#define kDoNotRideConditionString @"Poor"

#pragma mark Condition Image Names
#define kRideBackgroundImageName @"green_bkg.png"
#define kRideWheelImageName @"green_wheel.png"

#define kCautionBackgroundImageName @"orange_bkg.png"
#define kCautionWheelImageName @"orange_wheel.png"

#define kDoNotRideBackgroundImageName @"red_bkg.png"
#define kDoNotRideWheelImageName @"red_wheel.png"



#pragma mark -
#pragma mark Macro Functions
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};



#pragma mark -
#pragma mark Properties
@synthesize wheelImageView;
@synthesize backgroundImageView;



// The designated initializer.  Override if you create the controller 
// programmatically and want to perform customization that is not appropriate 
// for viewDidLoad.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
//{
//  if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
//  {
//    // Custom initialization
//  }
//  
//  return self;
//}




// Implement viewDidLoad to do additional setup after loading the view, 
// typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad]; 
}



- (void)updateViewWithCondition:(NSString *)condition
{
  rotationAnimation = 
    [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
  rotationAnimation.toValue = [NSNumber numberWithFloat:DegreesToRadians(360)];      
  rotationAnimation.repeatCount = 999;
  
  UIImage *wheelImage = nil;
  UIImage *wheelBackgroundImage = nil;
  if([kRideConditionString isEqualToString:condition])
  {
    wheelImage = [UIImage imageNamed:kRideWheelImageName];
    wheelBackgroundImage = [UIImage imageNamed:kRideBackgroundImageName];
    rotationAnimation.duration = 0.5;    
  }
  else if([kDoNotRideConditionString isEqualToString:condition])
  {
    wheelImage = [UIImage imageNamed:kDoNotRideWheelImageName]; 
    wheelBackgroundImage = [UIImage imageNamed:kDoNotRideBackgroundImageName];
    rotationAnimation.duration = 12.5;
    rotationAnimation.timingFunction = 
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];      
  }
  else 
  {
    wheelImage = [UIImage imageNamed:kCautionWheelImageName];
    wheelBackgroundImage = [UIImage imageNamed:kCautionBackgroundImageName];
    rotationAnimation.duration = 2.5;
    rotationAnimation.timingFunction = 
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];      
  }
  
  self.wheelImageView.image = wheelImage;
  self.backgroundImageView.image = wheelBackgroundImage;   
}



- (void)startRotationAnimation
{
  [self.wheelImageView.layer addAnimation:rotationAnimation 
                                   forKey:kRotationAnimationKey];
}



- (void)stopRotationAnimation
{
  [self.wheelImageView.layer removeAnimationForKey:kRotationAnimationKey];  
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */



- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

  self.wheelImageView = nil;
  self.backgroundImageView = nil;
}



- (void)dealloc 
{
  [self.wheelImageView release];
  [self.backgroundImageView release];
  
  [super dealloc];
}



@end
