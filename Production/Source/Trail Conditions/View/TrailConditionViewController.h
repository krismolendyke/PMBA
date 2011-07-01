//
//  TrailConditionViewController.h
//  PMBA
//
//  Created by Kris on 2/25/10.
//  Copyright Siemens 2010. All rights reserved.
//



@class TrailCondition;
@class TrailConditionImageViewController;



@interface TrailConditionViewController : UIViewController
{
  TrailConditionImageViewController *conditionImageViewController;
  UILabel *conditionLabel;
  UILabel *dateStampLabel;
  UILabel *timeStampLabel;
  UILabel *titleLabel;
  UILabel *userLabel;
  
  NSDateFormatter *dateStampFormatter;
  NSDateFormatter *timeStampFormatter;
}



#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) IBOutlet TrailConditionImageViewController *conditionImageViewController;
@property (nonatomic, retain) IBOutlet UILabel *conditionLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateStampLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) NSDateFormatter *dateStampFormatter;
@property (nonatomic, retain) NSDateFormatter *timeStampFormatter;



#pragma mark -
#pragma mark Instance Methods
- (void)updateViewWithTrailCondition:(TrailCondition *)trailCondition;



@end
