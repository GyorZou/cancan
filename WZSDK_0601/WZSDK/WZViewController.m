//
//  WZViewController.m
//  WZSDK
//
//  Created by 生生 on 2017/4/24.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZViewController.h"
#import "WZBluetooh.h"
#import "WZFlashListViewController.h"
#import "SVProgressHUD.h"

//static NSString *const MacAdress = @"FE44EBA3E408";
//static NSString *const MacAdress = @"D9B657189E27";


@interface WZViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UITableView *tablew;
@property (weak, nonatomic) IBOutlet UILabel *statuLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabl;
@property (weak, nonatomic) IBOutlet UIButton *lookDataButton;
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;

@property (nonatomic, strong) WZBluetooh *bluetooh;
@property (nonatomic, assign) BOOL bluReady;

@property (nonatomic, strong) NSData *MacAdress;
@property (strong, nonatomic) NSMutableArray *postureArray;
@property (strong, nonatomic) NSMutableArray *peripheralArray;
@property (nonatomic, assign) BOOL hasSelect;

@end

@implementation WZViewController

@end
