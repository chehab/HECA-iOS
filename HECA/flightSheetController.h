//
//  flightSheetController.h
//  HECA
//
//  Created by Chehab Mustafa-Hilmy on 7/4/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flightSheetController : UITableViewController 
< UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, strong) NSArray *dumyData;
@property (weak, nonatomic) IBOutlet UIView *workingIndicator;
@property (nonatomic,strong) NSMutableDictionary *arrival;

@end
