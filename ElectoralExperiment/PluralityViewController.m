//
//  PluralityViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/22/11.
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

#import "PluralityViewController.h"
#import "FileHandle.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "MySingelton.h"
#import "SizeConstants.h"
#import "CandidateWriteInPluralitycell.h"
#import "CandidatePluralitycell.h"
#import "PluralityInstructionsViewController.h"

@interface PluralityViewController()
@property BOOL isViewInPortraitMode;
@property (nonatomic, retain) UIPopoverController *instructionsPopover;
@end

@implementation PluralityViewController

@synthesize candidateList;
@synthesize candidateTextField;
@synthesize myTableView;
@synthesize cellReferenceList;
@synthesize isViewInPortraitMode;
@synthesize instructionsPopover;
@synthesize instructionsButton = _instructionsButton;
@synthesize instructionsHeader;
@synthesize castMyVoteButton = _castMyVoteButton;
@synthesize undoButton = _undoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //NSLog
        
        // create mutable array that will hold a reference pointer to each cell //
        cellReferenceList = [[NSMutableArray alloc] init];
        
        candidateTextField = [[UITextField alloc] init];
                       
        
        // Check to see if Plurality data file was created //
        BOOL pluralityFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityDataFileName]];
        // Check to see if Plurality stats data file was created //
        BOOL pluralityStatsFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityStatsFileName]];
        // Check to see if Plurality default messages data file was created //
        BOOL doesMessagesDataFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityMessagesFileName]];
        
        // if file does not exist then create it //
        if (pluralityFileExists == NO) {
            
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger:0],@"", nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kPluralityDataFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Plurality Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        
        // if file does not exist then create it //
        if (pluralityStatsFileExists == NO) {
           
            // create file with a voter ID starting at 1 //
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"",[NSNumber numberWithUnsignedInteger:0], nil];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kPluralityStatsFileName] atomically:YES];
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create Plurality Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
            
            BOOL fileWriteStatus = [dict writeToFile:[FileHandle getFilePathForFileWithName:kPluralityMessagesFileName] atomically:YES];
            
            [dict release];
            [array release];
            
            if (fileWriteStatus == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create kPluralityMessagesFileName Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }            
        }        

        NSString *filepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
        self.candidateList = [NSArray arrayWithContentsOfFile:filepath];
    }
    return self;
}

- (void) dealloc
{
    [candidateList release];
    [candidateTextField release];
    [myTableView release];
    [_instructionsButton release];
    [instructionsPopover release];
    [instructionsHeader release];
    [_castMyVoteButton release];
    [_undoButton release];
    [cellReferenceList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL) isThereAwriteInCandidateInTheTextField{
    
    // test to see if the text field string length is greater than zero //
    if ([self.cellReferenceList count] > 0) {
        
        if ( [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField].text length] > 0 ) {
            
            return YES;
        }
    }    
    
    return NO;
}

#pragma mark - User Interaction Buttons

-(IBAction) undoButton:(id)sender{
    self.candidateTextField.text = nil;
    
    if ([self.cellReferenceList count] > 0) {
        [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] setText:nil];
    }
    
    [self.myTableView reloadData];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.myTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}


- (IBAction)instructionsButton:(id)sender {
    
    CGRect instructionsButtonRect = [self.instructionsButton frame];
    
    [self.instructionsPopover presentPopoverFromRect:instructionsButtonRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(kPopoverContentSizeWidth, kPopoverContentSizeHeight)];
}

