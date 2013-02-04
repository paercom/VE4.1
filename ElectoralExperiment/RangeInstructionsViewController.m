//
//  RangeInstructionsViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 3/20/12.
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

#import "RangeInstructionsViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"

@interface RangeInstructionsViewController ()

@end

@implementation RangeInstructionsViewController
@synthesize popoverDelegate;
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
}

- (void)viewDidUnload
{
    [self setInstructionsBlock:nil];
    [self setPopoverDelegate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // get file path //
    NSString *filepath = [FileHandle getFilePathForFileWithName:kRangeMessagesFileName];
    
    // load data from file into a local NSDictionary //
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    
    NSString *key = kSingleElementKey;
    
    NSString *infoBlock;
    
    if ([((NSArray*)[dataDictionary valueForKey:key]) count] == 0) {
        infoBlock = kDefaultInstructionsMessageRange;
    } else {
        infoBlock = [((NSArray*)[dataDictionary valueForKey:key]) objectAtIndex:1];
    }
    
    //NSLog(@"Block:%@",infoBlock);
    //NSLog(@"Header:%@",infoHeader);
    
    //[self.instructionsHeader setText:infoHeader];
    [self.instructionsBlock setText:infoBlock];
    [self.instructionsBlock setFont:[UIFont boldSystemFontOfSize:kFontSizeInInstructionsInPopOver]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [popoverDelegate rangePopoverDidAppear:self];
}
-(void)viewDidDisappear:(BOOL)animated {
    [popoverDelegate rangePopoverDidDisappear:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [instructionsBlock release];
    [super dealloc];
}
@end
