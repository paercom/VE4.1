//
//  RangeStatsViewerViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/25/11.
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

#import "RangeStatsViewerViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"
#import "AdminMenuOptions.h"
#import "SizeConstants.h"

#import "RangeDataViewerViewController.h"


@implementation RangeStatsViewerViewController

@synthesize myTableView;
@synthesize dataDictionary;

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
    [dataDictionary release];
    [myTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadRangeDataViewer;{
    RangeDataViewerViewController *rangeDataViewer = [[RangeDataViewerViewController alloc] initWithNibName:@"RangeDataViewerViewController" bundle:nil];
    [self.navigationController pushViewController:rangeDataViewer animated:YES];
    [rangeDataViewer release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // get filepath for Plurality data set //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeStatsFileName];
    
    // load data from file into a local NSDictionary //
    //self.dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filepath];
    self.dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
    UIBarButtonItem *rightBarButton;
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:kDataViewerTitle style:UIBarButtonItemStylePlain target:self action:@selector(loadRangeDataViewer)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
    [rightBarButton release];
    
    self.title = kStatsViewerTitle;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataDictionary count] - 1;
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
    
    NSString  *candidateName = [[self.dataDictionary valueForKey:key] objectAtIndex:0];
    NSNumber *candidateTally = [((NSArray*)[self.dataDictionary valueForKey:key]) objectAtIndex:1];
    
    NSString *cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
    
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
