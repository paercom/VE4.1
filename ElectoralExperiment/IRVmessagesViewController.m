//
//  IRVmessagesViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 3/25/12.
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

#import "IRVmessagesViewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"

@interface IRVmessagesViewController ()

@end

@implementation IRVmessagesViewController
@synthesize instructionsHeader;
@synthesize instructionsBlock;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Check to see if IRV default messages data file was created //
    BOOL doesMessagesDataFileExist = [FileHandle doesFileWithNameExist:[FileHandle getFilePathForFileWithName:kIRVMessagesFileName]];
    
    // if file does not exist then create it //
    if (doesMessagesDataFileExist == NO) {
        
        // create file with default messages //
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:kDefaultHeaderMessage, kDefaultInstructionsMessage, nil];
        
        // allocate mem for dictionary //
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        // save data to dictionary with a sequential key //
        [dict setObject:array forKey:[NSString stringWithFormat:@"%@", kSingleElementKey]];
        
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

- (void)viewDidUnload
{
    [self setInstructionsBlock:nil];
    [self setInstructionsHeader:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    self.title = kMenuOptionSeven;
}

- (void) viewWillAppear:(BOOL)animated
{
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVMessagesFileName];
    
    // load data from file into a local NSDictionary //
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
    NSString *key = kSingleElementKey;
    
    NSString *infoHeader;
    NSString *infoBlock;
    
    if ([((NSArray*)[dataDictionary valueForKey:key]) count] == 0) {
        infoHeader = kDefaultHeaderMessage;
        infoBlock = kDefaultInstructionsMessage;
    } else {
        infoHeader = [((NSArray*)[dataDictionary valueForKey:key]) objectAtIndex:0];
        infoBlock = [((NSArray*)[dataDictionary valueForKey:key]) objectAtIndex:1];
    } 
    
    //NSLog(@"Block:%@",infoBlock);
    //NSLog(@"Header:%@",infoHeader);
    
    [self.instructionsHeader setText:infoHeader];
    [self.instructionsBlock setText:infoBlock];
    [self.instructionsHeader setFont:[UIFont systemFontOfSize:kFontSizeInViewHeader]];
    [self.instructionsBlock setFont:[UIFont systemFontOfSize:kFontSizeInInstructionsInPopOver]];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    //NSLog(@"Block:%@",[self.instructionsBlock text]);
    //NSLog(@"Header:%@",[self.instructionsHeader text]);
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kIRVMessagesFileName];
    // create file with current messages //
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[self.instructionsHeader text], [self.instructionsBlock text], nil];
    // allocate mem for dictionary //
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];    
    // save data to dictionary with a sequential key //
    [dict setObject:array forKey:kSingleElementKey];
    
    BOOL fileWriteStatus = [dict writeToFile:filepath atomically:YES];
    
    if ( fileWriteStatus ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Saved" message:@"The current messages have been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save current messages." delegate:self cancelButtonTitle:@"Sucks!" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [array release];
    [dict release];
}


- (void)dealloc {
    [instructionsBlock release];
    [instructionsHeader release];
    [super dealloc];
}
@end
