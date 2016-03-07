//
//  MPCLog.m
//  MPCChat
//
//  Created by Chengzhao Li on 2016-03-07.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import "MPCLog.h"

@interface MPCLog()
{
    NSString *filename;
    NSString *fileFullpath;
    NSFileHandle *fileHandle;
}

@end

@implementation MPCLog

-(instancetype)initWithFilename:(NSString *)fn
{
    self = [super init];
    
    if (self) {
        if (![self createLogWithFilename:fn]) {
            NSLog(@"!!!!!!!!Cannot create log file with name %@", fn);
        };
    }
    
    return self;
}

-(void)newLogFileWithName:(NSString *)fn
{
    if (![self createLogWithFilename:fn]) {
        NSLog(@"!!!!!!!!Cannot create log file with name %@", fn);
    };
}

-(void)newLogFile
{
    if (![self createLogWithFilename:@""]) {
        NSLog(@"!!!!!!!!Cannot create log file");
    };
}

-(BOOL)createLogWithFilename:(NSString *)fn
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    filename = [fn stringByAppendingString:@".txt"];
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond) fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    NSString *filePrefix = [NSString stringWithFormat:@"%@_%d_%d_%d_%d_%d_%d_", prodName,year, month, day, hour, minute, second];
    NSString *fullFilename = [filePrefix stringByAppendingString:filename];
    
    fileFullpath = [filePath stringByAppendingPathComponent:fullFilename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFullpath]) {
        if ([[NSFileManager defaultManager] createFileAtPath:fileFullpath contents:nil attributes:nil]) {
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileFullpath];
            return  TRUE;
        } ;
    } else {
        // try to resolve file name conflict
        NSInteger nanosecond = [components nanosecond];
        filePrefix = [filePrefix stringByAppendingString:[NSString stringWithFormat:@"%d_", nanosecond]];
        NSString *fullFilename = [filePrefix stringByAppendingString:filename];
        fileFullpath = [filePath stringByAppendingPathComponent:fullFilename];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileFullpath]) {
            if ([[NSFileManager defaultManager] createFileAtPath:fileFullpath contents:nil attributes:nil]) {
                fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileFullpath];
                return  TRUE;
            } ;
        }
    }
    
    return FALSE;
}

-(void)write:(NSString *)log
{
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
