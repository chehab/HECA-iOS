//
//  flightViewController.m
//  HECA
//
//  Created by Chehab Mustafa Hilmy on 7/30/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import "flightViewController.h"

@interface flightViewController ()

@end

@implementation flightViewController

//UI
@synthesize tableView = _tableView;

// Fetching
@synthesize jsonConnection = _jsonConnection;

// Refresh related
@synthesize currentTimeStamp = _currentTimeStamp;
@synthesize updateTimer = _updateTimer;

// Flags
@synthesize loadFlightBoard = _loadFlightBoard;
@synthesize currentFlightBoard = _currentFlightBoard;

// Procesed Flight Board
@synthesize departureBoard = _departureBoard;
@synthesize arrivalBoard = _arrivalBoard;
@synthesize fligthBoard = _fligthBoard;

// Fligth Data
@synthesize departureData = _departureData;
@synthesize arrivalData = _arrivalData;
@synthesize fligthData = _fligthData;


#pragma mark - HECA/CAI

-(void) updateHECACurrentFlightBoard
{
    LOGFUNCTION
    [self loadHECABoardDataAsJSONWithFlightBoard:self.currentFlightBoard];
}

-(void) loadHECABoardDataAsJSONWithFlightBoard:(flightBoards) heading
{
    LOGFUNCTION
    self.loadFlightBoard = heading;
    NSString *request = nil;
    switch (self.loadFlightBoard) {
            
        case Arrival:
            request = [NSString stringWithFormat:@"%@=%@",@"json",@"arrival"];
            break;
            
        case Departure:
            request = [NSString stringWithFormat:@"%@=%@",@"json",@"departure"];
            break;
    }
    
    NSURLRequest *jsonURLRequest = [NSURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                     [NSString stringWithFormat:@"%@?%@&key=%@",APIURL,request,APIKEY]]];
#if VERBOSE >= 2
     NSLog(@"API Req URL =========>  %@",jsonURLRequest);
#endif
    
    self.jsonConnection = [[NSURLConnection alloc] initWithRequest:jsonURLRequest delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSAssert(self.jsonConnection != nil, @"Couldn't Establish A Connection With The Server.");
}

- (void) serializHECAFlightBoardFromJSONData:(NSData *)JSONData
{
    LOGFUNCTION
    NSError *e = nil;
    
    switch (self.loadFlightBoard) {
            
        case Arrival:
            self.arrivalBoard = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
            //            NSLog(@"%@", self.arrivalBoard);
            break;
            
            
        case Departure:
            self.departureBoard = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
            //            NSLog(@"%@", self.departureBoard);
            break;
    }
#if VERBOSE >= 1    
    NSLog(@"JSON Serialization Completed");
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
#if VERBOSE >= 2
        NSLog(@"dispatch_get_main_queue ---> reloadData");
#endif
        [self.tableView reloadData];
    });
    
    //[self.tableView reloadData];
}


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
#if VERBOSE >= 1
    NSLog(@"%s %@", __FUNCTION__, [response MIMEType]);
#endif
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    switch (self.loadFlightBoard) {
            
        case Arrival:
            if (!self.arrivalData) self.arrivalData = [[NSMutableData alloc] init];
            break;
            
            
        case Departure:
            if (!self.departureData) self.departureData = [[NSMutableData alloc] init];
            break;
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
#if VERBOSE >= 1
    NSLog(@"%s (length: %d)", __FUNCTION__, [data length]);
#endif
    switch (self.loadFlightBoard) {
            
        case Arrival:
            [self.arrivalData appendData:data];
            break;
            
            
        case Departure:
            [self.departureData appendData:data];
            break;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    LOGFUNCTION
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.jsonConnection = nil;
    
    switch (self.loadFlightBoard) {
            
        case Arrival:
            NSLog(@"have data: %d bytes", [self.arrivalData length]);
            [NSThread detachNewThreadSelector:@selector(serializHECAFlightBoardFromJSONData:) toTarget:self withObject:self.arrivalData];
            self.arrivalData = nil;
            break;
            
            
        case Departure:
            NSLog(@"have data: %d bytes", [self.departureData length]);
            [NSThread detachNewThreadSelector:@selector(serializHECAFlightBoardFromJSONData:) toTarget:self withObject:self.departureData];
            self.departureData = nil;
            break;
    }
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    LOGFUNCTION
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.jsonConnection = nil;
}

#pragma mark - Error handling

- (void)handleError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"error is %@, %@", error, [error domain]);
    //    NSString *errorMessage = [error localizedDescription];
    
    // errors in NSXMLParserErrorDomain >= 10 are harmless parsing errors
    //    if ([error domain] == NSXMLParserErrorDomain && [error code] >= 10) {
    //        alertMessage(@"Cannot parse feed: %@", errorMessage);  // tell the user why parsing is stopped
    //    } else {
    //        UIAlertView *alertView = [[UIAlertView alloc]
    //                                  initWithTitle:@"Error" message:errorMessage delegate:nil
    //                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //        [alertView show];
    //        [alertView release];
    //        [self dismissModalViewControllerAnimated:YES];
    //    }
}

