//
//  IRV_ResultsViewController.m
//  ElectoralExperiment3
//
//  Created by Stefan Agapie on 6/2/12.
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

#import "IRV_ResultsViewController.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"

@interface IRV_ResultsViewController ()

- (NSString*)textStringWithComputedIRVResultFromVoterVectorList:(NSArray*)voterVectorList;
- (NSArray*)arrayWithVoterVectorListFromDataSetsInFilepath;

@end

@implementation IRV_ResultsViewController
@synthesize dataDictionary = _dataDictionary;
@synthesize IRV_ResultsTextView = _IRV_ResultsTextView;


- (NSDictionary*)dataDictionary
{
    if (_dataDictionary == nil) {
        // get filepath for Range data set //
        NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVdataFileName];
        
        // load data from file into a local NSDictionary //
        //self.dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filepath];
        _dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    }
    return [_dataDictionary retain];
}

#pragma mark - View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = kIRV_DataResultsViewerTitle;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDataDictionary:nil];
    [self setIRV_ResultsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    // get IRV results //    
    NSArray *vectorList = [self arrayWithVoterVectorListFromDataSetsInFilepath];
    NSString *resultsString = [self textStringWithComputedIRVResultFromVoterVectorList:vectorList]; 
    
    [self.IRV_ResultsTextView setText:resultsString];
    
    vectorList = nil;
    resultsString = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [_dataDictionary release];
    [_IRV_ResultsTextView release];
    
    [super dealloc];
}

#pragma mark - IRV Results Brain

- (NSUInteger)randomNumberForAMaxRangeValueOf:(NSUInteger)maxrange
{
    return arc4random();
    //return arc4random() % maxrange; // integer between [ 0, maxrange ) //
}

// Returns YES if the largest value on a list of values has satisfied the simple majority condition, returns NO otherwise //
// By way of reference the percentage points of the largest value in the list of values is set -- there my be multiple items with the same largest value, but we just set the first found value //
// By way of reference the index of the item wiht the largest value in the list of values is set //
- (BOOL)hasTheLargestValueOnTheItemTallyListSatisfiedTheSimpleMajorityCondition:(NSMutableArray*)itemTallyList withVoterVectorListSize:(NSUInteger)vectorListSize withPercentageReference:(CGFloat*)percentage withIndexOfLargestTally:(NSUInteger*)itemIndexWithLargestTally;
{
    // find the largest value and determine if it holds a majority //
    if ([itemTallyList count] > 0) {
        
        // find the largest tally... //
        NSUInteger largestTally = [[itemTallyList objectAtIndex:0] unsignedIntegerValue]; // assume this is the largest //
        //NSUInteger itemIndexWithLargestTally = 0;
        
        // TODO: temporarly store all the largest values into a list of largest values with corresponding indecies and randomly select one... //
        for (int k = 0; k < [itemTallyList count]; k++) {
            if (largestTally < [[itemTallyList objectAtIndex:k] unsignedIntegerValue]) {
                largestTally = [[itemTallyList objectAtIndex:k] unsignedIntegerValue];
                *itemIndexWithLargestTally = k;
            }
        }// end for loop //
        
        
        // does the largest tally hold a super majority? if so, display it... //
        *percentage = largestTally/((CGFloat)vectorListSize);
        if ( *percentage > 0.5 ) {
            
            return YES;
        }
    }// end if //
    return NO;    
}

// find the smallest tally value in the itemTallyList and create a list items that share a numerical tie to the smallest value //
-(NSMutableArray*)arrayWithItemsThatShareAnumericalToAsmallestTallyValue:(NSMutableArray*)itemTallyList andItemList:(NSMutableArray*)itemList;
{
    NSMutableArray *itemsWithVotingNumericalTie = [[[NSMutableArray alloc] init] autorelease];
    if ([itemTallyList count] > 0) {
        
        // find the smallest tally... //
        NSUInteger smallestTally = [[itemTallyList objectAtIndex:0] unsignedIntegerValue]; // assume this is the smallest //
        for (int k = 0; k < [itemTallyList count]; k++) {
            if (smallestTally > [[itemTallyList objectAtIndex:k] unsignedIntegerValue]) {
                smallestTally = [[itemTallyList objectAtIndex:k] unsignedIntegerValue];
            }
        }// end for loop //
        
        // create item list with numerical ties to the smallest value //
        for (int h = 0; h < [itemTallyList count]; h++) {
            if (smallestTally == [[itemTallyList objectAtIndex:h] unsignedIntegerValue]) {
                [itemsWithVotingNumericalTie addObject:[itemList objectAtIndex:h]];
            }
        }// end for loop //
    }// end if //
    
    return itemsWithVotingNumericalTie;
}

