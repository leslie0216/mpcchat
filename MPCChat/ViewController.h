//
//  ViewController.h
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-24.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textview_edit_msg;
@property (strong, nonatomic) IBOutlet UITextView *textview_history_msg;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnPing;
@property (weak, nonatomic) IBOutlet UISwitch *swReliable;

- (IBAction)sendMsg:(id)sender;
- (IBAction)ping:(id)sender;

@end

