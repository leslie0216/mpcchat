//
//  MPCLog.h
//  MPCChat
//
//  Created by Chengzhao Li on 2016-03-07.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPCLog : NSObject

-(instancetype)initWithFilename: (NSString *)fn;
-(void)newLogFileWithName:(NSString *)fn;
-(void)newLogFile;
-(void)write:(NSString *)log;

@end
