//
//  mySingelton.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/31/11.
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

#import "MySingelton.h"
#import "AdminMenuOptions.h"
#import "ElectoralExperiments.h"

#import "PluralityViewController.h"
#import "RangeViewController.h"
#import "IRVviewController.h"
#import "ApprovalViewController.h"


@implementation MySingelton

static MySingelton *sharedInstance;

- (id)init
{
    @synchronized(self) {
        [super init];
        
        // experimentsNotCompletedList = [[NSMutableArray alloc] initWithObjects:kPlurality, kRange, kIRV, kApproval, nil]; //
        [self populateExperimentsNotCompletedList];
        isExperimentActive = NO;
        
        return self;
    }
}

#pragma -mark singelton action methods

-(void) runExperiment{
   
    // start the experiment //    
    isExperimentActive = YES;
    
}

-(BOOL) getIsExperimentActive{return isExperimentActive;}
-(void) setIsExperimentActive:(BOOL)inVal{isExperimentActive = inVal;}

-(void) populateExperimentsNotCompletedList{
    
    if (experimentsNotCompletedList == nil) {
        experimentsNotCompletedList = [[NSMutableArray alloc] initWithObjects:kPlurality, kRange, kIRV, kApproval, nil];
    } else {
        [experimentsNotCompletedList release];
        experimentsNotCompletedList = [[NSMutableArray alloc] initWithObjects:kPlurality, kRange, kIRV, kApproval, nil];
    }
}


#pragma -mark boiler plate methods

+ (MySingelton *)sharedObject
{
    
    
    @synchronized (self) {
        
        if (!sharedInstance) {
            
            //[[self alloc] init];
            sharedInstance = [[MySingelton alloc] init];
        }
    }
    
    return sharedInstance;
}

/*
+(GameProgress *)sharedGameProgress

{
    
    static GameProgress *sharedGameProgress;
    
    @synchronized(self)
    
    {
        
        if (!sharedGameProgress)
            
            sharedGameProgress = [[GameProgress alloc] init];
        
        return sharedGameProgress;
        
    }
    
}
 */

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}
/*
- (void)release
{
    // do nothing
}
 */

- (id)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax; // This is sooo not zero
}

@end
