//
//  IRVviewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/26/11.
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

#import "IRVviewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"
#import "SizeConstants.h"

#import "CandidateCell.h"
#import "CandidateIRVcell.h"
#import "CandidateWriteInIRVcell.h"
#import "IRVinstructionsViewController.h"

#import "MySingelton.h"

@interface IRVviewController()
@property (nonatomic, retain) UITextField *writeInCandidateField;
@property (nonatomic, retain) UIPopoverController *instructionsPopover;
@property (nonatomic, retain) IBOutlet UIButton *instructionsButton;
@property (retain, nonatomic) IBOutlet UIButton *castMyVoteButton;
@property (retain, nonatomic) IBOutlet UIButton *undoButton;
@end

@implementation IRVviewController

@synthesize voterCandidateSelectionList = _voterCandidateSelectionList;

@synthesize candidateList;
@synthesize myTableView;
@synthesize selectedItemsTableView;
@synthesize instructionsHeader;
@synthesize cellReferenceList;

@synthesize writeInCandidateField;
@synthesize instructionsPopover = _instructionsPopover;
@synthesize instructionsButton = _instructionsButton;
@synthesize castMyVoteButton;
@synthesize undoButton;

/*
@synthesize candidateOneLabel, candidateTwoLabel, candidateThreeLabel;
*/

- (NSMutableArray*)voterCandidateSelectionList
{
    if (!_voterCandidateSelectionList) {
        _voterCandidateSelectionList = [[NSMutableArray alloc] initWithCapacity:kMaxNumberOfCandidatesInIRVlist];
    }
    return _voterCandidateSelectionList;
}

#pragma mark - View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // create mutable array that will hold a reference pointer to each cell //
        self.cellReferenceList = [NSMutableArray array];
        
        writeInCandidateField = [[UITextField alloc] init];
        
        self.candidateList = [NSMutableArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
        
        // Check to see if IRV data file was created //
        BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVdataFileName]];
        // Check to see if IRV stats data file was created //
        BOOL doesCat1StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName]];
        BOOL doesCat2StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName]];
        BOOL doesCat3StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName]];
        
        // Check to see if IRV default messages data file was created //
        BOOL doesMessagesDataFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVMessagesFileName]];
        
        // if file does not exist then create it //
        if (doesDataFileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0], @"",@"", nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            // create and write to file //
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kIRVdataFileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create IRV Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (doesCat1StatsFileExist == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create cat1 IRV Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        // if file does not exist then create it //
        if (doesCat2StatsFileExist == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create cat2 IRV Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        // if file does not exist then create it //
        if (doesCat3StatsFileExist == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create cat3 IRV Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kIRVMessagesFileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create kIRVMessagesFileName Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }            
        }
    }
    return self;
}

