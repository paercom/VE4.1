//
//  FileHandle.h
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

#import <Foundation/Foundation.h>


@interface FileHandle : NSObject {
    
}

+(void)createTextFileWithName:(NSString *)filename;
+(void)deleteFileWithPath:(NSString *)filepath;
+(BOOL)doesFileWithNameExist:(NSString *)filepath;

+(void)writeToFileWithName:(NSString *)filepath thisArray:(NSMutableArray *)dataArray;
+(NSString *)readFromFileWithName:(NSString *)filepath;

+(NSString *)getDocumentsPath;
+(NSString *)getFilePathForFileWithName:(NSString *)filename;

+(void)toggleFlagForCompletedElectoralExperiment:(NSInteger)experimentIndex;
+(NSInteger)getFlagStateForCompletedElectoralExperiment:(NSInteger)experimentIndex;

@end
