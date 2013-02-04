//
//  ApprovalViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/28/11.
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

#import "ApprovalViewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"
#import "SizeConstants.h"

#import "CandidateApprovalCell.h"
#import "CandidateWriteInApprovalCell.h"
#import "ApprovalInstructionsViewController.h"

#import "MySingelton.h"

@interface ApprovalViewController()
@property (nonatomic, retain) NSMutableArray *dataModelArrayForSegmentValues;
@property (nonatomic, retain) NSMutableArray *cellReferenceList;
@property (nonatomic, retain) UITextField *candidateTextField;
@property (nonatomic, retain) UIPopoverController *instructionsPopover;
@property (nonatomic, retain) IBOutlet UIButton *instructionsButton;
@property (retain, nonatomic) IBOutlet UIButton *castMyVoteButton;
@property (retain, nonatomic) IBOutlet UIButton *undoButton;
@end

@implementation ApprovalViewController

@synthesize dataModelArrayForSegmentValues = _dataModelArrayForSegmentValues;
@synthesize candidateTextField = _candidateTextField;
@synthesize instructionsPopover = _instructionsPopover;
@synthesize instructionsButton = _instructionsButton;
@synthesize castMyVoteButton;
@synthesize undoButton;
@synthesize cellReferenceList;
@synthesize candidateList;
@synthesize myTableView;
@synthesize instructionsHeader;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.cellReferenceList = [NSMutableArray array];
        
        _candidateTextField = [UITextField alloc];
        
        self.candidateList = [NSMutableArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
        
        // Create the data model array to hold the segmented state values for each candidate on the list plus the write-in candidate //
        NSNumber *defaultSegmentedValue = [NSNumber numberWithInteger:UISegmentedControlNoSegment];
        _dataModelArrayForSegmentValues = [[NSMutableArray alloc] initWithCapacity:([self.candidateList count] + 1)];
        for (NSInteger i = 0; i < [self.candidateList count] + 1; i++) {
            [self.dataModelArrayForSegmentValues addObject:defaultSegmentedValue];
        }    
        
        // Check to see if Approval data file was created //
        BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalDataFileName]];
        // Check to see if Approval stats data file was created //
        BOOL doesYayStatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName]];
        BOOL doesNayStatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName]];
        // Check to see if IRV default messages data file was created //
        BOOL doesMessagesDataFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalMessagesFileName]];
        
        // if file does not exist then create it //
        if (doesDataFileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0], @"",@"", nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            // create and write to file //
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kApprovalDataFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Approval Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (doesYayStatsFileExist == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Yay Approval Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (doesNayStatsFileExist == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Nay Approval Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (doesMessagesDataFileExist == NO) {
            
            // create file with default messages //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:kDefaultHeaderMessage, kDefaultInstructionsMessage, nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d", [dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kApprovalMessagesFileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create kApprovalMessagesFileName Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }            
        }
    }
    return self;
}

