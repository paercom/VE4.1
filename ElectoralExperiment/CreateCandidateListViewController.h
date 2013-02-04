//
//  CreateCandidateListViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/20/11.
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


@interface CreateCandidateListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *candidateList;
    
}
@property (nonatomic, retain) NSMutableArray *candidateList;
@property (nonatomic, retain) IBOutlet UITextField *candidateInputField;
@property (nonatomic, retain) IBOutlet UITableView *candidateTableView;

-(IBAction)addButton:(id)sender;
-(IBAction)saveButton:(id)sender;

@end
