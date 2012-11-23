//
//  CandidateWriteInCell.m
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

#import "CandidateWriteInCell.h"
#import "SizeConstants.h"
#import "ElectoralExperiments.h"


@implementation CandidateWriteInCell

@synthesize delegate;

@synthesize candidateSlider = _candidateSlider;
@synthesize candidateRangeLabel = _candidateRangeLabel;
@synthesize candidateNameTextField = _candidateNameTextField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCandidateSlider:(UISlider *)candidateSlider {
    _candidateSlider = candidateSlider;
    
    [_candidateSlider addTarget:self action:@selector(updateSliderValueLabel:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)touchUpOnSlider:(id)sender {
    
    //NSLog(@"Touch up on slider");
    
    CGFloat sliderRange = [self.candidateSlider maximumValue] - [self.candidateSlider minimumValue];
    
    NSString *sliderPositionString = [self.candidateRangeLabel text];
    
    CGFloat sliderPositionValue = ([sliderPositionString integerValue]/((CGFloat)kMaxRangeValue))*sliderRange;
    
    [self.candidateSlider setValue:sliderPositionValue animated:YES];
}

- (IBAction)candidatteStepper:(UIStepper *)sender {
    
    self.candidateSlider.value = sender.value;
    
    [self updateSliderValueLabel:self.candidateSlider];
}

-(void)updateSliderValueLabel:(id)sender{
    
    NSInteger intValue = 0;
    
    float sliderValue = ((UISlider*)sender).value;
    
    const float_t sliderValueInterval = .1666667;
    
    if (sliderValue < sliderValueInterval) { // this if block is redundent //
        intValue = 0;
    } else if (sliderValue < 2*sliderValueInterval) {
        intValue = 1;
    } else if (sliderValue < 3*sliderValueInterval) {
        intValue = 2;
    } else if (sliderValue < 4*sliderValueInterval) {
        intValue = 3;
    } else if (sliderValue < 5*sliderValueInterval) {
        intValue = 4;
    } else {
        intValue = 5;
    }
    
    // get the unique tag value of this uislider--this tag value corresponds to a unique cell index //
    //NSInteger uniqueTag = [((UISlider*)sender) tag];
    
    // convert an integer value to an NSString value //
    NSString *rangeValue = [NSString stringWithFormat:@"%d",intValue];
    
    self.candidateRangeLabel.text = rangeValue;
    
    // send message to the delegate class that tha slider value did change //
    [delegate rangeValueOnSliderInWriteInCellDidChange:self];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.candidateSlider = nil;
    self.candidateRangeLabel = nil;
    self.candidateNameTextField = nil;
    [super dealloc];
}


@end
