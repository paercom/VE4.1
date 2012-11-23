//
//  PluralityInstructionsViewController.h
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PluralityInstructionsViewController;

@protocol PluralityPopoverDelegate <NSObject>

- (void)pluralityPopoverDidAppear:(PluralityInstructionsViewController*)popoverViewController;
- (void)pluralityPopoverDidDisappear:(PluralityInstructionsViewController*)popoverViewController;

@end

@interface PluralityInstructionsViewController : UIViewController {
    id <PluralityPopoverDelegate> popoverDelegate;
}
@property (nonatomic, assign) id <PluralityPopoverDelegate> popoverDelegate;

@property (retain, nonatomic) IBOutlet UITextView *instructionsBlock;
@end
