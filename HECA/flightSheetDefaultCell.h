//
//  flightSheetDefaultCell.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 10/25/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flightSheetDefaultCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *flightNumber;
@property (nonatomic, strong) IBOutlet UILabel *airliner;

@property (nonatomic, strong) IBOutlet UILabel *clockMode;
@property (nonatomic, strong) IBOutlet UILabel *flightStatus;
@property (nonatomic, strong) IBOutlet UILabel *clock;

@property (nonatomic, strong) IBOutlet UILabel *codeIATA;
@property (nonatomic, strong) IBOutlet UILabel *city;
@property (nonatomic, strong) IBOutlet UILabel *country;

@property (nonatomic, strong) IBOutlet UIImageView *flightStatusIcons;

@property (nonatomic, strong) IBOutlet UILabel *termialinfo;


@property (nonatomic, strong) IBOutlet UILabel *utc2;
@property (nonatomic, strong) IBOutlet UILabel *cairo;
@property (nonatomic, strong) IBOutlet UILabel *cai;
@property (nonatomic, strong) IBOutlet UILabel *egypt;


@end
