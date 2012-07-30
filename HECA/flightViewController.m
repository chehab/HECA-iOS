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
    NSURLRequest *jsonURLRequest = nil;
    switch (self.loadFlightBoard) {
            
        case Arrival:
            jsonURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apis.chehab.me/HECA/?json=arrival"]];
            break;
            
            
        case Departure:
            jsonURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apis.chehab.me/HECA/?json=departure"]];
            break;
    }
    
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
    
    NSLog(@"JSON Serialization Completed");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_get_main_queue ---> reloadData");
        [self.tableView reloadData];
    });
    
    //[self.tableView reloadData];
}


#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s %@", __FUNCTION__, [response MIMEType]);
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
    NSLog(@"%s (length: %d)", __FUNCTION__, [data length]);
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
    NSLog(@"OBJECT %@",self);

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
    
    

//    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
//                                                        target:self
//                                                      selector:@selector(updateHECACurrentFlightBoard)
//                                                      userInfo:nil
//                                                       repeats:YES];

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
            NSLog(@"-----> %i",[[self.arrivalBoard objectForKey:@"Arrival"] count]);
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
    static NSString *CellIdentifier2 = @"flightStatus";
    
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
        
        //TODO: IATA Airport Code
        
        //TODO: ICAO Airport Code
        
        // Setting Clock and its Modes.
        if (![[fl objectForKey:@"actual"] isEqualToString:@""] ) {
            statusCell.clock.text = [fl objectForKey:@"actual"];
            //statusCell.clockMode.text = [fl objectForKey:@"status"];
            statusCell.flightStatus.text = [fl objectForKey:@"status"];
        }
        else if (![[fl objectForKey:@"eta"] isEqualToString:@""] ) {
            statusCell.clock.text = [fl objectForKey:@"eta"];
            statusCell.clockMode.text = @"ETA";
            statusCell.flightStatus.text= @"Live";
        }
        else if (![[fl objectForKey:@"sch"] isEqualToString:@""] ) {
            statusCell.clock.text = [fl objectForKey:@"sch"];
            statusCell.clockMode.text = @"Sch";
            statusCell.flightStatus.text= @"Schedualed";
        }
        else {
            statusCell.clock.text = @"--:--";
            statusCell.clockMode.text = @"N/A";
            statusCell.flightStatus.text = @"N/A";
        }
        
        
        // Hall Number
        if (![[fl objectForKey:@"hall"] isEqualToString:@""] ) {
            statusCell.hallNumber.text = [fl objectForKey:@"hall"];
        }
        else {
            statusCell.hallNumber.text = @"-";
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
