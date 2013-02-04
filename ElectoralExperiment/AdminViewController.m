//
//  AdminViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/19/11.
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

#import "AdminViewController.h"
#import "CreateCandidateListViewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"
#import "SizeConstants.h"

#import "PluralityDataViewerViewController.h"
#import "PluralityStatsViewerViewController.h"

#import "RangeDataViewerViewController.h"
#import "RangeStatsViewerViewController.h"

#import "IRVdataViewerViewController.h"
#import "IRVstatsViewerViewController.h"

#import "ApprovalDataViewerViewController.h"
#import "ApprovalStatsViewerViewController.h"

#import "UserDemographicTableViewController.h"

#import "IRVmessagesViewController.h"
#import "ApprovalMessagesViewController.h"
#import "RangeMessagesViewController.h"
#import "PluralityMessagesViewController.h"

#import "EmailComposerViewController.h"


@implementation AdminViewController

@synthesize adminMenuOptionList;
@synthesize myTableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [adminMenuOptionList release];
    [myTableView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
            
    self.adminMenuOptionList = [NSArray arrayWithObjects: kMenuOptionOne, kMenuOptionTwo, kMenuOptionThree, kMenuOptionFour, kMenuOptionFive, kMenuOptionSix, kMenuOptionSeven, kMenuOptionEight, kMenuOptionNine, kMenuOptionTen, kMenuOptionEleven, kMenuOptionTwelve, nil];

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
    self.adminMenuOptionList = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.title = kAdminMenuTitle;
    
    // check for candidate list file //
    if ([FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]]) {
        // File Exists //
    } else {
        // File Does Not Exist //
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action Required" message:@"Please create file for Candidate List." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        [alert release];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [adminMenuOptionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
    
    cell.textLabel.text = [adminMenuOptionList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableViewCellRowHeight;   
}
 */

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        BOOL IDfileExists;
        
        // delete candidate file and all other files //
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityDataFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kPluralityDataFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityStatsFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kPluralityStatsFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeDataFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kRangeDataFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeStatsFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kRangeStatsFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVdataFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kIRVdataFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalDataFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kApprovalDataFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kUserDemographicDataBaseName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kUserDemographicDataBaseName]];
        
        /*
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityMessagesFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kPluralityMessagesFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVMessagesFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kIRVMessagesFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeMessagesFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kRangeMessagesFileName]];
        
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalMessagesFileName]];
        if (IDfileExists) [FileHandle deleteFileWithPath:[FileHandle getFilePathForFileWithName:kApprovalMessagesFileName]];
         */
        
        // Check to see if voter ID used log file exists -- at this stage this file should have been deleted! //
        IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
        
        // if file does not exist then create //
        if (IDfileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSInteger voterID = 1;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:[NSNumber numberWithUnsignedInt:voterID]];
            
            // also create binary slots indicating which voting experiment the current voter has completed //
            for (integer_t i = 0; i < kNumberOfVoterExperiments; i++) {
                [array addObject:[NSNumber numberWithUnsignedInt:0]];
            }
            
            [array writeToFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName] atomically:YES];
            [array release];
            
            if ([FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]] == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Current Voter ID log file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
            
        }
        
        [self.myTableView reloadData];
        
    } else if (buttonIndex == -1 ){
        
        // cancel button pressed //
        [self.myTableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check for candidate list file -- if file does not exist and the selection does not create a candidate file then ignore all other selection //
    if (![FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]] &&
        [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionOne] ) {
        
        // File Does not Exist and Admin wants to create Candidate List file //
        
        CreateCandidateListViewController *candidateListViewController = [[CreateCandidateListViewController alloc] initWithNibName:@"CreateCandidateListViewController" bundle:nil];
        [self.navigationController pushViewController:candidateListViewController animated:YES];
        [candidateListViewController release];
        
        
    } else if ([FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]] &&
               [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionOne] ){
        
        // File Does Exist and Admin wants to create a Candidate list file //
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action Required" message:@"Please delete file for Candidate List before creating a new Candidate List." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        [alert release];
    } else if ([FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]] &&
               ![((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionOne] ){
        
        // File Does Exist and Admin wants to perform some other task other than create a candidate list file //
        
        if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionTwo] ) {
            
            // user requested to delete candidate list file //
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Files?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete The Data Files." otherButtonTitles:nil];
            [actionSheet showInView:self.view];
            [actionSheet release];
        
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionThree] ){
            
            // user requested to view plurality data sets //
            PluralityStatsViewerViewController *pluralityData = [[PluralityStatsViewerViewController alloc] initWithNibName:@"PluralityStatsViewerViewController" bundle:nil];
            [self.navigationController pushViewController:pluralityData animated:YES];
            [pluralityData release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionFour] ){
            
            // user requested to view range data sets //
            RangeStatsViewerViewController *rangeData = [[RangeStatsViewerViewController alloc] initWithNibName:@"RangeStatsViewerViewController" bundle:nil];
            [self.navigationController pushViewController:rangeData animated:YES];
            [rangeData release];
        
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionFive] ){
            
            // user requested to view irv data sets //
            IRVstatsViewerViewController *irvStats = [[IRVstatsViewerViewController alloc] initWithNibName:@"IRVstatsViewerViewController" bundle:nil];
            [self.navigationController pushViewController:irvStats animated:YES];
            [irvStats release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionSix] ){
            
            // user requested to view Approval data sets //
            ApprovalStatsViewerViewController *approvalStats = [[ApprovalStatsViewerViewController alloc] initWithNibName:@"ApprovalStatsViewerViewController" bundle:nil];
            [self.navigationController pushViewController:approvalStats animated:YES];
            [approvalStats release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionSeven] ){
            
            // user requested to view irv user messages //
            IRVmessagesViewController *irv = [[IRVmessagesViewController alloc] initWithNibName:@"IRVmessagesViewController" bundle:nil];
            [self.navigationController pushViewController:irv animated:YES];
            [irv release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionEight] ){
            
            // user requested to view approval messages //
            ApprovalMessagesViewController *approval = [[ApprovalMessagesViewController alloc] initWithNibName:@"ApprovalMessagesViewController" bundle:nil];
            [self.navigationController pushViewController:approval animated:YES];
            [approval release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionNine] ){
            
            // user requested to view range messages //
            RangeMessagesViewController *range = [[RangeMessagesViewController alloc] initWithNibName:@"RangeMessagesViewController" bundle:nil];
            [self.navigationController pushViewController:range animated:YES];
            [range release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionTen] ){
            
            // user requesetd to view plurality messages //
            PluralityMessagesViewController *plurality = [[PluralityMessagesViewController alloc] initWithNibName:@"PluralityMessagesViewController" bundle:nil];
            [self.navigationController pushViewController:plurality animated:YES];
            [plurality release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionEleven] ){
            
            // user requesetd emailComposer //
            EmailComposerViewController *emailComposer = [[EmailComposerViewController alloc] initWithNibName:@"EmailComposerViewController" bundle:nil];
            [self.navigationController pushViewController:emailComposer animated:YES];
            [emailComposer release];
            
        } else if ( [((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionTwelve] ){
            
            // user requested to view the User Demographic Data Base //
            UserDemographicTableViewController *demographic = [[UserDemographicTableViewController alloc] initWithNibName:@"UserDemographicTableViewController" bundle:nil];
            [self.navigationController pushViewController:demographic animated:YES];
            [demographic release];
        }
        
    } else if (![FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]] &&
               ![((NSString*)[self.adminMenuOptionList objectAtIndex:indexPath.row]) isEqualToString:kMenuOptionOne] ){
        
        // File Does NOT Exist and Admin wants to perform some other task other than create a candidate list file //
        
    }
}

@end
