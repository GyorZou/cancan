//
//  ResultViewController.m
//  WZSDK
//
//  Created by jp007 on 2017/6/6.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "ResultViewController.h"
#import "WZBleSDK.h"
#import "SVProgressHUD.h"
#import "InfoCell.h"
#import "HistoryViewController.h"
@interface ResultViewController ()<WZBleSDKInterfaceListener,UITableViewDelegate,UITableViewDataSource>
{
    WZBleSDKInterface * face;
    
    InfoCell * _curInfo;

    NSMutableArray * _todaySitArr;
}
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    face = [WZBleSDKInterface sharedInterface];
    [face addListner:self];
    

    _todaySitArr = [NSMutableArray new];
    self.title = _curDevice.name;
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    
    [self.view addSubview:tableView];
    
    
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.navigationItem.leftBarButtonItem = [self rightItem2];
    
    [tableView registerNib:[UINib nibWithNibName:@"InfoCell" bundle:nil] forCellReuseIdentifier:@"InfoCell.xib"];
}
-(UIBarButtonItem*)rightItem2
{
    UIButton * indi = [UIButton buttonWithType:UIButtonTypeCustom];
    [indi setTitle:@"返回" forState:UIControlStateNormal];
    [indi  setTitleColor:[UIColor blackColor] forState:0];
    [indi addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    indi.frame = CGRectMake(0, 0, 40, 40);
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:indi];
    
    
    return item;
}
-(void)dismiss{
    
    [face removeListener:self];
    
    [face disConnectDevice:_curDevice];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)bleDevice:(WZBleDevice *)device didDisconneted:(NSError *)error
{
    if(device==_curDevice){
        [SVProgressHUD showInfoWithStatus:@"设备已断开连接"];
        //[self.navigationController popViewControllerAnimated:YES];
        [self dismiss];
    }
}
-(void)bleDevice:(WZBleDevice *)device didRefreshData:(WZBleData *)data comandCode:(WZBluetoohCommand)command
{
    NSLog(@"finished cmd:%@",[self stringOfCMD:command]);
    if (command!= WZBluetoohCommandGetRTPosture) {
        
        
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"已完成指令：%@",[self stringOfCMD:command]]];
    }
    if (command == WZBluetoohCommandSetName) {
        [face bleDevice:_curDevice sendCommandCode:WZBluetoohCommandRestartDevice extraData:nil];//修改名字后要重启
    }
    
    
    if (command == WZBluetoohCommandSynSitStatus) {
        
       NSString * s = [NSString stringWithFormat:@"正坐:%lds,前倾:%lds,右倾:%lds,后倾:%lds,左倾:%lds",_curDevice.data.sitTime,_curDevice.data.forwardSitTime,_curDevice.data.rightSitTime,_curDevice.data.backwardSitTime,_curDevice.data.leftSitTime];
        if (_curDevice.data.synTodayTime) {
            BOOL isOld = NO;
            for (NSMutableDictionary* d in _todaySitArr) {
                NSString * dayKey = [[d allKeys] firstObject];
                if (dayKey == _curDevice.data.synTodayTime) {
                    NSArray * cur = d[dayKey];
                    
                    NSMutableArray * temp = [NSMutableArray arrayWithArray:cur];
                    [temp addObject:s];
                    
                    d[dayKey] = [temp copy];//保存
                    
                    isOld = YES;
                }
            }
            
            if (isOld == NO) {//新建并保存
                NSMutableDictionary *d = [NSMutableDictionary new];
                NSMutableArray * temp = [NSMutableArray arrayWithObject:s];
                d[_curDevice.data.synTodayTime] = temp;
                [_todaySitArr addObject:d];
            }
            
        }
        
        _curInfo.todaySitLabel.text = s ;
    }
    
    if (command == WZBluetoohCommandSynPostures) {
        if (data.todayPos.count>0) {
            NSDictionary * d =  [data.todayPos lastObject];
            NSString * day = [[d allKeys] firstObject];
            
            NSArray * datas = d[day];
            
            NSString * temp=@"";
            NSMutableArray * arr = [NSMutableArray new];
            for (int i = 0; i<datas.count; i++) {
                WZHistoryModel * model = datas[i];
                
                NSString * value = model.value;
                NSArray * t =[value componentsSeparatedByString:@"-"];
                if (t.count==3) {
                    
                    NSString * s = [NSString stringWithFormat:@"%@时%@分 %@",t[0],t[1],[WZBleDeviceTools postureString:[t[2] intValue]]];
                    [arr addObject:s];
                }
                
                
                
            }
            temp = [arr componentsJoinedByString:@";"];
            _curInfo.todayStateLabel.text = [NSString stringWithFormat:@"%@:%@",day,temp];
        }
    }
    
    
    [self updateInfo:_curInfo];
}
-(NSString*)stringOfCMD:(WZBluetoohCommand)cmd
{
    return [WZBleDeviceTools descriptionOfCMD:cmd];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }
    
    return WZBluetoohCommandNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return 258;
    }
    return 40;
}
-(void)hisBtnClick:(UIButton*)btn
{
    HistoryViewController * his = [HistoryViewController new];
    if(btn.tag==100){//历史状态
        his.data = _curDevice.data.historyPos;
    }else if(btn.tag==101){//历史步数
        his.data = _curDevice.data.historySteps;
    }else if(btn.tag==102){//历史坐时
        his.data = _curDevice.data.historySit;
    }else if(btn.tag==103){//jinri姿势
        his.data = _curDevice.data.todayPos;
    }else if(btn.tag==104){//jinri坐时
        his.data = [_todaySitArr copy];
    }
    his.tag = (int)btn.tag;
    
    his.title = btn.titleLabel.text;
    [self.navigationController pushViewController:his animated:YES];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        if(_curInfo){
            return _curInfo;
        }
        InfoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell.xib"];
        _curInfo = cell;
        
        [cell.historySitBtn removeTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.historyBtn removeTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.historyStepBtn removeTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.todayPosBtn removeTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.todaySitBtn removeTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell.historySitBtn addTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.historyBtn addTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.historyStepBtn addTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.todayPosBtn addTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.todaySitBtn addTarget:self action:@selector(hisBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateInfo:cell];
        return cell;
    }
    NSString *identifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"(%ld)%@",indexPath.row, [self stringOfCMD:(WZBluetoohCommand)indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0)return;
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
            
            [face bleDevice:_curDevice sendCommandCode:(WZBluetoohCommand)indexPath.row extraData:nil];
            break;
        case 15:{
            
            NSArray * paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"zip" inDirectory:nil];
            
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"选择版本" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:cancelAction];
            
            for (NSString * path in paths) {
                NSString * cmp = [path lastPathComponent];
                UIAlertAction *action = [UIAlertAction actionWithTitle:cmp style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [face bleDevice:_curDevice sendCommandCode:(WZBluetoohCommand)indexPath.row extraData:cmp];
                }];
                [alertController addAction:action];
            }
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        }
            
            break;
            
            
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
        case 21:
        {
            NSString * s = [self stringOfCMD:(WZBluetoohCommand)indexPath.row];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:s message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入内容";
            }];
            
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField * field =  [alert.textFields firstObject];
                
                if (indexPath.row==WZBluetoohCommandSetName) {//名字
                    if(field.text.length>10){
                        [SVProgressHUD showInfoWithStatus:@"名字长度不要超过10位"];
                        return ;
                    }
                }else if(indexPath.row ==WZBluetoohCommandSetMotorDuration){//马达时长
                    if(field.text.intValue>500||field.text.intValue<1){
                        [SVProgressHUD showInfoWithStatus:@"0<马达时长<500"];
                        return;
                    }
                }else{
                    if(field.text.intValue>90||field.text.intValue<1){
                        [SVProgressHUD showInfoWithStatus:@"0<倾角<90"];
                        return;
                    }
                    
                }
                
                [face bleDevice:_curDevice sendCommandCode:(WZBluetoohCommand)indexPath.row extraData:field.text];
            }];
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:action];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
            
            break;
            
            
        default:
            break;
    }
    
}

-(void)updateInfo:(InfoCell*)cell
{
    WZBleData * data = _curDevice.data;
    
    cell.motorStateLabel.text = _curDevice.data.isMotorOn?@"开":@"关";
    cell.nameLabel.text = _curDevice.name;
    cell.batLabel.text = @(data.battery).stringValue;
    cell.motorLabel.text = @(data.speed).stringValue;
    cell.verLabel.text = data.version;
    
    cell.stepLabel.text = @(data.steps).stringValue;
    cell.posLabel.text = data.sitStatusString;
    cell.stateLabel.text = data.postureStatusString;
    
    cell.historyBtn.enabled = data.postures.count>0;
    cell.historyStepBtn.enabled = data.historySteps.count>0;
    cell.historySitBtn.enabled = data.historySit.count>0;
    
    
    
    
    
}

@end
