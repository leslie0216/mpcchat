//
//  MPCHandler.h
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-24.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <sys/socket.h>

@interface MPCHandler : NSObject<MCSessionDelegate>

@property(nonatomic, strong) MCPeerID *peerID;
@property(nonatomic, strong) MCSession *session;
@property(nonatomic, strong) MCBrowserViewController *browser;
@property(nonatomic, strong) MCAdvertiserAssistant *advertiser;

- (void) setupPeerWithDisplayName:(NSString *)displayName;
- (void) setupSession;
- (void) setupBrowser;
- (void) advertiseSelf:(BOOL)advertise;
@end