- (void)dealloc
{
    [candidateList release];
    [_candidateTextField release];
    [myTableView release];
    [cellReferenceList release];
    [_instructionsButton release];
    [_instructionsPopover release];
    [_dataModelArrayForSegmentValues release];
    [instructionsHeader release];
    [castMyVoteButton release];
    [undoButton release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) updateApprovalDataFileForVoter:(NSNumber*)voterID CandidateList:(NSArray *)candidateListArray{
    
    // load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kApprovalDataFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    NSInteger endIndexOffset = 0;
    if ( [self isThereAwriteInCandidateInTheTextField] == NO) {
        endIndexOffset = 1;
    }
    
    for (NSInteger j = 0; j < [self.dataModelArrayForSegmentValues count] - endIndexOffset; j++) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:voterID];
        
        if (j == [self.dataModelArrayForSegmentValues count] - 1 ) {
            
            // there is a write-in item, else the last item is not a write-in //
            NSString *candidateName = [self.candidateTextField text];
            [array addObject:candidateName];
            
        } else {
            
            NSString *candidateName = [self.candidateList objectAtIndex:j];
            [array addObject:candidateName];
        }
        
        NSInteger storedValue = [[self.dataModelArrayForSegmentValues objectAtIndex:j] integerValue];
        
        NSString *segmentValueString = [NSString stringWithFormat:@"%i", storedValue];
        
        [array addObject:segmentValueString];
        
        // load the new array into the dictionary //
        [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
        
        [array release];
    }
    
    /*    
    // At this point the ballot requirements have been satisfied. //
    NSInteger cellOffsetIndex = 0;
    // If a write-in candidate does not exist, then increment the cellOffsetIndex by one since we want to skip the first cell in the table view, thus ignoring the voter's approval/disapproval rating for the void cell //
    NSString *writInCandidateName = [[self.cellReferenceList objectAtIndex:0] candidateTextField].text; // get write-in text //
    if ([writInCandidateName length] <= 0) {
        cellOffsetIndex += 1; // skip the first cell //
    }
    
    for (NSInteger j = 0 + cellOffsetIndex; j < [self.cellReferenceList count]; j++) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSString *candidateName;
        NSInteger candidateApprovalDisapprovalIndex = [[[self.cellReferenceList objectAtIndex:j] candidateApprovalDisapprovalButton] selectedSegmentIndex];
        NSString *candidateApprovalDisapprovalString = [[[self.cellReferenceList objectAtIndex:j] candidateApprovalDisapprovalButton] titleForSegmentAtIndex:candidateApprovalDisapprovalIndex];
        
        if ( j == 0) {
            // for write-in candidates //
            candidateName = [NSString stringWithString:writInCandidateName];
        } else {
            // for non write-in candidates //
            candidateName = [[self.cellReferenceList objectAtIndex:j] candidateNameLabel].text;
        }                     
        
        [array addObject:voterID];
        [array addObject:candidateName];
        [array addObject:candidateApprovalDisapprovalString];
        
        // load the new array into the dictionary //
        [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
        
        [array release];
        
    }
     */
    
    // save update Approval data to file //
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to Approval Data file. Voter's ballot was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
    
}

