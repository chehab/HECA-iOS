//
//  flightTableViewController.h
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "flightInfoCell.h"
#import "flightStatusCell.h"

#define LOGFUNCTION {NSLog(@"%s", __FUNCTION__);}

typedef enum{Arrival, Departure} flightBoards;

@interface flightTableView : UITableView //UITableViewController
< UITableViewDataSource, UITableViewDelegate >

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