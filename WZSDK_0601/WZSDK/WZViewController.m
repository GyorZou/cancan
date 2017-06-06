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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tablew.delegate = self;
    self.tablew.dataSource = self;
    
    self.connectLabel.text = @"请选择>>>>>";
    self.statuLabel.hidden = YES;
    self.stepLabl.hidden = YES;
    self.lookDataButton.hidden = YES;
    self.settingLabel.hidden = YES;
    self.currentStatusLabel.hidden = YES;
    
    self.bluReady = NO;
    self.hasSelect = NO;
    self.postureArray = [[NSMutableArray alloc] init];
    self.peripheralArray = [[NSMutableArray alloc] init];
    self.bluetooh = [WZBluetooh shareBabyBluetooth];
    
    __weak typeof(self) weakSelf = self;

    [self.bluetooh startBluetoothServiceWithPeriphera:^(CBPeripheral *peripheral, NSDictionary *advertisementData) {
        
        for (NSDictionary *dict in weakSelf.peripheralArray) {
            CBPeripheral *peripheralTemp = [dict valueForKeyPath:@"peripheral"];
            if ([peripheralTemp.name isEqualToString:peripheral.name]) {
                return ;
            }
        }
        
        NSDictionary *dict = @{@"peripheral":peripheral, @"advertisementData":advertisementData};
        
        [weakSelf.peripheralArray addObject:dict];
        [weakSelf.tablew reloadData];

        
//        for (CBPeripheral *peripheralTemp in weakSelf.peripheralArray) {
//            if ([peripheralTemp.name isEqualToString:peripheral.name]) {
//                return ;
//            }
//        }
//        
//        [weakSelf.peripheralArray addObject:peripheral];
//        [weakSelf.tablew reloadData];
    }];
    [self connet];
    
    [self.bluetooh getRealTimeStatus:^(NSInteger status, NSInteger sitting) {
        
        NSString *statusString;
        if (status == 0) {
            statusString = @"未知";
        } else if (status == 1) {
            statusString = @"坐/站立";
        } else if (status == 2) {
            statusString = @"躺";
        } else if (status == 3) {
            statusString = @"走";
        } else if (status == 4) {
            statusString = @"跑";
        }
        
        NSString *sittingString = @"未知";
        if (status == 1) {
            if (sitting == 0) {
                sittingString = @"未知";
            } else if (sitting == 1) {
                sittingString = @"正坐";
            } else if (sitting == 2) {
                sittingString = @"偏左";
            } else if (sitting == 3) {
                sittingString = @"偏右";
            } else if (sitting == 4) {
                sittingString = @"偏前";
            } else if (sitting == 5) {
                sittingString = @"偏后";
            }
        }
        

        NSString *currentStatusAndSetting = [NSString stringWithFormat:@"当前状态:%@ 当前坐姿：%@", statusString, sittingString];
        weakSelf.currentStatusLabel.text = currentStatusAndSetting;
//        NSLog(@"currentStatusAndSetting: %@", currentStatusAndSetting);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)jumpToListView:(NSArray *)postureArray {
    WZFlashListViewController *listView = [[WZFlashListViewController alloc] init];
    listView.postureArray =  postureArray;
    [self presentViewController:listView animated:YES completion:^{
        
    }];
}

#pragma mark - reponse

- (IBAction)lookDataButtonClick:(id)sender {
    [self jumpToListView:self.postureArray];
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.hasSelect) {
        return self.peripheralArray.count;
    }
    
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (!self.hasSelect) {
        NSDictionary *dict = self.peripheralArray[indexPath.row];
        NSDictionary *advertisementData = [dict valueForKey:@"advertisementData"];
        NSString *name = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
        CBPeripheral* per = [dict valueForKey:@"peripheral"];
        cell.textLabel.text = per.name;
        return cell;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"读取电池电量";
            break;
        case 1:
            cell.textLabel.text = @"激活命令";
            break;
        case 2:
            cell.textLabel.text = @"取消激活命令";
            break;
        case 3:
            cell.textLabel.text = @"链接状态下同步计数数据";
            break;
        case 4:
            cell.textLabel.text = @"链接状态下同步状态数据";
            break;
        case 5:
            cell.textLabel.text = @"设置马达震动秒数 open";
            break;
        case 6:
            cell.textLabel.text = @"设置马达震动 close";
            break;
        case 7:
            cell.textLabel.text = @"读取马达震动";
            break;
        case 8:
            cell.textLabel.text = @"校准坐姿";
            break;
        case 9:
            cell.textLabel.text = @"取消校准坐姿";
            break;
        case 10:
            cell.textLabel.text = @"设置前倾角度";
            break;
        case 11:
            cell.textLabel.text = @"设置后倾角度";
            break;
        case 12:
            cell.textLabel.text = @"设置左倾角度";
            break;
        case 13:
            cell.textLabel.text = @"设置右倾角度";
            break;
        case 14:
            cell.textLabel.text = @"清除缓存";
            break;
        case 15:
            cell.textLabel.text = @"重启";
            break;
        case 16:
            cell.textLabel.text = @"发送升级数据";
            break;
        case 17:
            cell.textLabel.text = @"修改名字";
            break;

        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.hasSelect) {
        self.hasSelect = YES;
        NSDictionary *dict = self.peripheralArray[indexPath.row];
        NSDictionary *advertisementData = [dict valueForKey:@"advertisementData"];
        NSData *kCBAdvDataManufacturerData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
      NSData *mac = [kCBAdvDataManufacturerData subdataWithRange:NSMakeRange(2, 6)];
////        
        self.MacAdress = self.bluetooh.macAdress = mac;
        [SVProgressHUD showSuccessWithStatus:@"正在连接。。。。"];
        return;
    }
    
    
    if (!self.bluReady) {
        [SVProgressHUD showSuccessWithStatus:@"蓝牙还没准备好"];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    switch (indexPath.row) {
        case 0:
            [self.bluetooh getBattary:^(NSInteger battary) {
                NSString *string = [NSString stringWithFormat:@"获取到的电池电量: %ld", (long)battary];
                [SVProgressHUD showSuccessWithStatus:string];
            }];
            break;
        case 1:
            [self.bluetooh activation:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"激活指令生效"];
            }];
            break;
        case 2:
            [self.bluetooh cancelActivation:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"取消激活指令生效"];
            }];
            break;
        case 3:
            [self.bluetooh synStep:^(NSString *time, unsigned long steps) {
                NSString *string = [NSString stringWithFormat:@"时间：%@  计步数据:%ld",time, steps];
                [SVProgressHUD showSuccessWithStatus:string];
            }];
            break;
        case 4:{
            [self.bluetooh synPosture:^(NSDictionary *posture) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf jumpToListView:@[posture]];
                });
            }];}
            break;
        case 5:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置马达震动秒数（0～120）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 5;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
            
        }
            break;
        case 6:
            [self.bluetooh setMotor:NO shockTime:0 complete:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"设置马达震动成功 close"];
            }];
            break;
        case 7:
            [self.bluetooh getMotor:^(NSInteger speed) {
                NSString *string = [NSString stringWithFormat:@"马达震动: %ld", (long)speed];
                [SVProgressHUD showSuccessWithStatus:string];
            }];
            break;
        case 8:
            [self.bluetooh setPosture:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"效准坐姿"];

            }];
            break;
        case 9:
            [self.bluetooh cancelSetPosture:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"取消效准坐姿"];
                
            }];
            break;
        case 10:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置前倾角度（0～90）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 10;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
            
        }
            break;
        case 11:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置后倾角度（0～90）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 11;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
        }
            break;
        case 12:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置左倾角度（0～90）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 12;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
        }
            break;
        case 13:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"设置右倾角度（0～90）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 13;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
        }
            break;
        case 14:
            [self.bluetooh clearData:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"清除缓存"];
            }];
            break;
        case 15:
        {
            [self.bluetooh restart:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"重启成功"];
                /*
                //延时两秒，再扫描
                double delayInSeconds = .5;
                dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
                    [weakSelf.bluetooh startBluetoothService];
                });*/
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reScanBle];
            });
            
        }
            break;
        case 16:{
            NSString *url = [[NSBundle mainBundle] pathForResource:@"dfuwzV1.1.3" ofType:@"zip"];
            [SVProgressHUD showProgress:0];
            [self.bluetooh uploadWith:url upload:^(NSInteger part, NSInteger totalParts, NSInteger progress, NSInteger currentSpeedBytesPerSecond, NSInteger avgSpeedBytesPerSecond) {
                NSLog(@"progress %f", (long)progress/100.0);
                [SVProgressHUD showProgress:progress/100.0];
            } complete:^(BOOL success) {
                [SVProgressHUD showSuccessWithStatus:@"iOS升级成功"];
                [weakSelf.bluetooh startBluetoothService];
            }];}
            break;
        case 17:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"修改名称，请输入（中文最多5个汉字，英文最多17个字节）"
                                                               delegate:self cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alertView.tag = 17;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNamePhonePad;
            [alertView show];
        }
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            if (alertView.tag == 10) {
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || [text intValue]==0 || [text intValue]<0 || [text intValue]>90) {
                    [SVProgressHUD showErrorWithStatus:@"输入的角度范围（0～90）"];
                    return;
                }
                [self.bluetooh setAngle:[text intValue] forward:^(BOOL success) {
                    [SVProgressHUD showSuccessWithStatus:@"设置前倾角度"];
                }];
            }else if(alertView.tag == 11){
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || [text intValue]==0 || [text intValue]<0 || [text intValue]>90) {
                    [SVProgressHUD showErrorWithStatus:@"输入的角度范围（0～90）"];
                    return;
                }
                [self.bluetooh setAngle:[text intValue] backward:^(BOOL success) {
                    [SVProgressHUD showSuccessWithStatus:@"设置后倾角度"];
                }];
            }
            else if(alertView.tag == 12){
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || [text intValue]==0 || [text intValue]<0 || [text intValue]>90) {
                    [SVProgressHUD showErrorWithStatus:@"输入的角度范围（0～90）"];
                    return;
                }
                [self.bluetooh setAngle:[text intValue] leftLeaning:^(BOOL success) {
                    [SVProgressHUD showSuccessWithStatus:@"设置左倾角度"];
                }];
            }
            else if(alertView.tag == 13){
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || [text intValue]==0 || [text intValue]<0 || [text intValue]>90) {
                    [SVProgressHUD showErrorWithStatus:@"输入的角度范围（0～90）"];
                    return;
                }
                [self.bluetooh setAngle:[text intValue] rightDeviation:^(BOOL success) {
                    [SVProgressHUD showSuccessWithStatus:@"设置右倾角度"];
                }];
            }
            else if(alertView.tag == 5){
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || [text intValue]==0 || [text intValue]<0 || [text intValue]>120) {
                    [SVProgressHUD showErrorWithStatus:@"输入的角度范围（0～120）"];
                    return;
                }
                [self.bluetooh setMotor:YES shockTime:[text intValue] complete:^(BOOL success) {
                    [SVProgressHUD showSuccessWithStatus:@"设置马达震动秒数成功"];
                }];
            }
            else if(alertView.tag == 17){
                UITextField *tf=[alertView textFieldAtIndex:0];
                NSString * text=tf.text;
                if (text.length==0 || 11<[self convertToInt:text]) {
                    [SVProgressHUD showErrorWithStatus:@"请输入字符范围，中文最多5个汉字，英文最多17个字节。"];
                    return;
                }
                __weak typeof(self)weakSelf = self;
                //中文最多5个汉字，英文最多17个字节
                [self.bluetooh renameWithName:text complete:^(BOOL success, NSError *error) {
                    if (error) {
                        [SVProgressHUD showSuccessWithStatus:error.localizedDescription];
                        return ;
                    }
                    [SVProgressHUD showSuccessWithStatus:@"修改名字成功"];
                    //[weakSelf performSelector:@selector(reScanBle) withObject:nil afterDelay:1];
                }];
            }
            
        }
            break;

        default:
            break;
    }
}
- (int)convertToInt:(NSString*)strtemp//判断中英混合的的字符串长度
{
    int strlength = 0;
    char *p = (char *)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i < [strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

-(void)reScanBle{
    
    self.connectLabel.text = @"请选择>>>>>";
    self.statuLabel.hidden = YES;
    self.stepLabl.hidden = YES;
    self.lookDataButton.hidden = YES;
    self.settingLabel.hidden = YES;
    self.currentStatusLabel.hidden = YES;
    
    self.bluReady = NO;
    self.hasSelect = NO;
    
    
    //[self.postureArray removeAllObjects];
    [self.peripheralArray removeAllObjects];
    
    [self.tablew reloadData];

    self.MacAdress = self.bluetooh.macAdress = nil;
    __weak typeof(self) weakSelf = self;
//    [self.bluetooh startBluetoothServiceWithPeriphera:^(CBPeripheral *peripheral, NSDictionary *advertisementData) {
//        
//        for (NSDictionary *dict in weakSelf.peripheralArray) {
//            CBPeripheral *peripheralTemp = [dict valueForKeyPath:@"peripheral"];
//            if ([peripheralTemp.name isEqualToString:peripheral.name]) {
//                return ;
//            }
//        }
//        
//        NSDictionary *dict = @{@"peripheral":peripheral, @"advertisementData":advertisementData};
//        
//        [weakSelf.peripheralArray addObject:dict];
//        [weakSelf.tablew reloadData];
//        
//        
//    }];
    [self connet];
}

- (void)connet {
    __weak typeof(self) weakSelf = self;
    [self.bluetooh scanDeviceWithRespondStatuBlock:^(CBPeripheral*pr,NSInteger battary, NSInteger speed, NSMutableString *versionString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.statuLabel.text = [NSString stringWithFormat:@"电池电量：%ld  马达速度：%ld 版本号：%@",(long)battary, (long)speed, versionString];
            weakSelf.connectLabel.text = [NSString stringWithFormat:@"已连接设备：%@", self.MacAdress];
            weakSelf.statuLabel.hidden = NO;
            weakSelf.stepLabl.hidden = NO;
            weakSelf.lookDataButton.hidden = NO;
            weakSelf.settingLabel.hidden = NO;
            weakSelf.currentStatusLabel.hidden = NO;
            [weakSelf.tablew reloadData];
        });
        
    } synStep:^(NSString *time, unsigned long steps) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.stepLabl.text = [NSString stringWithFormat:@"时间：%@ 步数：%ld",time, steps];
        });
        
    } posture:^(NSDictionary *posture) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.postureArray addObject:posture];
            
            //去重
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            for(NSString *str in weakSelf.postureArray) {
                [dic setValue:str forKey:str];
            }
            weakSelf.postureArray = [[dic allKeys] mutableCopy];
        });
        
    } sitting:^(NSString *time, NSInteger sittingTime, NSInteger forwardTime, NSInteger backwardTime, NSInteger leftLeaningTime, NSInteger rightDeviationTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *settingString = [NSString stringWithFormat:@"时间 %@  正坐时间：%ld  前倾时间：%ld  后倾时间：%ld  左倾时间：%ld  右倾时间：%ld", time, (long)sittingTime, (long)forwardTime, (long)backwardTime, (long)leftLeaningTime,(long)rightDeviationTime];
            
            weakSelf.settingLabel.text = settingString;
        });
        
        
    } replyComplete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.connectLabel.text = [NSString stringWithFormat:@"已连接设备：%@", self.MacAdress];
            weakSelf.statuLabel.hidden = NO;
            weakSelf.stepLabl.hidden = NO;
            weakSelf.lookDataButton.hidden = NO;
            weakSelf.settingLabel.hidden = NO;
            weakSelf.currentStatusLabel.hidden = NO;
            [weakSelf.tablew reloadData];
        });
        
        
    } writeReady:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.bluReady = success;
        });
        
    } readRSSI:^(CBPeripheral * p,NSNumber *RSSI, NSError *error) {
        
    } fail:^(NSError *error) {
        
    } disconnect:^(NSError *error,CBPeripheral*p) {
        NSLog(@"");
    }];

}

@end
