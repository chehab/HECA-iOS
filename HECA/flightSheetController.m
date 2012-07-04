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

@synthesize dumyData = _dumyData;
@synthesize workingIndicator = _workingIndicator;
@synthesize arrival = _arrival;

#pragma mark - GDC

dispatch_queue_t arrivalQ;

- (void) getCAIArrivalsDataFromJSONAsync
{
    NSURL *arrivalsJSONURL = [NSURL URLWithString:@"http://apis.chehab.me/HECA/?json=1&arrival=1"];    
    
    NSData *arrivalsJSONData = [[[NSString alloc] initWithContentsOfURL:arrivalsJSONURL] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    
    self.arrival = [NSJSONSerialization JSONObjectWithData:arrivalsJSONData options:NSJSONReadingMutableContainers error:&e];
    
    NSLog(@"JSON Serialization Completed");
    
    dispatch_async(dispatch_get_main_queue(), 
                   ^{ self.workingIndicator.hidden = YES; });
}

- (void) getCAIArrivalsDataFromJSON
{
    NSURL *arrivalsJSONURL = [NSURL URLWithString:@"http://apis.chehab.me/HECA/?json=1&arrival=1"];    
    
    NSData *arrivalsJSONData = [[[NSString alloc] initWithContentsOfURL:arrivalsJSONURL] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    
    self.arrival = [NSJSONSerialization JSONObjectWithData:arrivalsJSONData options:NSJSONReadingMutableContainers error:&e];
    
    NSLog(@"%@", self.arrival);
    
    NSLog(@"JSON Serialization Completed");
    
    self.workingIndicator.hidden = YES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.workingIndicator.hidden = NO;
    
//    arrivalQ = dispatch_queue_create("me.chehab.apps.heca", NULL);
//    dispatch_async(arrivalQ, ^{ [self getCAIArrivalsDataFromJSONAsync]; });
    [self getCAIArrivalsDataFromJSON];
    
    self.dumyData = [[NSArray alloc] initWithObjects:@"Chehab",
                     @"Mostafa",@"Hilmy",@"Abd El-Karim",
                     @"Abu Tariq",@"Batul",@"Zainab", nil];
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
    return [[self.arrival objectForKey:@"Arrival"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"flightSheetCell";
        
    flightSheet *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[flightSheet alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }

    NSMutableDictionary *fl = [[self.arrival objectForKey:@"Arrival"] objectAtIndex:[indexPath row]];
    // Configure the cell...
    if (![[fl objectForKey:@"airline"] isEqualToString:@""] ) {
        cell.airline.text = [fl objectForKey:@"airline"];
    }
    else {
        cell.airline.text = @"N/A";
    }
    
    if (![[fl objectForKey:@"flightno"] isEqualToString:@""] ) {
        cell.flightNumber.text = [fl objectForKey:@"flightno"];
    }
    else {
        cell.flightNumber.text = @"N/A";
    }
    
    if (![[fl objectForKey:@"airport"] isEqualToString:@""] ) {
        cell.cityCountry.text = [fl objectForKey:@"airport"];
    }
    else {
        cell.cityCountry.text = @"N/A";
    }
        
    if (![[fl objectForKey:@"status"] isEqualToString:@""]) {
        cell.flightStatus.text = [fl objectForKey:@"status"];
        NSLog(@"$> flightStatus = %@",[fl objectForKey:@"status"]);
    }
    else {
        cell.flightStatus.text = @"N/A";
        NSLog(@"$> flightStatus N/A");
    }
    
    if (![[fl objectForKey:@"terminal"] isEqualToString:@""] ) {
        cell.terminalGate.text = [fl objectForKey:@"terminal"];
    }
    else {
        cell.terminalGate.text = @"N/A";
    }
    
    if (![[fl objectForKey:@"eta"] isEqualToString:@""] ) {
        cell.clock.text = [fl objectForKey:@"eta"];
        cell.clockMode.text = @"ETA";
    }
    else if (![[fl objectForKey:@"sch"] isEqualToString:@""] ) {
        cell.clock.text = [fl objectForKey:@"sch"];
        cell.clockMode.text = @"Schedualed";
    }
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

@end
