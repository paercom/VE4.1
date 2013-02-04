//
//  DataImporterThruEmailViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 12/1/12.
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

#import "DataImporterThruEmailViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"

#import "UserDemographicsViewController.h"
#import "UserDemographicTableViewController.h"

// valid data file names //
const NSString *plurality           = @"Plurality";
const NSString *plurality_stats     = @"PluralityStats";
const NSString *approval            = @"Approval";
const NSString *approvalStatsYay    = @"ApprovalStatsYay";
const NSString *approvalStatsNay    = @"ApprovalStatsNay";
const NSString *range               = @"Range";
const NSString *rangeStats          = @"RangeStats";
const NSString *irv                 = @"IRV";
const NSString *irvStatsCat1        = @"IRVstatsCat1";
const NSString *irvStatsCat2        = @"IRVstatsCat2";
const NSString *irvStatsCat3        = @"IRVstatsCat3";
const NSString *userDemographic     = @"UserDemographic";
const NSString *candidateList       = @"CandidateList";

@interface DataImporterThruEmailViewController () <UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *dataViewer_TextView;
@property (retain, nonatomic) IBOutlet UILabel *dataFileName_Label;
@property (retain, nonatomic) IBOutlet UIButton *importAndMergeDataButton;

@property (nonatomic, retain) NSURL *sourceURL;
@property (nonatomic, retain) NSDictionary *incomingDataDictionary;
@property (nonatomic, retain) NSMutableDictionary *localDataDictionary;

- (IBAction)importAndMergeDataButtonPressed:(UIButton *)sender;
@end

@implementation DataImporterThruEmailViewController

@synthesize incomingDataDictionary = _incomingDataDictionary;
@synthesize localDataDictionary = _localDataDictionary;
@synthesize sourceURL = _sourceURL;

#pragma mark - Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Initialization Setup Methods
- (void) setUpImportDataView {
    
    // determine if the URL contains a valid file name -- return void and display an alert if the filename is invalid //
    // ----------------------------------------------- //
    NSString *acceptableFilename = [self nameOfValidDataFileFromURL:self.sourceURL];
    if (acceptableFilename == nil) {
        
        NSString *message = [NSString stringWithFormat:@"The selected data filename \"%@\" is invalid.",self.sourceURL.lastPathComponent];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Data Filename" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        [alert release], alert = nil;
        
        return;
    }
    // ----------------------------------------------- //
    
    [self setupDataFiles];    
    
    [self.dataViewer_TextView setText:[NSString stringWithFormat:@"%@",self.incomingDataDictionary]];
    
    [self.dataFileName_Label setText:[NSString stringWithFormat:@"%@",acceptableFilename]];
    
    // enable user action button //
    self.importAndMergeDataButton.enabled = YES;
    
}

- (void) setupDataFiles
{    
    [self setupPluralityDataFiles];
    [self setupApprovalDataFiles];
    [self setupRangeDataFiles];
    [self setupIRVDataFiles];
}

