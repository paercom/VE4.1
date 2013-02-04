//
//  UserDemographicsViewController.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 8/5/12.
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

#import "UserDemographicsViewController.h"
#import "UserDemographicTableViewController.h"
#import "FileHandle.h"
#import "ElectoralExperiments.h"

#import "UserID.h"
#import "AgeGroupQuestionaire.h"
#import "MostImportantIssueQuestionaire.h"
#import "AnnualHousholdIncomeQuestionaire.h"
#import "RaceQuestionaire.h"
#import "GenderQuestionaire.h"
#import "PoliticalAffiliationQuestionaire.h"

typedef enum {
    PoliticalPartyAffiliation_TextField = 0,
    RaceAmericanIndianOrAlaskaNative_TextField,
    RaceOther_TextField,
    GenderOther_TextField
}UserEntryTextField;

typedef enum {
    AmericanIndianOrAlaskaNative = 0,
    AsianOrPacificIslander,
    BlackAfricanAmerican,
    HispanicLatino,
    WhiteCaucasian,
    OtherRace
}RaceSelectionOption;

typedef enum {    
    HouseholdIncomeUnder_10000 = 0,
    HouseholdIncome_10000_to_24999,
    HouseholdIncome_25000_to_34999,
    HouseholdIncome_35000_to_44999,
    HouseholdIncome_45000_to_54999,
    HouseholdIncome_55000_to_84999,
    HouseholdIncome_85000_to_125000,
    HouseholdIncomeOver_125000    
}AnnualHouseholdIncomeSelectionOption;

typedef enum {
    AgeGroupUnder_18 = 0,
    AgeGroup_18_to_21,
    AgeGroup_22_to_25,
    AgeGroup_26_to_30,
    AgeGroup_31_to_40,
    AgeGroup_41_to_50,
    AgeGroup_51_to_60,
    AgeGroupOver_60
}AgeGroupSelectionOption;

typedef enum {
    GenderFemale = 0,
    GenderMale,
    GenderOther
}GenderSelectionOption;

@interface UserDemographicsViewController () {
    CGPoint svos;
    
}

@property (nonatomic, retain) UIImage *stretchableRedButtonImage;
@property (nonatomic, retain) UIImage *stretchableWhiteButtonImage;

- (void)toggleRaceSelectionButtonState:(UIButton *)sender;
- (void)toggleHouseholdIncomeSelectionButtonState:(UIButton *)sender;
- (void)toggleAgeGroupSelectionButtonState:(UIButton *)sender;
- (void)toggleGenderSelectionButtonState:(UIButton *)sender;

@end

@implementation UserDemographicsViewController
@synthesize genderSelectionButtons;
@synthesize ageGroupSelectionButtons;
@synthesize householdIncomeSelectionButttons;
@synthesize raceSelectionButtons;
@synthesize otherPoliticalAffiliation;
@synthesize otherTribeTextField;
@synthesize otherRaceTextField;
@synthesize otherGenderTextField;
@synthesize importantIssueTextView;
@synthesize userAffiliationPickerView;
@synthesize myScrollView;
@synthesize fullScreenDismissButtonOutlet;

@synthesize stretchableRedButtonImage;
@synthesize stretchableWhiteButtonImage;

// -------------------- non xib properties ------------------ //
@synthesize partyAffiliationArray = _partyAffiliationArray;

