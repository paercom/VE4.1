//
//  UserDemographicsViewController.h
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface UserDemographicsViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
}

@property (retain, nonatomic) IBOutlet UITextField *otherPoliticalAffiliation;
@property (retain, nonatomic) IBOutlet UITextField *otherTribeTextField;
@property (retain, nonatomic) IBOutlet UITextField *otherRaceTextField;
@property (retain, nonatomic) IBOutlet UITextField *otherGenderTextField;
@property (retain, nonatomic) IBOutlet UITextView *importantIssueTextView;
@property (retain, nonatomic) IBOutlet UIPickerView *userAffiliationPickerView;

@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (retain, nonatomic) IBOutlet UIButton *fullScreenDismissButtonOutlet;
- (IBAction)fullScreenDismissButton:(UIButton *)sender;

- (IBAction)raceSelectionButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *raceSelectionButtons;

- (IBAction)annualHouseholdIncomeSelectionButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *householdIncomeSelectionButttons;

- (IBAction)ageGroupSelectionButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *ageGroupSelectionButtons;

- (IBAction)genderSelectionButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *genderSelectionButtons;

// -------------------- non xib properties ------------------ //
@property (retain, nonatomic) NSMutableArray *partyAffiliationArray;

// -------------------- Core Data... ------------------------ //
@property (retain, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (retain, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// used to create new entries from an existing data set //
- (void)saveUserDemographicsToDataStoreGivenData:(NSDictionary*)incommingDataDictionary withNewUserIDoffsetValue:(NSInteger) newUserID_offset;

@end
