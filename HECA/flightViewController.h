//
//  flightViewController.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "config.h"
#import "flightInfoCell.h"
#import "flightStatusCell.h"
#import "flightSheetDefaultCell.h"




typedef enum{Arrival, Departure} flightBoards;

@interface flightViewController : UIViewController
< UITableViewDataSource, UITableViewDelegate >

//UI
@property (nonatomic, strong) IBOutlet UITableView *tableView;

// Fitching
@property (nonatomic, strong) NSURLConnection *jsonConnection;
@property (nonatomic, strong) NSTimer *updateTimer;

// Refresh related
@property (nonatomic, strong) NSString *currentTimeStamp;

// Procesed Flight Board
@property (nonatomic, strong) NSMutableDictionary *departureBoard;
@property (nonatomic, strong) NSMutableDictionary *arrivalBoard;
@property (nonatomic, strong) NSMutableDictionary *fligthBoard;

// Fligth Data
@property (nonatomic, strong) NSMutableData *departureData;
@property (nonatomic, strong) NSMutableData *arrivalData;
@property (nonatomic, strong) NSMutableData *fligthData;

// Flags
@property (nonatomic, readwrite) flightBoards currentFlightBoard;
@property (nonatomic, readwrite) flightBoards loadFlightBoard;


@end
