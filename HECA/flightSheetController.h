//
//  flightSheetController.h
//  HECA
//
//  Created by Chehab Mustafa-Hilmy on 7/4/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LOGFUNCTION {NSLog(@"%s", __FUNCTION__);}

typedef enum{Arrival, Departure} flightWay;

@interface flightSheetController : UITableViewController 
< UITableViewDataSource, UITableViewDelegate >

@property (weak, nonatomic) IBOutlet UIView *workingIndicator;

@property (nonatomic, strong) NSMutableDictionary *departureBoard;
@property (nonatomic, strong) NSMutableDictionary *arrivalBoard;
@property (nonatomic, strong) NSMutableDictionary *fligthBoard;

@property (nonatomic, strong) NSMutableData *departureData;
@property (nonatomic, strong) NSMutableData *arrivalData;
@property (nonatomic, strong) NSMutableData *fligthData;

@property (nonatomic, readwrite) flightWay currentFlightWay;
@property (nonatomic, strong) NSString *currentTimeStamp;

@property (nonatomic, strong) NSURLConnection *jsonConnection;


@end
