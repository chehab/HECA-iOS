//
//  flightSheet.h
//  HECA
//
//  Created by Chehab Mustafa-Hilmy on 7/4/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flightSheet : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *airline;
@property (nonatomic, strong) IBOutlet UILabel *flightNumber;
@property (nonatomic, strong) IBOutlet UILabel *terminalNumber;
@property (nonatomic, strong) IBOutlet UILabel *hallNumber;
@property (nonatomic, strong) IBOutlet UILabel *clock;
@property (nonatomic, strong) IBOutlet UILabel *clockDayTime;
@property (nonatomic, strong) IBOutlet UILabel *clockMode;
@property (nonatomic, strong) IBOutlet UILabel *codeIATA;
@property (nonatomic, strong) IBOutlet UILabel *codeICAO;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property (nonatomic, strong) IBOutlet UILabel *flightStatus;

@end