#pragma mark - User Action Method
- (IBAction)importAndMergeDataButtonPressed:(UIButton *)sender {
    
    NSString *acceptableFilename = [self nameOfValidDataFileFromURL:self.sourceURL];
    BOOL fileWriteStatus = NO;
    
    if ([plurality isEqualToString:acceptableFilename]) {
        // Plurality data file... //
        fileWriteStatus = [self mergePluralityDataSets];
    }
    else if ([plurality_stats isEqualToString:acceptableFilename]) {
        // PluralityStats data file... //
        fileWriteStatus = [self mergePluralityStatsDataSets];
    }
    else if ([approval isEqualToString:acceptableFilename]) {
        // Approval data file... //
        fileWriteStatus = [self mergeApprovalDataSets];
    }
    else if ([approvalStatsYay isEqualToString:acceptableFilename]) {
        // ApprovalStatsYay data file... //
        fileWriteStatus = [self mergeApprovalStatsYayDataSets];
    }
    else if ([approvalStatsNay isEqualToString:acceptableFilename]) {
        // ApprovalStatsNay data file... //
        fileWriteStatus = [self mergeApprovalStatsNayDataSets];
    }
    else if ([range isEqualToString:acceptableFilename]) {
        // Range data file... //
        fileWriteStatus = [self mergeRangeDataSets];
    }
    else if ([rangeStats isEqualToString:acceptableFilename]) {
        // Range data file... //
        fileWriteStatus = [self mergeRangeStatsDataSets];
    }
    else if ([irv isEqualToString:acceptableFilename]) {
        // IRV data file... //
        fileWriteStatus = [self mergeIRVDataSets];
    }
    else if ([irvStatsCat1 isEqualToString:acceptableFilename]) {
        // IRV Category One data file... //
        fileWriteStatus = [self mergeIRVCatOneStatsDataSets];
    }
    else if ([irvStatsCat2 isEqualToString:acceptableFilename]) {
        // IRV Category Two data file... //
        fileWriteStatus = [self mergeIRVCatTwoStatsDataSets];
    }
    else if ([irvStatsCat3 isEqualToString:acceptableFilename]) {
        // IRV Category Three data file... //
        fileWriteStatus = [self mergeIRVCatThreeStatsDataSets];
    }
    else if ([candidateList isEqualToString:acceptableFilename]) {
        // Candidate List data file... //
        fileWriteStatus = [self replaceCandidateListWithIncommingList];
    }
    else if ([userDemographic isEqualToString:acceptableFilename]) {
        // User Demographic data file... //
        fileWriteStatus = [self mergeUserDemographicDataSets];
    }
    
    if (fileWriteStatus == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Failed" message:@"The selected file failed to import" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        [alert release], alert = nil;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Utility Methods
- (NSInteger)theLargestVoterIDInThisDictionaryOfArrays:(NSDictionary*)dictionary {
    // This method returns the largest voter ID value in a dictionary of arrays //
    // A negative one is returned if an error occured... //
    // The Form of the Dictionary must be:  @{
    //                                      @"key1" : @[<voter ID=1>,<other voter data>,...,<last voter data>],
    //                                      @"key2" : @[<voter ID=2>,<other voter data>,...,<last voter data>],
    //                                      ...     : ...,
    //                                      @"keyn" : @[<voter ID=n>,<other voter data>,...,<last voter data>]
    //                                      };
    // Note: the data structure after the object @"keyn" is an NSArray... //
    
    // does the dictionary contain at least one object? if so then proceed... //
    if ([dictionary count] == 0 ) { return -1; }
    
    // is the object for a given key in the dictionary in fact an NSArray? if is so then proceed... //
    for (id key in dictionary) { if ([[dictionary valueForKey:key] isKindOfClass:[NSArray class]] == NO) { return -1; }  }
    
    // at this point our inbound dictionary has passed the basic data structure attributes requierments //
    // we now proceed to find the largest voter ID //
    
    // get all the keys from our dictionary //
    NSArray *allKeysArray = [dictionary allKeys];
    
    // get the data array of the voter that corresponds to the firs key in the above array //
    NSArray *someVoterArray = [dictionary valueForKey:[allKeysArray objectAtIndex:0]];
    
    // assume that the first element is the largest //
    NSInteger assumedLargestVoterID = ((NSNumber*)[someVoterArray objectAtIndex:0]).integerValue;
    
    // iterate thru our dictionary to test the assumption that in fact the largest value was in the first voter data array. if we are //
    // wrong in our assumption then we assign the newly discoverd largest value as the assumed largest value and continue our search //
    for (int nextValue = 1; nextValue < [allKeysArray count]; nextValue++) {
        
        // get the data array of the voter that corresponds to the firs key in the above array //
        someVoterArray = [dictionary valueForKey:[allKeysArray objectAtIndex:nextValue]];
        
        NSInteger voterID = ((NSNumber*)[someVoterArray objectAtIndex:0]).integerValue;
        if (assumedLargestVoterID < voterID) {
            // a larger voter ID was discoverd... //
            assumedLargestVoterID = voterID;
        }
    }    
    return assumedLargestVoterID;
}

- (NSInteger)theLargestVoterIDInThisDictionaryOfDictionaries:(NSDictionary*)dictionary {
    // This method returns the largest voter ID value in a dictionary of dictionaries of NSManagedObjects //
    // A negative one is returned if an error occured... //
    // The Form of the Dictionary must be:  @{
    //                                      @"key1" : @{@"key(0,0)" : NSManagedObject,...,@"key(m,0)" : NSManagedObject],
    //                                      @"key2" : @{@"key(0,1)" : NSManagedObject,...,@"key(m,1)" : NSManagedObject],
    //                                      ...     : ...,
    //                                      @"keyn" : @{@"key(0,n)" : NSManagedObject,...,@"key(m,n)" : NSManagedObject]
    //                                      };
    // Note: the data structure after the object @"keyn" is an NSDictionary... //
    
    // does the dictionary contain at least one object? if so then proceed... //
    if ([dictionary count] == 0 ) { return -1; }
    
    // is the object for a given key in the dictionary in fact an NSDictionary? if is so then proceed... //
    for (id key in dictionary) { if ([[dictionary valueForKey:key] isKindOfClass:[NSDictionary class]] == NO) { return -1; }  }
    
    // at this point our inbound dictionary has passed the basic data structure attributes requierments //
    // we now proceed to find the largest voter ID //
    
    // get all the keys from our dictionary //
    NSArray *allKeysArray = [dictionary allKeys];
    
    // get the data dictionary of the voter that corresponds to the firs key in the above array //
    NSDictionary *someVoterDictionary = [dictionary valueForKey:[allKeysArray objectAtIndex:0]];
    
    // assume that the first element is the largest //
    NSInteger assumedLargestVoterID = ((NSNumber*)[someVoterDictionary valueForKey:@"userID.description"]).integerValue;
    
    // iterate thru our dictionary to test the assumption that in fact the largest value was in the first voter data dictionary. if we are //
    // wrong in our assumption then we assign the newly discoverd largest value as the assumed largest value and continue our search //
    for (int nextValue = 1; nextValue < [allKeysArray count]; nextValue++) {
        
        // get the data dictionary of the voter that corresponds to the firs key in the above array //
        someVoterDictionary = [dictionary valueForKey:[allKeysArray objectAtIndex:nextValue]];
        
        NSInteger voterID = ((NSNumber*)[someVoterDictionary valueForKey:@"userID.description"]).integerValue;
        if (assumedLargestVoterID < voterID) {
            // a larger voter ID was discoverd... //
            assumedLargestVoterID = voterID;
        }
    }
    return assumedLargestVoterID;
}

#pragma mark - Replace Candidate List Data Set Methods
// this method replaces the existing candidate list with the user selected candidate import list //
- (BOOL)replaceCandidateListWithIncommingList {
    
    //NSLog(@" ...... Incoming Data: <<< %@ >>> ......",self.incomingDataDictionary);
    
    // the candidate list is a single array that was wrapped in a dictionary so that it can pass thru the structure of the code since most incoming data is a dictionary //
    // and we didn't want to heavily modify the code to handle a single instance of the incoming candidate list //
    NSMutableArray *candidateList = [self.incomingDataDictionary valueForKey:@"candidateList"];
    
    if ([candidateList count] > 0) {
        // save Candidate List to file //
        NSString *filepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
        if ( [candidateList writeToFile:filepath atomically:YES] ){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Saved" message:@"The current Candidate List has been saved to file." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save current Candidate List to file." delegate:nil cancelButtonTitle:@"Sucks!" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Merge Data Sets Methods -- (User Demographic)
// this method merges an imported User Demographic data set with an existing User Demographic data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeUserDemographicDataSets
{
    NSURL *importedSQLITEdbURL = [self.incomingDataDictionary valueForKey:@"UserDemographic"];
    UserDemographicTableViewController *userDemographicDataController = [[UserDemographicTableViewController alloc] initWith_sqlite_dataBase:importedSQLITEdbURL];
    
    // replace the dictionary's NSURL object with the actual data the NSURL points to //
    self.incomingDataDictionary = [userDemographicDataController retrieveAnNSDictionaryOfEntitiesFromCoreDataStore];
    if (self.incomingDataDictionary == nil) { return NO; } // something went wrong... //    
    
    return [self forUserDemographic_mergeThisImportedDataDictionaryAndUpdateItsKeysWithOurCoreDataStore:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary]];
}

- (BOOL) forUserDemographic_mergeThisImportedDataDictionaryAndUpdateItsKeysWithOurCoreDataStore:(NSMutableDictionary*)latestDataDictionary
{
    //NSLog(@" ...... Latest Data Dictionary: <<< %@ >>> ......",latestDataDictionary);
    
    // get data from the current data store and compute the userID offset value--value is used to remap the useID's so that they do not repeat //
    // -------------------------------------------------- //
    UserDemographicTableViewController *currentUserDemoCoreDataStroe = [[UserDemographicTableViewController alloc] init];
    NSDictionary *userDataStoreDictionary = [currentUserDemoCoreDataStroe retrieveAnNSDictionaryOfEntitiesFromCoreDataStore];
    
    //NSLog(@" ...... Current Data Dictionary: <<< %@ >>> ......",userDataStoreDictionary);
    
    // compute a user id offset; since we are remapping the existing data sets to a new user id //
    NSInteger newUserID_offset = [self theLargestVoterIDInThisDictionaryOfDictionaries:userDataStoreDictionary];
    if (newUserID_offset < 1) { newUserID_offset = 0; }
    
    userDataStoreDictionary = nil;
    // -------------------------------------------------- //
    
    
    if (latestDataDictionary == nil) { return NO; } // something went wrong... //
    
    UserDemographicsViewController *incommingDataMergerController = [[UserDemographicsViewController alloc] init];
    
    NSArray *dictionaryKeys = [latestDataDictionary allKeys];
    
    for (id key in dictionaryKeys) {
        [incommingDataMergerController saveUserDemographicsToDataStoreGivenData:[latestDataDictionary objectForKey:key] withNewUserIDoffsetValue:newUserID_offset];
    }
    
    return YES;
}

#pragma mark - Merge Data Sets Methods -- (IRV)
// this method merges an imported IRV data set with an existing IRV data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeIRVDataSets
{    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVdataFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forIRVOnly_mergeThisNewDictionaryAndUpdateItsKeys:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update plurality data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}
// used to merge two IRV Sets //
- (void) forIRVOnly_mergeThisNewDictionaryAndUpdateItsKeys:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // we get the largest voter ID size in our existing dictionary, since it is appended with new data and we need this constant value to remap our voter's ID //
    NSInteger startingSizeOfExistingDictionary = [self theLargestVoterIDInThisDictionaryOfArrays:existingDataDictionary];
    
    if (startingSizeOfExistingDictionary == -1) { return; } // terminate method since there was an error getting the startingSizeOfExistingDictionary //
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original voter ID -- //
        NSInteger originalVoterID = ((NSNumber*)[newItem objectAtIndex:0]).integerValue;
        
        // -- original voter ID remapped to the existing dictionary -- we subtract by one because our existing dictionary contains a dummy value -- //
        NSInteger voterID = (originalVoterID) + startingSizeOfExistingDictionary;
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:1]);
        
        // -- original candidate approval value -- we assign this integer for clarity... //
        NSString *candidateRangeScore = ((NSString*)[newItem objectAtIndex:2]);
        
        // Load the voterId and candidate's name into an updated NSArray -- we do this because we remapped the voter ID //
        NSMutableArray *updatedArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:voterID], candidateName, candidateRangeScore, nil];
        
        // load the new array into the dictionary //
        [existingDataDictionary setObject:updatedArray forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
    }
}

