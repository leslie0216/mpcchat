//
//  OptionsViewController.h
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-05.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface OptionsViewController : UIViewController<MCBrowserViewControllerDelegate>

@property(weak, nonatomic) IBOutlet UISwitch *swVisible;
@property(weak, nonatomic) IBOutlet UITextView *tvPlayerList;

- (IBAction)disconnect:(id)sender;
- (IBAction)searchForPlayers:(id)sender;
- (IBAction)toggleVisibility:(id)sender;


@end
