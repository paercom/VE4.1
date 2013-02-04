//
//  PluralitySpreadsheetGenerator.m
//  ElectoralExperiment3
//
//  Created by Stefan Agapie on 6/5/12.
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

#import "PluralitySpreadsheetGenerator.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"


@implementation PluralitySpreadsheetGenerator

+(void)generatePluralitySreadsheetDataSet{
    
    // get filepath for Plurality data set and create a filepath for the spreadsheet data set //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kPluralityDataFileName];
    NSString *newFilepath = [FileHandle getFilePathForFileWithName:kPluralitySpreadsheetDataSetFilename];
    NSString *voterChoiceListFilepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
    
    // load data from file into a local NSDictionary //
    NSMutableDictionary *pluralityModel;
    NSArray *voterChoiceList;
    
    
    // if file at path exists then load the plurality data model //
    BOOL IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kPluralityDataFileName]];
    if (IDfileExists) { pluralityModel = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath]; }
    
    IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
    if (IDfileExists) { voterChoiceList = [[NSArray alloc] initWithContentsOfFile:voterChoiceListFilepath]; } 
        
    if ( !(pluralityModel && voterChoiceList) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Generation Error" message:@"Unable to generate the Plurality Spreadsheet Data Sets." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;        
    }
    
    NSString *pluralityDataModelString = @"Voter ID,Voter's Choice,Write-In\n";    
    
    // load the plurality data model into a NSString object //
    [pluralityModel removeObjectForKey:@"0"]; // remove this key since it's only a place holder //
    NSArray *dataObjectKeys = [pluralityModel allKeys];    
    for (NSString *dataObjectKey in dataObjectKeys) {
        NSNumber *voterID = [[pluralityModel valueForKey:dataObjectKey] objectAtIndex:0];
        NSMutableString *voterChoice = [[[pluralityModel valueForKey:dataObjectKey] objectAtIndex:1] mutableCopy];
        NSString *voterWriteIn = @"YES";
        
        // determine if the voter's choice is a write in candidate //
        BOOL isVoterChoiceA_WriteIn = YES;
        for (NSString *choiceItem in voterChoiceList) {
            // voter's choice is assumed to be a write-in unless we find at least one on the predefined choice list //
            if ([voterChoice isEqualToString:choiceItem]){
                isVoterChoiceA_WriteIn = NO;
                voterWriteIn = @"NO";
                break;
            }
        }
        
        // since we are generating a CSV file we need to remove any extreneous commas from our data points and replace it with some other symbol //
        [voterChoice replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [voterChoice length])];
               
        NSString *data = [NSString stringWithFormat:@"%u,%@,%@\n",[voterID integerValue],voterChoice,voterWriteIn];
        
        pluralityDataModelString = [pluralityDataModelString stringByAppendingString:data];        
        
    }
    
    NSError *err;    
    if ([pluralityModel count] > 0) {
        // save plurality spreadsheet data model List to file //
        if ( ![pluralityDataModelString writeToFile:newFilepath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&err] ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save Plurality Spreadsheet Data Set to file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } 
    }
    
}

@end
