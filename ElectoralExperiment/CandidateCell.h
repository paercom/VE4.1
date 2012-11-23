//
//  CandidateCell.h
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

@class CandidateCell;

@protocol CandidateCellDelegate <NSObject>

- (void) rangeValueOnSliderInStandardCellDidChange:(CandidateCell*)forSlider;

@end

@interface CandidateCell : UITableViewCell {
    id <CandidateCellDelegate> delegate;    
}
@property (nonatomic, assign) id <CandidateCellDelegate> delegate;

@property (nonatomic, retain) IBOutlet UISlider *candidateSlider;
@property (nonatomic, retain) IBOutlet UILabel *candidateRangeLabel;
@property (nonatomic, retain) IBOutlet UILabel *candidateNameLabel;

- (IBAction)candidateStepper:(UIStepper *)sender;

@end