// this method merges an imported irv stats data set with an existing irv stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeIRVCatOneStatsDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forIRVStatsCategoryOneOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update irv data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// this method merges an imported irv stats data set with an existing irv stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeIRVCatTwoStatsDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forIRVStatsCategoryOneOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update irv data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// this method merges an imported irv stats data set with an existing irv stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeIRVCatThreeStatsDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forIRVStatsCategoryOneOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update irv data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// used to merge two RangeStats sets //
- (void) forIRVStatsCategoryOneOnly_mergeThisNewDictionary:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:0]);
        
        // -- original candidate irv value -- we assign this integer for clarity... //
        NSInteger candidateIRVTallyRating = ((NSNumber*)[newItem objectAtIndex:1]).integerValue;
        
        BOOL isCandidatInIRVstatsFile = NO;
        
        // check to see if candidate selected is already in the IRV Stats data file for a particular Category //
        for (NSInteger k = 0; k < [existingDataDictionary count]; k++) {
            
            NSString *key = [NSString stringWithFormat:@"%d",k];
            NSArray *array = [[NSArray alloc] initWithObjects:[[existingDataDictionary objectForKey:key] objectAtIndex:0], [[existingDataDictionary objectForKey:key] objectAtIndex:1], nil];
            
            if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
                
                // candidate was located in the Range stats file //
                // increment Range category count for this candidate //
                NSInteger lastValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                NSInteger updatedValueCount = lastValueCount + candidateIRVTallyRating;
                
                NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedValueCount], nil];
                
                // save updated stats to dictionary //
                [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                
                [dataUpdate release], dataUpdate = nil;
                
                isCandidatInIRVstatsFile = YES;
                
                // exit for loop //
                k = [existingDataDictionary count];
            }// end if block //
            [array release];
        }// end nested for block //
        
        // candidate was not located on the irv Stats list, thus candidate is added to the stats list //
        if (isCandidatInIRVstatsFile == NO) {
            
            NSInteger updatedValueCount = candidateIRVTallyRating;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedValueCount], nil];
            
            // save updated stats to dictionary //
            [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
            
            [dataUpdate release];
        }
    }
    
}

