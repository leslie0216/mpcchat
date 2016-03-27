//
//  MPCHandler.m
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-24.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import "MPCHandler.h"
#import "Messages.pbobjc.h"

@interface MPCHandler()
{
    NSString *currentToken;
}
@end

@implementation MPCHandler

- (void) setupPeerWithDisplayName:(NSString *)displayName
{
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}

- (void) setupSession
{
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
}

- (void) setupBrowser
{
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:@"mpcchat" session:_session];
}

- (void) advertiseSelf:(BOOL)advertise
{
    if (advertise) {
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"mpcchat" discoveryInfo:nil session:self.session];
        [self.advertiser start];
    } else {
        [self.advertiser stop];
        self.advertiser = nil;
    }
}

- (void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSDictionary *userInfo = @{ @"peerID": peerID, @"state": @(state)};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MPCChat_DidChangeStateNotification"
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    CFTimeInterval t = CACurrentMediaTime() * 1000;
    NSNumber *time = [NSNumber numberWithDouble:t];
    
    TransferMessage *message = [[TransferMessage alloc] initWithData:data error:nil];

    if (message.messageType == TransferMessage_MsgType_Ping) {
        
        
        TransferMessage *packet = [[TransferMessage alloc]init];
        packet.message = message.message;
        packet.messageType = TransferMessage_MsgType_Response;
        
        MCSessionSendDataMode mode = message.isReliable ? MCSessionSendDataReliable : MCSessionSendDataUnreliable;
        
        packet.isReliable = message.isReliable;

        NSTimeInterval t2 = CACurrentMediaTime() * 1000;
        packet.responseTime = t2 - t;
        //NSLog(@"Response time = %f", (t2-t));
        
        NSData *sendData = [packet data];

        [self.session sendData:sendData toPeers:self.session.connectedPeers withMode:mode error:nil];
        
        NSLog(@"send response with token : %@ and local response time : %f", message.message, packet.responseTime);
        
    } else {
        NSDictionary *userInfo = @{ @"data": data,
                                @"peerID": peerID,
                                @"time": time};
    
    NSLog(@"Receive time = %f with token : %@ \n", t, message.message);
    
        dispatch_async(dispatch_get_main_queue(), ^{
    
    
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MPCChat_DidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:userInfo];
        });
    }
}

- (void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

- (void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

@end