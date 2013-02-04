//
//  RangeViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/24/11.
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

#import "RangeViewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"
#import "SizeConstants.h"

#import "CandidateCell.h"
#import "CandidateWriteInCell.h"

#import "MySingelton.h"
#import "RangeInstructionsViewController.h"

@interface RangeViewController()
@property (nonatomic, retain) NSMutableArray *dataModelArrayForRangeValues;
@property (nonatomic, retain) NSMutableArray *cellReferenceList;
@property (nonatomic, retain) UIPopoverController *instructionsPopover;
@end

@implementation RangeViewController

@synthesize candidateList;
@synthesize candidateTextField;
@synthesize myTableView;
@synthesize dataModelArrayForRangeValues = _dataModelArrayForRangeValues;
@synthesize cellReferenceList = _cellReferenceList;
@synthesize instructionsPopover;
@synthesize instructionsButton;
@synthesize castMyVoteButton;
@synthesize undoButton;
@synthesize instructionsHeader;

- (void)dealloc
{
    [_cellReferenceList release];
    [candidateList release];
    [candidateTextField release];
    [myTableView release];
    [_dataModelArrayForRangeValues release];
    [instructionsButton release];
    [instructionsPopover release];
    [instructionsHeader release];
    [castMyVoteButton release];
    [undoButton release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // create mutable array that will hold a reference pointer to each cell //
        _cellReferenceList = [[NSMutableArray alloc] init];
        
        candidateTextField = [[UITextField alloc] init];
        
        // create the list of candidates //
        self.candidateList = [NSArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
                
        // Create the data model array to hold the range values for each candidate on the list plus the write-in candidate //       
        NSNumber *defaultRagneValue = [NSNumber numberWithFloat:kDefaultRangeValue/((CGFloat)kMaxRangeValue-kMinRangeValue)];
        _dataModelArrayForRangeValues = [[NSMutableArray alloc] initWithCapacity:([self.candidateList count] + 1)];
        for (NSInteger i = 0; i < [self.candidateList count] + 1; i++) {
            [self.dataModelArrayForRangeValues addObject:defaultRagneValue];
        }
        
        // Check to see if Plurality data file was created //
        BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeDataFileName]];
        // Check to see if Plurality stats data file was created //
        BOOL doesStatsFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeStatsFileName]];
        // Check to see if Range default messages data file was created //
        BOOL doesMessagesDataFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeMessagesFileName]];
        
        // if file does not exist then create it //
        if (doesDataFileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0], @"",@"", nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            // create and write to file //
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kRangeDataFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Range Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (doesStatsFileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            
            // allocate mem for dictionary //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            // save data to dictionary with a sequential key //
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kRangeStatsFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Range Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kRangeMessagesFileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create kRangeMessagesFileName Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }            
        }
        
    }
    return self;
}

-(void) updateRangeDataFileForVoter:(NSNumber*)voterID CandidateList:(NSArray *)candidateListArray{
    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeDataFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    NSInteger endIndexOffset = 0;
    if ( [self isThereAwriteInCandidateInTheTextField] == NO) {
        endIndexOffset = 1;
    }
    
    for (NSInteger j = 0; j < [self.dataModelArrayForRangeValues count] - endIndexOffset; j++) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
                        
        [array addObject:voterID];
        
        if (j == [self.dataModelArrayForRangeValues count] - 1 ) {
            
            // there is a write-in item, else the last item is not a write-in //
            NSString *candidateName = [self.candidateTextField text];
            [array addObject:candidateName];
        } else {
                        
            NSString *candidateName = [self.candidateList objectAtIndex:j];
            [array addObject:candidateName];
        }
        
        CGFloat storedValue = [[self.dataModelArrayForRangeValues objectAtIndex:j] floatValue];
        
        NSInteger intValue = 0;
        
        const float_t sliderValueInterval = .1666667;
        
        if (storedValue < sliderValueInterval) { // this if block is redundent //
            intValue = 0;
        } else if (storedValue < 2*sliderValueInterval) {
            intValue = 1;
        } else if (storedValue < 3*sliderValueInterval) {
            intValue = 2;
        } else if (storedValue < 4*sliderValueInterval) {
            intValue = 3;
        } else if (storedValue < 5*sliderValueInterval) {
            intValue = 4;
        } else {
            intValue = 5;
        }
                
        NSString *rangVal = [NSString stringWithFormat:@"%i",intValue];
        
        [array addObject:rangVal];
        
        // load the new array into the dictionary //
        [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
        
        [array release];    
    }

    // save update plurality data to file //
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to Range Data file. Voter's ballot was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
}



