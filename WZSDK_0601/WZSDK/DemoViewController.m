//
//  DemoViewController.m
//  WZSDK
//
//  Created by jp007 on 2017/6/6.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "DemoViewController.h"
#import "WZBleSDKInterface.h"
#import "DeviceCell.h"
#import "SVProgressHUD.h"
#import "ResultViewController.h"
@interface DemoViewController ()<WZBleSDKInterfaceListener,UITableViewDelegate,UITableViewDataSource>
{
    WZBleSDKInterface * face;
    NSMutableArray * _devices;
    UITableView * _tableView;
    WZBleDevice * _curDev;
    NSTimer * _timer;
}
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设备列表";
   // self.navigationItem.leftBarButtonItem =[self leftItem];
    face = [[WZBleSDKInterface alloc] init];
    
 
    [face addListner:self ];
    

    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    
    [self.view addSubview:tableView];
    
    
    [tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:nil] forCellReuseIdentifier:@"DeviceCell.h"];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    
    _tableView = tableView;
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self doScan];
}
-(void)doScan{
    if (face.status != WZBleStatusPowerOn) {//蓝牙不可用
        return;
    }
    self.navigationItem.rightBarButtonItem = [self rightItem1];
    [face clearDevices];
    [face startScan];
    [_tableView reloadData];
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self stop];
    }];
}
-(void)stop{
    self.navigationItem.rightBarButtonItem = [self rightItem2];
    [face stopScan];
}
-(UIBarButtonItem*)rightItem1
{
    UIActivityIndicatorView * indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indi.frame = CGRectMake(0, 0, 40, 40);
    [indi startAnimating];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:indi];
    
    
    return item;
}
-(UIBarButtonItem*)rightItem2
{
    UIButton * indi = [UIButton buttonWithType:UIButtonTypeCustom];
    [indi setTitle:@"重扫" forState:UIControlStateNormal];
    [indi  setTitleColor:[UIColor blackColor] forState:0];
    [indi addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
    indi.frame = CGRectMake(0, 0, 40, 40);
   
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:indi];
    
    
    return item;
}


-(UIBarButtonItem*)leftItem
{
    UIButton * indi = [UIButton buttonWithType:UIButtonTypeCustom];
    [indi setTitle:@"test" forState:UIControlStateNormal];
    [indi  setTitleColor:[UIColor blackColor] forState:0];
    [indi addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchUpInside];
    indi.frame = CGRectMake(0, 0, 40, 40);
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:indi];
    
    
    return item;
}
-(void)sendCode
{
    [face bleDevice:_curDev sendCommandCode:WZBluetoohCommandGetBattery extraData:nil];
}

#pragma mark ========ble delegate=====
-(void)bleDevicesChanged:(WZBleDevice *)device
{

    _devices = [NSMutableArray arrayWithArray:face.devices];
    [_tableView reloadData];
}
-(void)bleDevice:(WZBleDevice *)device didDisconneted:(NSError *)error
{
    
    [_tableView reloadData];
}

-(void)bleDidConnectDevice:(WZBleDevice *)device
{
    [SVProgressHUD dismiss];
    ResultViewController * rs = [[ResultViewController alloc] init];
    rs.curDevice = device;
    [self.navigationController pushViewController:rs animated:YES];
}
-(void)bleFailConnectDevice:(WZBleDevice *)device error:(NSError *)err
{
    [SVProgressHUD dismiss];
}
-(void)bleStatusChanged:(WZBleStatus)state
{
    if (state==WZBleStatusPowerOn) {//蓝牙可用，扫描按钮可点击
        [self doScan];
    }else if (state==WZBleStatusPowerOff) {//蓝牙关闭，提示用户
        [SVProgressHUD showInfoWithStatus:@"蓝牙关闭，请打开"];
    }else if (state==WZBleStatusUnauthorized) {//未授权，提示用户去设置
        [SVProgressHUD showInfoWithStatus:@"蓝牙未授权，请设置"];
    }else if (state==WZBleStatusUnSupport){//不支持ble
        [SVProgressHUD showInfoWithStatus:@"抱歉，此设备不支持ble"];
        [self stop];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];//不可点
    }
}

-(void)bleDevice:(WZBleDevice *)device didRefreshData:(WZBleData *)data comandCode:(WZBluetoohCommand)command
{
    if (command == WZBluetoohCommandUploadDFUData) {
        float f = data.progress/100.;
    
        if(data.progress == 100){
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"升级成功"];
            [self doScan];//重新扫描
            return;
        }
        [SVProgressHUD showProgress:f status:@"正在升级"];
    }
}
#pragma mark ======tableview delegate========
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell.h"];
    WZBleDevice * device = [_devices objectAtIndex:indexPath.row];
    cell.nameLabel.text =[NSString stringWithFormat:@"%@--%@",device.periral.name, device.name];
    cell.serviceLabel.text = @(device.services.count).stringValue;
    return cell;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    WZBleDevice * device = [_devices objectAtIndex:indexPath.row];
    [self stop];
    [face connectDevice:device];
    _curDev  = device;
    
    [SVProgressHUD showWithStatus:@"正在连接..."];
    
  
}
@end