// -------------------- Core Data... ------------------------ //
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark
#pragma mark Lazy Instantiation
- (NSMutableArray*)partyAffiliationArray
{
    if (_partyAffiliationArray == nil) {
        _partyAffiliationArray = [[NSMutableArray alloc] initWithObjects:@" :: Scroll to Select an Option :: ", nil];
        NSString *filepath = [FileHandle getFilePathForFileWithName:kCandidateFileName];
        //[_partyAffiliationArray addObjectsFromArray:[NSArray arrayWithContentsOfFile:filepath]];        
        for (NSString *item in [NSArray arrayWithContentsOfFile:filepath]) {
            [_partyAffiliationArray addObject:[NSString stringWithFormat:@" %@",item]];
        }
    }
    return _partyAffiliationArray;
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
#pragma mark Core Data Creating a New Entry
// used to create new entries from an existing data set //
- (void)saveUserDemographicsToDataStoreGivenData:(NSDictionary*)incommingDataDictionary withNewUserIDoffsetValue:(NSInteger) newUserID_offset
{
    
    // create the NSManaged Objects //
    // --------------------------------------------------------------------------- //
    UserID *userID;
    RaceQuestionaire *raceQuestionaire;
    GenderQuestionaire *genderQuestionaire;
    AgeGroupQuestionaire *ageGroupQuestionaire;
    MostImportantIssueQuestionaire *mostImportantIssueQuestionare;
    AnnualHousholdIncomeQuestionaire *annualHouseholdIncomeQuestionaire;
    PoliticalAffiliationQuestionaire *politicalAffiliationQuestionaire;
    
    userID = [NSEntityDescription insertNewObjectForEntityForName:@"UserID" inManagedObjectContext:self.managedObjectContext];
    raceQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"RaceQuestionaire" inManagedObjectContext:self.managedObjectContext];
    genderQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"GenderQuestionaire" inManagedObjectContext:self.managedObjectContext];
    ageGroupQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"AgeGroupQuestionaire" inManagedObjectContext:self.managedObjectContext];
    mostImportantIssueQuestionare = [NSEntityDescription insertNewObjectForEntityForName:@"MostImportantIssueQuestionaire" inManagedObjectContext:self.managedObjectContext];
    annualHouseholdIncomeQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"AnnualHousholdIncomeQuestionaire" inManagedObjectContext:self.managedObjectContext];
    politicalAffiliationQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"PoliticalAffiliationQuestionaire" inManagedObjectContext:self.managedObjectContext];
    // --------------------------------------------------------------------------- //
    
    // set the user's demographics data for each table... //
    userID.userID = [NSNumber numberWithInteger:newUserID_offset + ((NSNumber*)[incommingDataDictionary valueForKey:@"userID.description"]).integerValue];
    genderQuestionaire.userGenderSelection = [[incommingDataDictionary valueForKey:@"genderObject.description"] valueForKey:@"userGenderSelection"];
    genderQuestionaire.additionalGenderInformation = [[incommingDataDictionary valueForKey:@"genderObject.description"] valueForKey:@"additionalGenderInformation"];
    ageGroupQuestionaire.userAgeGroupSelection = [[incommingDataDictionary valueForKey:@"ageGroupObject.description"] valueForKey:@"userAgeGroupSelection"];
    raceQuestionaire.userRaceOptionSelection = [[incommingDataDictionary valueForKey:@"raceObject.description"] valueForKey:@"userRaceOptionSelection"];
    raceQuestionaire.additionalRaceInformation = [[incommingDataDictionary valueForKey:@"raceObject.description"] valueForKey:@"additionalRaceInformation"];
    politicalAffiliationQuestionaire.userPoliticalAffiliationSelection = [[incommingDataDictionary valueForKey:@"politicalAffiliationObject.description"] valueForKey:@"userPoliticalAffiliationSelection"];
    annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = [[incommingDataDictionary valueForKey:@"annualHouseholdIncomeObject.description"] valueForKey:@"userAnnualHousholdIncomeSelection"];
    mostImportantIssueQuestionare.userAnswer = [[incommingDataDictionary valueForKey:@"mostImportantIssueObject.description"] valueForKey:@"userAnswer"];
        
    // set relationships... //
    userID.raceObject = raceQuestionaire;
    userID.genderObject = genderQuestionaire;
    userID.ageGroupObject = ageGroupQuestionaire;
    userID.mostImportantIssueObject = mostImportantIssueQuestionare;
    userID.annualHouseholdIncomeObject = annualHouseholdIncomeQuestionaire;
    userID.politicalAffiliationObject = politicalAffiliationQuestionaire;
    raceQuestionaire.userID = userID;
    genderQuestionaire.userID = userID;
    ageGroupQuestionaire.userID = userID;
    mostImportantIssueQuestionare.userID = userID;
    annualHouseholdIncomeQuestionaire.userID = userID;
    politicalAffiliationQuestionaire.userID = userID;
    
    // save the managed object context //
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

