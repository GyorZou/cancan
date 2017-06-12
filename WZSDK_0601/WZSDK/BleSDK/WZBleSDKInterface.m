//
//  WZBleSDKInterface.m
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//


#define WZSERVICEUUID  @"5A48"


#import "WZBleSDKInterface.h"

#import "WZBluetooh.h"

@interface WZBleSDKInterface()

-(void)notifyDevice:(WZBleDevice*)device dataForCMD:(WZBluetoohCommand)cmd;
-(WZBleDevice*)findDeviceWith:(CBPeripheral*)perial;

@property (nonatomic, strong) WZBluetooh *bluetooh;
@end

@implementation WZBleSDKInterface


-(instancetype)init
{
    static  WZBleSDKInterface * shareface;
    

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareface = [super init];
        shareface.bluetooh = [WZBluetooh shareBabyBluetooth];
        
        
        
        _devices = [[NSMutableArray alloc] init];
        _listeners = [[NSMutableArray alloc] init];
        [shareface initData];
    });

    
    return shareface;
}
-(void)initData
{
    __weak typeof(self) weakSelf = self;
    __weak NSArray * wsli = _listeners;
    self.bluetooh.centralStateblock = ^(CBManagerState state) {
        NSLog(@"state changing:%ld",state);
        [weakSelf clearDevices];
        WZBleStatus stat = WZBleStatusPowerOn;
        if (state==CBManagerStatePoweredOff) {
            stat=WZBleStatusPowerOff;
            [weakSelf clearDevices];
        }else if (state == CBManagerStateUnauthorized){
            stat = WZBleStatusUnauthorized;
        }else if (state == CBManagerStateUnsupported){
            stat = WZBleStatusUnSupport;
        }else if(state == CBManagerStatePoweredOn &&_markForScan){
            [weakSelf startScan];
        }
        weakSelf.status = stat;
        for (id<WZBleSDKInterfaceListener> li in wsli) {
            if ([li respondsToSelector:@selector(bleStatusChanged:)]) {
                [li bleStatusChanged:stat];
            }
        }

        
    };
    
    self.bluetooh.perialConnectBlock = ^(CBPeripheral * p,NSError * error){
        
        WZBleDevice * temp =  [weakSelf findDeviceWith:p];
        if (error) {
            for (id<WZBleSDKInterfaceListener> li in wsli) {
                if ([li respondsToSelector:@selector(bleFailConnectDevice:error:)]) {
                    [li bleFailConnectDevice:temp error:error];
                }
            }

        }else{
            for (id<WZBleSDKInterfaceListener> li in wsli) {
                if ([li respondsToSelector:@selector(bleDidConnectDevice:)]) {
                    [li bleDidConnectDevice:temp];
                }
            }

        }

        
    };

    [self.bluetooh startBluetoothService];

    
    
}

