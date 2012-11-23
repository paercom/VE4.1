//
//  UserDemographicCell.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 8/26/12.
//
//

#import <UIKit/UIKit.h>

@interface UserDemographicCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *userIdLabel;
@property (retain, nonatomic) IBOutlet UILabel *userGenderLabel;
@property (retain, nonatomic) IBOutlet UILabel *userAgeGroupLabel;
@property (retain, nonatomic) IBOutlet UILabel *userRaceLabel;
@property (retain, nonatomic) IBOutlet UILabel *userPoliticalAffiliationLabel;
@property (retain, nonatomic) IBOutlet UILabel *userAnnualHouseholdIncom;
@property (retain, nonatomic) IBOutlet UITextView *userMostImportantIssueTextView;
@end