#pragma mark - Merge Data Sets Methods -- (Range)
// this method merges an imported range data set with an existing range data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeRangeDataSets
{    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeDataFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forRangeOnly_mergeThisNewDictionaryAndUpdateItsKeys:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update plurality data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// used to merge two range Sets //
- (void) forRangeOnly_mergeThisNewDictionaryAndUpdateItsKeys:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // we get the largest voter ID size in our existing dictionary, since it is appended with new data and we need this constant value to remap our voter's ID //
    NSInteger startingSizeOfExistingDictionary = [self theLargestVoterIDInThisDictionaryOfArrays:existingDataDictionary];
    
    if (startingSizeOfExistingDictionary == -1) { return; } // terminate method since there was an error getting the startingSizeOfExistingDictionary //
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original voter ID -- //
        NSInteger originalVoterID = ((NSNumber*)[newItem objectAtIndex:0]).integerValue;
        
        // -- original voter ID remapped to the existing dictionary -- we subtract by one because our existing dictionary contains a dummy value -- //
        NSInteger voterID = (originalVoterID) + startingSizeOfExistingDictionary;
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:1]);
        
        // -- original candidate approval value -- we assign this integer for clarity... //
        NSString *candidateRangeScore = ((NSString*)[newItem objectAtIndex:2]);
        
        // Load the voterId and candidate's name into an updated NSArray -- we do this because we remapped the voter ID //
        NSMutableArray *updatedArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:voterID], candidateName, candidateRangeScore, nil];
        
        // load the new array into the dictionary //
        [existingDataDictionary setObject:updatedArray forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
    }
    
}

