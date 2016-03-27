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

#define LOG_ENABLE

@interface PingInfo : NSObject
@property(strong, nonatomic)NSString* token;
@property(assign, nonatomic)CFTimeInterval startTime;
@property(strong, nonatomic)NSMutableArray *timeIntervals;
@property(assign, nonatomic)unsigned long totalCount;
@property(assign, nonatomic)unsigned long currentCount;
@property(assign, nonatomic)unsigned long number;

@end

@implementation PingInfo
@synthesize token;
@synthesize startTime;
@synthesize timeIntervals;
@synthesize totalCount;
@synthesize currentCount;
@synthesize number;

@end

@interface ViewController ()
{
    NSTimer *timer;
    CFTimeInterval totalStartTime;
    NSMutableArray *timerArray;
    BOOL isPing;
    NSString *chatHistory;
    MPCLog *myLog;
    NSMutableDictionary *pingDict;
    unsigned long count;
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
            MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
            NSLog(@"Received From > %@", [peerID displayName]);
            NSLog(@"Received Message > %@", message.message);
            
            NSString *history = [NSString stringWithFormat:@"%@: %@\n\n", [peerID displayName], message.message];
            
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
            NSString *token = message.message;

            CFTimeInterval receiveTime = [[[notification userInfo] objectForKey:@"time"] doubleValue];
            
            PingInfo *info = pingDict[token];
            if (info == nil) {
                NSLog(@"Invalid ping token received!!!");
                return;
            } else if(info.totalCount == info.currentCount) {
                NSLog(@"Token over received!!!");
                return;
            }
            
            NSLog(@"Receive time(r) = %f with token : %@ \n", receiveTime, token);
            NSLog(@"Start time(r) = %f with token : %@ \n", info.startTime, token);
            
            CFTimeInterval timeInterval = receiveTime - info.startTime - message.responseTime;
            NSLog(@"timeInterval : %f", timeInterval);
            if (timeInterval > 300) {
                NSLog(@"!!!High latency!!!");
            } else if(timeInterval < 0) {
                NSLog(@"!!!Negative value!!!");
            }

            NSNumber *numTime = [[NSNumber alloc] initWithDouble:timeInterval];
            [timerArray addObject:numTime];
            
            [info.timeIntervals addObject:numTime];
            info.currentCount += 1;
            

            NSString *ping = [[NSString alloc]initWithFormat:@"(Ping) current : %f\nreceived count : %lu\n total count : %lu\nisReliable : %@\n", timeInterval, (unsigned long)[timerArray count], count, self.swReliable.isOn ? @"Yes" : @"No"];
            
#ifdef LOG_ENABLE
            // log
            NSString *log = [[NSString alloc]initWithFormat:@"%@, %f, %@, %lu, %f\n", [[[notification userInfo] objectForKey:@"peerID"] displayName], timeInterval, token, info.number,CACurrentMediaTime() * 1000];

            [self writeLog:log];
#endif
            
            if (isPing) {
                [self.textview_history_msg setText:[ping stringByAppendingString:chatHistory]];
            }
            /*
            if (isPing) {
                [self doPing];
            }*/
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
    //packet.name = [[UIDevice currentDevice] name];
    packet.message = message;
    
    if (ping) {
        packet.messageType = TransferMessage_MsgType_Ping;
    } else if (response) {
        packet.messageType = TransferMessage_MsgType_Response;
    } else {
        packet.messageType = TransferMessage_MsgType_Text;
    }
    
    NSError *error;
    MCSessionSendDataMode mode = self.swReliable.isOn ? MCSessionSendDataReliable : MCSessionSendDataUnreliable;
    
    NSString *currentPingToken = [[NSUUID UUID] UUIDString];
    if (ping) {
        
        packet.message = currentPingToken;
        packet.isReliable = self.swReliable.isOn ? YES : NO;
    }
    NSData *sendData = [packet data];
    CFTimeInterval startTime = CACurrentMediaTime() * 1000;
   
    [self.appDelegate.mpcHandler.session sendData:sendData toPeers:self.appDelegate.mpcHandler.session.connectedPeers withMode:mode error:&error];
     NSLog(@"Start time = %f with token : %@ package size : %d\n", startTime, currentPingToken, [sendData length]);
    if (isPing) {
        PingInfo *info = [[PingInfo alloc]init];
        info.startTime = startTime;
        info.token =  currentPingToken;
        info.totalCount = self.appDelegate.mpcHandler.session.connectedPeers.count;
        info.currentCount = 0;
        count += info.totalCount;
        info.number = count;
        info.timeIntervals = [[NSMutableArray alloc]initWithCapacity:info.totalCount];
        
        [pingDict setValue:info forKey:currentPingToken];
    }
    
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
        //[self stopSuperPing];
        //isPing = FALSE;
    } else {
        [self startPing];
        //isPing = TRUE;
        //[self startSuperPing];
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
    chatHistory = @"";//self.textview_history_msg.text;
    totalStartTime = CACurrentMediaTime() * 1000;
    
    count = 0;
    if (pingDict == nil) {
        pingDict = [[NSMutableDictionary alloc]init];
    } else {
        [pingDict removeAllObjects];
    }
#ifdef LOG_ENABLE
    [self startLog];
#endif
    //[self doPing];
    [self startSuperPing];
    
}

- (void)stopPing
{
    isPing = NO;
    self.swReliable.enabled = TRUE;
    self.btnSend.enabled = TRUE;
    self.btnPing.enabled = TRUE;
    self.textview_edit_msg.editable = TRUE;
    [self.btnPing setTitle:@"Start Ping" forState:UIControlStateNormal];
    [self stopSuperPing];
}

- (void)doPing
{
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
    //[self writeLog:@"ping, timestamp\n"];
}

-(void)writeLog:(NSString *)log
{
    if (myLog != nil) {
        [myLog write:log];
    }
}

-(void)startSuperPing
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                 target:self
                                               selector:@selector(doSuperPing)
                                               userInfo:nil
                                                repeats:YES];
}

-(void)doSuperPing
{
    [self sendPacket:@"p" ping:YES response:NO];
}

-(void)stopSuperPing
{
    [timer invalidate];

    // calculate loss rate, min/max time interval, standard deviation after 1s
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(calculateResult)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)calculateResult
{
    unsigned long total = 0;
    unsigned long received = 0;
    NSMutableArray *allTimes = [[NSMutableArray alloc]init];
    for (id key in pingDict) {
        PingInfo *info = pingDict[key];
        
        total += info.totalCount;
        received += info.currentCount;
        
        for(NSNumber *num in info.timeIntervals) {
            [allTimes addObject:num];
        }
    }
    
    NSNumber *average = [allTimes valueForKeyPath:@"@avg.self"];
    NSNumber *min = [allTimes valueForKeyPath:@"@min.self"];
    NSNumber *max = [allTimes valueForKeyPath:@"@max.self"];
    NSNumber *std = [self standardDeviationOf:timerArray mean:[average doubleValue]];
    double lossRate = 1.0 - (double)received/total;
    NSString* lossRateStr = [NSString stringWithFormat:@"%f%%",lossRate*100];
    
    NSString* result = [NSString stringWithFormat:@"total : %lu\nreceived : %lu\nloss rate : %@\nmin : %.8f\nmax : %.8f\naverage : %.8f\nstdev : %.8f", total, received, lossRateStr, [min doubleValue], [max doubleValue], [average doubleValue], [std doubleValue]];
    
    [self.textview_history_msg setText:result];
}

@end