- (void)dealloc
{
        
    [writeInCandidateField release];
    
    [_voterCandidateSelectionList release];
    [candidateList release];
    [myTableView release];
    [selectedItemsTableView release];
    [cellReferenceList release];
    
    [_instructionsButton release];
    [_instructionsPopover release];
    
    /*
    [candidateOneLabel release];
    [candidateTwoLabel release];
    [candidateThreeLabel release];
     */
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

#pragma mark - Private Methods

-(void) updateIRVdataFileForVoter:(NSNumber*)voterID CandidateList:(NSArray *)candidateListArray{
            
    // load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVdataFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    // if the minimun or the maximum number of candidates selected by the voter has satisfied the stated condition then save ballot to file, else inform the voter of this fact--a code logic error will generally lead to the stated else condition. // 
    if ( [candidateListArray count] <= kMaxNumberOfCandidatesInIRVlist  && [candidateListArray count] != 0 ) {
        
        for (NSInteger j = 0; j < [candidateListArray count]; j++) {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSString *candidateName = [candidateListArray objectAtIndex:j];
            NSString *candidateCategory = [NSString stringWithFormat:@"%d",j+1];            
            
            [array addObject:voterID];
            [array addObject:candidateName];
            [array addObject:candidateCategory];
            
            // load the new array into the dictionary //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            [array release];
            
        }
    } else {
        NSString *message = @"";
        if ([candidateListArray count] == 0) {
            message = @"Could not save ballot to file because the minimun number of candidates condition has not been satisfied.";
        }
        if ([candidateListArray count] > kMaxNumberOfCandidatesInIRVlist) {
            message = @"Could not save ballot to file because the maximum number of candidates condition has not been satisfied.";
        }
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error Saving To File" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    // save update IRV data to file //
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to IRV Data file. Voter's ballot was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
}
    

-(void) updateIRVstatsfileForCandidate:(NSArray*)candidateListArray{
        
    // load the contents of the  current file into an NSDictionary //
    NSString *filepathCat1 = [FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName];
    NSString *filepathCat2 = [FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName];
    NSString *filepathCat3 = [FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName];
    NSMutableDictionary *dictCat1 = [[NSMutableDictionary alloc] initWithContentsOfFile:filepathCat1];
    NSMutableDictionary *dictCat2 = [[NSMutableDictionary alloc] initWithContentsOfFile:filepathCat2];
    NSMutableDictionary *dictCat3 = [[NSMutableDictionary alloc] initWithContentsOfFile:filepathCat3];
   
    // if the minimun or the maximum number of candidates selected by the voter has satisfied the stated condition then save ballot to file, else inform the voter of this fact--a code logic error will generally lead to the stated else condition. // 
    if ( [candidateListArray count] <= kMaxNumberOfCandidatesInIRVlist  && [candidateListArray count] != 0 ) {
                
        // go thru the candidats on a voters ballot and tally the number of times that each candidate was selected for each category //
        for (NSInteger j = 0; j < [candidateListArray count]; j++) {
            
            NSInteger candidateCategory = j+1;
            NSArray *array;
            NSString *key;
            BOOL isCandidatInIRVstatsFile = NO;
            
            switch (candidateCategory) {
                case 1:
                    // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
                    for (NSInteger k = 0; k < [dictCat1 count]; k++) {
                        
                        key = [NSString stringWithFormat:@"%d",k];
                        array = [[NSArray alloc] initWithObjects:[[dictCat1 objectForKey:key] objectAtIndex:0], [[dictCat1 objectForKey:key] objectAtIndex:1], nil];
                        
                        if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:[candidateListArray objectAtIndex:j]] ) {
                                                        
                            // candidate was located in the IRV category j stats file //
                            // increment IRV category count for this candidate //
                            NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                            NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                                              
                            
                            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                            
                            // save updated stats to dictionary //
                            [dictCat1 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                            
                            [dataUpdate release];
                            
                            isCandidatInIRVstatsFile = YES;
                            
                            // exit for loop //
                            k = [dictCat1 count];
                        }// end if block //
                        [array release];
                    }// end nested for block //
                    
                    // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                    if (isCandidatInIRVstatsFile == NO) {
                        
                        NSInteger updatedCategoryValueCount = 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictCat1 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictCat1 count]]];
                        
                        [dataUpdate release];
                    }
                    break;
                case 2:
                    // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
                    for (NSInteger k = 0; k < [dictCat2 count]; k++) {
                        
                        key = [NSString stringWithFormat:@"%d",k];
                        array = [[NSArray alloc] initWithObjects:[[dictCat2 objectForKey:key] objectAtIndex:0], [[dictCat2 objectForKey:key] objectAtIndex:1], nil];
                        
                        if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:[candidateListArray objectAtIndex:j]] ) {
                            
                            // candidate was located in the IRV category j stats file //
                            // increment IRV category count for this candidate //
                            NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                            NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                            
                            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                            
                            // save updated stats to dictionary //
                            [dictCat2 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                            
                            [dataUpdate release];
                            
                            isCandidatInIRVstatsFile = YES;
                            
                            // exit for loop //
                            k = [dictCat2 count];
                        }// end if block //
                        [array release];
                    }// end nested for block //
                    // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                    if (isCandidatInIRVstatsFile == NO) {
                        
                        NSInteger updatedCategoryValueCount = 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictCat2 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictCat2 count]]];
                        
                        [dataUpdate release];
                    }
                    break;
                case 3:
                    // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
                    for (NSInteger k = 0; k < [dictCat3 count]; k++) {
                        
                        key = [NSString stringWithFormat:@"%d",k];
                        array = [[NSArray alloc] initWithObjects:[[dictCat3 objectForKey:key] objectAtIndex:0], [[dictCat3 objectForKey:key] objectAtIndex:1], nil];
                        
                        if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:[candidateListArray objectAtIndex:j]] ) {
                            
                            // candidate was located in the IRV category j stats file //
                            // increment IRV category count for this candidate //
                            NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                            NSInteger updatedCategoryValueCount = lastCategoryValueCount + 1;
                            
                            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                            
                            // save updated stats to dictionary //
                            [dictCat3 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                            
                            [dataUpdate release];
                            
                            isCandidatInIRVstatsFile = YES;
                            
                            // exit for loop //
                            k = [dictCat3 count];
                        }// end if block //
                        [array release];
                    }// end nested for block //
                    // candidae was not located on the IRV Stats list, thus candidate is add to the stats list //
                    if (isCandidatInIRVstatsFile == NO) {
                        
                        NSInteger updatedCategoryValueCount = 1;
                        
                        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                        
                        // save updated stats to dictionary //
                        [dictCat3 setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dictCat3 count]]];
                        
                        [dataUpdate release];
                    }
                    break;                    
                default:
                    break;
            }// end switch //
            
        }// end for block //
        
        
    } else {
        NSString *message = @"";
        if ([candidateListArray count] == 0) {
            message = @"Could not create ballot stats file because the minimun number of candidates condition has not been satisfied.";
        }
        if ([candidateListArray count] > kMaxNumberOfCandidatesInIRVlist) {
            message = @"Could not create ballot stats file because the maximum number of candidates condition has not been satisfied.";
        }
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Error Saving To File" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    // save update IRV data to file //
    BOOL fileWriteStatusCat1 = [dictCat1 writeToFile:filepathCat1 atomically:YES];
    BOOL fileWriteStatusCat2 = [dictCat2 writeToFile:filepathCat2 atomically:YES];
    BOOL fileWriteStatusCat3 = [dictCat3 writeToFile:filepathCat3 atomically:YES];
    
    if (fileWriteStatusCat1 == NO || fileWriteStatusCat2 == NO || fileWriteStatusCat3 == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to IRV Stats file. Voter's ballot stats was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dictCat1 release];
    [dictCat2 release];
    [dictCat3 release];
}

-(BOOL) isThewriteInCandidateAlreadyOnTheCandidateList{
    
    // test to see if the entered text in the write-in candidate field matches any of the displayed candidates //
    
    // get write-in item //
    NSString *writeInItem = [self.writeInCandidateField text];
    
    // increment thru the pre-selected list of items and look for a match with the write-in item //
    for (NSString *item in self.candidateList) {
        if ([writeInItem isEqualToString:item]) {
            return YES;
        }
    }
    
    for (NSString *item in self.voterCandidateSelectionList) {
        if ([writeInItem isEqualToString:item]) {
            return YES;
        }
    }
    return NO;
    
    /*
    //--------------------------------------------------//
    // get writeIn candidate name //
    NSString *writeInCandidate = [[self.cellReferenceList objectAtIndex:0] candidateNameTextField].text;
    
    for (NSInteger j = 0; j < [self.voterCandidateSelectionList count]; j++) {
        
        // get listed candidate name //
        NSString *listedCandidate = [self.voterCandidateSelectionList objectAtIndex:j];
        
        if ( [writeInCandidate isEqualToString:listedCandidate] ) {
            
            // writeIn candidate matches an existing listed candidate //
            return YES;
        }
    } 
    
    for (NSInteger j = 0; j < [self.candidateList count]; j++) {
        
        // get listed candidate name //
        NSString *listedCandidate = [self.candidateList objectAtIndex:j];
        
        if ( [writeInCandidate isEqualToString:listedCandidate] ) {
            
            // writeIn candidate matches an existing listed candidate //
            return YES;
        }
    }    
    return NO;
     */
}

#pragma mark - UI Alert View Delegateion Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // handle alert view button presses for candidate confirmation only //
    if ([alertView.title isEqualToString:kAlerViewCandidateCastConfirmationtitle]) {
        if (buttonIndex == 1) {
            // Candidate confirmed by voter //
            
            // get current voter ID //
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
            NSNumber *voterID = [array objectAtIndex:0];
            
            // update range data file //
            [self updateIRVdataFileForVoter:voterID CandidateList:self.voterCandidateSelectionList];
            
            // update range stats data file //
            [self updateIRVstatsfileForCandidate:self.voterCandidateSelectionList];
            
            // update voter's completed experiment flag //
            [FileHandle toggleFlagForCompletedElectoralExperiment:kIRVNum];
            
            [array release];
            
            //*************************************************************
            // if the experiment is active than remove this experiment from a master list since it has been completed //
            experimentAdministrator = [MySingelton sharedObject];
            if ( [experimentAdministrator getIsExperimentActive] ) {
                
                // remove this experiment from list of uncompleted experiments //
                NSString *thisExperiment = kIRV;
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

-(IBAction) undoButton:(id)sender{
    // set all table cells to their default values //
    
    if ([self.cellReferenceList count] > 0) {
        [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] setText:@""];
        self.writeInCandidateField.text = @"";
    }
    
    //NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //[self.myTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // repopulate the candidate list //
    [self.candidateList removeAllObjects];
    self.candidateList = [NSMutableArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];           
    
    // empty the local voter selected candidate list //
    [self.voterCandidateSelectionList removeAllObjects];
            
    // reset the table view's frame //
    CGFloat widthOfOptionsTableView = [self.myTableView frame].size.width;
    CGFloat heightOfOptionsTableView;
    CGRect selectedTableRect;
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        //
        heightOfOptionsTableView = self.view.frame.size.height - 160;
        [self.myTableView setFrame:CGRectMake(0.0,
                                              75.0,
                                              widthOfOptionsTableView,
                                              heightOfOptionsTableView)];
        
        selectedTableRect = CGRectMake(0.0,
                                       75.0,
                                       widthOfOptionsTableView,
                                       kIRVselectionTableViewInitialHeightIncreaseFactor);
        [self.selectedItemsTableView setFrame:selectedTableRect];
    } else if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        //
        heightOfOptionsTableView = self.view.frame.size.height - 160;
        [self.myTableView setFrame:CGRectMake(0.0,
                                              75.0,
                                              widthOfOptionsTableView,
                                              heightOfOptionsTableView)];
        
        selectedTableRect = CGRectMake(0.0,
                                       75.0,
                                       widthOfOptionsTableView,
                                       kIRVselectionTableViewInitialHeightIncreaseFactor);
        [self.selectedItemsTableView setFrame:selectedTableRect];
    } 
    
    /*
    for (NSString *item in self.candidateList) {
        NSLog(@"----%@",item);
    }
    for (NSString *item in self.voterCandidateSelectionList) {
        NSLog(@"----%@",item);
    }
     */
    
    [self.myTableView reloadData];
    [self.selectedItemsTableView reloadData];
    
    /*
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    [self.selectedItemsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
     */
}

-(IBAction) castVoteButton:(id)sender{
    
    // voter must write-in or select at least one candiate before casting their vote //
    if ( [self.voterCandidateSelectionList count] < kMinNumberOfCandidatesInIRVlist ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voter Action Required" message:@"At least one item must be selected before casting your vote. You may also write-in an item by selecting the \"create your own unique entry\" row, or select items from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        
        // prompt the voter to accept and record ballot //
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:@"Cast your vote?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    }    
}

- (IBAction) instructionsButton:(id)sender{
    
    CGRect instructionsButtonRect = [self.instructionsButton frame];
    
    [self.instructionsPopover presentPopoverFromRect:instructionsButtonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(kPopoverContentSizeWidth, kPopoverContentSizeHeight)];    
}

#pragma mark - UI Keyboard Delegateion Methods

- (void)doneEditing: (id) sender {
    [sender resignFirstResponder];
}

- (void)keyboardDidShow: (id)sender {   
    
    // if ther are already the maximum number of candidates/items on the selected list, then dissmiss the keyboard //
    if ( [self.voterCandidateSelectionList count] < kMaxNumberOfCandidatesInIRVlist ) {
        
        [self.myTableView setScrollEnabled:NO];
        [self.myTableView setAllowsSelection:NO];
                
        self.writeInCandidateField = [[self.cellReferenceList objectAtIndex:0] candidateNameTextField];
        
        // since we are potentially deselecting a row selected by the user we will clear the candidateTextField //
        [self.writeInCandidateField setText:@""];    
        
        SEL doneWithKeyboard = @selector(doneEditing:);
        [self.writeInCandidateField addTarget:self action:doneWithKeyboard forControlEvents:UIControlEventEditingDidEndOnExit];
        
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
    } else {
        if ([self.cellReferenceList count] > 0) {
            [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] resignFirstResponder];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limit Reached" message:[NSString stringWithFormat:@"You are only allowed a maximum of %d candidats to select from. Please cast vote by pressing the appropriate button.",kMaxNumberOfCandidatesInIRVlist] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }    
     
}

- (void)keyboardWillHide: (id)sender {
    
    // if ther are already the maximum number of candidates/items on the selected list, then dissmiss the keyboard //
    if ( [self.voterCandidateSelectionList count] < kMaxNumberOfCandidatesInIRVlist ){
        
        // get the index value of the last row in the tableView //
        NSInteger indexValueOfLastRow = [self.myTableView numberOfRowsInSection:0] - 1;    
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:indexValueOfLastRow inSection:0];
        
        // store the textField entry in a local uitextField //
        if ([self.cellReferenceList count] > 0) {        
            NSString *userEntry = [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] text];
            [self.writeInCandidateField setText:userEntry];
            //NSLog(@"You typed: %@",userEntry);
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
        [self.myTableView setAllowsSelection:YES];
        [self.myTableView setUserInteractionEnabled:YES];
        [self.myTableView scrollToRowAtIndexPath:lastRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //[self.myTableView reloadData];
        
        
        
        //NSLog(@"Write In Candidate Field text: %@",[self.writeInCandidateField text]);
        
        
        if ([self.writeInCandidateField text].length > 0) {
            
            [self tableView:self.myTableView didSelectRowAtIndexPath:lastRowIndexPath];
            
            [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] resignFirstResponder];
            
            if ([self.cellReferenceList count] > 0) {
                [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] resignFirstResponder];
                self.writeInCandidateField.text = @"";
            }
        }
    }    
        
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = kIRV;
    
    UIImage *stretchableRedButtonImageNormal = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIImage *stretchableWhiteButtonImageNormal = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    
    [self.castMyVoteButton setBackgroundImage:stretchableRedButtonImageNormal forState:UIControlStateNormal];       
    [self.undoButton setBackgroundImage:stretchableWhiteButtonImageNormal forState:UIControlStateNormal];
    [self.instructionsButton setBackgroundImage:stretchableWhiteButtonImageNormal forState:UIControlStateNormal];
    
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
    IRVinstructionsViewController *viewCont = [[IRVinstructionsViewController alloc] initWithNibName:@"IRVinstructionsViewController" bundle:nil];
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
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVMessagesFileName];
    
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
    if ([tableView tag] == 1) {
        // return # of row for the items selected tableView //
        return [self.voterCandidateSelectionList count];
    } else {
        return [self.candidateList count] + 1;
    }
    
    /*
     // Return the number of rows in the section.
     return [candidateList count] + 1;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == 0) {
        
        //static NSString *CellCandidate = @"IRVCellCandidate";
        static NSString *CellCandidateWriteIn = @"IRVCellCandidateWriteIn";
        
        CandidateIRVcell *candidateCell = nil;
        CandidateWriteInIRVcell *candidateWriteInCell = nil;
        
        // store last row in section //
        NSInteger lastRowIndex = [tableView numberOfRowsInSection:indexPath.section];
        if (lastRowIndex != 0) {
            lastRowIndex -= 1;
        }
        
        
        if (indexPath.row == lastRowIndex) {
            candidateWriteInCell = (CandidateWriteInIRVcell*)[tableView dequeueReusableCellWithIdentifier:CellCandidateWriteIn];
            if (candidateWriteInCell != nil) {
                return candidateWriteInCell;
            }
        } else {
            /*
            candidateCell = (CandidateIRVcell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
            if (candidateCell != nil) {
                return candidateCell;
            }
             */
        }
         
        
        NSArray *cel;
        if ( indexPath.row == lastRowIndex && candidateWriteInCell == nil ) {
            
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateWriteInIRVcell" owner:self options:nil];
            candidateWriteInCell = (CandidateWriteInIRVcell*)[cel objectAtIndex:0];
            
            // assign a reference pointer to this cell from an array //
            [self.cellReferenceList addObject:candidateWriteInCell];
            
            // set a unique tag value for each cell //
            [candidateWriteInCell setTag:indexPath.row];
            
            candidateWriteInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return candidateWriteInCell;
            
        } else if ( indexPath.row != lastRowIndex && candidateCell == nil ) {
            
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateIRVcell" owner:self options:nil];
            candidateCell = (CandidateIRVcell*)[cel objectAtIndex:0];
            
            // assign to each of these cell a unique candidate name //
            //[candidateCell candidateNameLabel].text = [self.candidateList objectAtIndex:indexPath.row];
            candidateCell.textLabel.text = [self.candidateList objectAtIndex:indexPath.row];
            
            // set an unique tag value for each cell //
            [candidateCell setTag:indexPath.row];
            
            candidateCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return candidateCell;
            
        }
        
        /*
        //--------------------------------------------------//
        static NSString *CellCandidate = @"IRVCellCandidate";
        static NSString *CellCandidateWriteIn = @"IRVCellCandidateWriteIn";
        
        CandidateCell *candidateCell = nil;
        CandidateWriteInIRVcell *candidateWritInCell = nil;
        
        
        if (indexPath.row == 0) {
            candidateWritInCell = (CandidateWriteInIRVcell*)[tableView dequeueReusableCellWithIdentifier:CellCandidateWriteIn];
            
        } else {
            candidateCell = (CandidateCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
        }
        
        if (candidateCell == nil || candidateWritInCell == nil ) {
            
            NSArray *cel;
            if (indexPath.row == 0 ) {
                cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateWriteInIRVcell" owner:self options:nil];
                candidateWritInCell = (CandidateWriteInIRVcell*)[cel objectAtIndex:0];
                
                // assign a reference pointer to each from an array //
                [self.cellReferenceList addObject:candidateWritInCell];
                
                [self.cellReferenceList replaceObjectAtIndex:0 withObject:candidateWritInCell];
                
                candidateWritInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
                
                return candidateWritInCell;
            } else {           
                
                cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateIRVcell" owner:self options:nil];
                candidateCell = (CandidateCell*)[cel objectAtIndex:0];
                
                // assign to each of these cells a unique canidate name //
                candidateCell.textLabel.text = [candidateList objectAtIndex:indexPath.row - 1];
                
                candidateCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
                
                return candidateCell;
            }
        }
        
        if (indexPath.row == 0) {
            
            [self.cellReferenceList replaceObjectAtIndex:0 withObject:candidateWritInCell];
            
            return candidateWritInCell;
        }
        
        return candidateCell;
    } else if ([tableView tag] == 1) {
        static NSString *CellCandidate = @"IRVCellCandidate";
        CandidateCell *candidateCell = (CandidateCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
        if (candidateCell != nil) {
            return candidateCell;
        } else {
            NSArray *cel;
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateIRVcell" owner:self options:nil];
            candidateCell = (CandidateCell*)[cel objectAtIndex:0];
            
            // assign to each of these cells a unique canidate name //
            candidateCell.textLabel.text = [self.voterCandidateSelectionList objectAtIndex:indexPath.row];
            
            candidateCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return candidateCell;
        }
    }
    
    return nil;
    */
    } else if ([tableView tag] == 1) {
        
        CandidateIRVcell *candidateCell = nil;
        
        //static NSString *CellCandidate = @"IRVCellCandidate";
        //CandidateIRVcell *candidateCell = (CandidateIRVcell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
        
        if (candidateCell != nil) {
            return candidateCell;
        } else {
            NSArray *cel;
            
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateIRVcell" owner:self options:nil];
            candidateCell = (CandidateIRVcell*)[cel objectAtIndex:0];
            
            //NSLog(@"index path: %i",indexPath.row);
            //NSLog(@"Size of voterCandidateSelectionList: %i",[self.voterCandidateSelectionList count]);
            // assign to each of these cells a unique canidate name //
            
            @try {
                candidateCell.textLabel.text = [self.voterCandidateSelectionList objectAtIndex:indexPath.row];
            }
            @catch (NSException *exception) {
                NSLog(@" ...... Exception Catch -- Description: %@",[exception description]);
            }           
            
            candidateCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            
            return candidateCell;
        }
    }
    
    //NSLog(@"Returning 3: %@",NULL);
    // you should never get here, if you do, you got issues!!! //    
    return nil;        
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableViewCellRowHeight;   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // store last row in section //
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:indexPath.section];
    if (lastRowIndex != 0) {
        lastRowIndex -= 1;
    }
    
    if ([tableView tag] == 0) {
        // if the first cell with the write-in field is selected and the text field is not empty then process entry //
        if (indexPath.row == lastRowIndex && [self.writeInCandidateField.text length] > 0) {
            // User candidate entry was detected //
            
            // if the selected candidate list is bigger than the required max size then inform voter of this fact else add to the voter's candidate selected list if...  //
            if ( [self.voterCandidateSelectionList count] >= kMaxNumberOfCandidatesInIRVlist) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limit Reached" message:[NSString stringWithFormat:@"You are only allowed a maximum of %d candidats to select from. Please cast vote by pressing the appropriate button.",kMaxNumberOfCandidatesInIRVlist] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            } else {
                
                // if the candidate is already on the list of candidats then inform the voter of this fact else process the voter write-in entry //
                if ( [self isThewriteInCandidateAlreadyOnTheCandidateList] ) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Entry" message:@"This candidate is already on the candidate list below or on the voter accepted list of candidates." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                } else {
                    
                    // add to the user selected entry candidate list //
                    NSString *writeInCandidate = [self.writeInCandidateField text];
                    [self.voterCandidateSelectionList addObject:writeInCandidate];
                                        
                    //[self.candidateList removeObjectAtIndex:indexPath.row];
                    NSArray *indexPathArray = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [indexPathArray release];                
                    
                    //----------------------------------//
                    // change the height of the table view to accomidate the new cell... //
                    
                    NSInteger selectedCellCount = [self.voterCandidateSelectionList count];
                    CGFloat widthOfTableView = [self.selectedItemsTableView frame].size.width;
                    CGFloat heightOfOptionsTableView = [self.myTableView bounds].size.height;
                    
                    CGRect selectedTableRect, optionsTableRect;
                    
                    switch (selectedCellCount) {
                        case 1:
                            // something //
                            selectedTableRect = CGRectMake(0.0,
                                                           75.0,
                                                           widthOfTableView,
                                                           kIRVselectionTableViewInitialHeightIncreaseFactor);
                            [self.selectedItemsTableView setFrame:selectedTableRect];
                            
                            optionsTableRect = CGRectMake(0.0,
                                                          75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor,
                                                          widthOfTableView,
                                                          heightOfOptionsTableView - kIRVselectionTableViewInitialHeightIncreaseFactor);                        
                            [self.myTableView setFrame:optionsTableRect];
                            
                            break;
                        case 2:
                            // something //
                            selectedTableRect = CGRectMake(0.0,
                                                           75.0,
                                                           widthOfTableView,
                                                           kIRVselectionTableViewInitialHeightIncreaseFactor + kIRVselectionTableViewHeightIncreaseFactor);
                            [self.selectedItemsTableView setFrame:selectedTableRect];
                            
                            optionsTableRect = CGRectMake(0.0,
                                                          75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor + kIRVselectionTableViewHeightIncreaseFactor,
                                                          widthOfTableView,
                                                          heightOfOptionsTableView - kIRVselectionTableViewHeightIncreaseFactor);
                            [self.myTableView setFrame:optionsTableRect];  
                            
                            break;
                        case 3:
                            // something //
                            selectedTableRect = CGRectMake(0.0,
                                                           75.0,
                                                           widthOfTableView,
                                                           kIRVselectionTableViewInitialHeightIncreaseFactor + 2*kIRVselectionTableViewHeightIncreaseFactor);
                            [self.selectedItemsTableView setFrame:selectedTableRect];
                            
                            optionsTableRect = CGRectMake(0.0,
                                                          75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor + 2*kIRVselectionTableViewHeightIncreaseFactor,
                                                          widthOfTableView,
                                                          heightOfOptionsTableView - kIRVselectionTableViewHeightIncreaseFactor);                        
                            [self.myTableView setFrame:optionsTableRect];
                            
                            break;
                        default:
                            break;
                    }
                    
                    // insert the deleted row into the selected item table view //
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.voterCandidateSelectionList count] -1 inSection:0];
                    NSArray *newIndexPathArray = [[NSArray alloc] initWithObjects:newIndexPath, nil];
                    
                    NSIndexSet *SectionIndexSet = [[NSIndexSet alloc] initWithIndex:0];
                    [self.selectedItemsTableView reloadSections:SectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
                    [SectionIndexSet release];
                    
                    [newIndexPathArray release];
                    
                }// end else block //
            }// end else block //        
        } else if ( indexPath.row != lastRowIndex) {
            
            // voter selected a non write-in candidate //
            
            // if the selected candidate list is bigger than the required max size then inform voter of this fact else add to the voter's candidate selected list if...  //
            if ( [self.voterCandidateSelectionList count] >= kMaxNumberOfCandidatesInIRVlist) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limit Reached" message:[NSString stringWithFormat:@"You are only allowed a maximum of %d candidats to select from. Please cast vote by pressing the appropriate button.",kMaxNumberOfCandidatesInIRVlist] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            } else {
                
                // remove the selected candiate from the candidate list and place the candidate on to the voter's accepted candidate list //
                NSString *selectedCandidateName = [self.candidateList objectAtIndex:indexPath.row];
                
                [self.voterCandidateSelectionList addObject:selectedCandidateName];
                
                [self.candidateList removeObjectAtIndex:indexPath.row];
                NSArray *indexPathArray = [[NSArray alloc] initWithObjects:indexPath, nil];
                [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
                [indexPathArray release];
        
                
                //----------------------------------//
                // change the height of the table view to accomidate the new cell... //
                
                NSInteger selectedCellCount = [self.voterCandidateSelectionList count];
                CGFloat widthOfTableView = [self.selectedItemsTableView frame].size.width;
                CGFloat heightOfOptionsTableView = [self.myTableView bounds].size.height;
                
                CGRect selectedTableRect, optionsTableRect;
                
                switch (selectedCellCount) {
                    case 1:
                        // something //
                        selectedTableRect = CGRectMake(0.0,
                                                       75.0,
                                                       widthOfTableView,
                                                       kIRVselectionTableViewInitialHeightIncreaseFactor);
                        [self.selectedItemsTableView setFrame:selectedTableRect];
                        
                        optionsTableRect = CGRectMake(0.0,
                                                      75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor,
                                                      widthOfTableView,
                                                      heightOfOptionsTableView - kIRVselectionTableViewInitialHeightIncreaseFactor);                        
                        [self.myTableView setFrame:optionsTableRect];
                        
                        break;
                    case 2:
                        // something //
                        selectedTableRect = CGRectMake(0.0,
                                                       75.0,
                                                       widthOfTableView,
                                                       kIRVselectionTableViewInitialHeightIncreaseFactor + kIRVselectionTableViewHeightIncreaseFactor);
                        [self.selectedItemsTableView setFrame:selectedTableRect];
                        
                        optionsTableRect = CGRectMake(0.0,
                                                      75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor + kIRVselectionTableViewHeightIncreaseFactor,
                                                      widthOfTableView,
                                                      heightOfOptionsTableView - kIRVselectionTableViewHeightIncreaseFactor);
                        [self.myTableView setFrame:optionsTableRect];  
                        
                        break;
                    case 3:
                        // something //
                        selectedTableRect = CGRectMake(0.0,
                                                       75.0,
                                                       widthOfTableView,
                                                       kIRVselectionTableViewInitialHeightIncreaseFactor + 2*kIRVselectionTableViewHeightIncreaseFactor);
                        [self.selectedItemsTableView setFrame:selectedTableRect];
                        
                        optionsTableRect = CGRectMake(0.0,
                                                      75.0 + kIRVselectionTableViewInitialHeightIncreaseFactor + 2*kIRVselectionTableViewHeightIncreaseFactor,
                                                      widthOfTableView,
                                                      heightOfOptionsTableView - kIRVselectionTableViewHeightIncreaseFactor);                        
                        [self.myTableView setFrame:optionsTableRect];
                        
                        break;
                    default:
                        break;
                }
                
                // insert the deleted row into the selected item table view //
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.voterCandidateSelectionList count] -1 inSection:0];
                NSArray *newIndexPathArray = [[NSArray alloc] initWithObjects:newIndexPath, nil];
                
                NSIndexSet *SectionIndexSet = [[NSIndexSet alloc] initWithIndex:0];
                [self.selectedItemsTableView reloadSections:SectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
                [SectionIndexSet release];
                
                [newIndexPathArray release];                
            }
        }        
        [[self.cellReferenceList objectAtIndex:0] candidateNameTextField].text = @"";
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }// end if block //
    
}

#pragma mark - IRV popover view delegate

- (void)IRVPopoverDidAppear:(IRVinstructionsViewController *)popoverViewController {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.instructionsHeader setAlpha:0.15];
    [UIView commitAnimations];
}
- (void)IRVPopoverDidDisappear:(IRVinstructionsViewController *)popoverViewController{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.instructionsHeader setAlpha:1.0];
    [UIView commitAnimations];
}

@end
