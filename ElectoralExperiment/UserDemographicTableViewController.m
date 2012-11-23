//
//  UserDemographicTableViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 8/26/12.
//
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

#import "UserDemographicTableViewController.h"
#import "ElectoralExperiments.h"

#import "UserDemographicCell.h"
#import "GenderQuestionaire.h"
#import "AgeGroupQuestionaire.h"
#import "RaceQuestionaire.h"
#import "PoliticalAffiliationQuestionaire.h"
#import "AnnualHousholdIncomeQuestionaire.h"
#import "MostImportantIssueQuestionaire.h"
#import "UserID.h"

@interface UserDemographicTableViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation UserDemographicTableViewController

// -------------------- Core Data... ------------------------ //
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark
#pragma mark View Life Cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    if ( ![[self fetchedResultsController] performFetch:&error]) {
        
        NSLog(@"Unresolved Error %@, %@",error,[error userInfo]);
        
    }
    self.title = @"User Demographic Database Viewer";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fetchedResultsController = nil;
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
    _managedObjectContext = nil;
}

- (void)dealloc
{
    [_fetchedResultsController release];
    [_persistentStoreCoordinator release];
    [_managedObjectModel release];
    [_managedObjectContext release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark 
#pragma mark Fetched Results Controller Lazy Instantiation & Delegate

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserID"
                                              inManagedObjectContext:self.managedObjectContext];    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"userID" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:self.managedObjectContext
                                 sectionNameKeyPath:nil
                                 cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;    
}

#pragma mark
#pragma mark Custom Method

// return the URL to the application's Documents directory //
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark
#pragma mark Core Data Lazy Instantiation
// return the persistant store coordinator for the application//
// if the coordinator doesn't already esist, it is created and the application's store added to it //
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kUserDemographicDataBaseName];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    id victory = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:storeURL
                                                                 options:nil
                                                                   error:&error];
    if (victory == nil) {
        NSLog(@"Unable to create the Persistent Store Coordinator, Error: %@",[error localizedDescription]);
    }
    
    return _persistentStoreCoordinator;
    
    // NOTE: The kUserDemographicDataBaseName is created if it doesn't already exist //
}

// return the managed object model for the application //
// if the model doesn't already exist, it is created from the application's model //
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DemographicsDBModel" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// return the managed object context for the application //
// if the context doesn't already exist, it is created and bound to the persistent store coordinator for the application //
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

#pragma mark
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // updating number of rows in section //
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserDemographicCell";
    UserDemographicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDemographicCell" owner:self options:nil] objectAtIndex:0];
    }    
    // Configure the cell...
    UserID *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.userIdLabel.text = [NSString stringWithFormat:@"%@",user.userID];
    
    NSString *dataString;
    
    GenderQuestionaire *gender = user.genderObject;
    dataString = [NSString stringWithFormat:@"%@ -- %@",gender.userGenderSelection, gender.additionalGenderInformation];
    cell.userGenderLabel.text = dataString;
    
    AgeGroupQuestionaire *age = user.ageGroupObject;
    dataString = [NSString stringWithFormat:@"%@",age.userAgeGroupSelection];
    cell.userAgeGroupLabel.text = dataString;
    
    RaceQuestionaire *race = user.raceObject;
    dataString = [NSString stringWithFormat:@"%@ -- %@",race.userRaceOptionSelection, race.additionalRaceInformation];
    cell.userRaceLabel.text = dataString;
    
    PoliticalAffiliationQuestionaire *politicalAffiliation = user.politicalAffiliationObject;
    dataString = [NSString stringWithFormat:@"%@",politicalAffiliation.userPoliticalAffiliationSelection];
    cell.userPoliticalAffiliationLabel.text = dataString;
    
    AnnualHousholdIncomeQuestionaire *income = user.annualHouseholdIncomeObject;
    dataString = [NSString stringWithFormat:@"%@",income.userAnnualHousholdIncomeSelection];
    cell.userAnnualHouseholdIncom.text = dataString;
    
    MostImportantIssueQuestionaire *issureAnswer = user.mostImportantIssueObject;
    dataString = [NSString stringWithFormat:@"%@",issureAnswer.userAnswer];
    cell.userMostImportantIssueTextView.text = dataString;
    
    return cell;
}

@end