-(void)stopScan
{
    [self.bluetooh stopScan];
    
}
-(WZErrorCode)startScan
{
    
    if(self.status!=WZBleStatusPowerOn){
        _markForScan = YES;
        return WZErrorBleNotPrepared;
    }
    _markForScan = NO;
    __weak typeof(self) ws = self;
    
    

    [self.bluetooh scanDeviceWithRespondStatuBlock:^(CBPeripheral * perial,NSInteger battary, NSInteger speed, NSMutableString *versionString) {
        
        WZBleDevice * tempDevice=[self findDeviceWith:perial];
        tempDevice.data.battery = battary;
        
        tempDevice.data.motorFlag = speed;
        
        tempDevice.data.version = [versionString copy];
        
        [self notifyDevice:tempDevice dataForCMD:WZBluetoohCommandNone];
        
    } synStep:^(CBPeripheral* p,NSString *time, unsigned long steps) {
        WZBleDevice * tempDevice=[self findDeviceWith:p];
        tempDevice.data.stepTime = time;
        tempDevice.data.steps = steps;
        
        [self notifyDevice:tempDevice dataForCMD:WZBluetoohCommandSynSteps];

        
    } posture:^(CBPeripheral*p,NSDictionary *posture) {
        WZBleDevice * tempDevice=[self findDeviceWith:p];
        tempDevice.data.postures= posture;
        
        [self notifyDevice:tempDevice dataForCMD:WZBluetoohCommandSynPostures];
    } sitting:^(CBPeripheral *p,NSString *time, NSInteger sittingTime, NSInteger forwardTime, NSInteger backwardTime, NSInteger leftLeaningTime, NSInteger rightDeviationTime) {
        
        WZBleDevice * tempDevice=[self findDeviceWith:p];
        
        
        tempDevice.data.sitTime = sittingTime;
        tempDevice.data.leftSitTime = leftLeaningTime;
        tempDevice.data.rightSitTime = rightDeviationTime;
        tempDevice.data.backwardSitTime = backwardTime;
        tempDevice.data.forwardSitTime = forwardTime;

        tempDevice.data.synTime=time;//这行要在设置的最后面
        
        [self notifyDevice:tempDevice dataForCMD:WZBluetoohCommandSynStatus];
        
 
        
        
    } replyComplete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{

        });
        
        
    } writeReady:^(BOOL success) {

        
    } readRSSI:^(CBPeripheral*perial,NSNumber *RSSI, NSError *error) {
        WZBleDevice * tempDevice=[self findDeviceWith:perial];
        
        tempDevice.data.rssi = RSSI;

        NSLog(@"sss");
    } fail:^(NSError *error) {
        
    } disconnect:^(NSError *error,CBPeripheral*perial) {
        NSLog(@"disconneted:%@",error.localizedDescription);
        
        WZBleDevice * tempDevice=[self findDeviceWith:perial];
        
        [_devices removeObject:tempDevice];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //weakSelf.bluReady = success;
            for (id<WZBleSDKInterfaceListener> lis in _listeners) {
                if ([lis respondsToSelector:@selector(bleDevicesChanged:)]) {
                    [lis bleDevicesChanged:tempDevice];
                }
            }
            for (id<WZBleSDKInterfaceListener> li in _listeners) {
                if ([li respondsToSelector:@selector(bleDevice:didDisconneted:)]) {
                    [li bleDevice:tempDevice didDisconneted:error];
                }
            }
        });
        


    }];

    
    [self.bluetooh startBluetoothServiceWithPeriphera:^(CBPeripheral *peripheral, NSDictionary *advertisementData) {
         NSLog(@"find perial:%@\n====\n%@==\n%@",peripheral.name,advertisementData,peripheral);
        [ws findPerial:peripheral adver:advertisementData];
        
        
    }];

    

    return WZErrorNone;
}
-(BOOL)isValidDevice:(CBPeripheral*)p adver:(NSDictionary*)adver
{
    for (int i=0; i<[adver[@"kCBAdvDataServiceUUIDs"] count]; i++) {
        CBUUID *uuid = adver[@"kCBAdvDataServiceUUIDs"][i];
        //NSLog(@"$$$$$$$$$$$$%@",uuid.UUIDString);
        NSString * uuidStr =  [uuid UUIDString];
        if([uuidStr isEqualToString:WZSERVICEUUID]){
            return YES;
        }
    }
  
    return NO;
}
-(void)findPerial:(CBPeripheral*)perial adver:(NSDictionary*)adver
{
    if ([self isValidDevice:perial adver:adver]==NO) {
        NSLog(@"this is not valid device");
        return ;
    }
    for (WZBleDevice * device in _devices) {
        if ([[device.periral.identifier UUIDString] isEqualToString:[perial.identifier UUIDString]]) {
            NSLog(@"find an exist device");
            return;
        }
    }
    NSLog(@"===get a wz device====");
    WZBleDevice * device = [[WZBleDevice alloc] init];
    device.periral = perial;
    
    device.advertisment = adver;
    
    [_devices addObject:device];
    
    
    for (id<WZBleSDKInterfaceListener> lis in _listeners) {
        if ([lis respondsToSelector:@selector(bleDevicesChanged:)]) {
            [lis bleDevicesChanged:device];
        }
    }
    
    
}

-(NSArray<WZBleDevice *> *)devices
{
    return [_devices copy];
}
-(void)clearDevices
{
    [_devices removeAllObjects];
    for (id<WZBleSDKInterfaceListener> lis in _listeners) {
        if ([lis respondsToSelector:@selector(bleDevicesChanged:)]) {
            [lis bleDevicesChanged:nil];
        }
    }
}
-(void)disConnectDevice:(WZBleDevice *)device
{
    [self.bluetooh disConnectPeriperal:device.periral];
}
-(void)connectDevice:(WZBleDevice *)device
{

    [self.bluetooh connectPeriperal:device.periral];
    __weak typeof(self) ws =self;
    [self.bluetooh getRealTimeStatus:^(NSInteger status, NSInteger sitting) {
        
        device.data.postureStatus = status;
        device.data.sitStatus = sitting;
        [ws notifyDevice:device dataForCMD:WZBluetoohCommandGetRTPosture];
        
    }];
    
}


