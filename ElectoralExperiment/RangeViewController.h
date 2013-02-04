//
//  RangeViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/24/11.
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
#import "CandidateCell.h"
#import "CandidateWriteInCell.h"
#import "RangeInstructionsViewController.h"

@class MySingelton;


@interface RangeViewController : UIViewController <UIAlertViewDelegate, CandidateCellDelegate, CandidateWriteInCellDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, RangePopoverDelegate> {
    
    MySingelton *experimentAdministrator;    
}
@property (nonatomic, retain) NSArray *candidateList;
@property (nonatomic, retain) UITextField *candidateTextField;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) IBOutlet UILabel *instructionsHeader;

@property (nonatomic, retain) IBOutlet UIButton *instructionsButton;
@property (retain, nonatomic) IBOutlet UIButton *castMyVoteButton;
@property (retain, nonatomic) IBOutlet UIButton *undoButton;




-(IBAction) castVoteButton:(id)sender;
-(IBAction) undoButton:(id)sender;
-(IBAction)instructionsButton:(id)sender;

-(void) updateRangeDataFileForVoter:(NSNumber*)voterID CandidateList:(NSArray *)candidateListArray; 
-(void) updateRangeStatsfileForCandidate:(NSArray*)candidateListArray;

-(BOOL) isThereAwriteInCandidateInTheTextField;
-(BOOL) isThewriteInCandidateAlreadyOnTheCandidateList;
-(BOOL) isAtLeastOneRangeValueDifferentThanTheOthers;

@end
