//
//  IRVSpreadsheetGenerator.m
//  ElectoralExperiment3
//
//  Created by Stefan Agapie on 6/10/12.
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

#import "IRVSpreadsheetGenerator.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"



@implementation IRVSpreadsheetGenerator


+(void)generateIRVSpreadsheetDataSets{
    
    // get filepath for Range data set and create a filepath for the spreadsheet data set //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVdataFileName];
    NSString *newFilepath = [FileHandle getFilePathForFileWithName:kIRVSpreadsheetDataSetFilename];
    NSString *voterChoiceListFilepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
    
    // load data from file into a local NSDictionary //
    NSMutableDictionary *IRV_Model;
    NSArray *voterChoiceList;
    
    // if file at path exists then load the range data model //
    BOOL IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVdataFileName]];
    if (IDfileExists) { IRV_Model = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath]; }
    
    IDfileExists = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kCandidateFileName]];
    if (IDfileExists) { voterChoiceList = [[NSArray alloc] initWithContentsOfFile:voterChoiceListFilepath]; }
    
    if ( !(IRV_Model && voterChoiceList) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Generation Error" message:@"Unable to generate the IRV Spreadsheet Data Sets." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;        
    }
    
    NSString *IRV_DataModelString = @"Voter ID,Voter's Choice,Ranked Choice Value,Write-In\n";
    
    // load the range data model into a NSString object //
    [IRV_Model removeObjectForKey:@"0"]; // remove this key since it's only a place holder //
    NSArray *dataObjectKeys = [IRV_Model allKeys];
    for (NSString *dataObjectKey in dataObjectKeys) {
        NSNumber *voterID = [[IRV_Model valueForKey:dataObjectKey] objectAtIndex:0];
        NSString *voterChoice = [[IRV_Model valueForKey:dataObjectKey] objectAtIndex:1];
        NSString *voterChoiceRankValue = [[IRV_Model valueForKey:dataObjectKey] objectAtIndex:2];
        NSString *voterWriteIn = @"YES";
        
        // determine if the voter's item choice is a write in candidate //
        BOOL isVoterChoiceItemA_WriteIn = YES;
        for (NSString *choiceItem in voterChoiceList) {
            // voter's choice is assumed to be a write-in unless we find at least one on the predefined choice list //
            if ([voterChoice isEqualToString:choiceItem]) {
                isVoterChoiceItemA_WriteIn = NO;
                voterWriteIn = @"NO";
                break;
            }
        }
        
        NSString *data = [NSString stringWithFormat:@"%u,%@,%@,%@\n",[voterID integerValue],voterChoice,voterChoiceRankValue,voterWriteIn];
        IRV_DataModelString = [IRV_DataModelString stringByAppendingString:data];
    }
    
    NSError *err;    
    if ([IRV_Model count] > 0) {
        // save plurality spreadsheet data model List to file //
        if ( ![IRV_DataModelString writeToFile:newFilepath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&err] ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save IRV Spreadsheet Data Set to file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } 
    }
    
}


@end