// used to create new entry from the user interface //
- (void)saveUserDemographicsToDataStore
{
    // create the NSManaged Objects //
    UserID *userID;
    RaceQuestionaire *raceQuestionaire;
    GenderQuestionaire *genderQuestionaire;
    AgeGroupQuestionaire *ageGroupQuestionaire;
    MostImportantIssueQuestionaire *mostImportantIssueQuestionare;
    AnnualHousholdIncomeQuestionaire *annualHouseholdIncomeQuestionaire;
    PoliticalAffiliationQuestionaire *politicalAffiliationQuestionaire;
    
    userID = [NSEntityDescription insertNewObjectForEntityForName:@"UserID" inManagedObjectContext:self.managedObjectContext];
    raceQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"RaceQuestionaire" inManagedObjectContext:self.managedObjectContext];
    genderQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"GenderQuestionaire" inManagedObjectContext:self.managedObjectContext];
    ageGroupQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"AgeGroupQuestionaire" inManagedObjectContext:self.managedObjectContext];
    mostImportantIssueQuestionare = [NSEntityDescription insertNewObjectForEntityForName:@"MostImportantIssueQuestionaire" inManagedObjectContext:self.managedObjectContext];
    annualHouseholdIncomeQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"AnnualHousholdIncomeQuestionaire" inManagedObjectContext:self.managedObjectContext];
    politicalAffiliationQuestionaire = [NSEntityDescription insertNewObjectForEntityForName:@"PoliticalAffiliationQuestionaire" inManagedObjectContext:self.managedObjectContext];
    
    // set the user's demographics data for each table... //
    
    // save current user id //
    {
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:[FileHandle getFilePathForFileWithName:kCurrentVoterIDLogFileName]];        
        userID.userID = [dataArray objectAtIndex:0];
    }
    
    // save user race selection //
    {
        // ascertain which button was selected //
        NSInteger userSelection = -1; // -1 indicates that the user has made no selection //
        for (NSInteger i = 0; i < [self.raceSelectionButtons count]; i++) {
            UIButton *someButton = [self.raceSelectionButtons objectAtIndex:i];
            if ( [[someButton backgroundImageForState:UIControlStateNormal] isEqual:self.stretchableRedButtonImage]) {
                userSelection = i;
                break;
            }
        }
        switch (userSelection) {
            case AmericanIndianOrAlaskaNative:
                
                NSLog(@"American Indian or Alaska Native");
                raceQuestionaire.userRaceOptionSelection = @"American Indian or Alaska Native";
                if ([self.otherTribeTextField.text isEqualToString:kUserDemographicRaceOtherPrincipleTribePlaceholderText]) {
                    raceQuestionaire.additionalRaceInformation = @"";
                } else{
                    raceQuestionaire.additionalRaceInformation = self.otherTribeTextField.text;
                }
                break;
                
            case AsianOrPacificIslander:
                
                NSLog(@"Asian or Pacific Islander");
                raceQuestionaire.userRaceOptionSelection = @"Asian or Pacific Islander";
                raceQuestionaire.additionalRaceInformation = @"";
                break;
                
            case BlackAfricanAmerican:
                
                NSLog(@"Black/African American");
                raceQuestionaire.userRaceOptionSelection = @"Black/African American";
                raceQuestionaire.additionalRaceInformation = @"";
                break;
                
            case HispanicLatino:
                
                NSLog(@"Hispanic/Latino");
                raceQuestionaire.userRaceOptionSelection = @"Hispanic/Latino";
                raceQuestionaire.additionalRaceInformation = @"";
                break;
                
            case WhiteCaucasian:
                
                NSLog(@"White/Caucasian");
                raceQuestionaire.userRaceOptionSelection = @"White/Caucasian";
                raceQuestionaire.additionalRaceInformation = @"";
                break;
                
            case OtherRace:
                
                NSLog(@"Other (please specify)");
                raceQuestionaire.userRaceOptionSelection = @"Other (please specify)";
                if ([self.otherRaceTextField.text isEqualToString:kUserDemographicRaceOtherPlaceholderText]) {
                    raceQuestionaire.additionalRaceInformation = @"";
                } else{
                    raceQuestionaire.additionalRaceInformation = self.otherRaceTextField.text;
                }                
                break;
                
            default:
                raceQuestionaire.userRaceOptionSelection = @"No Selection Made";
                raceQuestionaire.additionalRaceInformation = @"No Selection Made";
                break;
        }
    }
    
    // save user gender selection //
    {
        // ascertain which button was selected //
        NSInteger userSelection = -1; // -1 indicates that the user has made no selection //
        for (NSInteger i = 0; i < [self.genderSelectionButtons count]; i++) {
            UIButton *someButton = [self.genderSelectionButtons objectAtIndex:i];
            if ( [[someButton backgroundImageForState:UIControlStateNormal] isEqual:self.stretchableRedButtonImage]) {
                userSelection = i;
                break;
            }
        }
        switch (userSelection) {
            case GenderFemale:
                
                NSLog(@"Female");
                genderQuestionaire.userGenderSelection = @"Female";
                genderQuestionaire.additionalGenderInformation = @"";
                break;
            case GenderMale:
                
                NSLog(@"Male");
                genderQuestionaire.userGenderSelection = @"Male";
                genderQuestionaire.additionalGenderInformation = @"";
                break;
                
            case GenderOther:
                
                NSLog(@"Gender Other");
                genderQuestionaire.userGenderSelection = @"Gender Other";
                if ([self.otherGenderTextField.text isEqualToString:kUserDemographicGenderOtherPlaceholderText]) {
                    genderQuestionaire.additionalGenderInformation = @"";
                } else {
                    genderQuestionaire.additionalGenderInformation = self.otherGenderTextField.text;
                }
                break;
                
            default:
                genderQuestionaire.userGenderSelection = @"No Selection Made";
                genderQuestionaire.additionalGenderInformation = @"No Selection Made";
                break;
        }
    }
    
    // save user age group selection //
    {
        // ascertain which button was selected //
        NSInteger userSelection = -1; // -1 indicates that the user has made no selection //
        for (NSInteger i = 0; i < [self.ageGroupSelectionButtons count]; i++) {
            UIButton *someButton = [self.ageGroupSelectionButtons objectAtIndex:i];
            if ( [[someButton backgroundImageForState:UIControlStateNormal] isEqual:self.stretchableRedButtonImage]) {
                userSelection = i;
                break;
            }
        }
        switch (userSelection) {
            case AgeGroupUnder_18:
                
                NSLog(@"Under 18");
                ageGroupQuestionaire.userAgeGroupSelection = @"Under 18";
                break;
            case AgeGroup_18_to_21:
                
                NSLog(@"18 - 21");
                ageGroupQuestionaire.userAgeGroupSelection = @"18 - 21";
                break;
            case AgeGroup_22_to_25:
                
                NSLog(@"22 - 25");
                ageGroupQuestionaire.userAgeGroupSelection = @"22 - 25";
                break;
            case AgeGroup_26_to_30:
                
                NSLog(@"26 - 30");
                ageGroupQuestionaire.userAgeGroupSelection = @"26 - 30";
                break;
            case AgeGroup_31_to_40:
                
                NSLog(@"31 - 40");
                ageGroupQuestionaire.userAgeGroupSelection = @"31 - 40";
                break;
            case AgeGroup_41_to_50:
                
                NSLog(@"41 - 50");
                ageGroupQuestionaire.userAgeGroupSelection = @"41 - 50";
                break;
            case AgeGroup_51_to_60:
                
                NSLog(@"51 - 60");
                ageGroupQuestionaire.userAgeGroupSelection = @"51 - 60";
                break;
            case AgeGroupOver_60:
                
                NSLog(@"Over 60");
                ageGroupQuestionaire.userAgeGroupSelection = @"Over 60";
                break;
                
            default:
                ageGroupQuestionaire.userAgeGroupSelection = @"No Selection Made";
                break;
        }        
    }
    
    // save user most important issue response //
    {
        if ([self.importantIssueTextView.text isEqualToString:kUserDemographicImportantIssueAnswerPlaceholderText] ||
            [self.importantIssueTextView.text isEqualToString:@""]) {
            mostImportantIssueQuestionare.userAnswer = @"No Selection Made";
        } else {
            mostImportantIssueQuestionare.userAnswer = self.importantIssueTextView.text;
        }        
    }
    
    // save user annual houshold income selection //
    {
        // ascertain which button was selected //
        NSInteger userSelection = -1; // -1 indicates that the user has made no selection //
        for (NSInteger i = 0; i < [self.householdIncomeSelectionButttons count]; i++) {
            UIButton *someButton = [self.householdIncomeSelectionButttons objectAtIndex:i];
            if ( [[someButton backgroundImageForState:UIControlStateNormal] isEqual:self.stretchableRedButtonImage]) {
                userSelection = i;
                break;
            }
        }
        switch (userSelection) {
            case HouseholdIncomeUnder_10000:
                
                NSLog(@"Under $10,000");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"Under $10,00";
                break;
            case HouseholdIncome_10000_to_24999:
                
                NSLog(@"$10,000 - $24,999");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$10,000 - $24,999";
                break;
            case HouseholdIncome_25000_to_34999:
                
                NSLog(@"$25,000 - $34,999");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$25,000 - $34,999";
                break;
            case HouseholdIncome_35000_to_44999:
                
                NSLog(@"$35,000 - $44,999");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$35,000 - $44,999";
                break;
            case HouseholdIncome_45000_to_54999:
                
                NSLog(@"$45,000 - $54,999");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$45,000 - $54,999";
                break;
            case HouseholdIncome_55000_to_84999:
                
                NSLog(@"$55,000 - $84,999");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$55,000 - $84,999";
                break;
            case HouseholdIncome_85000_to_125000:
                
                NSLog(@"$85,000 - $125,000");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"$85,000 - $125,000";
                break;
            case HouseholdIncomeOver_125000:
                
                NSLog(@"over $125,000");
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"over $125,000";
                break;
                
            default:
                annualHouseholdIncomeQuestionaire.userAnnualHousholdIncomeSelection = @"No Selection Made";
                break;
        }
    }
    
    // save user political affiliation selection //
    {
        if ([self.otherPoliticalAffiliation.text isEqualToString:kUserDemographicPoliticalAffiliationPlaceholderText] ||
            [self.otherPoliticalAffiliation.text isEqualToString:@""]){
            politicalAffiliationQuestionaire.userPoliticalAffiliationSelection = @"No Selection Made";
        } else {
            politicalAffiliationQuestionaire.userPoliticalAffiliationSelection = self.otherPoliticalAffiliation.text;
        }
    }    
    
    // set relationships... //
    userID.raceObject = raceQuestionaire;
    userID.genderObject = genderQuestionaire;
    userID.ageGroupObject = ageGroupQuestionaire;
    userID.mostImportantIssueObject = mostImportantIssueQuestionare;
    userID.annualHouseholdIncomeObject = annualHouseholdIncomeQuestionaire;
    userID.politicalAffiliationObject = politicalAffiliationQuestionaire;
    raceQuestionaire.userID = userID;
    genderQuestionaire.userID = userID;
    ageGroupQuestionaire.userID = userID;
    mostImportantIssueQuestionare.userID = userID;
    annualHouseholdIncomeQuestionaire.userID = userID;
    politicalAffiliationQuestionaire.userID = userID;
    
    // save the managed object context //
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }    
    
}