// this method merges an imported range stats data set with an existing range stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeRangeStatsDataSets
{    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeStatsFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forRangeStatsOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update approval data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// used to merge two RangeStats sets //
- (void) forRangeStatsOnly_mergeThisNewDictionary:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    //    NSLog(@" ...... APPROVAL (YAY): <<< %@ >>> ......",myLatestDictionaryValuesArray);
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:0]);
        
        // -- original candidate range value -- we assign this integer for clarity... //
        NSInteger candidateRangeTallyRating = ((NSNumber*)[newItem objectAtIndex:1]).integerValue;
        
        BOOL isCandidatInRangestatsFile = NO;
        
        // check to see if candidate selected is already in the Range Stats data file for a particular Category //
        for (NSInteger k = 0; k < [existingDataDictionary count]; k++) {
            
            NSString *key = [NSString stringWithFormat:@"%d",k];
            NSArray *array = [[NSArray alloc] initWithObjects:[[existingDataDictionary objectForKey:key] objectAtIndex:0], [[existingDataDictionary objectForKey:key] objectAtIndex:1], nil];
            
            if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
                
                // candidate was located in the Range stats file //
                // increment Range category count for this candidate //
                NSInteger lastValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                NSInteger updatedValueCount = lastValueCount + candidateRangeTallyRating;
                
                NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedValueCount], nil];
                
                // save updated stats to dictionary //
                [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                
                [dataUpdate release], dataUpdate = nil;
                
                isCandidatInRangestatsFile = YES;
                
                // exit for loop //
                k = [existingDataDictionary count];
            }// end if block //
            [array release];
        }// end nested for block //
        
        // candidate was not located on the range Stats list, thus candidate is added to the stats list //
        if (isCandidatInRangestatsFile == NO) {
            
            NSInteger updatedValueCount = candidateRangeTallyRating;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedValueCount], nil];
            
            // save updated stats to dictionary //
            [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
            
            [dataUpdate release];
        }
    }
    
}

#pragma mark - Merge Data Sets Methods -- (Approval)
// this method merges an imported approval data set with an existing approval data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeApprovalDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kApprovalDataFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forApprovalOnly_mergeThisNewDictionaryAndUpdateItsKeys:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update Approval data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// this method merges an imported approval stats data set with an existing approval stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergeApprovalStatsYayDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forApprovalStatsYayOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update approval data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

- (BOOL)mergeApprovalStatsNayDataSets
{    
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forApprovalStatsNayOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update approval data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// used to merge two approval Sets //
- (void) forApprovalOnly_mergeThisNewDictionaryAndUpdateItsKeys:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // we get the largest voter ID size in our existing dictionary, since it is appended with new data and we need this constant value to remap our voter's ID //
    NSInteger startingSizeOfExistingDictionary = [self theLargestVoterIDInThisDictionaryOfArrays:existingDataDictionary];
    
    if (startingSizeOfExistingDictionary == -1) { return; } // terminate method since there was an error getting the startingSizeOfExistingDictionary //
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original voter ID -- //
        NSInteger originalVoterID = ((NSNumber*)[newItem objectAtIndex:0]).integerValue;
        
        // -- original voter ID remapped to the existing dictionary -- we subtract by one because our existing dictionary contains a dummy value -- //
        NSInteger voterID = (originalVoterID) + startingSizeOfExistingDictionary;
                
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:1]);
        
        // -- original candidate approval value -- we assign this integer for clarity... //
        NSString *candidateApprovalRating = ((NSString*)[newItem objectAtIndex:2]);
        
        // Load the voterId and candidate's name into an updated NSArray -- we do this because we remapped the voter ID //
        NSMutableArray *updatedArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:voterID], candidateName, candidateApprovalRating, nil];
        
        // load the new array into the dictionary //
        [existingDataDictionary setObject:updatedArray forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
    }
}

