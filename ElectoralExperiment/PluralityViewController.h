//
//  PluralityViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/22/11.
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
#import "PluralityInstructionsViewController.h"

@class MySingelton;


@interface PluralityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIPopoverControllerDelegate, PluralityPopoverDelegate> {
    
    //NSArray *candidateList;
    MySingelton *experimentAdministrator;
    
}
@property (nonatomic, retain) NSArray *candidateList;
@property (nonatomic, retain) IBOutlet UITextField *candidateTextField;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *cellReferenceList;
@property (retain, nonatomic) IBOutlet UILabel *instructionsHeader;

@property (nonatomic, retain) IBOutlet UIButton *instructionsButton;
@property (retain, nonatomic) IBOutlet UIButton *castMyVoteButton;
@property (retain, nonatomic) IBOutlet UIButton *undoButton;

-(IBAction) castVoteButton:(id)sender;
-(IBAction) undoButton:(id)sender;

-(void) updatePluralityDataFileForVoter:(NSNumber*)voterID CandidateName:(NSString *)candidateName; 
-(void) updatePluralityStatsfileForCandidate:(NSString*)candidateName writeIn:(BOOL) isCandidateWriteIn;

-(BOOL) isCandidateAwriteInCandidate:(NSString*)candidateName;


@end
