//
//  ApprovalViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/28/11.
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
#import "CandidateApprovalCell.h"
#import "CandidateWriteInApprovalCell.h"
#import "ApprovalInstructionsViewController.h"

@class MySingelton;

@interface ApprovalViewController : UIViewController <UIAlertViewDelegate, CandidateApprovalCellDelegate, CandidateWriteInApprovalCellDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, ApprovalPopoverDelegate> {
    
    MySingelton *experimentAdministrator;
    
}

@property (nonatomic, retain) NSMutableArray *candidateList;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) IBOutlet UILabel *instructionsHeader;


-(BOOL) isThereAwriteInCandidateInTheTextField;
-(BOOL) isThewriteInCandidateAlreadyOnTheCandidateList;

-(IBAction) castVoteButton:(id)sender;
-(IBAction) undoButton:(id)sender;

-(void) updateApprovalDataFileForVoter:(NSNumber*)voterID CandidateList:(NSArray *)candidateListArray; 
-(void) updateApprovalStatsfileForCandidate:(NSArray*)candidateListArray;

@end