-(IBAction) castVoteButton:(id)sender{
    // vote casted //
    // Two Cases can occure when casting vote: 1) button was pressed but no candidate was writen-in or selected. 2) button was pressed and a candidate was selected or writen-in. //
    // Case 1 //
    // Note: when user selects candidate the UITextField is populated with the candidates name //
    
        
    // if candidate is in the text field then accept the write-in as the item to be voted on... //
    if ( [self isThereAwriteInCandidateInTheTextField] ) {
        
        [self.candidateTextField setText:[[self.cellReferenceList objectAtIndex:0] candidateNameTextField].text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:[NSString stringWithFormat:@"Cast your vote for %@?",[candidateTextField text]] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    } else {
        
        // determine which row in the table view has been selected //
        if ( [[candidateTextField text] length] <= 0 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voter Action Required" message:@"Please write-in an item by selecting the \"create your own unique entry\" row, or select an item from the given list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if ( [[candidateTextField text] length] > 0 ){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlerViewCandidateCastConfirmationtitle message:[NSString stringWithFormat:@"Cast your vote for %@?",[candidateTextField text]] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - File update methods

-(void) updatePluralityDataFileForVoter:(NSNumber*)voterID CandidateName:(NSString *)candidateName{
    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityDataFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    // Load the voterId and candidate's name into an NSArray //
    NSArray *array = [[NSArray alloc] initWithObjects:voterID, candidateName, nil];
    
    // load the new array into the dictionary //
    [dict setObject:array forKey:[NSString stringWithFormat:@"%d",[dict count]]];
    
    // save update plurality data to file //
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not write to Plurality Data file. Voter's ballot was not recorded." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
    [array release];    
    
}

-(void) updatePluralityStatsfileForCandidate:(NSString*)candidateName writeIn:(BOOL) isCandidateWriteIn{
    
    // load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityStatsFileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    // check to see if candidate selected is already in the plurality stats data file //
    BOOL isCandidatInPluralityStatsFile = NO;
    NSArray *array;
    for (NSInteger i = 0; i < [dict count]; i++) {
        array = [[NSArray alloc] initWithObjects:[[dict objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:0],[[dict objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:1],nil];
        
        if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
            
            // candidate was located in the plurality stats file //
            // increment vote count //
            NSInteger lastVoteCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
            NSInteger updatedVoteCount = lastVoteCount + 1;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedVoteCount], nil];
            
            // save updated stats to dictionary //
            [dict setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",i]];
            
            [dataUpdate release];            
            isCandidatInPluralityStatsFile = YES;
            
            // exit for loop //
            i = [dict count];            
        }
        [array release];
    }
    
    if (isCandidatInPluralityStatsFile == NO) {
        
        // candidate was not located on the plurality stats list, thus candidate will be add to the stats list //
        // increment vote count //
        NSInteger lastVoteCount = 0;
        NSInteger updatedVoteCount = lastVoteCount + 1;
        
        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedVoteCount], nil];
        
        // save updated stats to dictionary //
        [dict setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[dict count]]];
        
        [dataUpdate release];
        
    }
    
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update the Plurality Stats Data file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    [dict release];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        
    // handle alert view button presses for candidate confirmation only //
    if ([alertView.title isEqualToString:kAlerViewCandidateCastConfirmationtitle]) {
        if (buttonIndex == 1) {
            // Candidate confirmed by voter //
            
            // get current voter ID //
            NSArray *array = [[NSArray alloc] initWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];
            NSNumber *voterID = [array objectAtIndex:0];
            
            // get voter selected (or write-in) candidate //
            NSString *candidateNameStr = [NSString stringWithString:[candidateTextField text]];
            
            // ascertain if candidate is a write-in or selected candidate //
            BOOL writeInCandidate = [self isCandidateAwriteInCandidate:candidateNameStr];
            
            // update plurality data file //
            [self updatePluralityDataFileForVoter:voterID CandidateName:candidateNameStr];
            
            // update plurality stats data file //
            [self updatePluralityStatsfileForCandidate:candidateNameStr writeIn:writeInCandidate];
            
            // update voter's completed experiment flag //
            [FileHandle toggleFlagForCompletedElectoralExperiment:kPluralityNum];
            
            [array release];
            
            //*************************************************************
            // if the experiment is active than remove this experiment from a master list since it has been completed //
            experimentAdministrator = [MySingelton sharedObject];
            if ( [experimentAdministrator getIsExperimentActive] ) {
                
                // remove this experiment from list of uncompleted experiments //
                NSString *thisExperiment = kPlurality;
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


-(BOOL) isCandidateAwriteInCandidate:(NSString*)candidateName{
    // read in from file the list of non write-in candidates //
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
    
    for (NSInteger i = 0; i < [array count]; i++) {
        if ([((NSString*)[array objectAtIndex:i]) isEqualToString:candidateName]){
            [array release];
            return NO;
        }
    }
    [array release];
    return YES;
}

#pragma mark - keyboard 

- (void)doneEditing: (id) sender {
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
    NSInteger indexValueOfLastRow = [myTableView numberOfRowsInSection:0] - 1;
    
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
    
    // programmatically select last row in the tableView //
    [self.myTableView selectRowAtIndexPath:lastRowIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    
}

- (void)keyboardWillHide: (id)sender {
    
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
    
    [self.myTableView setScrollEnabled:YES];
        
}
 
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = kPlurality;
            
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
    PluralityInstructionsViewController *viewCont = [[PluralityInstructionsViewController alloc] initWithNibName:@"PluralityInstructionsViewController" bundle:nil];
    [viewCont setPopoverDelegate:self];
    
    instructionsPopover = [[UIPopoverController alloc] initWithContentViewController:viewCont];
    [self.instructionsPopover setDelegate:self];
    
    [self.instructionsPopover setPopoverContentSize:CGSizeMake(0, 0)];
    
    [viewCont release];
}

- (void)viewDidUnload
{
   
    [self setInstructionsHeader:nil];
    [self setCastMyVoteButton:nil];
    [self setUndoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //NSLog(@"Plurality View Did Unload");
}

- (void)viewWillAppear:(BOOL)animated
{
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityMessagesFileName];
    
    // load data from file into a local NSDictionary //
    NSDictionary *dataDictionary;
    dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
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

- (void)viewDidAppear:(BOOL)animated {
           
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    // Return YES for supported orientations
    return YES;
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
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
    return [candidateList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellItem = @"PluralityCellItem";
    static NSString *CellItemWriteIn = @"PluralityCellItemWriteIn";
    
    CandidatePluralitycell *itemCell = nil;
    CandidateWriteInPluralitycell *itemWriteInCell = nil;
    
    // store last row in section //
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:indexPath.section];
    if (lastRowIndex != 0) {
        lastRowIndex -= 1;
    }
    
    // if last row then dequeue the write-in cell, else dequeue non write-in cell //
    if (indexPath.row == lastRowIndex) {
        itemWriteInCell = (CandidateWriteInPluralitycell*)[tableView dequeueReusableCellWithIdentifier:CellItemWriteIn];
    } else {
        itemCell = (CandidatePluralitycell*)[tableView dequeueReusableCellWithIdentifier:CellItem];
    }
    
    if (itemCell == nil || itemWriteInCell == nil ) {
        
        NSArray *cel;
        if (indexPath.row == lastRowIndex ) {
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidateWriteInPluralitycell" owner:self options:nil];
            itemWriteInCell = (CandidateWriteInPluralitycell*)[cel objectAtIndex:0];
            
            // assign a reference pointer to each from an array //
            [self.cellReferenceList addObject:itemWriteInCell];
            
            [self.cellReferenceList replaceObjectAtIndex:0 withObject:itemWriteInCell];
            
            itemWriteInCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return itemWriteInCell;
        } else {           
            
            cel = [[NSBundle mainBundle] loadNibNamed:@"CandidatePluralitycell" owner:self options:nil];
            itemCell = (CandidatePluralitycell*)[cel objectAtIndex:0];
            
            // assign to each of these cells a unique canidate name //
            itemCell.textLabel.text = [candidateList objectAtIndex:indexPath.row];
            
            itemCell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
            
            return itemCell;
        }
    }
    
    if (indexPath.row == lastRowIndex) {
        
        [self.cellReferenceList replaceObjectAtIndex:0 withObject:itemWriteInCell];
        
        return itemWriteInCell;
    }
    
    return itemCell;
    
    // Configure the cell...
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableViewCellRowHeight;   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // populate text field with selected item //
    if ( (indexPath.row) < [self.candidateList count]) {
        
        if ([self.cellReferenceList count] > 0) {
            [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] setText:@""];
        }        
        
        self.candidateTextField.text = [candidateList objectAtIndex:indexPath.row];
        
        if ([self.cellReferenceList count] > 0) {
            [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] resignFirstResponder];
        }
        
    } else if (indexPath.row == ([self.myTableView numberOfRowsInSection:0] - 1)) {
        
        if ([self.cellReferenceList count] > 0) {
            [[[self.cellReferenceList objectAtIndex:0] candidateNameTextField] becomeFirstResponder];
        }        
    }    
}

#pragma mark - Plurality popover view delegate

- (void)pluralityPopoverDidAppear:(PluralityInstructionsViewController *)popoverViewController {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.instructionsHeader setAlpha:0.15];
    [UIView commitAnimations];
}
- (void)pluralityPopoverDidDisappear:(PluralityInstructionsViewController *)popoverViewController{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.instructionsHeader setAlpha:1.0];
    [UIView commitAnimations];
}




@end
