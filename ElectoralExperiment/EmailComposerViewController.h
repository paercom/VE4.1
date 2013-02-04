//
//  EmailComposerViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 3/30/12.
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
#import <MessageUI/MessageUI.h>
#import "FileHandle.h"
#import "ElectoralExperiments.h"

@interface EmailComposerViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UITextField *toTextField;
@property (retain, nonatomic) IBOutlet UITextField *ccTextField;
@property (retain, nonatomic) IBOutlet UITextField *bccTextField;

- (IBAction)composeEmailButton:(id)sender;
@end
