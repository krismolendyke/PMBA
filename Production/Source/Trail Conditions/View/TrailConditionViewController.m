//
//  MainViewController.m
//  PMBA
//
//  Created by Kris on 2/25/10.
//  Copyright Siemens 2010. All rights reserved.
//



#import "TrailConditionViewController.h"
#import "TrailCondition.h"
#import "TrailConditionImageViewController.h"



#pragma mark -
#pragma mark Public Interface
@implementation TrailConditionViewController



#pragma mark -
#pragma mark Constants
#pragma mark Date Stamp Formats
#define kDateStampFormat @"EEEE, MMMM d"
#define kTimeStampFormat @"h:mm a"



#pragma mark -
#pragma mark Properties
@synthesize conditionImageViewController;
@synthesize conditionLabel;
@synthesize titleLabel;
@synthesize dateStampLabel;
@synthesize timeStampLabel;
@synthesize userLabel;
@synthesize dateStampFormatter;
@synthesize timeStampFormatter;



#pragma mark -
#pragma mark Instance Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
  if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
  {    
    self.dateStampFormatter = [[NSDateFormatter alloc] init];
    [self.dateStampFormatter setDateFormat:kDateStampFormat];
    
    self.timeStampFormatter = [[NSDateFormatter alloc] init];
    [self.timeStampFormatter setDateFormat:kTimeStampFormat];
  }
  
  return self;
}



- (void)updateViewWithTrailCondition:(TrailCondition *)trailCondition
{
  [self.conditionImageViewController 
   updateViewWithCondition:trailCondition.condition];
  [self.conditionImageViewController startRotationAnimation];
  
  self.conditionLabel.text = trailCondition.condition;
  self.titleLabel.text = trailCondition.title;
  self.userLabel.text = 
    [NSString stringWithFormat:@"Updated by %@", trailCondition.user];
  self.dateStampLabel.text = 
    [self.dateStampFormatter stringFromDate:trailCondition.date];
  self.timeStampLabel.text = 
    [self.timeStampFormatter stringFromDate:trailCondition.date];
}



#pragma mark -
#pragma mark View Methods
- (void)viewDidLoad 
{
  [super viewDidLoad];  
}



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

  self.userLabel = nil;
  self.titleLabel = nil;
  self.timeStampLabel = nil;
  self.dateStampLabel = nil;
  self.conditionLabel = nil;
  self.conditionImageViewController = nil;  
}



- (void)dealloc 
{
  [self.dateStampFormatter release];
  [self.timeStampFormatter release];
  [self.userLabel release];
  [self.titleLabel release];
  [self.timeStampLabel release];
  [self.dateStampLabel release];
  [self.conditionLabel release];
  [self.conditionImageViewController release];
  
  [super dealloc];
}



@end
