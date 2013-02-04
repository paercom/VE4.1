//
//  UserDemographicSpreadsheetGenerator.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 2/4/13.
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

#import "UserDemographicSpreadsheetGenerator.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"
#import "UserDemographicTableViewController.h"

@implementation UserDemographicSpreadsheetGenerator

+(void)generateUserDemographicSpreadsheetDataSets {
    
    NSString *newFilepath = [FileHandle getFilePathForFileWithName:kUserDemographicSpreadsheetDataSetFilename];
    
    // get data from the current data store //
    // -------------------------------------------------- //
    UserDemographicTableViewController *currentUserDemoCoreDataStroe = [[UserDemographicTableViewController alloc] init];
    NSDictionary *userDataStoreDictionary = [currentUserDemoCoreDataStroe retrieveAnNSDictionaryOfEntitiesFromCoreDataStore];
    // -------------------------------------------------- //
        
    if ( !(userDataStoreDictionary) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Generation Error" message:@"Unable to generate the User Demographic Spreadsheet Data Sets." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSMutableString *userDemographicDataModelString = [[NSMutableString alloc] initWithString:@"Voter ID,Age Group,Annual Houshold Income,Political Affiliation,Gender,Gender (additional info),Race,Race (additional info),Most Important Issue This Election\n"];
    
    // load the user demographic data model into a NSString object //
    NSArray *dataObjectKeys = [userDataStoreDictionary allKeys];
    for (NSString *dataObjectKey in dataObjectKeys) {
        
        NSDictionary *oneUserDataDictionary = [userDataStoreDictionary valueForKey:dataObjectKey];
        
        @autoreleasepool {
            // set the user's demographics data for each table... //
            NSNumber *voterID = [oneUserDataDictionary valueForKey:@"userID.description"];
            NSMutableString *userGenderSelection =          [[[[oneUserDataDictionary valueForKey:@"genderObject.description"] valueForKey:@"userGenderSelection"] mutableCopy] autorelease];
            NSMutableString *additionalGenderInformation =  [[[[oneUserDataDictionary valueForKey:@"genderObject.description"] valueForKey:@"additionalGenderInformation"] mutableCopy] autorelease];
            NSMutableString *userAgeGroupSelection =        [[[[oneUserDataDictionary valueForKey:@"ageGroupObject.description"] valueForKey:@"userAgeGroupSelection"] mutableCopy] autorelease];
            NSMutableString *userRaceOptionSelection =      [[[[oneUserDataDictionary valueForKey:@"raceObject.description"] valueForKey:@"userRaceOptionSelection"] mutableCopy] autorelease];
            NSMutableString *additionalRaceInformation =    [[[[oneUserDataDictionary valueForKey:@"raceObject.description"] valueForKey:@"additionalRaceInformation"] mutableCopy] autorelease];
            NSMutableString *userPoliticalAffiliationSelection =    [[[[oneUserDataDictionary valueForKey:@"politicalAffiliationObject.description"] valueForKey:@"userPoliticalAffiliationSelection"] mutableCopy] autorelease];
            NSMutableString *userAnnualHousholdIncomeSelection =    [[[[oneUserDataDictionary valueForKey:@"annualHouseholdIncomeObject.description"] valueForKey:@"userAnnualHousholdIncomeSelection"] mutableCopy] autorelease];
            NSMutableString *userAnswer =                           [[[[oneUserDataDictionary valueForKey:@"mostImportantIssueObject.description"] valueForKey:@"userAnswer"] mutableCopy] autorelease];
            
            // since we are generating a CSV file we need to remove any extreneous commas from our data points and replace it with some other symbol //
            [userAnswer                     replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userAnswer length])];
            [userAnswer                     replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userAnswer length])];
            [userGenderSelection            replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userGenderSelection length])];
            [additionalGenderInformation    replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [additionalGenderInformation length])];
            [userAgeGroupSelection          replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userAgeGroupSelection length])];
            [userRaceOptionSelection        replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userRaceOptionSelection length])];
            [additionalRaceInformation      replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [additionalRaceInformation length])];
            [userPoliticalAffiliationSelection replaceOccurrencesOfString:@"," withString:@" --" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userPoliticalAffiliationSelection length])];
            [userAnnualHousholdIncomeSelection replaceOccurrencesOfString:@"," withString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(0, [userAnnualHousholdIncomeSelection length])];
            
            
            // check for blank or nil values //
            if (!userAnswer || [userAnswer length] < 1)            { userAnswer = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!userGenderSelection || [userGenderSelection length] < 1)   { userGenderSelection = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!additionalGenderInformation || [additionalGenderInformation length] < 1)   { additionalGenderInformation = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!userAgeGroupSelection || [userAgeGroupSelection length] < 1)         { userAgeGroupSelection = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!userRaceOptionSelection || [userRaceOptionSelection length] < 1)       { userRaceOptionSelection = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!additionalRaceInformation || [additionalRaceInformation length] < 1)         { additionalRaceInformation = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!userPoliticalAffiliationSelection || [userPoliticalAffiliationSelection length] < 1) { userPoliticalAffiliationSelection = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            if (!userAnnualHousholdIncomeSelection || [userAnnualHousholdIncomeSelection length] < 1) { userAnnualHousholdIncomeSelection = [NSMutableString stringWithString:@"<Intentionally Left Blank>"];};
            
            
            // generate a row... //
            NSMutableString *data = [NSMutableString stringWithFormat:@"%u,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                     [voterID integerValue],
                                     userAgeGroupSelection,
                                     userAnnualHousholdIncomeSelection,
                                     userPoliticalAffiliationSelection,                                     
                                     userGenderSelection,
                                     additionalGenderInformation,                                     
                                     userRaceOptionSelection,
                                     additionalRaceInformation,
                                     userAnswer];
            
            NSLog(@"%@",data);
            
            [userDemographicDataModelString appendString:data];
            
        }// end outorelease pool--drain //
    }
    
    NSLog(@"%@",userDemographicDataModelString);
    
    NSError *err;
    if ([userDataStoreDictionary count] > 0) {
        // save plurality spreadsheet data model List to file //
        if ( ![userDemographicDataModelString writeToFile:newFilepath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&err] ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save User Demographic Spreadsheet Data Set to file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

@end