#pragma mark
#pragma mark UIPickerView Delegate & Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.partyAffiliationArray count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((component == 0) ? ( [self.partyAffiliationArray objectAtIndex:row]): NULL);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // set text field just below the picker to show (redundent) to the user the item that they selected // 
    if (component == 0 && row != 0) {
        [self.otherPoliticalAffiliation setText:[self.partyAffiliationArray objectAtIndex:row]]; 
    }
}


#pragma mark
#pragma mark TextField Delegate 
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Text Field Did Begin Editing");
    
    [self.fullScreenDismissButtonOutlet setHidden:NO];
    
    svos = self.myScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:self.myScrollView];
    pt = rc.origin;
    
    switch (textField.tag) {
        case PoliticalPartyAffiliation_TextField:
            pt.x = 0;
            pt.y = 0;
            [self.userAffiliationPickerView selectRow:0 inComponent:0 animated:YES];
            break;
        case RaceAmericanIndianOrAlaskaNative_TextField:
            pt.x = 0;
            pt.y = pt.y + -305;
            for (UIButton *button in self.raceSelectionButtons) {
                if (button.tag == AmericanIndianOrAlaskaNative) { [self toggleRaceSelectionButtonState:button]; }
            }
            [self.otherRaceTextField setText:@""];
            break;
        case RaceOther_TextField:
            pt.x = 0;
            pt.y = pt.y + -301;
            for (UIButton *button in self.raceSelectionButtons) {
                if (button.tag == OtherRace) { [self toggleRaceSelectionButtonState:button]; }
            }
            [self.otherTribeTextField setText:@""];
            break;
        case GenderOther_TextField:
            pt.x = 0;
            pt.y = pt.y + -305;
            for (UIButton *button in self.genderSelectionButtons) {
                if (button.tag == GenderOther) { [self toggleGenderSelectionButtonState:button]; }
            }
            break;           
        default:
            break;
    }
    
    [self.myScrollView setContentOffset:pt animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{    
    [self.myScrollView setContentOffset:svos animated:YES];
    [textField resignFirstResponder];
    
    [self.fullScreenDismissButtonOutlet setHidden:YES];
}

#pragma mark
#pragma mark Text View delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Text View Did Begin Editing");
    
    [self.fullScreenDismissButtonOutlet setHidden:NO];
    
    textView.text = @""; // Clear any message //
    
    svos = self.myScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textView bounds];
    rc = [textView convertRect:rc toView:self.myScrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y = pt.y + -215;
    
    [self.myScrollView setContentOffset:pt animated:YES];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.myScrollView setContentOffset:svos animated:YES];
    [textView resignFirstResponder];
    
    [self.fullScreenDismissButtonOutlet setHidden:YES];
}

