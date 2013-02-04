//
//  IRVstatsViewerViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/27/11.
//  Copyright 2011 Stefan Agapie. All rights reserved.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "IRVstatsViewerViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"
#import "AdminMenuOptions.h"
#import "SizeConstants.h"

#import "IRVdataViewerViewController.h"

#import "MySingelton.h"


@implementation IRVstatsViewerViewController

@synthesize myTableView;
@synthesize dataCat1Dictionary, dataCat2Dictionary, dataCat3Dictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [myTableView release];
    [dataCat1Dictionary release];
    [dataCat2Dictionary release];
    [dataCat3Dictionary release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadIRVdataViewer;{
    IRVdataViewerViewController *irvDataViewer = [[IRVdataViewerViewController alloc] initWithNibName:@"IRVdataViewerViewController" bundle:nil];
    [self.navigationController pushViewController:irvDataViewer animated:YES];
    [irvDataViewer release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    // get filepath for IRV data set //
    NSString *filepathCat1 = [FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName];
    NSString *filepathCat2 = [FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName];
    NSString *filepathCat3 = [FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName];
    
    // load data from file into a local NSDictionary //
    //self.dataCat1Dictionary = [[NSDictionary alloc] initWithContentsOfFile:filepathCat1];
    //self.dataCat2Dictionary = [[NSDictionary alloc] initWithContentsOfFile:filepathCat2];
    //self.dataCat3Dictionary = [[NSDictionary alloc] initWithContentsOfFile:filepathCat3];
    self.dataCat1Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat1];
    self.dataCat2Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat2];
    self.dataCat3Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat3];
    
    UIBarButtonItem *rightBarButton;
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:kDataViewerTitle style:UIBarButtonItemStylePlain target:self action:@selector(loadIRVdataViewer)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:YES];
    [rightBarButton release];
    
    self.title = kStatsViewerTitle;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"Category 1 Voting Tallies";
    }
    if (section == 1) {
        return @"Category 2 Voting Tallies";
    }
    if (section == 2) {
        return @"Category 3 Voting Tallies";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.dataCat1Dictionary count] - 1;
    } else if (section == 1){
        return [self.dataCat2Dictionary count] - 1;
    } 
    return [self.dataCat3Dictionary count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
    
    NSString *key = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    
    NSString *candidateName = @"";
    NSNumber *candidateTally;    
    NSString *cellData = @"";
    
    switch (indexPath.section) {
        case 0:
            candidateName = [[self.dataCat1Dictionary valueForKey:key] objectAtIndex:0];
            candidateTally = [((NSArray*)[self.dataCat1Dictionary valueForKey:key]) objectAtIndex:1];
            
            cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
            break;
        case 1:
            candidateName = [[self.dataCat2Dictionary valueForKey:key] objectAtIndex:0];
            candidateTally = [((NSArray*)[self.dataCat2Dictionary valueForKey:key]) objectAtIndex:1];
            
            cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
            break;
        case 2:
            candidateName = [[self.dataCat3Dictionary valueForKey:key] objectAtIndex:0];
            candidateTally = [((NSArray*)[self.dataCat3Dictionary valueForKey:key]) objectAtIndex:1];
            
            cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
            break;            
        default:
            break;
    }
        
    cell.textLabel.text = cellData;
    
    return cell;
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 
 return kTableViewCellRowHeight;   
 }
 */


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView reloadData];
    
}

@end
