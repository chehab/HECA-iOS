//
//  flightSheetController.m
//  HECA
//
//  Created by Chehab Mustafa-Hilmy on 7/4/12.
//  Copyright (c) 2012 Freelance. All rights reserved.
//

#import "flightSheetController.h"
#import "flightSheet.h"

@interface flightSheetController ()

@end

@implementation flightSheetController

@synthesize workingIndicator = _workingIndicator;

@synthesize currentFlightWay = _currentFlightWay;
@synthesize currentTimeStamp = _currentTimeStamp;

@synthesize departureBoard = _departureBoard;
@synthesize arrivalBoard = _arrivalBoard;
@synthesize fligthBoard = _fligthBoard;

@synthesize departureData = _departureData;
@synthesize arrivalData = _arrivalData;
@synthesize fligthData = _fligthData;

@synthesize jsonConnection = _jsonConnection;







#pragma mark - HECA/CAI 

-(void) loadHECABoardDataAsJSONWithFlightWay:(flightWay) heading
{
    LOGFUNCTION
    self.currentFlightWay = heading;
    NSURLRequest *jsonURLRequest = nil;
    switch (self.currentFlightWay) {
            
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
    
    switch (self.currentFlightWay) {
            
        case Arrival:
            self.arrivalBoard = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"%@", self.arrivalBoard);
            break;
            
            
        case Departure:
            self.departureBoard = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"%@", self.departureBoard);
            break;
    } 
    
    NSLog(@"JSON Serialization Completed");
    [self.tableView reloadData];
    self.workingIndicator.hidden = YES;
}


#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s %@", __FUNCTION__, [response MIMEType]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    switch (self.currentFlightWay) {
            
        case Arrival:
            if (!self.arrivalData) self.arrivalData = [[NSMutableData alloc] init];
            break;
            
            
        case Departure:
            if (!self.departureData) self.departureData = [[NSMutableData alloc] init];
            break;
    } 
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s (length: %d)", __FUNCTION__, [data length]);
    switch (self.currentFlightWay) {
            
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
    
    switch (self.currentFlightWay) {
            
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



#pragma mark -


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self loadHECABoardDataAsJSONWithFlightWay:Arrival];
//    
//    self.workingIndicator.hidden = NO;
//    [self getCAIArrivalsDataFromJSON];
    
//    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadHECABoardDataAsJSONWithFlightWay:Arrival];
    
    self.workingIndicator.hidden = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.workingIndicator.hidden = NO;
    
//    arrivalQ = dispatch_queue_create("me.chehab.apps.heca", NULL);
//    dispatch_async(arrivalQ, ^{ [self getCAIArrivalsDataFromJSONAsync]; });
//    [self getCAIArrivalsDataFromJSON];
    
}

- (void)viewDidUnload
{
    [self setWorkingIndicator:nil];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.dumyData count];
    switch (self.currentFlightWay) {
            
        case Arrival:
            return [[self.arrivalBoard objectForKey:@"Arrival"] count];
            break;
            
            
        case Departure:
            return [[self.departureBoard objectForKey:@"departure"] count];
            break;
    } 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOGFUNCTION
    static NSString *CellIdentifier = @"flightSheetCell";
        
    flightSheet *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[flightSheet alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }

    NSMutableDictionary *fl = nil;
    switch (self.currentFlightWay) {
            
        case Arrival:
            fl = [[self.arrivalBoard objectForKey:@"Arrival"] objectAtIndex:[indexPath row]];
            break;
            
            
        case Departure:
            fl = [[self.departureBoard objectForKey:@"departure"] objectAtIndex:[indexPath row]];
            break;
    } 
    
    
    // Configure the cell...
    
    cell.airline.text = [fl objectForKey:@"airline"];
    cell.flightNumber.text = [fl objectForKey:@"flightno"];
    cell.location.text = [fl objectForKey:@"airport"];

    // IATA Airport Code if found
        //TODO:
    
    // ICAO Airport Code if found
        //TODO:

    
    // Flight Status
    if (![[fl objectForKey:@"status"] isEqualToString:@""]) {
        cell.flightStatus.text = [fl objectForKey:@"status"];
    }
    else {
        cell.flightStatus.text = @"N/A";
    }
    
    // Terminal Number
    if (![[fl objectForKey:@"terminal"] isEqualToString:@""] ) {
        cell.terminalNumber.text = [fl objectForKey:@"terminal"];
    }
    else {
        cell.terminalNumber.text = @"-";
    }
    
    // Hall Number
    if (![[fl objectForKey:@"hall"] isEqualToString:@""] ) {
        cell.hallNumber.text = [fl objectForKey:@"hall"];
    }
    else {
        cell.hallNumber.text = @"-";
    }
    
    
    // Setting Clock and its Modes.
    if (![[fl objectForKey:@"actual"] isEqualToString:@""] ) {
        cell.clock.text = [fl objectForKey:@"actual"];
        cell.clockMode.text = [fl objectForKey:@"status"];
    }
    else if (![[fl objectForKey:@"eta"] isEqualToString:@""] ) {
        cell.clock.text = [fl objectForKey:@"eta"];
        cell.clockMode.text = @"ETA";
    }
    else if (![[fl objectForKey:@"sch"] isEqualToString:@""] ) {
        cell.clock.text = [fl objectForKey:@"sch"];
        cell.clockMode.text = @"Schedualed";
    }
    //
    else {
        cell.clock.text = @"--:--";
        cell.clockMode.text = @"N/A";
    }

    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


@end
