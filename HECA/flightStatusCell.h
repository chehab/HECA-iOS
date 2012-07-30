//
//  flightStatusCell.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flightStatusCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *codeIATA;

@property (nonatomic, strong) IBOutlet UILabel *codeICAO;

@property (nonatomic, strong) IBOutlet UILabel *clockMode;

@property (nonatomic, strong) IBOutlet UILabel *clock;

@property (nonatomic, strong) IBOutlet UILabel *flightStatus;

@property (nonatomic, strong) IBOutlet UILabel *hallNumber;

@property (nonatomic, strong) IBOutlet UILabel *terminalNumber;


@end
