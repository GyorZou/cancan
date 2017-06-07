//
//  InfoCell.h
//  WZSDK
//
//  Created by zougyor on 2017/6/7.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell

@property IBOutlet UILabel * nameLabel;
@property IBOutlet UILabel * batLabel;
@property IBOutlet UILabel * motorLabel;
@property IBOutlet UILabel * verLabel;
@property IBOutlet UILabel * stepLabel;
@property IBOutlet UILabel * posLabel;
@property IBOutlet UILabel * stateLabel;
@property IBOutlet UIButton * historyBtn;
@end