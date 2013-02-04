//
//  ApprovalStatsViewerViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/31/11.
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

#import "ApprovalStatsViewerViewController.h"
#import "ApprovalDataViewerViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"
#import "AdminMenuOptions.h"
#import "SizeConstants.h"

#import "MySingelton.h"

@implementation ApprovalStatsViewerViewController

@synthesize myTableView;
@synthesize dataApprovalDictionary, dataDisapprovalDictionary;

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
    [dataApprovalDictionary release];
    [dataDisapprovalDictionary release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadApprovaldataViewer;{
    ApprovalDataViewerViewController *approvalDataViewer = [[ApprovalDataViewerViewController alloc] initWithNibName:@"ApprovalDataViewerViewController" bundle:nil];
    [self.navigationController pushViewController:approvalDataViewer animated:YES];
    [approvalDataViewer release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    // get filepath for Plurality data set //
    NSString *filepathApproval = [FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName];
    NSString *filepathDisapproval = [FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName];
    
    // load data from file into a local NSDictionary //
    self.dataApprovalDictionary = [NSDictionary dictionaryWithContentsOfFile:filepathApproval];
    self.dataDisapprovalDictionary = [NSDictionary dictionaryWithContentsOfFile:filepathDisapproval];
    
    UIBarButtonItem *rightBarButton;
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:kDataViewerTitle style:UIBarButtonItemStylePlain target:self action:@selector(loadApprovaldataViewer)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Approval Voting Tallies";
    }
    if (section == 1) {
        return @"Disapproval Voting Tallies";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.dataApprovalDictionary count] - 1;
    } 
    return [self.dataDisapprovalDictionary count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *key = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    
    NSString *candidateName = @"";
    NSNumber *candidateTally;    
    NSString *cellData = @"";
    
    switch (indexPath.section) {
        case 0:
            candidateName = [[self.dataApprovalDictionary valueForKey:key] objectAtIndex:0];
            candidateTally = [((NSArray*)[self.dataApprovalDictionary valueForKey:key]) objectAtIndex:1];
            
            cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
            break;
        case 1:
            candidateName = [[self.dataDisapprovalDictionary valueForKey:key] objectAtIndex:0];
            candidateTally = [((NSArray*)[self.dataDisapprovalDictionary valueForKey:key]) objectAtIndex:1];
            
            cellData = [NSString stringWithFormat:@"Tally: %-7d   Candidate: %@",[candidateTally unsignedIntegerValue], candidateName];
            break;            
        default:
            break;
    }
    
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
    
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
