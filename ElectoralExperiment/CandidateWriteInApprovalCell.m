//
//  CandidateWriteInApprovalCell.m
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

#import "CandidateWriteInApprovalCell.h"
#import "SizeConstants.h"


@implementation CandidateWriteInApprovalCell

@synthesize delegate;

@synthesize candidateTextField = _candidateTextField;
@synthesize candidateApprovalDisapprovalButton = _candidateApprovalDisapprovalButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setCandidateApprovalDisapprovalButton:(UISegmentedControl *)candidateApprovalDisapprovalButton
{
    _candidateApprovalDisapprovalButton = candidateApprovalDisapprovalButton;
    
    [_candidateApprovalDisapprovalButton addTarget:self action:@selector(segmentedButtonStateDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentedButtonStateDidChange:(id)sender
{
    // Tell it to whomever cares //
    [delegate valueOnSegmentedButtonInWriteInCellDidChange:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_candidateTextField release];
    [_candidateApprovalDisapprovalButton release];
    [super dealloc];
}

@end
