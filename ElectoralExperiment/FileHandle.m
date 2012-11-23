//
//  FileHandel.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/20/11.
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

#import "FileHandle.h"
#import "ElectoralExperiments.h"


@implementation FileHandle

+(void)createTextFileWithName:(NSString *)filename{
    
}

+(void)deleteFileWithPath:(NSString *)filepath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL doesFileExists = [fileManager fileExistsAtPath:filepath];
    //NSLog(@"Path to file: %@", filepath);        
    //NSLog(@"File exists: %d", doesFileExists);
    //NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:filepath]);
    if (doesFileExists) 
    {
        BOOL success = [fileManager removeItemAtPath:filepath error:&error];
        if (!success) {
            //NSLog(@"Error: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File was located but could no be deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not locate to be deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
}

// check if file exists //
+(BOOL)doesFileWithNameExist:(NSString *)filepath{
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

// write content into a specified file path //
+(void)writeToFileWithName:(NSString *)filepath thisArray:(NSMutableArray *)dataArray{
    
    // if file exist, then write to file //
    if ([self doesFileWithNameExist:filepath]) {        
        
        [dataArray writeToFile:filepath atomically:YES];
                
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Error" message:[NSString stringWithFormat:@"File with path: %@ does not exist!", filepath] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    
}

// read content from a specified file path //
+(NSString *)readFromFileWithName:(NSString *)filepath{
    
    // if file exist, then read from file //
    if ([self doesFileWithNameExist:filepath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filepath];
        NSString *data = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
        [array release];
        return data;
    }
    return nil;
    
}

// finds the path to the application's Documents directory //
+(NSString *)getDocumentsPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
    
}

+(NSString *)getFilePathForFileWithName:(NSString *)filename{
    
    NSString *filepathAndName = [[self getDocumentsPath] stringByAppendingPathComponent:filename];
    return filepathAndName;
    
}

+(void)toggleFlagForCompletedElectoralExperiment:(NSInteger)experimentIndex{
    
    NSString *filepath = [FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    if (experimentIndex < [array count] && experimentIndex > 0) {
        
        if ([[array objectAtIndex:experimentIndex] integerValue] == 0) {
            [array replaceObjectAtIndex:experimentIndex withObject:[NSNumber numberWithUnsignedInteger:1]];
        } else {
            [array replaceObjectAtIndex:experimentIndex withObject:[NSNumber numberWithUnsignedInteger:0]];
        }
        
        // save voter's voting state to file //
        BOOL isDataSaved = [array writeToFile:filepath atomically:YES];
        
        if (isDataSaved == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could Not Save Voter State to File." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }        
    }
    [array release];    
}

+(NSInteger)getFlagStateForCompletedElectoralExperiment:(NSInteger)experimentIndex{
    
    NSString *filepath = [FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    NSInteger flagValue = kVoidFlagValueForCompletedExperiment;
    
    if (experimentIndex < [array count] && experimentIndex > 0) {
        
        flagValue = [[array objectAtIndex:experimentIndex] integerValue];
    }
    [array release]; 
    
    return flagValue;    
}

@end
