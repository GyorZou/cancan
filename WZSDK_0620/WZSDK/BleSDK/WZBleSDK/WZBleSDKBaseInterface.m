//
//  WZBleSDKInterface.m
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//


#define WZSERVICEUUID  @"5A48"

#import "WZBleSDKBaseInterface.h"




static WZBleDevice * _dfuDevice;

@interface WZBleSDKBaseInterface()
{
}

@end

@implementation WZBleSDKBaseInterface
+(WZBleDevice *)dfuingDevice
{
    return _dfuDevice;
}
+(void)setDfuingDevice:(WZBleDevice*)device
{
    _dfuDevice = device;
}
+(instancetype)sharedInterface
{
    return [[[self class] alloc] init];
}


-(void)initData
{
    
}


-(void)addListner:(id<WZBleSDKInterfaceListener>)listener
{
    @synchronized (self) {
        if ([_listeners containsObject:listener]) {
            return;
        }
        [_listeners addObject:listener];

    }
}

-(void)removeListener:(id<WZBleSDKInterfaceListener>)listener
{
    @synchronized (self) {
        [_listeners removeObject:listener];

    }
}
-(void)stopScan
{
    
}
-(WZErrorCode)startScan
{
    
   
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
   
}
-(WZBleDevice*)findDeviceWith:(CBPeripheral*)perial
{
    WZBleDevice * tempDevice;
    NSArray * temp = [_devices copy];
    for (WZBleDevice *device in temp) {
        if ([device.periral.identifier isEqual:perial.identifier]) {
            tempDevice = device;
            break;
        }
    }
    return tempDevice;
}
-(void)connectDevice:(WZBleDevice *)device
{

   
}


#pragma mark ========指令=======
-(void)bleDevice:(WZBleDevice *)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data
{
    
}
-(void)notifyDevice:(WZBleDevice*)device dataForCMD:(WZBluetoohCommand)cmd
{

    dispatch_async(dispatch_get_main_queue(), ^{
        
            NSArray * ls = [_listeners copy];
            for (id<WZBleSDKInterfaceListener> li in ls) {
                if ([li respondsToSelector:@selector(bleDevice:didRefreshData:comandCode:)]) {
                    [li bleDevice:device didRefreshData:device.data comandCode:cmd];
                }
            }
   
        
    });


}
@end