// used to merge two ApprovalStats sets //
- (void) forApprovalStatsYayOnly_mergeThisNewDictionary:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
//    NSLog(@" ...... APPROVAL (YAY): <<< %@ >>> ......",myLatestDictionaryValuesArray);
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:0]);

        // -- original candidate approval value -- we assign this integer for clarity... //
        NSInteger candidateApprovalTallyRating = ((NSNumber*)[newItem objectAtIndex:1]).integerValue;
        
        BOOL isCandidatInApprovalstatsFile = NO;
        
        // check to see if candidate selected is already in the Approval Stats data file for a particular Category //
        for (NSInteger k = 0; k < [existingDataDictionary count]; k++) {
            
            NSString *key = [NSString stringWithFormat:@"%d",k];
            NSArray *array = [[NSArray alloc] initWithObjects:[[existingDataDictionary objectForKey:key] objectAtIndex:0], [[existingDataDictionary objectForKey:key] objectAtIndex:1], nil];
            
            if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
                
                // candidate was located in the Approval category stats file //
                // increment Approval category count for this candidate //
                NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                NSInteger updatedCategoryValueCount = lastCategoryValueCount + candidateApprovalTallyRating;
                
                NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                
                // save updated stats to dictionary //
                [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                
                [dataUpdate release], dataUpdate = nil;
                
                isCandidatInApprovalstatsFile = YES;
                
                // exit for loop //
                k = [existingDataDictionary count];
            }// end if block //
            [array release];
        }// end nested for block //
        
        // candidate was not located on the approval Stats list, thus candidate is added to the stats list //
        if (isCandidatInApprovalstatsFile == NO) {
            
            NSInteger updatedCategoryValueCount = candidateApprovalTallyRating;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
            
            // save updated stats to dictionary //
            [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
            
            [dataUpdate release];
        }
    }
}
- (void) forApprovalStatsNayOnly_mergeThisNewDictionary:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
//    NSLog(@" ...... APPROVAL (NAY): <<< %@ >>> ......",myLatestDictionaryValuesArray);
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:0]);
        
        // -- original candidate approval value -- we assign this integer for clarity... //
        NSInteger candidateApprovalTallyRating = ((NSNumber*)[newItem objectAtIndex:1]).integerValue;
        
        BOOL isCandidatInApprovalstatsFile = NO;
        
        // check to see if candidate selected is already in the Approval Stats data file for a particular Category //
        for (NSInteger k = 0; k < [existingDataDictionary count]; k++) {
            
            NSString *key = [NSString stringWithFormat:@"%d",k];
            NSArray *array = [[NSArray alloc] initWithObjects:[[existingDataDictionary objectForKey:key] objectAtIndex:0], [[existingDataDictionary objectForKey:key] objectAtIndex:1], nil];
            
            if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
                
                // candidate was located in the Approval category stats file //
                // increment Approval category count for this candidate //
                NSInteger lastCategoryValueCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
                NSInteger updatedCategoryValueCount = lastCategoryValueCount + candidateApprovalTallyRating;
                
                NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
                
                // save updated stats to dictionary //
                [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",k]];
                
                [dataUpdate release], dataUpdate = nil;
                
                isCandidatInApprovalstatsFile = YES;
                
                // exit for loop //
                k = [existingDataDictionary count];
            }// end if block //
            [array release];
        }// end nested for block //
        
        // candidate was not located on the approval Stats list, thus candidate is added to the stats list //
        if (isCandidatInApprovalstatsFile == NO) {
            
            NSInteger updatedCategoryValueCount = candidateApprovalTallyRating;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedCategoryValueCount], nil];
            
            // save updated stats to dictionary //
            [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
            
            [dataUpdate release];
        }
    }
}

#pragma mark - Merge Data Sets Methods -- (PLURALITY)
// this method merges an imported plurality data set with an existing plurality data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergePluralityDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityDataFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    [self forPluralityOnly_mergeThisNewDictionaryAndUpdateItsKeys:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    // save update plurality data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}
// this method merges an imported plurality stats data set with an existing plurality stats data set (an existing data set is the current data on file) -- returns YES on success... //
- (BOOL)mergePluralityStatsDataSets
{
    // Load the contents of the current file into an NSDictionary //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityStatsFileName];
    NSMutableDictionary *existingDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    NSLog(@" ...... Plurality STATS: <<< %@ >>> ......",existingDictionary);
    
    [self forPluralityStatsOnly_mergeThisNewDictionary:[NSMutableDictionary dictionaryWithDictionary:self.incomingDataDictionary] withThisDictionary:existingDictionary];
    
    NSLog(@" ...... Plurality STATS: <<< %@ >>> ......",existingDictionary);
    
    // save update plurality data to file //
    return [existingDictionary writeToFile:filepath atomically:YES];
}