-(void) updateApprovalStatsfileForCandidate:(NSArray*)candidateListArray{
    
    // load the contents of the  current file into an NSDictionary //
    NSString *filepathYay = [FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName];
    NSString *filepathNay = [FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName];
    NSMutableDictionary *dictYay = [[NSMutableDictionary alloc] initWithContentsOfFile:filepathYay];
    NSMutableDictionary *dictNay = [[NSMutableDictionary alloc] initWithContentsOfFile:filepathNay];
    
    // if the write-in candidate cell is empty then we skip this cell when tallying results setting an offset //
    NSInteger endIndexOffset = 0;
    if ( [self isThereAwriteInCandidateInTheTextField] == NO ) {
        endIndexOffset = 1;
    }
    
    // go thru the candidats on a voters ballot and tally the number of times that each candidate was selected for each Yay or Nay (Approval or Disapproval) category //
    for (NSInteger j = 0; j < [self.dataModelArrayForSegmentValues count] - endIndexOffset; j++) {
        
        NSInteger candidateApprovalCategory = UISegmentedControlNoSegment; // assigns a negative one (-1) value //
        NSArray *array;
        NSString *key;
        NSString *candidateNameOnBallot;
        BOOL isCandidatInApprovalstatsFile = NO;
        
        // determine which category this candidate falls under by getting the segmented button index value //
        candidateApprovalCategory = [[self.dataModelArrayForSegmentValues objectAtIndex:j] integerValue];
        
        // get the next candidate on the ballot that is to be compared with archived candidates //
        if ( j == [self.dataModelArrayForSegmentValues count] -1 ) {
            candidateNameOnBallot = [self.candidateTextField text];
        } else {
            candidateNameOnBallot = [self.candidateList objectAtIndex:j]; 
        }
        
        switch (candidateApprovalCategory) {
            case 0:
                // check to see if candidate selected is already in the Approval Stats data file for a particular Category //
                for (NSInteger k = 0; k < [dictYay count]; k++) {
                    
                    key = [NSString stringWithFormat:@"%d",k];
                    array = [[NSArray alloc] initWithObjects:[[dictYay objectForKey:key] objectAtIndex:0], [[dictYay objectForKey:key] objectAtIndex:1], nil];
                    
                    if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateNameOnBallot] ) {
                        
                        // candidate was located in the Approval category stats file //
                        // increment Approval category count for this candidate //
                        NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                        NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictYay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                        
                        [dataUpdate release];
                        
                        isCandidatInApprovalstatsFile = YES;
                        
                        // exit for loop //
                        k = [dictYay count];
                    }// end if block //
                    [array release];
                }// end nested for block //
                
                // candidae was not located on the IRV Stats list, thus candidate is added to the stats list //
                if (isCandidatInApprovalstatsFile == NO) {
                    
                    NSInteger updatedCategoryValueCount = 1;
                    
                    NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                    
                    // save updated stats to dictionary //
                    [dictYay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictYay count]]];
                    
                    [dataUpdate release];
                }
                break;
            case 1:
                // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
                for (NSInteger k = 0; k < [dictNay count]; k++) {
                    
                    key = [NSString stringWithFormat:@"%d",k];
                    array = [[NSArray alloc] initWithObjects:[[dictNay objectForKey:key] objectAtIndex:0], [[dictNay objectForKey:key] objectAtIndex:1], nil];
                    
                    if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateNameOnBallot] ) {
                        
                        // candidate was located in the IRV category j stats file //
                        // increment Disapproval category count for this candidate //
                        NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                        NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictNay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                        
                        [dataUpdate release];
                        
                        isCandidatInApprovalstatsFile = YES;
                        
                        // exit for loop //
                        k = [dictNay count];
                    }// end if block //
                    [array release];
                }// end nested for block //
                // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                if (isCandidatInApprovalstatsFile == NO) {                   
                    
                    NSInteger updatedCategoryValueCount = 1;
                    
                    NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                    
                    // save updated stats to dictionary //
                    [dictNay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictNay count]]];
                    
                    [dataUpdate release];
                }
                break;
            default:
                break;
        }// end switch //        
        
    }
    
    /*
    // ------------------------------------------------------ //
    // if the write-in candidate cell is empty then we skip this cell when tallying results setting an offset //
    NSInteger cellOffsetIndex = 0;
    if ( [self.cellReferenceList count] > 0) {
        if ( [[[self.cellReferenceList objectAtIndex:0] candidateTextField].text length] == 0) {
            cellOffsetIndex += 1;
        }
    }
    
    // go thru the candidats on a voters ballot and tally the number of times that each candidate was selected for each Yay or Nay (Approval or Disapproval) category //
    for (NSInteger j = 0+cellOffsetIndex; j < [self.cellReferenceList count]; j++) {
        
        NSInteger candidateApprovalCategory = -1;
        NSArray *array;
        NSString *key;
        NSString *candidateNameOnBallot;
        BOOL isCandidatInApprovalstatsFile = NO;
        
        // determine which category this candidate falls under by geting the segmented button index value //
        candidateApprovalCategory = [[[self.cellReferenceList objectAtIndex:j] candidateApprovalDisapprovalButton] selectedSegmentIndex]; 
        
        // get the next candidate on the ballot to be compared with archived candidates //
        if (j == 0) {
            candidateNameOnBallot = [[self.cellReferenceList objectAtIndex:j] candidateTextField].text;
        } else {
            candidateNameOnBallot = [[self.cellReferenceList objectAtIndex:j] candidateNameLabel].text;
        }
        
        switch (candidateApprovalCategory) {
            case 0:
                // check to see if candidate selected is already in the Approval Stats data file for a particular Category //
                for (NSInteger k = 0; k < [dictYay count]; k++) {
                    
                    key = [NSString stringWithFormat:@"%d",k];
                    array = [[NSArray alloc] initWithObjects:[[dictYay objectForKey:key] objectAtIndex:0], [[dictYay objectForKey:key] objectAtIndex:1], nil];
                    
                    if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateNameOnBallot] ) {
                        
                        // candidate was located in the Approval category stats file //
                        // increment Approval category count for this candidate //
                        NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                        NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictYay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                        
                        [dataUpdate release];
                        
                        isCandidatInApprovalstatsFile = YES;
                        
                        // exit for loop //
                        k = [dictYay count];
                    }// end if block //
                    [array release];
                }// end nested for block //
                
                // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                if (isCandidatInApprovalstatsFile == NO) {
                    
                    NSInteger updatedCategoryValueCount = 1;
                    
                    NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                    
                    // save updated stats to dictionary //
                    [dictYay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictYay count]]];
                    
                    [dataUpdate release];
                }
                break;
            case 1:
                // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
                for (NSInteger k = 0; k < [dictNay count]; k++) {
                    
                    key = [NSString stringWithFormat:@"%d",k];
                    array = [[NSArray alloc] initWithObjects:[[dictNay objectForKey:key] objectAtIndex:0], [[dictNay objectForKey:key] objectAtIndex:1], nil];
                    
                    if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateNameOnBallot] ) {
                        
                        // candidate was located in the IRV category j stats file //
                        // increment Disapproval category count for this candidate //
                        NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                        NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictNay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                        
                        [dataUpdate release];
                        
                        isCandidatInApprovalstatsFile = YES;
                        
                        // exit for loop //
                        k = [dictNay count];
                    }// end if block //
                    [array release];
                }// end nested for block //
                // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                if (isCandidatInApprovalstatsFile == NO) {                   
                    
                    NSInteger updatedCategoryValueCount = 1;
                    
                    NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateNameOnBallot, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                    
                    // save updated stats to dictionary //
                    [dictNay setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictNay count]]];
                    
                    [dataUpdate release];
                }
                break;
            default:
                break;
        }// end switch //
        
    }// end for block //
    */
    
    // save update IRV data to file //
    BOOL fileWriteStatusApproval = [dictYay writeToFile:filepathYay atomically:YES];
    BOOL fileWriteStatusDisapproval = [dictNay writeToFile:filepathNay atomically:YES];
    
    if (fileWriteStatusApproval == NO || fileWriteStatusDisapproval == NO ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to Approval Stats file. Voter's ballot stats was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dictYay release];
    [dictNay release];
    
}