-(void) updateRangeStatsfileForCandidate:(NSArray*)candidateListArray{
    
    // load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeStatsFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    // if the write-in candidate cell is empty then we skip this cell when tallying results setting an offset //
    NSInteger endIndexOffset = 0;
    if ( [self isThereAwriteInCandidateInTheTextField] == NO) {
        endIndexOffset = 1;
    }
    
    // go thru the candidats on a voters ballot and tally the candidates rank and add any write-in candidats //
    for (NSInteger j = 0; j < [self.dataModelArrayForRangeValues count] - endIndexOffset; j++) {
        // check to see if candidate selected is already in the Range stats data file //
        BOOL isCandidatInRangeStatsFile = NO;
        NSArray *array;
        for (NSInteger i = 0; i < [dict count]; i++) {
            
            array = [[NSArray alloc] initWithObjects:[[dict objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:0],[[dict objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:1],nil];
            
            if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:[candidateListArray objectAtIndex:j]] ) {
                
                // candidate was located in the range stats file //
                // increment range count //
                NSInteger lastVoteCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                //NSString *rangeStringValue = [NSString stringWithFormat:@"%i",[(NSNumber*)[self.dataModelArrayForRangeValues objectAtIndex:j] floatValue]];
                
                CGFloat storedValue = [[self.dataModelArrayForRangeValues objectAtIndex:j] floatValue];
                
                NSInteger intValue = 0;
                
                const float_t sliderValueInterval = .1666667;
                
                if (storedValue < sliderValueInterval) { // this if block is redundent //
                    intValue = 0;
                } else if (storedValue < 2*sliderValueInterval) {
                    intValue = 1;
                } else if (storedValue < 3*sliderValueInterval) {
                    intValue = 2;
                } else if (storedValue < 4*sliderValueInterval) {
                    intValue = 3;
                } else if (storedValue < 5*sliderValueInterval) {
                    intValue = 4;
                } else {
                    intValue = 5;
                }
                
                NSInteger updatedVoteCount = lastVoteCount + intValue;
                
                NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedVoteCount], nil];
                
                // save updated stats to dictionary //
                [dict setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",i]];
                
                [dataUpdate release];            
                isCandidatInRangeStatsFile = YES;
                
                // exit for loop //
                i = [dict count];
                
            }
            [array release];
        }
        
        if (isCandidatInRangeStatsFile == NO) {
            
            // candidate was not located on the plurality stats list, thus candidate will be add to the stats list //
            // increment vote count //
            NSInteger lastVoteCount = 0;
            
            CGFloat storedValue = [[self.dataModelArrayForRangeValues objectAtIndex:j] floatValue];
            
            NSInteger intValue = 0;
            
            const float_t sliderValueInterval = .1666667;
            
            if (storedValue < sliderValueInterval) { // this if block is redundent //
                intValue = 0;
            } else if (storedValue < 2*sliderValueInterval) {
                intValue = 1;
            } else if (storedValue < 3*sliderValueInterval) {
                intValue = 2;
            } else if (storedValue < 4*sliderValueInterval) {
                intValue = 3;
            } else if (storedValue < 5*sliderValueInterval) {
                intValue = 4;
            } else {
                intValue = 5;
            }
            
            NSInteger updatedVoteCount = lastVoteCount + intValue;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:[candidateListArray objectAtIndex:j], [NSNumber numberWithInteger:updatedVoteCount], nil];
            
            // save updated stats to dictionary //
            [dict setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            [dataUpdate release];
            
        }
    }
    
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update the Range Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
    
}



-(BOOL) isThereAwriteInCandidateInTheTextField{
    
    // if the textfield string is greater than zero return true else return false //
    if ([[self.candidateTextField text] length] > 0) {
        return  YES;
    }
    
    return NO;
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
}  