// used to merge two Plurality Sets //
- (NSDictionary*) forPluralityOnly_mergeThisNewDictionaryAndUpdateItsKeys:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{    
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // we get the starting size of the existing dictionary, since it is appended with new data and we need this constant value to remap our voter's ID //
    NSInteger startingSizeOfExistingDictionary = [existingDataDictionary count];
    
    // iterate thru our latest data values and append the new data values to our existing dictionary with remapped voter ID's //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
        
        // -- original voter ID -- //
        NSInteger originalVoterID = ((NSNumber*)[newItem objectAtIndex:0]).integerValue;
        
        // -- original voter ID remapped to the existing dictionary -- we subtract by one because our existing dictionary contains a dummy value -- //
        NSInteger voterID = (originalVoterID - 1) + startingSizeOfExistingDictionary;
        
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:1]);
        
        // Load the voterId and candidate's name into an updated NSArray -- we do this because we remapped the voter ID //
        NSMutableArray *updatedArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:voterID], candidateName, nil];
        
        // load the new array into the dictionary //
        [existingDataDictionary setObject:updatedArray forKey:[NSString stringWithFormat:@"%d",voterID]];
    }
    
    return existingDataDictionary;
}

// used to merge two PluralityStats sets //
- (NSDictionary*) forPluralityStatsOnly_mergeThisNewDictionary:(NSMutableDictionary*)latestDataDictionary withThisDictionary:(NSMutableDictionary*)existingDataDictionary
{
    // remove the "0" key from the new dictionary -- this key must only appear once since its empty value is used as a place holder... //
    [latestDataDictionary removeObjectForKey:@"0"];
    
    // get just the values from our latest data dictionary //
    NSArray *myLatestDictionaryValuesArray = [latestDataDictionary allValues];
    
    // iterate thru our latest data values and update the new data values to our existing dictionary //
    for (NSArray *newItem in myLatestDictionaryValuesArray) {
                
        // -- original candidateName -- we assign this string for clarity... //
        NSString *candidateName = ((NSString*)[newItem objectAtIndex:0]);
        
        // -- original candidate tally -- we assign this integer for clarity... //
        NSInteger importedCandidateTally = ((NSNumber*)[newItem objectAtIndex:1]).integerValue;
        
        // update our local plurality stats data store //
        [self updatePluralityStatsfileForCandidate:candidateName withTally:importedCandidateTally toExistingDataDictionary:existingDataDictionary];
    }
    
    return existingDataDictionary;
}

-(void) updatePluralityStatsfileForCandidate:(NSString*)candidateName withTally:(NSInteger)importedTally toExistingDataDictionary:(NSMutableDictionary*)existingDataDictionary
{        
    // check to see if candidate selected is already in the plurality stats data file //
    BOOL isCandidatInPluralityStatsFile = NO;
    NSArray *array;
    for (NSInteger i = 0; i < [existingDataDictionary count]; i++) {
        array = [[NSArray alloc] initWithObjects:
                 [[existingDataDictionary objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:0],
                 [[existingDataDictionary objectForKey:[NSString stringWithFormat:@"%d",i]] objectAtIndex:1],nil];
        
        if ( [((NSString*)[array objectAtIndex:0]) isEqualToString:candidateName] ) {
            
            // candidate was located in the plurality stats file //
            // increment vote count //
            NSInteger lastVoteCount = [((NSNumber*)[array objectAtIndex:1]) integerValue];
            NSInteger updatedVoteCount = lastVoteCount + importedTally;
            
            NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedVoteCount], nil];
            
            // save updated stats to dictionary //
            [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",i]];
            
            [dataUpdate release];
            isCandidatInPluralityStatsFile = YES;
            
            // exit for loop //
            i = [existingDataDictionary count];
        }
        [array release];
    }
    
    if (isCandidatInPluralityStatsFile == NO) {
        
        // candidate was not located on the plurality stats list, thus candidate will be add to the stats list //
        // increment vote count //
        NSInteger lastVoteCount = 0;
        NSInteger updatedVoteCount = lastVoteCount + importedTally;
        
        NSArray *dataUpdate = [[NSArray alloc] initWithObjects:candidateName, [NSNumber numberWithInteger:updatedVoteCount], nil];
        
        // save updated stats to dictionary //
        [existingDataDictionary setObject:dataUpdate forKey:[NSString stringWithFormat:@"%d",[existingDataDictionary count]]];
        
        [dataUpdate release];
        
    }
}

#pragma mark - File Setup Methods

- (void) setupPluralityDataFiles
{
    // Check to see if Plurality data file was created //
    BOOL pluralityFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityDataFileName]];
    // Check to see if Plurality stats data file was created //
    BOOL pluralityStatsFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityStatsFileName]];
    
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
}

