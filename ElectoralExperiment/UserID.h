//
//  UserID.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 8/26/12.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AgeGroupQuestionaire, AnnualHousholdIncomeQuestionaire, GenderQuestionaire, MostImportantIssueQuestionaire, PoliticalAffiliationQuestionaire, RaceQuestionaire;

@interface UserID : NSManagedObject

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) RaceQuestionaire *raceObject;
@property (nonatomic, retain) PoliticalAffiliationQuestionaire *politicalAffiliationObject;
@property (nonatomic, retain) MostImportantIssueQuestionaire *mostImportantIssueObject;
@property (nonatomic, retain) AnnualHousholdIncomeQuestionaire *annualHouseholdIncomeObject;
@property (nonatomic, retain) AgeGroupQuestionaire *ageGroupObject;
@property (nonatomic, retain) GenderQuestionaire *genderObject;

@end