#pragma mark ========指令=======
-(void)bleDevice:(WZBleDevice *)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data
{
    __weak typeof(self) ws =self;
    
    switch (command) {
        case WZBluetoohCommandSynSteps:{
            [self.bluetooh synStep:^(CBPeripheral *p,NSString *time, unsigned long steps) {
    
                device.data.stepTime = time;
                device.data.steps = steps;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
        case WZBluetoohCommandGetBattery:
        {
            [self.bluetooh  getBattary:^(NSInteger battary) {
                NSLog(@"bater =%ld",battary);
                device.data.battery = battary;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
            
        case WZBluetoohCommandActivateDevice:
        {
            [self.bluetooh activation:^(BOOL success) {
                device.data.isSuccess = success;
                 [ws notifyDevice:device dataForCMD:command];
            }];

        }
            break;
            
        case WZBluetoohCommandCancelActivateDevice:
        {
            [self.bluetooh cancelActivation:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
            
        case WZBluetoohCommandSynPostures:
        {
            [self.bluetooh synPosture:^(CBPeripheral *p,NSDictionary *posture) {
               
                device.data.postures = posture;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
            
        }
            break;
        case WZBluetoohCommandSetName:
        {
            [self.bluetooh renameWithName:data complete:^(BOOL success, NSError *error) {
                device.data.isSuccess = error==nil;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandCloseMotor:
        {
            [self.bluetooh setMotor:NO shockTime:0 complete:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
        case WZBluetoohCommandSetMotorDuration:
        {
            [self.bluetooh setMotor:YES shockTime:[data intValue] complete:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
            
        case WZBluetoohCommandAdjustPosture:
        {
       
            [self.bluetooh setPosture:^(BOOL success) {
             
            }];
        }
            break;
        case WZBluetoohCommandCancelAdjustPosture:
        {
            [self.bluetooh cancelSetPosture:^(BOOL success) {
             
                
            }];
            
        }
            break;
        case WZBluetoohCommandGetRTPosture:
        {
            
            
        }
            break;
        case WZBluetoohCommandSynStatus:
        {
            
            
        }
            break;
        case WZBluetoohCommandSetLeftAngel:
        {
            [self.bluetooh setAngle:[data intValue] leftLeaning:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandRestartDevice:
        {
            [self.bluetooh restart:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandSetRightAngel:
        {
            [self.bluetooh setAngle:[data intValue] rightDeviation:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandUploadDFUData:
        {
            NSString *url = [[NSBundle mainBundle] pathForResource:data ofType:nil];
         
            
            
            [self.bluetooh uploadWith:url upload:^(NSInteger part, NSInteger totalParts, NSInteger progress, NSInteger currentSpeedBytesPerSecond, NSInteger avgSpeedBytesPerSecond) {
                device.data.isSuccess = YES;
                device.data.progress = progress;
                [ws notifyDevice:device dataForCMD:command];
                
            } complete:^(BOOL success) {
                device.data.isSuccess = success;
                device.data.progress = 100;
                [ws notifyDevice:device dataForCMD:command];
                [ws.bluetooh startBluetoothService];
            }];
            
        }
            break;
        case WZBluetoohCommandSetForwardAngel:
        {
            [self.bluetooh setAngle:[data intValue] forward:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandSetBackwardAngel:
        {
            [self.bluetooh setAngle:[data intValue] backward:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
            
        }
            break;
        case WZBluetoohCommandClearData:
        {
            [self.bluetooh clearData:^(BOOL success) {
                device.data.isSuccess = success;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
        case WZBluetoohCommandReadMotor:
        {
            [self.bluetooh getMotor:^(NSInteger speed) {
                device.data.speed = speed;
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
        case WZBluetoohCommandOpenMotor:
        {
            [self.bluetooh setMotor:YES shockTime:60 complete:^(BOOL success) {
                [ws notifyDevice:device dataForCMD:command];
            }];
        }
            break;
    
        default:
            break;
    }
  
}

@end
