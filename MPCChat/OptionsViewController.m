//
//  OptionsViewController.m
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-05.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import "OptionsViewController.h"
#import "AppDelegate.h"

@interface OptionsViewController ()

@property(strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.appDelegate.mpcHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
    [self.appDelegate.mpcHandler setupSession];
    [self.appDelegate.mpcHandler advertiseSelf:self.swVisible.isOn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)
                                                 name:@"MPCChat_DidChangeStateNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchForPlayers:(id)sender
{
    if (self.appDelegate.mpcHandler.session != nil)
    {
        [[self.appDelegate mpcHandler] setupBrowser];
        [[[self.appDelegate mpcHandler] browser] setDelegate:self];

        [self presentViewController:self.appDelegate.mpcHandler.browser
                           animated:YES
                         completion:nil];
        
    }
}

- (IBAction)toggleVisibility:(id)sender
{
    [self.appDelegate.mpcHandler advertiseSelf:self.swVisible.isOn];
}

- (IBAction)disconnect:(id)sender
{
    [self.appDelegate.mpcHandler.session disconnect];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification
{
    // Get the state of the peer.
    int state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    // We care only for the Connected and the Not Connected states.
    // The Connecting state will be simply ignored.
    if (state != MCSessionStateConnecting) {
        // We'll just display all the connected peers (players) to the text view.
        NSString *allPlayers = @"Other players connected with:\n\n";
        
        for (int i = 0; i < self.appDelegate.mpcHandler.session.connectedPeers.count; i++) {
            NSString *displayName = [[self.appDelegate.mpcHandler.session.connectedPeers objectAtIndex:i] displayName];
            
            allPlayers = [allPlayers stringByAppendingString:@"\n"];
            allPlayers = [allPlayers stringByAppendingString:displayName];
        }
        
        [self.tvPlayerList setText:allPlayers];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
