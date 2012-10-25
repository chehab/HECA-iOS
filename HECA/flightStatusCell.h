//
//  flightStatusCell.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "config.h"

@interface flightStatusCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *termialTitle;

@property (nonatomic, strong) IBOutlet UILabel *hallTitle;

@property (nonatomic, strong) IBOutlet UILabel *date;

@property (nonatomic, strong) IBOutlet UILabel *codeIATA;

@property (nonatomic, strong) IBOutlet UILabel *codeICAO;

@property (nonatomic, strong) IBOutlet UILabel *clockMode;

@property (nonatomic, strong) IBOutlet UILabel *flightStatus;

@property (nonatomic, strong) IBOutlet UILabel *hallNumber;

@property (nonatomic, strong) IBOutlet UILabel *terminalNumber;

#if STATUSCELL == 1 || STATUSCELL == 3

@property (nonatomic, strong) IBOutlet UILabel *clock;

#endif

#if STATUSCELL == 1

@property (nonatomic, strong) IBOutlet UILabel *timzone;

#elif STATUSCELL == 2

@property (nonatomic, strong) IBOutlet UILabel *hours;

@property (nonatomic, strong) IBOutlet UILabel *minutes;

#endif

@end