- (void) setupApprovalDataFiles
{
    // Check to see if Approval data file was created //
    BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalDataFileName]];
    // Check to see if Approval stats data file was created //
    BOOL doesYayStatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalYayStatsFileName]];
    BOOL doesNayStatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kApprovalNayStatsFileName]];
    
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
}

- (void) setupRangeDataFiles
{
    // Check to see if Plurality data file was created //
    BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeDataFileName]];
    // Check to see if Plurality stats data file was created //
    BOOL doesStatsFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kRangeStatsFileName]];
    
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

}

- (void) setupIRVDataFiles
{
    // Check to see if IRV data file was created //
    BOOL doesDataFileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVdataFileName]];
    // Check to see if IRV stats data file was created //
    BOOL doesCat1StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName]];
    BOOL doesCat2StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName]];
    BOOL doesCat3StatsFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName]];
        
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
}

#pragma mark - Import Data Filename Checker Methods

// returns the name of the valid data filename else it returns nil -- we check the filename in this way because our incomming file name is at times //
// attached with a numeric increment like so Plurality-x.data, where x is the increment. This occures if the Plurality.data is sent to this app more than once.//
- (NSString*)nameOfValidDataFileFromURL:(NSURL*)sourceURL
{
    NSArray *arrayOfacceptableFilenames_plurality   = [NSArray arrayWithObjects:plurality_stats, plurality, nil];
    NSArray *arrayOfacceptableFilenames_approval    = [NSArray arrayWithObjects:approvalStatsYay, approvalStatsNay, approval, nil];
    NSArray *arrayOfacceptableFilenames_range       = [NSArray arrayWithObjects:rangeStats, range, nil];
    NSArray *arrayOfacceptableFilenames_irv         = [NSArray arrayWithObjects:irvStatsCat1, irvStatsCat2, irvStatsCat3, irv, nil];
    NSArray *arrayOfacceptableFilenames_demographic = [NSArray arrayWithObjects:userDemographic, nil];
    NSArray *arrayOfacceptableFilenames_candidate   = [NSArray arrayWithObjects:candidateList, nil];
    
    // store the last component of the incomming NSURL //
    NSString *lastComponentOfURL_string = [sourceURL lastPathComponent];
    
    // Check for known unacceptable filenames -- this is a list of files that would normally get thru... //
    // --------------------------------------------------- //
    NSArray *arrayOfKnownUnacceptableFilenames      = [NSArray arrayWithObjects:@"PluralityMessages", @"ApprovalMessages", @"RangeMessages", @"IRVMessages", nil];
    for (NSString *unacceptableFilename in arrayOfKnownUnacceptableFilenames) {
        
        NSRange rangeOfFoundUnacceptableFilename = [lastComponentOfURL_string rangeOfString:unacceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundUnacceptableFilename.location != NSNotFound) {
            // we return nil since finding this file with given name is unacceptable //
            return nil;
        }
    }
    // --------------------------------------------------- //
    
    // We start with the longest string first within a given filename catagory since for example the string "Range" appears //
    // in both "RangeStats" and "Range." Starting with the shortest string first would result in a false positive search... //
    NSRange rangeOfFoundAcceptableFilename;
    
    // check for match under plurality //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_plurality) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // check for match under approval //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_approval) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // check for match under range //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_range) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // check for match under irv //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_irv) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // check for match under userDemographic //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_demographic) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // check for match under candidateList //
    for (NSString *acceptableFilename in arrayOfacceptableFilenames_candidate) {
        
        rangeOfFoundAcceptableFilename = [lastComponentOfURL_string rangeOfString:acceptableFilename];
        
        // did we find any thing? //
        if (rangeOfFoundAcceptableFilename.location != NSNotFound) {
            return acceptableFilename;
        }
    }
    
    // if after iterating thru our acceptable filenames array we did not find one then we return nil //
    return nil;
}

#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andWithEmailImportedDataDictionary:(NSDictionary*)importedDataDictionary fromURL:(NSURL*)sourcURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //        NSLog(@" ...... DATA: <<< %@ >>> ......",importedDataDictionary);
        
        // initialize local data store //
        self.incomingDataDictionary = importedDataDictionary;
        self.sourceURL = sourcURL;
        
        // disable user action button //
        self.importAndMergeDataButton.enabled = NO;
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // magic... //
    [self setUpImportDataView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_dataViewer_TextView release];
    [_dataFileName_Label release];
    [_incomingDataDictionary release];
    [_localDataDictionary release];
    [_sourceURL release];
    [_importAndMergeDataButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDataViewer_TextView:nil];
    [self setDataFileName_Label:nil];
    [self setIncomingDataDictionary:nil];
    [self setLocalDataDictionary:nil];
    [self setSourceURL:nil];
    [self setImportAndMergeDataButton:nil];
    [super viewDidUnload];
}
@end