-(BOOL) isThereAwriteInCandidateInTheTextField{
    
    // if the textfield string is greater than zero return true else return false //
    if ([[self.candidateTextField text] length] > 0) {
        return YES;
    }
    
    return NO;
    
    /*
    // test to see if the text field string length is greater than zero //
    if ( [[[self.cellReferenceList objectAtIndex:0] candidateTextField].text length] > 0 ) {
        
        return YES;
    }
    
    return NO;
     */
}

-(BOOL) isThewriteInCandidateAlreadyOnTheCandidateList{
    
    // test to see if the entered text in the write-in candidate field matches any of the displayed candidates //
    
    // get write-in item //
    NSString *writeInItem = [self.candidateTextField text];
    
    // increment thru the pre-selected list of items and look for a match with the write-in item //
    for (NSString *item in self.candidateList) {
        if ([writeInItem isEqualToString:item]) {
            return YES;
        }
    }
    return NO;
    
    /*
    // get writeIn candidate name //
    NSString *writeInCandidate = [[self.cellReferenceList objectAtIndex:0] candidateTextField].text;
    
    for (NSInteger j = 1; j < [self.cellReferenceList count]; j++) {
        
        // get listed candidate name //
        NSString *listedCandidate = [[self.cellReferenceList objectAtIndex:j] candidateNameLabel].text;
        
        if ( [writeInCandidate isEqualToString:listedCandidate] ) {
            
            // writeIn candidate matches an existing listed candidate //
            return YES;
        }
    }    
    return NO;
     */
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // handle alert view button presses for candidate confirmation only //
    if ([alertView.title isEqualToString:kAlerViewCandidateCastConfirmationtitle]) {
        if (buttonIndex == 1) {
            // Candidate confirmed by voter //
            
            // get current voter ID //
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
            NSNumber *voterID = [array objectAtIndex:0];
            
            // update range data file //
            [self updateApprovalDataFileForVoter:voterID CandidateList:self.candidateList];
            
            // update range stats data file //
            [self updateApprovalStatsfileForCandidate:self.candidateList];
            
            // update voter's completed experiment flag //
            [FileHandle toggleFlagForCompletedElectoralExperiment:kApprovalNum];
            
            [array release];
            
            //*************************************************************
            // if the experiment is active than remove this experiment from a master list since it has been completed //
            experimentAdministrator = [MySingelton sharedObject];
            if ( [experimentAdministrator getIsExperimentActive] ) {
                
                // remove this experiment from list of uncompleted experiments //
                NSString *thisExperiment = kApproval;
                NSInteger j = 0;
                for (; j < [experimentAdministrator->experimentsNotCompletedList count]; j++) {
                    
                    if ([[experimentAdministrator->experimentsNotCompletedList objectAtIndex:j] isEqualToString:thisExperiment]) {
                        
                        [experimentAdministrator->experimentsNotCompletedList removeObjectAtIndex:j];
                        
                    }// end if //
                }// end for //
                
                // pop this view //
                [self.navigationController popViewControllerAnimated:YES];
                self.navigationItem.hidesBackButton = NO;        
            } else {
                
                // pop this view //
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }
}

#pragma mark - User Action Buttons

- (IBAction)instructionsButton:(id)sender {
    
    CGRect instructionsButtonRect = [self.instructionsButton frame];
    
    [self.instructionsPopover presentPopoverFromRect:instructionsButtonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(kPopoverContentSizeWidth, kPopoverContentSizeHeight)];
}

-(IBAction) undoButton:(id)sender{
    
    // set all table cells to their default values //
    
    if ([self.cellReferenceList count] > 0) {
        [[[self.cellReferenceList objectAtIndex:0] candidateTextField] setText:nil];
        self.candidateTextField.text = nil;
    }
    
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.myTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    NSNumber *defaultSegmentValue = [NSNumber numberWithInteger:UISegmentedControlNoSegment];
    
    for (NSInteger i = 0; i < [self.dataModelArrayForSegmentValues count]; i++) {
        [self.dataModelArrayForSegmentValues replaceObjectAtIndex:i withObject:defaultSegmentValue];
    }
    
    // get array with the visible tableView cells and animate the segmented buttons back into their default position //
    NSArray *visibleCellsArray = [self.myTableView visibleCells];
    
    for (id cell in visibleCellsArray) {
        [[cell candidateApprovalDisapprovalButton] setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    
    /*
    //------------------------------------------------------//
    for (NSInteger j = 0; j < [self.cellReferenceList count]; j++) {
        if (j == 0) {
            [[self.cellReferenceList objectAtIndex:j] candidateTextField].text = nil;
        }
        [[[self.cellReferenceList objectAtIndex:j] candidateApprovalDisapprovalButton] setSelectedSegmentIndex:-1]; 
    }
     */
    
}

-(IBAction) castVoteButton:(id)sender{
    
    // test for duplicate voter entry //
    BOOL isThereAduplicateVoterEntry = NO;
    if ([self isThereAwriteInCandidateInTheTextField]) {
        
        isThereAduplicateVoterEntry = [self isThewriteInCandidateAlreadyOnTheCandidateList];
        
        /*
        NSLog(@"There is a write-in candidate in the TextField: %@", [self.candidateTextField text]);
        if (isThereAduplicateVoterEntry) {
            NSLog(@"And it's a dubplicate");
        }
         */
    }
    
    // if a write in duplicate entry is found inform the user of this fact and do not continue... //
    if (isThereAduplicateVoterEntry) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Entry" message:@"This write-in item is already on the given list of items. Please make your selecttion from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    } else  {
        
        // if a segmented button has not been selected by the voter then inform them of this fact -- all segmented button must be selected //
        BOOL isThereAsegmentedButtonThatHasNotBeenSelected = NO;
        BOOL isThereAsegmentedButtonThatHasAdifferentSelectionState = NO;
        
        // if the write-in item is blank then ignore the last segmented value on the list, so we setup an offset to accomplish this //
        NSInteger endIndexOffset = 0;
        if ( [self isThereAwriteInCandidateInTheTextField] == YES && [self isThewriteInCandidateAlreadyOnTheCandidateList] == NO ) {
            endIndexOffset = 0;
        } else if ( [self isThewriteInCandidateAlreadyOnTheCandidateList] == NO ){
            endIndexOffset = 1;
        }
        
        // Increment thru the data array that holds the state values for each segmented button to determine if all the segments have been selected //
        for (NSInteger j = 0; j < [self.dataModelArrayForSegmentValues count] - endIndexOffset; j++) {
            // if a segmented button select index is -1 then it has not been selected //
            NSInteger segmentState = [[self.dataModelArrayForSegmentValues objectAtIndex:j] integerValue];
            if (segmentState == UISegmentedControlNoSegment) {
                isThereAsegmentedButtonThatHasNotBeenSelected = YES;
                
                // exit for loop //
                j = [self.dataModelArrayForSegmentValues count];
            }
        }
        
        /*
        for (NSNumber *number in self.dataModelArrayForSegmentValues) {
            NSLog(@"State Values: %@", number);
        }
        NSLog(@"Is There A Segment Button That Has Not Been Selected %i",isThereAsegmentedButtonThatHasNotBeenSelected);
        */ 
         
        // if a segmented button is found to have not been selected, inform the user of this fact, else proceed to casting the voter's ballot //
        if (isThereAsegmentedButtonThatHasNotBeenSelected) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voter Action Required" message:@"Please, either Approve of Disapprove of each item before casting your vote. If you approve or disapprove of an item, then select the appropriate button segment that is displayed to the left of each item's name. You may also write-in an item by selecting the \"create your own unique entry\" row and Approve or Disapprove of it along with every item in the list, or Approve or Disapprove of each item from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            
        } else {
            // test to see if at least one of the selected segments is different than the other segments //
            // We need at least 2 segments for this test, else ... //
            if ( [self.dataModelArrayForSegmentValues count] - endIndexOffset >= 2) {
                // get the selection index of the first segment and compare it to the rest //
                NSInteger firstSegmentSelectionIndex = [[self.dataModelArrayForSegmentValues objectAtIndex:0] integerValue];
                NSInteger otherSegmentSelectionIndex;
                
                for (NSInteger j = 1; j < [self.dataModelArrayForSegmentValues count] - endIndexOffset; j++) {
                    
                    otherSegmentSelectionIndex = [[self.dataModelArrayForSegmentValues objectAtIndex:j] integerValue];
                    if ( firstSegmentSelectionIndex != otherSegmentSelectionIndex ) {
                        isThereAsegmentedButtonThatHasAdifferentSelectionState = YES;
                    }
                }
            } else {
                // since there is only one cell that is relavent this logical check defaults to this value //
                isThereAsegmentedButtonThatHasAdifferentSelectionState = YES;
            }
            
            if (isThereAsegmentedButtonThatHasAdifferentSelectionState == NO ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voter Action Required" message:@"Please select at least one candidate that has a different Approval or Disapproval rating than the other candidates."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            } else {
                
                // preliminary directives have been satisfied now we can proceed to saving the voters ballot //
                // ***************************************************************************************** //
                // prompt the voter to accept and record ballot //
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:@"Cast your vote?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                [alert show];
                [alert release];
                
            }
        }
        
    }
}

#pragma mark - keyboard 

- (void)doneEditing: (id) sender {
    [sender resignFirstResponder];
}

- (void)keyboardDidShow: (id)sender {
    
    [self.myTableView setScrollEnabled:NO];
    
    self.candidateTextField = [[self.cellReferenceList objectAtIndex:0] candidateTextField];
    
    // since we are potentially deselecting a row selected by the user we will clear the candidateTextField //
    [self.candidateTextField setText:@""];    
    
    SEL doneWithKeyboard = @selector(doneEditing:);
    [self.candidateTextField addTarget:self action:doneWithKeyboard forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // get the index value of the last row in the tableView //
    NSInteger indexValueOfLastRow = [self.myTableView numberOfRowsInSection:0] - 1;    
    NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:indexValueOfLastRow inSection:0];
    
    NSInteger heightOffsetValue = 0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        heightOffsetValue = kTableViewHeightOffsetValue_LandScapeMode;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        heightOffsetValue = kTableViewHeightOffsetValue_PortraitMode;
    }
    
    // change the height of the table view to make room for the keyboard //
    CGFloat xOrigin = self.myTableView.frame.origin.x;
    CGFloat yOrigin = self.myTableView.frame.origin.y;
    CGFloat wSize = self.myTableView.frame.size.width;
    CGFloat hSize = self.myTableView.frame.size.height - heightOffsetValue;
    CGRect tempRect = CGRectMake(xOrigin, yOrigin, wSize, hSize);
    [self.myTableView setFrame:tempRect];
    [self.myTableView setBounds:tempRect];
    
    //NSLog(@"keyboardDidShow Rect: %f, %f, %f, %f", tempRect.origin.x, tempRect.origin.y, tempRect.size.width, tempRect.size.height);
    
    [self.myTableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];  
    
    // programmatically select last row in the tableView //
    //[self.myTableView selectRowAtIndexPath:lastRowIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];   
    
}

- (void)keyboardWillHide: (id)sender {
    
    // get the index value of the last row in the tableView //
    NSInteger indexValueOfLastRow = [self.myTableView numberOfRowsInSection:0] - 1;    
    NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:indexValueOfLastRow inSection:0];
    
    // store the textField entry in a local uitextField //
    if ([self.cellReferenceList count] > 0) {
        NSString *userEntry = [[(CandidateWriteInApprovalCell*)[self.cellReferenceList objectAtIndex:0] candidateTextField] text];
        [self.candidateTextField setText:userEntry];
        //NSLog(@"You typed: %@",[self.candidateTextField text]);
    }    
    
    NSInteger heightOffsetValue = 0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        heightOffsetValue = kTableViewHeightOffsetValue_LandScapeMode;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        heightOffsetValue = kTableViewHeightOffsetValue_PortraitMode;
    }
    
    // change the height of the table view to make room for the keyboard //
    CGFloat xOrigin = self.myTableView.frame.origin.x;
    CGFloat yOrigin = self.myTableView.frame.origin.y;
    CGFloat wSize = self.myTableView.frame.size.width;
    CGFloat hSize = self.myTableView.frame.size.height + heightOffsetValue;
    CGRect tempRect = CGRectMake(xOrigin, yOrigin, wSize, hSize);
    [self.myTableView setFrame:tempRect];
    [self.myTableView setBounds:tempRect];
    
    //NSLog(@"keyboardWillHide Rect: %f, %f, %f, %f", tempRect.origin.x, tempRect.origin.y, tempRect.size.width, tempRect.size.height);
    
    [self.myTableView setScrollEnabled:YES];
    [self.myTableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    //[self.myTableView reloadData];
            
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = kApproval;
    
    UIImage *stretchableRedButtonImageNormal = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIImage *stretchableWhiteButtonImageNormal = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    
    [self.castMyVoteButton setBackgroundImage:stretchableRedButtonImageNormal forState:UIControlStateNormal];       
    [self.undoButton setBackgroundImage:stretchableWhiteButtonImageNormal forState:UIControlStateNormal];
    [self.instructionsButton setBackgroundImage:stretchableWhiteButtonImageNormal forState:UIControlStateNormal];
    
    [self.myTableView setAllowsSelection:NO];
    
    //*************************************************************
    experimentAdministrator = [MySingelton sharedObject];
    
    // if the experiment is running then hide the back button... //
    if ( [experimentAdministrator getIsExperimentActive] ) {
        self.navigationItem.hidesBackButton = YES;
    }
    //*************************************************************
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // display the popover with instructions on how to utilize the menus //
    ApprovalInstructionsViewController *viewCont = [[ApprovalInstructionsViewController alloc] initWithNibName:@"ApprovalInstructionsViewController" bundle:nil];
    [viewCont setPopoverDelegate:self];
    
    _instructionsPopover = [[UIPopoverController alloc] initWithContentViewController:viewCont];
    [self.instructionsPopover setDelegate:self];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(0, 0)];
    
    [viewCont release];
        
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setInstructionsHeader:nil];
    [self setCastMyVoteButton:nil];
    [self setUndoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kApprovalMessagesFileName];
    
    // load data from file into a local NSDictionary //
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
    NSString *key = kSingleElementKey;
    
    NSString *infoHeader;
    
    //NSLog(@"Size: %i",[((NSArray*)[dataDictionary valueForKey:key]) count]);
    
    if ([((NSArray*)[dataDictionary valueForKey:key]) count] == 0) {
        infoHeader = kDefaultHeaderMessage;
    } else {
        infoHeader = [((NSArray*)[dataDictionary valueForKey:key]) objectAtIndex:0];
    }

    
    //NSLog(@"Block:%@",infoBlock);
    //NSLog(@"Self:%@, Header:%@",self,infoHeader);
    
    [self.instructionsHeader setText:infoHeader];
    [self.instructionsHeader setFont:[UIFont systemFontOfSize:kFontSizeInViewHeader]];
    //[self.instructionsBlock setText:infoBlock];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect instructionsButtonRect = [self.instructionsButton frame];
    
    [self.instructionsPopover presentPopoverFromRect:instructionsButtonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(kPopoverContentSizeWidth, kPopoverContentSizeHeight)];
    
    [super viewDidAppear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if ([self.instructionsPopover isPopoverVisible]) {
        
        [self.instructionsPopover dismissPopoverAnimated:NO]; 
        
        CGRect instructionsButtonRect = [self.instructionsButton frame];
        
        [self.instructionsPopover presentPopoverFromRect:instructionsButtonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [self.instructionsPopover setPopoverContentSize:CGSizeMake(kPopoverContentSizeWidth, kPopoverContentSizeHeight)];
    }    
    
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
    return [candidateList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellCandidate = @"ApprovalCellCandidate";
    static NSString *CellCandidateWriteIn = @"ApprovalCellCandidateWriteIn";
    
    CandidateApprovalCell *candidateCell = nil;
    CandidateWriteInApprovalCell *candidateWritInCell = nil;
    
    // store last row in section //
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:indexPath.section];
    if (lastRowIndex != 0) {
        lastRowIndex -= 1;
    }
    
    if (indexPath.row == lastRowIndex) {
        candidateWritInCell = (CandidateWriteInApprovalCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidateWriteIn];
        if (candidateWritInCell != nil) {
            return candidateWritInCell;
        }
    } else {
        candidateCell = (CandidateApprovalCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
        if (candidateCell != nil) {
            return candidateCell;
        }
    }
    
    NSArray *cel;
    if ( indexPath.row == lastRowIndex && candidateWritInCell == nil ) {
        
        cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateWriteInApprovalCell" owner:self options:nil];
        candidateWritInCell = (CandidateWriteInApprovalCell*)[cel objectAtIndex:0];
        
        // assign a reference pointer to this cell from an array //
        [self.cellReferenceList addObject:candidateWritInCell];
        
        // set a unique tag value for each cell //
        [candidateWritInCell setTag:indexPath.row];
        [candidateWritInCell setDelegate:self];
        candidateWritInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
        
        return candidateWritInCell;
    } else if (indexPath.row != lastRowIndex && candidateCell == nil ){
        
        cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateApprovalCell" owner:self options:nil];
        candidateCell = (CandidateApprovalCell*)[cel objectAtIndex:0];
        
        // assign to each of these cells a unique canidate name //
        [candidateCell candidateNameLabel].text = [candidateList objectAtIndex:indexPath.row];
        
        // set an unique tag value for each cell //
        [candidateCell setTag:indexPath.row];
        [candidateCell setDelegate:self];
        candidateCell.candidateNameLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
        
        return candidateCell;        
    }
    
    /*
    //--------------------------------------------------------//
    if (indexPath.row == 0) {
        candidateWritInCell = (CandidateWriteInApprovalCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidateWriteIn];
    } else {
        candidateCell = (CandidateApprovalCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
    }
        
    if (candidateCell == nil || candidateWritInCell == nil ) {
        
        NSArray *cel;
        if (indexPath.row == 0 ) {
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateWriteInApprovalCell" owner:self options:nil];
            candidateWritInCell = (CandidateWriteInApprovalCell*)[cel objectAtIndex:0];
            
            // assign a reference pointer to each from an array //
            [self.cellReferenceList addObject:candidateWritInCell];
            
            candidateWritInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return candidateWritInCell;
        } else {
                       
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateApprovalCell" owner:self options:nil];
            candidateCell = (CandidateApprovalCell*)[cel objectAtIndex:0];
            
            // assign a reference pointer to each from an array //
            [self.cellReferenceList addObject:candidateCell];
            
            // assign to each of these cells a unique canidate name //
            [candidateCell candidateNameLabel].text = [candidateList objectAtIndex:indexPath.row-1];
            
            candidateCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return candidateCell;
        }
    }
     */
    //NSLog(@"Returning 3: %@",candidateCell);
    // you should never get here, if you do, you got issues!!! //    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableViewCellRowHeight;   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}

#pragma mark - Candidate Cell delegate

- (void) valueOnSegmentedButtonInStandardCellDidChange:(CandidateApprovalCell*)forSegment
{
    //NSLog(@"Slider Value Changed with TAG: %i",[forSlider tag]);
        
    NSNumber *newSegmentValue = [NSNumber numberWithInteger:[[forSegment candidateApprovalDisapprovalButton] selectedSegmentIndex]];    
    [self.dataModelArrayForSegmentValues replaceObjectAtIndex:[forSegment tag] withObject:newSegmentValue];
    
    /*
    for (NSNumber *number in self.dataModelArrayForSegmentValues) {
        NSLog(@"Segment State: %i", [number integerValue]);
    }
     */
}

- (void) valueOnSegmentedButtonInWriteInCellDidChange:(CandidateWriteInApprovalCell*)forSegment
{
    NSNumber *newSegmentValue = [NSNumber numberWithInteger:[[forSegment candidateApprovalDisapprovalButton] selectedSegmentIndex]];    
    [self.dataModelArrayForSegmentValues replaceObjectAtIndex:[forSegment tag] withObject:newSegmentValue];
    
    /*
    for (NSNumber *number in self.dataModelArrayForSegmentValues) {
        NSLog(@"Segment State: %i", [number integerValue]);
    }
     */
}

#pragma mark - Approval popover view delegate

- (void)approvalPopoverDidAppear:(ApprovalInstructionsViewController *)popoverViewController {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.instructionsHeader setAlpha:0.15];
    [UIView commitAnimations];
}
- (void)approvalPopoverDidDisappear:(ApprovalInstructionsViewController *)popoverViewController{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.instructionsHeader setAlpha:1.0];
    [UIView commitAnimations];
}

@end
