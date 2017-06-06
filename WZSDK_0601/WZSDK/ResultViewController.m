//
//  ResultViewController.m
//  WZSDK
//
//  Created by jp007 on 2017/6/6.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "ResultViewController.h"
#import "WZBleSDKInterface.h"
#import "SVProgressHUD.h"
@interface ResultViewController ()<WZBleSDKInterfaceListener,UITableViewDelegate,UITableViewDataSource>
{
    WZBleSDKInterface * face;
}
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    face = [WZBleSDKInterface sharedInterface];
    [face addListner:self];
    
    
    self.title = _curDevice.name;
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    
    [self.view addSubview:tableView];
    
    

    
    tableView.delegate = self;
    tableView.dataSource = self;

    self.navigationItem.leftBarButtonItem = [self rightItem2];
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
        [self.navigationController popViewControllerAnimated:YES];
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

}
-(NSString*)stringOfCMD:(WZBluetoohCommand)cmd
{
    NSString * value = @"";
    switch (cmd) {
        case WZBluetoohCommandSetName:
            value =@"设置名字";
            break;
            
        case WZBluetoohCommandSynSteps:
            value =@"同步步数";
            break;
        case WZBluetoohCommandSynStatus:
            value =@"同步状态";
            break;
        case WZBluetoohCommandCloseMotor:
            value =@"关闭马达";
            break;
        case WZBluetoohCommandGetBattery:
            value =@"获取电池";
            break;
        case WZBluetoohCommandSynPostures:
            value =@"同步历史坐姿";
            break;
        case WZBluetoohCommandGetRTPosture:
            value =@"实时坐姿";
            break;
        case WZBluetoohCommandSetLeftAngel:
            value =@"设置左倾角";
            break;
        case WZBluetoohCommandAdjustPosture:
            value =@"矫正坐姿";
            break;
        case WZBluetoohCommandRestartDevice:
            value =@"重启设备";
            break;
        case WZBluetoohCommandSetRightAngel:
            value =@"设置右倾角";
            break;
        case WZBluetoohCommandUploadDFUData:
            value =@"上传dfu";
            break;
        case WZBluetoohCommandActivateDevice:
            value =@"激活设备";
            break;
        case WZBluetoohCommandSetForwardAngel:
            value =@"设置前倾角";
            break;
        case WZBluetoohCommandSetBackwardAngel:
            value =@"设置后倾角";
            break;
        case WZBluetoohCommandSetMotorDuration:
            value =@"马达时长";
            break;
        case WZBluetoohCommandCancelAdjustPosture:
            value =@"取消矫正坐姿";
            break;
        case WZBluetoohCommandCancelActivateDevice:
            value =@"取消激活设备";
            break;
        case WZBluetoohCommandClearData:
            value = @"清除缓存";
        default:
            break;
    }
    return value;
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    return WZBluetoohCommandClearData+1;
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

    
//    switch (indexPath.row) {
//        case 0:
//            cell.textLabel.text = @"读取电池电量";
//            break;
//        case 1:
//            cell.textLabel.text = @"激活命令";
//            break;
//        case 2:
//            cell.textLabel.text = @"取消激活命令";
//            break;
//        case 3:
//            cell.textLabel.text = @"链接状态下同步计数数据";
//            break;
//        case 4:
//            cell.textLabel.text = @"链接状态下同步状态数据";
//            break;
//        case 5:
//            cell.textLabel.text = @"设置马达震动秒数 open";
//            break;
//        case 6:
//            cell.textLabel.text = @"设置马达震动 close";
//            break;
//        case 7:
//            cell.textLabel.text = @"读取马达震动";
//            break;
//        case 8:
//            cell.textLabel.text = @"校准坐姿";
//            break;
//        case 9:
//            cell.textLabel.text = @"取消校准坐姿";
//            break;
//        case 10:
//            cell.textLabel.text = @"设置前倾角度";
//            break;
//        case 11:
//            cell.textLabel.text = @"设置后倾角度";
//            break;
//        case 12:
//            cell.textLabel.text = @"设置左倾角度";
//            break;
//        case 13:
//            cell.textLabel.text = @"设置右倾角度";
//            break;
//        case 14:
//            cell.textLabel.text = @"清除缓存";
//            break;
//        case 15:
//            cell.textLabel.text = @"重启";
//            break;
//        case 16:
//            cell.textLabel.text = @"发送升级数据";
//            break;
//        case 17:
//            cell.textLabel.text = @"修改名字";
//            break;
//            
//        default:
//            break;
//    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"(%ld)%@",indexPath.row, [self stringOfCMD:(WZBluetoohCommand)indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        case 18:
            [face bleDevice:_curDevice sendCommandCode:(WZBluetoohCommand)indexPath.row extraData:nil];
            break;
            
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        {
            NSString * s = [self stringOfCMD:(WZBluetoohCommand)indexPath.row];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:s message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入内容";
            }];
            
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               UITextField * field =  [alert.textFields firstObject];
                
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

@end
