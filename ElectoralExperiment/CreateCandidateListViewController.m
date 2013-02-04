//
//  CreateCandidateListViewController.m
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

#import "CreateCandidateListViewController.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"
#import "FileHandle.h"
#import "SizeConstants.h"


@implementation CreateCandidateListViewController

@synthesize candidateList;
@synthesize candidateInputField;
@synthesize candidateTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //self.candidateList = [[NSMutableArray alloc] init];
    self.candidateList = [NSMutableArray array];
            
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.candidateInputField becomeFirstResponder]; 
}

- (IBAction)addButton:(id)sender{
    
    if ([[candidateInputField text] length] > 0) {
        // add candidate to list //
        [self.candidateList addObject:candidateInputField.text];
        self.candidateInputField.text = nil;
        //[self.candidateInputField resignFirstResponder];
        [self.candidateTableView reloadData];
    }
}

-(IBAction)saveButton:(id)sender{
    
    if ([candidateList count] > 0) {
        // save Candidate List to file //
        NSString *filepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
        if ( [self.candidateList writeToFile:filepath atomically:YES] ){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Saved" message:@"The current Candidate List has been saved to file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to save current Candidate List to file." delegate:self cancelButtonTitle:@"Sucks!" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
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
    return [candidateList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:kTableViewCellFontSize];
    
    cell.textLabel.text = [self.candidateList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kTableViewCellRowHeight;   
}
 */

-(void)reloadTableViewData:(id)sender;{
    [self.candidateTableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // since we are delaying the reloadData method call, this if block ensures that the user does not select a table that is beyond the range of the array that acts as its datasource //
    if (indexPath.row < [candidateList count]) {
        self.candidateInputField.text = [self.candidateList objectAtIndex:indexPath.row];
        [self.candidateList removeObjectAtIndex:indexPath.row];
        
        [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(reloadTableViewData:) userInfo:nil repeats:NO];
    }
}


@end