#pragma mark - App Life Cycle

- (void)viewDidLoad
{
    LOGFUNCTION
#if VERBOSE >= 4
    NSLog(@"OBJECT %@",self);
#endif

    [super viewDidLoad];

    //Current Flight Board
    self.currentFlightBoard = Arrival;
    [self loadHECABoardDataAsJSONWithFlightBoard:Arrival];
    
    //Clear/Add TableView Background
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]]];
    
    //Clear Cells Boarders 
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    

    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                        target:self
                                                      selector:@selector(updateHECACurrentFlightBoard)
                                                      userInfo:nil
                                                       repeats:YES];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    LOGFUNCTION
    // Return the number of sections.
    switch (self.currentFlightBoard) {
            
        case Arrival:
#if VERBOSE >= 2
            NSLog(@"-----> %i",[[self.arrivalBoard objectForKey:@"Arrival"] count]);
#endif
            return [[self.arrivalBoard objectForKey:@"Arrival"] count];
            break;
            
            
        case Departure:
            return [[self.departureBoard objectForKey:@"departure"] count];
            break;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOGFUNCTION
    // Return the number of rows in the section.   
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOGFUNCTION
    switch ([indexPath row]) {
            
        case 0:
            return 63;
            break;
            
        case 1:
            return 63;
            break;
            
        default:
            return 20;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOGFUNCTION
    static NSString *CellIdentifier1 = @"flightInfo";
    
#if STATUSCELL == 1
    static NSString *CellIdentifier2 = @"flightStatus1";
#elif STATUSCELL == 2
    static NSString *CellIdentifier2 = @"flightStatus2";
#elif STATUSCELL == 3
    static NSString *CellIdentifier2 = @"flightStatus3";
#endif
    
    NSMutableDictionary *fl = nil;
    switch (self.currentFlightBoard) {
            
        case Arrival:
            fl = [[self.arrivalBoard objectForKey:@"Arrival"] objectAtIndex:[indexPath section]];
            break;
            
            
        case Departure:
            fl = [[self.departureBoard objectForKey:@"departure"] objectAtIndex:[indexPath section]];
            break;
    }
    
    if([indexPath row] == 0) {
    
        flightInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if (infoCell == nil) {
            infoCell = [[flightInfoCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier1];
        }

        // Configure the cell...
        
        //UI: Set Cell Background
        [infoCell setBackgroundColor:[UIColor yellowColor]];
        [infoCell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-flightInfo-1-tableViewCell"]]];
        //UI: Set Text Color
        infoCell.flightNumber.textColor   = [UIColor whiteColor];
        infoCell.airliner.textColor       = [UIColor whiteColor];
        infoCell.airportCountry.textColor = [UIColor whiteColor];
        
        
        //Basic
        infoCell.airliner.text = [fl objectForKey:@"airline"];
        infoCell.flightNumber.text = [fl objectForKey:@"flightno"];
        infoCell.airportCountry.text = [fl objectForKey:@"airport"];
        
        //TODO: Airliner Thumb
        
        //TODO: Flag Thumb
        
        
        return infoCell;
    }
    else
    {
        flightStatusCell *statusCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        if (statusCell == nil) {
            statusCell = [[flightStatusCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:CellIdentifier2];
        }
        
        //UI: Set Cell Background
        [statusCell setBackgroundColor:[UIColor yellowColor]];
        [statusCell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-flightStatus-2-tableViewCell"]]];
        //UI: Set Text Color        
        statusCell.codeIATA.textColor       = [UIColor whiteColor];
        statusCell.codeICAO.textColor       = [UIColor whiteColor];        
        statusCell.clockMode.textColor      = [UIColor whiteColor];
        statusCell.flightStatus.textColor   = [UIColor whiteColor];
        statusCell.hallNumber.textColor     = [UIColor whiteColor];
        statusCell.terminalNumber.textColor = [UIColor whiteColor];
        statusCell.termialTitle.textColor   = [UIColor whiteColor];
        statusCell.hallTitle.textColor      = [UIColor whiteColor];
        statusCell.date.textColor           = [UIColor whiteColor];
        
#if STATUSCELL == 1 || STATUSCELL == 3
        statusCell.clock.textColor          = [UIColor whiteColor];
#endif
#if STATUSCELL == 1
        statusCell.timzone.textColor        = [UIColor whiteColor];
#elif STATUSCELL == 2
        statusCell.hours.textColor          = [UIColor whiteColor];
        statusCell.minutes.textColor        = [UIColor whiteColor];
#endif
        
        
        //TODO: IATA Airport Code
        
        //TODO: ICAO Airport Code
        
        // Setting Clock and its Modes.
        
#if STATUSCELL == 2
        NSRange hr = {0,3};
        NSRange mn = {3,2};
#endif
        
        if (![[fl objectForKey:@"actual"] isEqualToString:@""] ) {
#if STATUSCELL == 1 || STATUSCELL == 3
            statusCell.clock.text = [fl objectForKey:@"actual"];
#endif
#if STATUSCELL == 2
            statusCell.hours.text = [[fl objectForKey:@"actual"] substringWithRange:hr];
            statusCell.minutes.text = [[fl objectForKey:@"actual"] substringWithRange:mn];
#endif
            //statusCell.clockMode.text = [fl objectForKey:@"status"];
            statusCell.flightStatus.text = [fl objectForKey:@"status"];
        }
        else if (![[fl objectForKey:@"eta"] isEqualToString:@""] ) {
#if STATUSCELL == 1 || STATUSCELL == 3
            statusCell.clock.text = [fl objectForKey:@"eta"];
#endif
#if STATUSCELL == 2
            statusCell.hours.text = [[fl objectForKey:@"eta"] substringWithRange:hr];
            statusCell.minutes.text = [[fl objectForKey:@"eta"] substringWithRange:mn];
#endif
            statusCell.clockMode.text = @"ETA";
            statusCell.flightStatus.text= @"Live";
        }
        else if (![[fl objectForKey:@"sch"] isEqualToString:@""] ) {
#if STATUSCELL == 1 || STATUSCELL == 3
            statusCell.clock.text = [fl objectForKey:@"sch"];
#endif
#if STATUSCELL == 2
            statusCell.hours.text = [[fl objectForKey:@"sch"] substringWithRange:hr];
            statusCell.minutes.text = [[fl objectForKey:@"sch"] substringWithRange:mn];
#endif
            statusCell.clockMode.text = @"Sch";
            statusCell.flightStatus.text= @"Schedualed";
        }
        else {
#if STATUSCELL == 1 || STATUSCELL == 3
            statusCell.clock.text = @"--:--";
#endif
            statusCell.clockMode.text = @"N/A";
            statusCell.flightStatus.text = @"N/A";
        }
        
        // Date
        if (![[fl objectForKey:@"date"] isEqualToString:@""] ) {
            statusCell.date.text = [[[fl objectForKey:@"date"]
                stringByReplacingOccurrencesOfString:@"2012"
                                          withString:@""]
                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
        }
        else {
            [statusCell.date  setHidden:YES];
        }
        
        // Hall Number
        if (![[fl objectForKey:@"hall"] isEqualToString:@""] ) {
            statusCell.hallNumber.text = [fl objectForKey:@"hall"];
        }
        else {
            statusCell.hallNumber.text = @"-";
            [statusCell.hallNumber  setHidden:YES];
            [statusCell.hallTitle  setHidden:YES];
        }
        
        
        // Terminal Number
        if (![[fl objectForKey:@"terminal"] isEqualToString:@""] ) {
            statusCell.terminalNumber.text = [fl objectForKey:@"terminal"];
        }
        else {
            statusCell.terminalNumber.text = @"-";
        }
        
        
        return statusCell;

    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