-(BOOL) isAtLeastOneRangeValueDifferentThanTheOthers{    
    
    // if the write-in item is blank then ignore the last range value on the list, so we setup an offset to accomplish this //
    NSInteger endIndexOffset = 0;
    if ( [self isThereAwriteInCandidateInTheTextField] == YES && [self isThewriteInCandidateAlreadyOnTheCandidateList] == NO ) {
        endIndexOffset = 0;
    } else if ( [self isThewriteInCandidateAlreadyOnTheCandidateList] == NO ){
        endIndexOffset = 1;
    }
        
    // there has to be at least two range values... //
    if ( [self.dataModelArrayForRangeValues count] >= 2 ) {
        
        NSNumber *aRangeNumber = [self.dataModelArrayForRangeValues objectAtIndex:0];
        
        for (NSInteger j = 1; j < [self.dataModelArrayForRangeValues count] - endIndexOffset; j++) {
            
            NSNumber *someRangeNumber = [self.dataModelArrayForRangeValues objectAtIndex:j];
            
            if ([aRangeNumber isEqualToNumber:someRangeNumber] == NO) {
                // there is at least one candidate range value that differs from some other value //
                return YES;
            }
        }
    }
    return NO;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // handle alert view button presses for candidate confirmation only //
    if ([alertView.title isEqualToString:kAlerViewCandidateCastConfirmationtitle]) {
        if (buttonIndex == 1) {
            // Candidate confirmed by voter //
            
            // get current voter ID //
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
            NSNumber *voterID = [array objectAtIndex:0];
            
            // get candidate list and or write-in candidate //
            NSMutableArray *candidateNameList = [[NSMutableArray alloc] init];
            for (NSString *name in self.candidateList) {
                [candidateNameList addObject:name];
            }
            if ( [self isThereAwriteInCandidateInTheTextField] ) {
                NSString *name = [self.candidateTextField text];
                //NSString *name = [[self.cellReferenceList objectAtIndex:0] candidateNameTextField].text;
                [candidateNameList addObject:name];
            }
            
            // update range data file //
            [self updateRangeDataFileForVoter:voterID CandidateList:candidateNameList];
            
            
            // update range stats data file //
            [self updateRangeStatsfileForCandidate:candidateNameList];
            
            // update voter's completed experiment flag //
            [FileHandle toggleFlagForCompletedElectoralExperiment:kRangeNum];
            
            [array release];
            [candidateNameList release];
            
            //###################################################################
            // if the experiment is active than remove this experiment from a master list since it has been completed //
            experimentAdministrator = [MySingelton sharedObject];
            if ( [experimentAdministrator getIsExperimentActive] ) {
                
                // remove this experiment from list of uncompleted experiments //
                NSString *thisExperiment = kRange;
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
        [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] setText:nil];
        self.candidateTextField.text = nil;
    }
    
    //[self.myTableView reloadData];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.myTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    NSNumber *defaultRagneValue = [NSNumber numberWithFloat:kDefaultRangeValue/((CGFloat)kMaxRangeValue-kMinRangeValue)];
    
    for (NSInteger i = 0; i < [self.dataModelArrayForRangeValues count]; i++) {
        [self.dataModelArrayForRangeValues replaceObjectAtIndex:i withObject:defaultRagneValue];        
    }
    
    // get array with visible tableView cells and animate the sliders back into their default position //
    NSArray *visibleCellsArray = [self.myTableView visibleCells];
    
    for (id cell in visibleCellsArray) {
        [[cell candidateSlider] setValue:kDefaultRangeValue/((CGFloat)kMaxRangeValue-kMinRangeValue) animated:YES];
        [[cell candidateRangeLabel] setText:[NSString stringWithFormat:@"%i",kDefaultRangeValue]];
        //[[(CandidateWriteInCell*)cell candidateRangeLabel] setText:[NSString stringWithFormat:@"%i",intValue]];
        //[[cell candidateRangeLabel] setText:[NSString stringWithFormat:@"%i",kDefaultRangeValue]];
    }
    
}


-(IBAction) castVoteButton:(id)sender{
    
    //NSLog(@"There is a write in candidate and it's: %@",self.candidateTextField.text);
            
    if ( [self isThereAwriteInCandidateInTheTextField] ) {
        
        BOOL isWriteInCandidateAccepted;
        BOOL isAtLeastOneRangeVoteDifferentThanTheRest = NO;
        
        // if candidate is already listed, inform the user of this fact, //
        if ( [self isThewriteInCandidateAlreadyOnTheCandidateList] ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Entry Found" message:@"The write-in item already exists. Please Clear the entry field, locate your item from the given list, and rate each one."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            
            isWriteInCandidateAccepted = NO;
            
        } else {
            
            isWriteInCandidateAccepted = YES;
        }
        if ( isWriteInCandidateAccepted ) {
            
            // is at least one rank/range value different from the other //
            isAtLeastOneRangeVoteDifferentThanTheRest = [self isAtLeastOneRangeValueDifferentThanTheOthers];
            
        }
        if ( isWriteInCandidateAccepted && isAtLeastOneRangeVoteDifferentThanTheRest ) {
            
            // prompt the voter to accept and record ballot //
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:@"Cast your vote?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
            [alert release];
            
        } else if ( isAtLeastOneRangeVoteDifferentThanTheRest == NO ) {
            
            // inform the voter that at least one range value must differ //
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voter Action Required" message:@"At least one of the items must be ranked differently than the other items, before casting your vote. You may also write-in an item by selecting the \"create your own unique entry\" row and rank it along with every item in the list, or rank each item from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    } else {
        
                 
        // is at least one rank/range value different from the other //
        BOOL isAtLeastOneRangeVoteDifferentThanTheRest = [self isAtLeastOneRangeValueDifferentThanTheOthers];
        
        /*
        NSLog(@"You are in the else block!!! With boolean value: %i",isAtLeastOneRangeVoteDifferentThanTheRest);
        for (NSNumber *rangeValue in self.dataModelArrayForRangeValues) {
            NSLog(@"%@",rangeValue);
        }
         */
        
        if ( isAtLeastOneRangeVoteDifferentThanTheRest ) {
            
            // prompt the voter to accept and record ballot //
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:@"Cast your vote?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
            [alert release];
            
        } else {
            
            // inform the voter that at least one range value must differ //
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Action Required" message:@"At least one of the items must be ranked differently than the other items, before casting your vote. You may also write-in an item by selecting the \"create your own unique entry\" row and rank it along with every item in the list, or rank each item from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }

    }   
    // Case One: If none of the slider values have been changed, then don't record vote and inform the voter that at leat one slider value is required to be different that the rest //    
}
 

#pragma mark - keyboard 

- (void)doneEditing: (id)sender {
    [sender resignFirstResponder];
}

- (void)keyboardDidShow: (id)sender {
      
    [self.myTableView setScrollEnabled:NO];    
            
    self.candidateTextField = [[self.cellReferenceList objectAtIndex:0] candidateNameTextField];
    
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
        NSString *userEntry = [[(CandidateWriteInCell*)[self.cellReferenceList objectAtIndex:0] candidateNameTextField] text];
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
    
    self.title = kRange;
    
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
    RangeInstructionsViewController *viewCont = [[RangeInstructionsViewController alloc] initWithNibName:@"RangeInstructionsViewController" bundle:nil];
    [viewCont setPopoverDelegate:self];
    
    instructionsPopover = [[UIPopoverController alloc] initWithContentViewController:viewCont];
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
    return YES;
    // Return YES for supported orientations
    /*
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
	return YES;
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeMessagesFileName];
    
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
        
//    static NSString *CellCandidate = @"RangeCellCandidate";
    static NSString *CellCandidateWriteIn = @"RangeCellCandidateWriteIn";
    
    CandidateCell *candidateCell = nil;
    CandidateWriteInCell *candidateWritInCell = nil;
    
    // store last row in section //
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:indexPath.section];
    if (lastRowIndex != 0) {
        lastRowIndex -= 1;
    }
    
    if (indexPath.row == lastRowIndex) {
        candidateWritInCell = (CandidateWriteInCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidateWriteIn];
        if (candidateWritInCell != nil) {
            return candidateWritInCell;
        }
    } else {
        /*
        candidateCell = (CandidateCell*)[tableView dequeueReusableCellWithIdentifier:CellCandidate];
        if (candidateCell != nil) {
            return candidateCell;
        }
         */
    }
    
    NSArray *cel;
    if (indexPath.row == lastRowIndex && candidateWritInCell == nil ) {
        
        //NSLog(@"Creating a Write-in cell");
        
        cel = [[NSBundle mainBundle] loadNibNamed:@"RangeViewCandidateWriteInCell" owner:self options:nil];
        candidateWritInCell = (CandidateWriteInCell*)[cel objectAtIndex:0];
        
        
        // assign a reference pointer to this cell from an array //
        [self.cellReferenceList addObject:candidateWritInCell];
                       
        // set an unique tag value for each cell //
        [candidateWritInCell setTag:indexPath.row];
        
        [candidateWritInCell setDelegate:self];        
        
        candidateWritInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
        
        //NSLog(@"Returning 1: %@",candidateWritInCell);
        
        return candidateWritInCell;
    } else if (indexPath.row != lastRowIndex && candidateCell == nil ) {
        
        //NSLog(@"Create a cell");
        /*
        //TEST//
        rangeCell = [[NSBundle mainBundle] loadNibNamed:@"CandidateRangeCell" owner:self options:nil];
        candidateRangeCell = (CandidateRangeCell*)[rangeCell objectAtIndex:0];
        [candidateRangeCell candidateNameLabel].text = [self.candidateList objectAtIndex:indexPath.row];
        [candidateRangeCell setDelegate:self];
        candidateRangeCell.candidateNameLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
        return candidateRangeCell;
        //TEST//
         */
        
        cel = [[NSBundle mainBundle] loadNibNamed:@"RangeViewCandidateCell" owner:self options:nil];
        candidateCell = [cel objectAtIndex:0];
        
        // assign to each of these cells a unique canidate name //
        [candidateCell candidateNameLabel].text = [self.candidateList objectAtIndex:indexPath.row];
                        
        // set an unique tag value for each cell //
        [candidateCell setTag:indexPath.row];
        
        [candidateCell setDelegate:self];
        
        candidateCell.candidateNameLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
        
        //NSLog(@"Returning 2: %@",candidateCell);
        return candidateCell;
    }
    
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    //NSLog(@"Start Will display cell");
    // assign the stored range value for the UISlider object in the cell //
    CGFloat storedValue = [[self.dataModelArrayForRangeValues objectAtIndex:indexPath.row] floatValue];
    
    NSInteger intValue = 0;
    
    const float_t sliderValueInterval = .1666667;
    
    if (storedValue < sliderValueInterval) { // this if block is redundent //
        intValue = 0;
    } else if (storedValue < 2*sliderValueInterval) {
        intValue = 1;
    } else if (storedValue < 3*sliderValueInterval) {
        intValue = 2;
    } else if (storedValue < 4*sliderValueInterval) {
        intValue = 3;
    } else if (storedValue < 5*sliderValueInterval) {
        intValue = 4;
    } else {
        intValue = 5;
    }
        
    if ([cell isKindOfClass:[CandidateCell class]]) {
        
        [[(CandidateCell*)cell candidateSlider] setValue:storedValue animated:NO];
        [[(CandidateCell*)cell candidateRangeLabel] setText:[NSString stringWithFormat:@"%i",intValue]];
        
    } else if ([cell isKindOfClass:[CandidateWriteInCell class]]) {
        
        [[(CandidateWriteInCell*)cell candidateSlider] setValue:storedValue animated:NO];
        [[(CandidateWriteInCell*)cell candidateRangeLabel] setText:[NSString stringWithFormat:@"%i",intValue]];
    }
    //NSLog(@"END Will display cell");
}
 

#pragma mark - Candidate Cell delegate

- (void) rangeValueOnSliderInStandardCellDidChange:(CandidateCell *)forSlider
{
    //NSLog(@"Slider Value Changed with TAG: %i",[forSlider tag]);
    
    NSString *stringRangeValue = [forSlider candidateRangeLabel].text;
    NSNumber *newRangeValue = [NSNumber numberWithFloat:[stringRangeValue floatValue]/((CGFloat)kMaxRangeValue-kMinRangeValue)];    
    [self.dataModelArrayForRangeValues replaceObjectAtIndex:[forSlider tag] withObject:newRangeValue];
}

- (void) rangeValueOnSliderInWriteInCellDidChange:(CandidateWriteInCell *)forSlider
{
    NSString *stringRangeValue = [forSlider candidateRangeLabel].text;
    NSNumber *newRangeValue = [NSNumber numberWithFloat:[stringRangeValue floatValue]/((CGFloat)kMaxRangeValue-kMinRangeValue)];    
    [self.dataModelArrayForRangeValues replaceObjectAtIndex:[forSlider tag] withObject:newRangeValue];
}

#pragma mark - Range popover view delegate

- (void)rangePopoverDidAppear:(RangeInstructionsViewController *)popoverViewController {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.instructionsHeader setAlpha:0.15];
    [UIView commitAnimations];
}
- (void)rangePopoverDidDisappear:(RangeInstructionsViewController *)popoverViewController{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.instructionsHeader setAlpha:1.0];
    [UIView commitAnimations];
}



@end