#pragma mark
#pragma mark View Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)doneAnsweringQuestions
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Demographic Questionaire";
    
    UIBarButtonItem *leftBarButton;
    leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Press When Done..." style:UIBarButtonItemStylePlain target:self action:@selector(doneAnsweringQuestions)];
    
    [self.navigationItem setLeftBarButtonItem:leftBarButton animated:YES];
    [leftBarButton release];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveUserDemographicsToDataStore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.otherPoliticalAffiliation.delegate = self;
    self.otherTribeTextField.delegate = self;
    self.otherRaceTextField.delegate = self;
    self.otherGenderTextField.delegate = self;
    self.importantIssueTextView.delegate = self;
    
    [self.fullScreenDismissButtonOutlet setHidden:YES];
    
    self.stretchableRedButtonImage = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    self.stretchableWhiteButtonImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    
    for (id button in self.raceSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    for (id button in self.householdIncomeSelectionButttons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    for (id button in self.ageGroupSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    for (id button in self.genderSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}    
    
}

- (void)viewDidUnload
{
    [self setMyScrollView:nil];
    [self setOtherTribeTextField:nil];
    [self setOtherRaceTextField:nil];
    [self setOtherGenderTextField:nil];
    [self setImportantIssueTextView:nil];
    [self setOtherPoliticalAffiliation:nil];
    [self setFullScreenDismissButtonOutlet:nil];
    [self setRaceSelectionButtons:nil];
    
    [self setStretchableRedButtonImage:nil];
    [self setStretchableWhiteButtonImage:nil];
    [self setHouseholdIncomeSelectionButttons:nil];
    [self setAgeGroupSelectionButtons:nil];
    [self setGenderSelectionButtons:nil];
    [self setUserAffiliationPickerView:nil];
    
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [myScrollView release];
    [otherTribeTextField release];
    [otherRaceTextField release];
    [otherGenderTextField release];
    [importantIssueTextView release];
    [otherPoliticalAffiliation release];
    [fullScreenDismissButtonOutlet release];
    [raceSelectionButtons release];
    
    [stretchableRedButtonImage release];
    [stretchableWhiteButtonImage release];
    [householdIncomeSelectionButttons release];
    [ageGroupSelectionButtons release];
    [genderSelectionButtons release];
    [userAffiliationPickerView release];
    
    [_persistentStoreCoordinator release];
    [_managedObjectModel release];
    [_managedObjectContext release];
    
    [super dealloc];
}

#pragma mark
#pragma mark Questionaire Sheet Logic (The Brain)

- (IBAction)fullScreenDismissButton:(UIButton *)sender {
    
    [self.otherTribeTextField resignFirstResponder];
    [self.otherRaceTextField resignFirstResponder];
    [self.otherPoliticalAffiliation resignFirstResponder];
    [self.otherGenderTextField resignFirstResponder];
    [self.importantIssueTextView resignFirstResponder];
    
}

- (void)toggleRaceSelectionButtonState:(UIButton *)sender
{
    for (id button in self.raceSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    [sender setBackgroundImage:self.stretchableRedButtonImage forState:UIControlStateNormal];
}
- (IBAction)raceSelectionButton:(UIButton *)sender {
            
    switch (sender.tag) {
        case AmericanIndianOrAlaskaNative:
            
            NSLog(@"American Indian or Alaska Native");
            [self toggleRaceSelectionButtonState:sender];
            break;
            
        case AsianOrPacificIslander:
            
            NSLog(@"Asian or Pacific Islander");
            [self toggleRaceSelectionButtonState:sender];
            break;
        
        case BlackAfricanAmerican:
            
            NSLog(@"Black/African American");
            [self toggleRaceSelectionButtonState:sender];
            break;
            
        case HispanicLatino:
            
            NSLog(@"Hispanic/Latino");
            [self toggleRaceSelectionButtonState:sender];
            break;
            
        case WhiteCaucasian:
            
            NSLog(@"White/Caucasian");
            [self toggleRaceSelectionButtonState:sender];
            break;
        
        case OtherRace:
            
            NSLog(@"Other (please specify)");
            [self toggleRaceSelectionButtonState:sender];
            break;
            
        default:
            NSLog(@"Oops! WTF!");
            break;
    }
}

- (void)toggleHouseholdIncomeSelectionButtonState:(UIButton *)sender
{
    for (id button in self.householdIncomeSelectionButttons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    [sender setBackgroundImage:self.stretchableRedButtonImage forState:UIControlStateNormal];
}
- (IBAction)annualHouseholdIncomeSelectionButton:(UIButton *)sender {
    
    switch (sender.tag) {
        case HouseholdIncomeUnder_10000:
            
            NSLog(@"Under $10,000");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_10000_to_24999:
            
            NSLog(@"$10,000 - $24,999");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_25000_to_34999:
            
            NSLog(@"$25,000 - $34,999");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_35000_to_44999:
            
            NSLog(@"$35,000 - $44,999");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_45000_to_54999:
            
            NSLog(@"$45,000 - $54,999");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_55000_to_84999:
            
            NSLog(@"$55,000 - $84,999");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncome_85000_to_125000:
            
            NSLog(@"$85,000 - $125,000");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
        case HouseholdIncomeOver_125000:
            
            NSLog(@"over $125,000");
            [self toggleHouseholdIncomeSelectionButtonState:sender];
            break;
            
        default:
            NSLog(@"Oops! WTF!");
            break;
    }    
}

- (void)toggleAgeGroupSelectionButtonState:(UIButton *)sender
{
    for (id button in self.ageGroupSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    [sender setBackgroundImage:self.stretchableRedButtonImage forState:UIControlStateNormal];
}
- (IBAction)ageGroupSelectionButton:(UIButton *)sender {
    
    switch (sender.tag) {
        case AgeGroupUnder_18:
            
            NSLog(@"Under 18");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_18_to_21:
            
            NSLog(@"18 - 21");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_22_to_25:
            
            NSLog(@"22 - 25");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_26_to_30:
            
            NSLog(@"26 - 30");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_31_to_40:
            
            NSLog(@"31 - 40");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_41_to_50:
            
            NSLog(@"41 - 50");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroup_51_to_60:
            
            NSLog(@"51 - 60");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
        case AgeGroupOver_60:
            
            NSLog(@"Over 60");
            [self toggleAgeGroupSelectionButtonState:sender];
            break;
            
        default:
            NSLog(@"Oops! WTF!");
            break;
    }
}

- (void)toggleGenderSelectionButtonState:(UIButton *)sender
{
    for (id button in self.genderSelectionButtons) { [button setBackgroundImage:self.stretchableWhiteButtonImage forState:UIControlStateNormal];}
    [sender setBackgroundImage:self.stretchableRedButtonImage forState:UIControlStateNormal];
}
- (IBAction)genderSelectionButton:(UIButton *)sender {
    
    switch (sender.tag) {
        case GenderFemale:
            
            NSLog(@"Female");
            [self toggleGenderSelectionButtonState:sender];
            break;
        case GenderMale:
            
            NSLog(@"Male");
            [self toggleGenderSelectionButtonState:sender];
            break;
            
        case GenderOther:
            
            NSLog(@"Gender Other");
            [self toggleGenderSelectionButtonState:sender];
            break;
            
        default:
            NSLog(@"Oops! WTF!");
            break;
    }
}

@end
