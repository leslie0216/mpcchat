//
//  ViewController.m
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-24.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Messages.pbobjc.h"
#import "MPCLog.h"

@interface ViewController ()
{
    NSTimer *timer;
    NSTimeInterval startTime;
    NSTimeInterval totalStartTime;
    NSMutableArray *timerArray;
    BOOL isPing;
    NSString *chatHistory;
    MPCLog *myLog;
}

@property(strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MPCChat_DidReceiveDataNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.appDelegate.mpcHandler.session != nil && self.appDelegate.mpcHandler.session.connectedPeers.count > 0) {
        self.lbStatus.text = @"Connected";
        self.btnSend.enabled = TRUE;
        self.btnPing.enabled = TRUE;
        [self.appDelegate.mpcHandler updateSendMode:self.swReliable.isOn];
    } else {
        self.lbStatus.text = @"Not Connected";
        self.btnSend.enabled = FALSE;
        self.btnPing.enabled = FALSE;
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification
{
    NSData *data = [[notification userInfo] objectForKey:@"data"];
    
    TransferMessage *message = [[TransferMessage alloc] initWithData:data error:nil];
    
    switch (message.messageType) {
        case TransferMessage_MsgType_Text:
        {
            NSLog(@"Received From > %@", message.name);
            NSLog(@"Received Message > %@", message.message);
            
            NSString *history = [NSString stringWithFormat:@"%@: %@\n\n", message.name, message.message];
            
            if (isPing) {
                chatHistory = [history stringByAppendingString:chatHistory];
            } else {
                [_textview_history_msg setText:[history stringByAppendingString:self.textview_history_msg.text]];
            }
        }
            break;
        case TransferMessage_MsgType_Ping:
        {
            //handled by MPCHandler
            //[self sendPacket:@"r" ping:NO response:YES];
        }
            break;
        case TransferMessage_MsgType_Response:
        {
            NSTimeInterval receiveTime = [[[notification userInfo] objectForKey:@"time"] doubleValue];

            NSTimeInterval timeInterval = receiveTime - startTime;
            NSTimeInterval timeInterval2 = (([[NSDate date] timeIntervalSince1970] * 1000) - startTime);
            //NSTimeInterval totalTime = (([[NSDate date] timeIntervalSince1970] * 1000) - totalStartTime);
            NSNumber *numTime = [[NSNumber alloc] initWithDouble:timeInterval];
            [timerArray addObject:numTime];
            BOOL isExceed = [timerArray count] > 2000 ? YES : NO;
            if (isExceed) {
                [timerArray removeObjectAtIndex:0];
            }
            NSNumber *average = [timerArray valueForKeyPath:@"@avg.self"];
            NSNumber *std = nil;
            if (isExceed) {
                std = [self standardDeviationOf:timerArray mean:[average doubleValue]];
            }
            NSString *ping = [[NSString alloc]initWithFormat:@"(Ping) current : %f (%f)  avg : %f\n  count : %lu  stdev : %f\n\n", timeInterval, timeInterval2, [average doubleValue], (unsigned long)[timerArray count], [std doubleValue]];
            
            // log
            NSString *log = [[NSString alloc]initWithFormat:@"%f,%f\n", timeInterval, ([[NSDate date] timeIntervalSince1970] * 1000)];
            [self writeLog:log];
             
            
            [self.textview_history_msg setText:[ping stringByAppendingString:chatHistory]];
            if (isPing) {
                [self doPing];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)sendPacket:(NSString *)message ping:(BOOL)ping response:(BOOL)response
{
    if (self.appDelegate.mpcHandler.session == nil || self.appDelegate.mpcHandler.session.connectedPeers.count == 0) {
        NSLog(@"No peers found!");
        return;
    }
    
    TransferMessage *packet = [[TransferMessage alloc]init];
    packet.name = [[UIDevice currentDevice] name];
    packet.message = message;
    
    if (ping) {
        packet.messageType = TransferMessage_MsgType_Ping;
    } else if (response) {
        packet.messageType = TransferMessage_MsgType_Response;
    } else {
        packet.messageType = TransferMessage_MsgType_Text;
    }
    
    NSError *error;
    
    if (ping) {
        startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    
    MCSessionSendDataMode mode = self.swReliable.isOn ? MCSessionSendDataReliable : MCSessionSendDataUnreliable;

    [self.appDelegate.mpcHandler.session sendData:[packet data] toPeers:self.appDelegate.mpcHandler.session.connectedPeers withMode:mode error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (!ping && !response) {
        self.btnPing.enabled = TRUE;
        self.btnSend.enabled = TRUE;
        
        if ([self.textview_edit_msg.text isEqualToString:@""]) {
            return;
        }
        
        NSString *history = [NSString stringWithFormat:@"I: %@\n\n", self.textview_edit_msg.text];
        
        [self.textview_history_msg setText:[history stringByAppendingString:self.textview_history_msg.text]];
        
        [self.textview_edit_msg setText:@""];
    }
}

- (IBAction)changeMode:(id)sender
{
    [self.appDelegate.mpcHandler updateSendMode:self.swReliable.isOn];
}

- (IBAction)sendMsg:(id)sender
{
    self.btnPing.enabled = FALSE;
    self.btnSend.enabled = FALSE;
    
    [self.textview_edit_msg resignFirstResponder];
    
    NSLog(@"Sent : %@", _textview_edit_msg.text);
    
    [self sendPacket:self.textview_edit_msg.text ping:NO response:NO];
}

- (IBAction)ping:(id)sender
{
    if (isPing) {
        [self stopPing];
    } else {
        [self startPing];
    }
}

- (void)startPing
{
    if (timerArray == nil) {
        timerArray = [[NSMutableArray alloc] init];
    } else {
        [timerArray removeAllObjects];
    }
    
    isPing = YES;
    self.swReliable.enabled = FALSE;
    self.btnSend.enabled = FALSE;
    self.btnPing.enabled = TRUE;
    self.textview_edit_msg.editable = FALSE;
    [self.textview_edit_msg resignFirstResponder];
    [self.btnPing setTitle:@"Stop Ping" forState:UIControlStateNormal];
    chatHistory = self.textview_history_msg.text;
    totalStartTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [self startLog];
    [self doPing];
    
}

- (void)stopPing
{
    isPing = NO;
    self.swReliable.enabled = TRUE;
    self.btnSend.enabled = TRUE;
    self.btnPing.enabled = TRUE;
    self.textview_edit_msg.editable = TRUE;
    [self.btnPing setTitle:@"Start Ping" forState:UIControlStateNormal];
}

- (void)doPing
{
    startTime = 0.0;
    [self sendPacket:@"p" ping:YES response:NO];
}

- (NSNumber *)standardDeviationOf:(NSArray *)array mean:(double)mean
{
    if(![array count]) return nil;
    
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [array count])];
}

-(void)startLog
{
    if (myLog == nil) {
        myLog = [[MPCLog alloc]init];
    }
    
    [myLog newLogFile];
    [self writeLog:@"ping, timestamp\n"];
}

-(void)writeLog:(NSString *)log
{
    if (myLog != nil) {
        [myLog write:log];
    }
}

@end
