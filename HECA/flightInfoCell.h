//
//  flightInfoCell.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface flightInfoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *flightNumber;

@property (nonatomic, strong) IBOutlet UILabel *airliner;

@property (nonatomic, strong) IBOutlet UITextView *airportCountry;

@property (nonatomic, strong) IBOutlet UIImageView *airlinerThumbnail;

@property (nonatomic, strong) IBOutlet UIImageView *flagThumbnail;


@end