- (NSString*)textStringWithComputedIRVResultFromVoterVectorList:(NSArray*)voterVectorList
{
    
    // get the candidates/items form the master list //
    NSMutableArray *itemList = [NSMutableArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
    
    /*
     // expand itemList to include write-in's -- get filepath for IRV data set//
     // ##################################################################################### //
     NSString *filepathCat1 = [FileHandle getFilePathForFileWithName:kIRVstatsCat1FileName];
     NSString *filepathCat2 = [FileHandle getFilePathForFileWithName:kIRVstatsCat2FileName];
     NSString *filepathCat3 = [FileHandle getFilePathForFileWithName:kIRVstatsCat3FileName];
     
     // load data from file into a local NSDictionary //
     NSMutableDictionary *dataCat1Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat1];
     NSMutableDictionary *dataCat2Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat2];
     NSMutableDictionary *dataCat3Dictionary = [NSDictionary dictionaryWithContentsOfFile:filepathCat3];
     
     NSMutableArray *cat1Keys = [NSMutableArray arrayWithArray:[dataCat1Dictionary allKeys]];
     [cat1Keys removeObject:@"0"];
     NSMutableArray *cat2Keys = [NSMutableArray arrayWithArray:[dataCat2Dictionary allKeys]];
     [cat2Keys removeObject:@"0"];
     NSMutableArray *cat3Keys = [NSMutableArray arrayWithArray:[dataCat3Dictionary allKeys]];
     [cat3Keys removeObject:@"0"];
     
     //NSArray *dataArray = [[NSArray alloc] initWithObjects:@"dataCat1Dictionary",@"dataCat2Dictionary",@"dataCat3Dictionary", nil];
     
     BOOL wasMatchFound = NO;
     for (NSString *itemNewKey in cat1Keys) {
     NSString *itemNew;
     for (NSString *itemExisting in itemList) {
     // if an item was found then we break the for loop and continue look for non-entries, else we add it on... //
     itemNew = [[dataCat1Dictionary valueForKey:itemNewKey] objectAtIndex:0];
     if ([itemNew isEqualToString:itemExisting]) {
     wasMatchFound = YES;
     break;
     } else {
     wasMatchFound = NO;
     }
     }
     if (wasMatchFound == NO) {
     // add new item to the existing list //
     [itemList addObject:itemNew];
     }
     }
     wasMatchFound = NO;
     for (NSString *itemNewKey in cat2Keys) {
     NSString *itemNew;
     for (NSString *itemExisting in itemList) {
     // if an item was found then we break the for loop and continue look for non-entries, else we add it on... //
     itemNew = [[dataCat2Dictionary valueForKey:itemNewKey] objectAtIndex:0];
     if ([itemNew isEqualToString:itemExisting]) {
     wasMatchFound = YES;
     break;
     } else {
     wasMatchFound = NO;
     }
     }
     if (wasMatchFound == NO) {
     // add new item to the existing list //
     [itemList addObject:itemNew];
     }
     }
     wasMatchFound = NO;
     for (NSString *itemNewKey in cat3Keys) {
     NSString *itemNew;
     for (NSString *itemExisting in itemList) {
     // if an item was found then we break the for loop and continue look for non-entries, else we add it on... //
     itemNew = [[dataCat3Dictionary valueForKey:itemNewKey] objectAtIndex:0];
     if ([itemNew isEqualToString:itemExisting]) {
     wasMatchFound = YES;
     break;
     } else {
     wasMatchFound = NO;
     }
     }
     if (wasMatchFound == NO) {
     // add new item to the existing list //
     [itemList addObject:itemNew];
     }
     }    
     // ##################################################################################### //
     */
    
    
    // an array that is intended to have a one-to-one correspondence with the itemList above -- used for holding tallies //
    NSMutableArray *itemTallyList = [[NSMutableArray alloc] initWithCapacity:[itemList count]];
    for (id bogus in itemList) { [itemTallyList addObject:[NSNumber numberWithUnsignedInteger:0]]; }
    
    // This list stores the candidates/items that were eliminated from the master list -- it must be all of them //
    // since this IRV elimination method does not stop when an item/candidate has a majority of votes, it just marks it as such //
    NSMutableArray *eliminatedItemList = [[NSMutableArray alloc] init];
    
    // this list stores all the candidates/items that have a voting numerical tie for each round of elimination //
    NSMutableArray *itemsWithVotingNumericalTie; // = [[NSMutableArray alloc] init];
    
    // holds the last random number that was generated in this method //
    NSUInteger rand = 0;
    
    NSString *resultsData = [NSString string];
    NSString *dataHeader = @"*** IRV Results...***\n\n";
    resultsData = [resultsData stringByAppendingString:dataHeader];
    
    // traverse the voter vector list until all candidates have been eliminated //
    do {
        
        // callculate IRV results //
        // traverse the voter vector list and tally the choices of each voter //
        for (unsigned voterIndex = 0; voterIndex < [voterVectorList count]; voterIndex++) {
            
            // start at first choice for voter i //
            NSUInteger choiceIndex = 1;
            NSString *voterItemChoice;
            BOOL exitDoWhile = YES;
            do {
                voterItemChoice = [[voterVectorList objectAtIndex:voterIndex] objectAtIndex:choiceIndex];
                
                // determine which voter's choice will be used for the nth round of voting //
                // if voterItemChoice is located on the eliminatedItemList then use their next ranked choice--if applicable //
                for (NSString *item in eliminatedItemList) {
                    
                    if ([voterItemChoice isEqualToString:item]) {
                        // the voter's choice for this item has been eliminated from the itemList //
                        // if permisible, increment to the voter's next ranked choice vote //
                        choiceIndex++;
                        exitDoWhile = NO;
                        break;                    
                    } else {
                        exitDoWhile = YES;
                    }
                }
                
            } while (choiceIndex < [[voterVectorList objectAtIndex:0] count] && exitDoWhile == NO);
            
            // go thru the itemList and find a match with the voterItemChoice //
            for (unsigned itemListIndex = 0; itemListIndex < [itemList count]; itemListIndex++) {
                
                NSString *item = [itemList objectAtIndex:itemListIndex];
                if ([item isEqualToString:voterItemChoice]) {
                    
                    // match found increment tally for the vote on the item at itemListIndex //
                    NSUInteger tally = [[itemTallyList objectAtIndex:itemListIndex] unsignedIntegerValue] + 1;
                    [itemTallyList replaceObjectAtIndex:itemListIndex withObject:[NSNumber numberWithUnsignedInteger:tally]];
                    break;
                }
            }// end nested for loop //
        }// end for loop //        
        
        // collect the items, and tally data before any elimination. this will be used for print out purposes //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        NSString *itemsVoteTallyResults = [NSString string];
        for (int n = 0; n < [itemList count]; n++) {
            NSString *data = [NSString stringWithFormat:@"Ballot Item-> %@, Vote Tally-> %@\n",[itemList objectAtIndex:n],[itemTallyList objectAtIndex:n]];
            itemsVoteTallyResults = [itemsVoteTallyResults stringByAppendingString:data];
        }        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////        
        
        // find the largest value and determine if it is a simple majority //
        CGFloat percentagePoints = 0.0;             // passed by reference //
        NSUInteger itemIndexWithLargestTally = 0;   // passed by reference //    
        BOOL hasSimpleMajority = [self hasTheLargestValueOnTheItemTallyListSatisfiedTheSimpleMajorityCondition:itemTallyList
                                                                                       withVoterVectorListSize:[voterVectorList count]
                                                                                       withPercentageReference:&percentagePoints
                                                                                       withIndexOfLargestTally:&itemIndexWithLargestTally];
        
        // collect and display the result of the simple majority condition //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        NSString *majorityReachedResults = @"Has The Simple Majority Condition Been Satisfied-> NO\n";
        if (hasSimpleMajority) {
            majorityReachedResults = @"Has The Simple Majority Condition Been Satisfied-> YES\n";
            majorityReachedResults = [majorityReachedResults stringByAppendingString:@"The Item To Receive The Majority Vote Is-> "];
            NSString *addOn = [NSString stringWithFormat:@"%@, With Percentage Points-> %g\n",[itemList objectAtIndex:itemIndexWithLargestTally], percentagePoints * 100.0];
            majorityReachedResults = [majorityReachedResults stringByAppendingString:addOn];
        }        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        // find the smallest tally value in the itemTallyList and create a list items that share a numerical tie to the smallest value //
        itemsWithVotingNumericalTie = [[NSMutableArray alloc] initWithArray:[self arrayWithItemsThatShareAnumericalToAsmallestTallyValue:itemTallyList andItemList:itemList]];
        
        // if multiple items share a vote tally then display that list //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        NSString *multipleItemsShareAvoteTallyResults = nil;
        if ([itemsWithVotingNumericalTie count] > 1) {
            multipleItemsShareAvoteTallyResults = @"There Are Multiple Items That Share A Vote Tally->\n";
            for (NSString *item in itemsWithVotingNumericalTie) {
                multipleItemsShareAvoteTallyResults = [multipleItemsShareAvoteTallyResults stringByAppendingFormat:@" • %@\n",item];
            }
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        // if a tie exists between items voted on, then randomly eliminate an item from the itemsWithVotingNumericalTie list //
        // place an eliminated item into eliminatedItemList //
        NSString *itemToEliminate;
        if ([itemsWithVotingNumericalTie count] > 0) {
            
            rand = [self randomNumberForAMaxRangeValueOf:0];
            NSUInteger indexToEliminate = (rand % [itemsWithVotingNumericalTie count]);
            itemToEliminate = [itemsWithVotingNumericalTie objectAtIndex:indexToEliminate];
            [itemList removeObject:itemToEliminate];
            [itemTallyList removeObjectAtIndex:indexToEliminate];
            
            [eliminatedItemList addObject:itemToEliminate];
        }
        
        // display which item was eliminated from the itemList and add to the eliminatedItemList -- of more than one item was up for elimination at a time then //
        // display the critera used to eliminate the current object //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        NSString *itemThatWasEliminatedResults = nil;
        if ([itemList count] > 1) {
            itemThatWasEliminatedResults = [NSString stringWithFormat:@"This Item Was Eliminated-> %@",itemToEliminate];
            if ([itemsWithVotingNumericalTie count] > 1) {
                itemThatWasEliminatedResults = [itemThatWasEliminatedResults stringByAppendingFormat:@", By Random Selection-> (rand mod %i = %i), Where (rand = %u)\n",[itemsWithVotingNumericalTie count], (rand % [itemsWithVotingNumericalTie count]), rand];            
            } else {
                itemThatWasEliminatedResults = [itemThatWasEliminatedResults stringByAppendingString:@"\n"];
            } 
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        // build string output //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        resultsData = [resultsData stringByAppendingString:[NSString stringWithFormat:@"Round # %i\n",[eliminatedItemList count]]];
        resultsData = [resultsData stringByAppendingString:@"---------------------\n"];
        if (itemsVoteTallyResults) resultsData = [resultsData stringByAppendingString:itemsVoteTallyResults];
        if (majorityReachedResults) resultsData = [resultsData stringByAppendingString:majorityReachedResults];
        resultsData = [resultsData stringByAppendingString:@"---------------------\n"];
        if (multipleItemsShareAvoteTallyResults) resultsData = [resultsData stringByAppendingString:multipleItemsShareAvoteTallyResults];
        if (itemThatWasEliminatedResults) {
            resultsData = [resultsData stringByAppendingString:itemThatWasEliminatedResults];
            resultsData = [resultsData stringByAppendingString:@"---------------------\n"];            
        }
        resultsData = [resultsData stringByAppendingString:@"---------------------\n\n"];
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        // end build string output //        
        
        
        [itemTallyList release];
        // an array that is intended to have a one-to-one correspondence with the itemList above -- used for holding tallies //
        itemTallyList = [[NSMutableArray alloc] initWithCapacity:[itemList count]];
        for (id bogus in itemList) { [itemTallyList addObject:[NSNumber numberWithUnsignedInteger:0]]; }        
        
        [itemsWithVotingNumericalTie release];
        
    } while ([itemList count] > 0);
    
    resultsData = [resultsData stringByAppendingString:@"---------- Nothing Follows ----------"];        
    
    // deallocate some memory //
    [itemTallyList release];
    [eliminatedItemList release];
    
    return resultsData;
}

- (NSArray*)arrayWithVoterVectorListFromDataSetsInFilepath
{
    // This is an example of a single IRV voter vector //
    // <@"Voter Name or ID", @"First Choice", "@Second Choice", @"Third Choice"> //
    // where this symbol < indicates the start of an NSArray, and this symbol > indicates the end. //        
    NSMutableArray *voterVector = [[NSMutableArray alloc] initWithObjects:@"#",@"#",@"#",@"#", nil];
    NSMutableArray *voterVectorList = [[NSMutableArray alloc] init];
    NSString *currentVoterID = @"";
    
    for (NSInteger j = 1; j <= [self.dataDictionary count]; j++) {
        
        NSString *key = [NSString stringWithFormat:@"%i", j];
        
        // get voter ID //
        NSNumber *voterID = [[self.dataDictionary objectForKey:key] objectAtIndex:0];
        NSString *nextVoterID = [NSString stringWithFormat:@"%i",[voterID integerValue]];
        
        if ([currentVoterID isEqualToString:@""]) {
            NSNumber *voterID = [[self.dataDictionary objectForKey:key] objectAtIndex:0];
            currentVoterID = [currentVoterID stringByAppendingString:[NSString stringWithFormat:@"%i",[voterID integerValue]]];
            [voterVector replaceObjectAtIndex:0 withObject:currentVoterID];
        }
        
        if ([currentVoterID isEqualToString:nextVoterID]) {
            
            NSString *itemVotedOn = [[self.dataDictionary objectForKey:key] objectAtIndex:1];
            NSString *itemVotedOnRank = [[self.dataDictionary objectForKey:key] objectAtIndex:2];
            [voterVector replaceObjectAtIndex:[itemVotedOnRank integerValue] withObject:itemVotedOn]; 
            
        } else  {
            
            // if it's the last object in the dataDictionary then add the voter vector and allow the loop to end //
            // else add the vector and continue by reseting values //
            [voterVectorList addObject:voterVector];
            
            if (j < [self.dataDictionary count]) {
                
                // reset values //
                [voterVector release], voterVector = nil;
                voterVector = [[NSMutableArray alloc] initWithObjects:@"#",@"#",@"#",@"#", nil];
                
                // reset values //        
                currentVoterID = @"";
                
                // add this value now since the second, from top, if block above skips this when false //            
                NSString *itemVotedOn = [[self.dataDictionary objectForKey:key] objectAtIndex:1];
                NSString *itemVotedOnRank = [[self.dataDictionary objectForKey:key] objectAtIndex:2];
                [voterVector replaceObjectAtIndex:[itemVotedOnRank integerValue] withObject:itemVotedOn];
            }            
        }            
    }
    
    //[dictionaryKeys release];
    [voterVector release], voterVector = nil;
    
    // TEST //
    //NSLog(@"Vector List %@",voterVectorList);
    
    return [voterVectorList autorelease];
}
@end
