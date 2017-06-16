//
//  DXBluetooh.m
//  BabyBluetoothAppDemo
//
//  Created by 戴义兴 on 2017/4/5.
//

#import "WZBluetooh.h"
#import "iOSDFULibrary/iOSDFULibrary-Swift.h"
#import "BabySpeaker.h"

#define perophoral @"perophoral"
#define channelOnPeropheralView @"channelOnPeropheral"
#define uploadChannelOnPeropheralView @"uploadChannelOnPeropheralView"
#define channelOnCharacteristicView @"CharacteristicView"
#define channelOnkeepAliveView @"channelOnkeepAliveView"

static NSString *const readCharacterUUID = @"EEA2";
static NSString *const writeCharacterUUID = @"EEA1";
static NSString *const keepAliveUUID = @"FFA2";


@interface WZBluetooh () <DFUServiceDelegate, DFUProgressDelegate>
{
    NSMutableArray *peripheralDataArray;
    BabyBluetooth *baby;
    BOOL _dfuing;
}

@property (strong, nonatomic) CBCentralManager *uploadCentralManager;
@property (strong, nonatomic) CBPeripheral *uploadPeripheral;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *currPeripheral;
@property (strong, nonatomic) CBCharacteristic *currReadCharacter;
@property (strong, nonatomic) CBCharacteristic *currWriteCharacter;
@property (strong, nonatomic) CBCharacteristic *currKeepCharacter;
@property (strong, nonatomic) NSMutableDictionary *postureDic;
@property (assign, nonatomic) BOOL writeBusy;
@property (strong, nonatomic) DFUServiceController *controller;
@property (assign, nonatomic) BOOL isUpload;
@property (strong, nonatomic) NSString *filePath;
@property (assign, nonatomic) BOOL isInit;

//列表
@property (copy, nonatomic) WZPeripheral peripheralBlock;

// 得到的数据
@property (copy, nonatomic) WZRespondStatuBlock respondStatuBlock;
@property (copy, nonatomic) WZSynStep respondSynStepBlock;
@property (copy, nonatomic) WZPosture respondSynPostureBlock;
@property (copy, nonatomic) WZComplete replyCompleteBlock;

//蓝牙状态值
@property (copy, nonatomic) WZWriteReady writeReadyBlock;
@property (copy, nonatomic) WZReadRSSI readRSSIBlock;
@property (copy, nonatomic) WZFail failBlock;
@property (copy, nonatomic) WZDisconnect disconnectBlock;

// 回复指令的block
@property (copy, nonatomic) WZBattaryBlock battaryBlock;
@property (copy, nonatomic) WZActivation activationBlock;
@property (copy, nonatomic) WZCancelActivation cancelActivationBlock;
@property (copy, nonatomic) WZSynStep synStepBlock;
@property (copy, nonatomic) WZPosture postureBlock;
@property (copy, nonatomic) WZSetMotor setMotorBlock;
@property (copy, nonatomic) WZGetMotor getMotorBlock;
@property (copy, nonatomic) WZSetPosture setPostureBlock;
@property (copy, nonatomic) WZSetPosture cancelSetPostureBlock;
@property (copy, nonatomic) WZRestart restartBlock;
@property (copy, nonatomic) WZComplete uploadCompleteBlock;
@property (copy, nonatomic) WZUpload uploadBlock;

@property (copy, nonatomic) WZComplete forwardBlock;
@property (copy, nonatomic) WZComplete backwardBlock;
@property (copy, nonatomic) WZComplete leftLeaningBlock;
@property (copy, nonatomic) WZComplete rightDeviationBlock;
@property (copy, nonatomic) WZComplete clearDataBlock;
@property (copy, nonatomic) WZSitting sittingBlock;
@property (copy, nonatomic) WZRealTime statusBlock;
@property (copy, nonatomic) WZRename renameBlock;

@end

@implementation WZBluetooh

+ (instancetype)shareBabyBluetooth {
    static WZBluetooh *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[WZBluetooh alloc] init];
        //share.writeBusy = YES;
        share.isUpload = NO;
    });
    return share;
}


- (void)startBluetoothService {
    //    [baby cancelScan];
    self.isInit = YES;
    peripheralDataArray = [NSMutableArray array];
    baby = [BabyBluetooth shareBabyBluetooth];
    //[baby cancelAllPeripheralsConnection];
    baby.scanForPeripherals().stopNow();
    baby.scanForPeripherals().begin();
    
    
     __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (weakSelf.centralStateblock) {
            weakSelf.centralStateblock(central.state);
        }
    }];
}

- (void)startBluetoothServiceWithPeriphera:(WZPeripheral)peripheralBlock {
    if(!self.isUpload) {
        self.peripheralBlock = peripheralBlock;
    }
    [self startBluetoothService];
}

#pragma mark - Bluetootconfigure

//蓝牙网关初始化和委托方法设置

- (void)scanDeviceWithRespondStatuBlock:(WZRespondStatuBlock)respondStatuBlock
                                synStep:(WZSynStep)respondSynStepBlock
                                posture:(WZPosture)respondSynPostureBlock
                                sitting:(WZSitting)sittingBlock
                          replyComplete:(WZComplete)replyCompleteBlock
                             writeReady:(WZWriteReady)writeReadyBlock
                               readRSSI:(WZReadRSSI)readRSSIBlock
                                   fail:(WZFail)failBlock
                             disconnect:(WZDisconnect)disconnectBlock {
    baby.scanForPeripherals().stopNow();
    baby.scanForPeripherals().begin();
    
    self.respondStatuBlock = respondStatuBlock;
    self.respondSynStepBlock = respondSynStepBlock;
    self.respondSynPostureBlock = respondSynPostureBlock;
    self.replyCompleteBlock = replyCompleteBlock;
    self.writeReadyBlock = writeReadyBlock;
    self.readRSSIBlock = readRSSIBlock;
    self.failBlock = failBlock;
    self.disconnectBlock = disconnectBlock;
    self.sittingBlock = sittingBlock;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(baby) weakBaby = baby;
 
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {

        //NSLog(@"搜索到了设备:%@ advertisementData:%@",peripheral.name, advertisementData);
        
        if(!weakSelf.isUpload && weakSelf.peripheralBlock) {
            if ([peripheral.name isEqualToString:@"DfuTarg"]) {
            }
            else
            {
                //NSData *kCBAdvDataManufacturerData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
              //  if (kCBAdvDataManufacturerData && kCBAdvDataManufacturerData.length==8){
                    weakSelf.peripheralBlock(peripheral, advertisementData);
                weakSelf.readRSSIBlock(peripheral,RSSI, nil);
                //}
            }
        }

        
//        for (int i=0; i<[advertisementData[@"kCBAdvDataServiceUUIDs"] count]; i++) {
        
            if (weakSelf.isUpload == YES) {
                if ([peripheral.name isEqualToString:@"DfuTarg"]) {
                    [weakBaby cancelScan];
                    weakSelf.uploadCentralManager = central;
                    weakSelf.uploadPeripheral = peripheral;
                    weakBaby.having(weakSelf.uploadPeripheral).and.channel(uploadChannelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
                    [weakSelf bluUpload];
                }
                return;
            }
        if ([peripheral.name isEqualToString:@"DfuTarg"]) {
            return;
        }
        
        NSData *kCBAdvDataManufacturerData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
        if (kCBAdvDataManufacturerData && kCBAdvDataManufacturerData.length==8) {
            NSData *mac = [kCBAdvDataManufacturerData subdataWithRange:NSMakeRange(2, 6)];
            if ([mac isEqual:weakSelf.macAdress]) {
                return;
                [weakBaby cancelScan];
                
                weakSelf.centralManager = central;
                weakSelf.currPeripheral = peripheral;
                [weakSelf connectDeviceWithCharacterUUID:readCharacterUUID
                                      writeCharacterUUID:writeCharacterUUID
                                           keepAliveUUID:keepAliveUUID];
                
                weakBaby.having(weakSelf.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
                
                weakSelf.readRSSIBlock(peripheral,RSSI, nil);
                //                break;
            }
        }
        else{
            return;
        }
        
        
//        }
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        for (int i=0; i<[advertisementData[@"kCBAdvDataServiceUUIDs"] count]; i++) {
            CBUUID *uuid = advertisementData[@"kCBAdvDataServiceUUIDs"][i];
            //NSLog(@"$$$$$$$$$$$$%@",uuid.UUIDString);
        }
        if (peripheralName.length > 0) {
            return YES;
        }
        return NO;
    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        //NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        //NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];

}



#pragma mark - 连接设备
-(void)stopScan
{
    [baby cancelScan];

}
-(void)disConnectPeriperal:(CBPeripheral *)perial
{
    [baby cancelPeripheralConnection:perial];
}
-(void)connectPeriperal:(CBPeripheral *)perial
{

    self.currPeripheral = perial;
   // baby.having(perial).connectToPeripherals().begin();
    
    __weak typeof (baby)weakBaby = baby;
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        //weakSelf.writeBusy = YES;
        if (weakSelf.perialConnectBlock) {
            weakSelf.perialConnectBlock(peripheral,nil);
        }
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //weakSelf.writeBusy = YES;
        //NSLog(@"设备：%@--连接失败",peripheral.name);
        weakSelf.failBlock(error);
        if (weakSelf.perialConnectBlock) {
            weakSelf.perialConnectBlock(peripheral,error);
        }
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //weakSelf.writeBusy = YES;
        //NSLog(@"设备：%@--断开连接",peripheral.name);
       
        weakSelf.disconnectBlock(error,perial);
         weakSelf.currPeripheral = nil;
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        //NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        //        //NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        if ([characteristics.UUID.UUIDString isEqualToString:readCharacterUUID]) { //获取读取数据的特征值
            weakSelf.currReadCharacter = characteristics;
            //NSLog(@"********%@",characteristics.UUID.UUIDString);
            [weakSelf readService];
            //            weakBaby.channel(channelOnPeropheralView).characteristicDetails(weakSelf.currPeripheral,weakSelf.currReadCharacter);
            [weakSelf setNotifiy];
            weakSelf.writeBusy = NO;
            weakSelf.writeReadyBlock(YES);
        } else
        if ([characteristics.UUID.UUIDString isEqualToString:writeCharacterUUID]) { //获取写入数据的特征值
            weakSelf.currWriteCharacter = characteristics;
            weakBaby.channel(channelOnPeropheralView).characteristicDetails(weakSelf.currPeripheral,weakSelf.currWriteCharacter);
        } else if ([characteristics.UUID.UUIDString isEqualToString:keepAliveUUID]) { //获取写入数据的特征值
            weakSelf.currKeepCharacter = characteristics;
            //
            [weakSelf setKeepNotifiy];
        }
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        //        //NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            //NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        //NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        //NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
        weakSelf.readRSSIBlock(perial,RSSI, error);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        //NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        //NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        //NSLog(@"setBlockOnBeatsOver call");
    }];
    

    

    
    
    
    
    baby.having(perial).channel(channelOnPeropheralView).connectToPeripherals().discoverServices().discoverCharacteristics()
    .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

- (void)connectDeviceWithCharacterUUID:(NSString *)readCharacterUUID
                    writeCharacterUUID:(NSString *)writeCharacterUUID
                         keepAliveUUID:(NSString *)keepAliveUUID
{
    
    
    __weak typeof (baby)weakBaby = baby;
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        //NSLog(@"设备：%@--连接成功",peripheral.name);
        //weakSelf.writeBusy = YES;
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //weakSelf.writeBusy = YES;
        //NSLog(@"设备：%@--连接失败",peripheral.name);
        weakSelf.failBlock(error);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //weakSelf.writeBusy = YES;
        //NSLog(@"设备：%@--断开连接",peripheral.name);
        self.currPeripheral = nil;
        weakSelf.disconnectBlock(error,peripheral);
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        //NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        //NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        if ([characteristics.UUID.UUIDString isEqualToString:readCharacterUUID]) { //获取读取数据的特征值
            weakSelf.currReadCharacter = characteristics;
            //NSLog(@"********%@",characteristics.UUID.UUIDString);
            [weakSelf readService];
//            weakBaby.channel(channelOnPeropheralView).characteristicDetails(weakSelf.currPeripheral,weakSelf.currReadCharacter);
            [weakSelf setNotifiy];
            weakSelf.writeBusy = NO;
            weakSelf.writeReadyBlock(YES);
        } else
        if ([characteristics.UUID.UUIDString isEqualToString:writeCharacterUUID]) { //获取写入数据的特征值
            weakSelf.currWriteCharacter = characteristics;
            weakBaby.channel(channelOnPeropheralView).characteristicDetails(weakSelf.currPeripheral,weakSelf.currWriteCharacter);
        } else if ([characteristics.UUID.UUIDString isEqualToString:keepAliveUUID]) { //获取写入数据的特征值
            weakSelf.currKeepCharacter = characteristics;
//            weakBaby.channel(channelOnPeropheralView).characteristicDetails(weakSelf.currPeripheral,weakSelf.currKeepCharacter);
            [weakSelf setKeepNotifiy];
        }
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        //NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            //NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        //NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        //NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
        weakSelf.readRSSIBlock(weakSelf.currPeripheral,RSSI, error);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        //NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        //NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        //NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
}


#pragma mark - 读取服务

- (void)readService {
    __weak typeof(self)weakSelf = self;
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        //NSLog(@"CharacteristicViewController===characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        //        //NSLog(@"CharacteristicViewController===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            //NSLog(@"CharacteristicViewController CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        //NSLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        //NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        //NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    
    [baby setBlockOnDisconnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        //weakSelf.writeBusy = YES;
        //NSLog(@"设备：%@--断开连接",peripheral.name);
        weakSelf.disconnectBlock(error,peripheral);
    }];
}


//接受通知
-(void)setNotifiy {
    
    __weak typeof(self)weakSelf = self;
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
//        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.currReadCharacter.properties & CBCharacteristicPropertyNotify ||  self.currReadCharacter.properties & CBCharacteristicPropertyIndicate) {
        
        if(self.currReadCharacter.isNotifying) {
            [baby cancelNotify:self.currPeripheral characteristic:self.currReadCharacter];
        }else{
            [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self.currReadCharacter];
            [baby notify:self.currPeripheral
          characteristic:self.currReadCharacter
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       
//                       //NSLog(@"notify block");
//                       //NSLog(@"new value %@",characteristics.value);
                       [weakSelf analysisData:characteristics.value];
//                       block(characteristics.value,error);
                   }];
        }
    }
    else{
//        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
        return;
    }
    
}

// keepNotifiy
-(void)setKeepNotifiy {
    
    __weak typeof(self)weakSelf = self;
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
        //        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.currKeepCharacter.properties & CBCharacteristicPropertyNotify ||  self.currKeepCharacter.properties & CBCharacteristicPropertyIndicate) {
        
        if(self.currKeepCharacter.isNotifying) {
            [baby cancelNotify:self.currPeripheral characteristic:self.currKeepCharacter];
        }else{
            [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self.currKeepCharacter];
            [baby notify:self.currPeripheral
          characteristic:self.currKeepCharacter
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       NSData *data = characteristics.value;
//                       //NSLog(@"收到的实时数据%@  %lu",data, (unsigned long)data.length);
                       Byte *ataByte = (Byte *)[data bytes];
                       if (!weakSelf.statusBlock) {
                           //NSLog(@"self.statusBlock nil");
                           return;
                       }
                       Byte ataByte_0;
                       memcpy(&ataByte_0, &ataByte[0], 1);

                       Byte ataByte_1;
                       memcpy(&ataByte_1, &ataByte[1], 1);
                       
                       weakSelf.statusBlock(ataByte_0, ataByte_1);
                   }];
        }
    }
    else{
        //        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
        return;
    }
    
}
#pragma mark - DFUServiceDelegate

- (void)dfuStateDidChangeTo:(enum DFUState)state {
//    //NSLog(@"dfuStateDidChangeTo:%ld",(long)state);
    
    if (DFUStateCompleted == state) {
        self.isUpload = NO;
        self.uploadCompleteBlock(YES);
        //延时两秒，再扫描
//        double delayInSeconds = 5.0;
//        __weak typeof(self) weakSelf = self;
//        dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
//            [weakSelf startBluetoothService];
//        });
        
    }
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message {
     NSLog(@"didOccurWithMessage:%@", message);
    self.uploadCompleteBlock(NO);
}

#pragma mark - DFUProgressDelegate

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    self.uploadBlock(part, totalParts, progress, currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
    NSLog(@"WZ progress:%ld",(long)progress);
}

#pragma mark - private

- (void)getRealTimeStatus:(WZRealTime)statusBlock {
    self.statusBlock = statusBlock;
}

- (void)bluUpload{
    if (_dfuing) {
        return;
    }
    _dfuing = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _dfuing = NO;
    });
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:self.uploadCentralManager target:self.uploadPeripheral];
    initiator = [initiator withFirmware:firmware];
    initiator.delegate = self;
    initiator.progressDelegate = self;
    self.controller = [initiator start];
    
}

- (void)analysisData:(NSData *)data {
    //NSLog(@"收到的数据%@  %lu",data, (unsigned long)data.length);
    Byte *dataByte = (Byte *)[data bytes];
    
    //获取协议包头
    Byte headerTyte[1];
    memcpy(&headerTyte, &dataByte[0], 1);
    NSData *headerData = [[NSData alloc] initWithBytes:&headerTyte length:1];
    
    //协议包头
    Byte getDataType[1] = {0xFE};
    if (![headerData isEqualToData:[[NSData alloc] initWithBytes:getDataType length:1]]) {
        //NSLog(@"接受包有问题");
        if (self.isInit == YES) {
            self.isInit = NO;
            [self respondTimeToHardware];
        }
        
        return ;
    }
    
    //获取协长度
    Byte lengthTyte[1];
    memcpy(&lengthTyte, &dataByte[1], 1);
    int length = (int)lengthTyte[0];
    if (length != data.length) {
        //NSLog(@"包长度不对");
        if (self.isInit == YES) {
            self.isInit = NO;
            [self respondTimeToHardware];
        }
        return;
    }
    
    self.isInit = NO;
    //获取协议种类
    Byte protocolTyte[1];
    memcpy(&protocolTyte, &dataByte[2], 1);
    if (protocolTyte[0] == 0xE1) {  // 同步时间应答
        //获取电量
        Byte battary[1];
        memcpy(&battary, &dataByte[3], 1);
        
        Byte motorVibration[1];
        memcpy(&motorVibration, &dataByte[4], 1);
        
        //版本号
        NSInteger headerCount = 3 + 1 + 1;
        NSInteger versionCount = length - headerCount;
        Byte version[versionCount];
        memcpy(&version, &dataByte[headerCount], versionCount);
        
        NSMutableString *versionString= [[NSMutableString alloc] init];
        for (NSInteger i = 0; i < versionCount; i ++) {
            NSString *string = [NSString stringWithFormat:@"%c", version[i]]; // A
            [versionString appendString:string];
        }
        
        [self respondTimeToHardware];
        if (!self.respondStatuBlock) {
            //NSLog(@"self.respondStatuBlock nil");
            return;
        }
        self.respondStatuBlock(self.currPeripheral,battary[0], motorVibration[0], versionString);
    } else if (protocolTyte[0] == 0xE2) { // 同步记忆计步数据应答
        //时间+计步数据
        NSInteger timeAndStepsCount = length - 3;
        Byte timeAndSteps[timeAndStepsCount];
        memcpy(&timeAndSteps, &dataByte[3], timeAndStepsCount);
        NSData *timeAndStepData = [[NSData alloc] initWithBytes:timeAndSteps length:timeAndStepsCount];
        
        if (timeAndStepData.length < 9) {
            return;
        }
        
        long year1 = timeAndSteps[0];
        long year2 = timeAndSteps[1];
        long month = timeAndSteps[2];
        long day = timeAndSteps[3];
        long hour = timeAndSteps[4];
        long minute = timeAndSteps[5];
        long second = timeAndSteps[6];
        
        NSString *time = [NSString stringWithFormat:@"%02ld-%02ld-%02ld %02ld:%02ld:%02ld", year2 *256+year1, month, day, hour, minute, second];
        //unsigned long step = (long)timeAndSteps[7] * 256 *256 * 256  + (long)timeAndSteps[8] * 256 *256 + (long)timeAndSteps[9]* 256 + (long)timeAndSteps[10];
        UInt32 count = 0;
        memcpy(&count, &timeAndSteps[7], 4);
        /*
         Byte num[4] = {0};
         num[0] = timeAndSteps[10];
         num[1] = timeAndSteps[9];
         num[2] = timeAndSteps[8];
         num[3] = timeAndSteps[7];
         memcpy(&count, &num[0], 4);*/
        unsigned long step = (unsigned long)count;
        [self respondsynStep];
        if (!self.respondSynStepBlock) {
            //NSLog(@"self.respondSynStepBlock nil");
            return;
        }
        self.respondSynStepBlock(_currPeripheral,time, step);

    } else if (protocolTyte[0] == 0xE3) { // 同步记忆状态数据flash应答
        //同步记忆状态数据flash
        NSInteger flashRecordCount = length - 3;
        Byte flashRecord[flashRecordCount];
        memcpy(&flashRecord, &dataByte[3], flashRecordCount);
        
        NSData *flashRecordData = [[NSData alloc] initWithBytes:flashRecord length:flashRecordCount];

        //NSLog(@"flashRecord: %s", flashRecord);
        //NSLog(@"dataByte: %s", dataByte);
        //NSLog(@"flashRecordData: %@", flashRecordData);

        [self statusMosaic:flashRecord lenght:flashRecordCount comeFrom:YES];
    } else if (protocolTyte[0] == 0x94) { // 同步记忆坐姿数据
        //同步记忆坐姿数据flash
        NSInteger postureCount = length - 3;
        Byte posture[postureCount];
        memcpy(&posture, &dataByte[3], postureCount);
        NSData *timeAndStepData = [[NSData alloc] initWithBytes:posture length:postureCount];
        
        if (timeAndStepData.length < 9) {
            return;
        }
        
        long year1 = posture[0];
        long year2 = posture[1];
        long month = posture[2];
        long day = posture[3];
        
        NSString *time = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", year2 *256+year1, month, day];
        
        NSInteger sitting = posture[4] + posture[5] * 256;
        NSInteger forward = posture[6] + posture[7] * 256;
        NSInteger backward = posture[8] + posture[9] * 256;
        NSInteger leftLeaning = posture[10] + posture[11] * 256;
        NSInteger rightDeviation = posture[12] + posture[13] * 256;

        [self respondsynPosture];
        if (!self.sittingBlock) {
            //NSLog(@"self.sittingBlock nil");
            return;
        }
        self.sittingBlock(_currPeripheral,time, sitting, forward, backward, leftLeaning, rightDeviation);
    } else if (protocolTyte[0] == 0xE4) { // 交换结束应答
        [self respondComplete];
        if (!self.replyCompleteBlock) {
            //NSLog(@"self.replyCompleteBlock nil");
            return;
        }
        self.replyCompleteBlock(YES);
    } else if (protocolTyte[0] == 0xE5) { // 读取电池电量
        //获取电量
        Byte battary[1];
        memcpy(&battary, &dataByte[3], 1);
        int battaryInt = (int)battary[0];
        
        if (!self.battaryBlock) {
            //NSLog(@"self.battaryBlock nil");
            return;
        }
        self.battaryBlock(battaryInt);
    } else if (protocolTyte[0] == 0xE6) { // 激活命令
        if (!self.activationBlock) {
            //NSLog(@"self.activationBlock nil");
            return;
        }
        self.activationBlock(YES);
    } else if (protocolTyte[0] == 0xE7) { // 取消激活命令
        if (!self.cancelActivationBlock) {
            //NSLog(@"self.cancelActivationBlock nil");
            return;
        }
        self.cancelActivationBlock(YES);

    } else if (protocolTyte[0] == 0xE8) { // 连接状态下同步计步数据
        //时间+计步数据
        NSInteger timeAndStepsCount = length - 3;
        Byte timeAndSteps[timeAndStepsCount];
        memcpy(&timeAndSteps, &dataByte[3], timeAndStepsCount);
        NSData *timeAndStepData = [[NSData alloc] initWithBytes:timeAndSteps length:timeAndStepsCount];
        
        if (timeAndStepData.length < 9) {
            return;
        }
        
        long year1 = timeAndSteps[0];
        long year2 = timeAndSteps[1];
        long month = timeAndSteps[2];
        long day = timeAndSteps[3];
        long hour = timeAndSteps[4];
        long minute = timeAndSteps[5];
        long second = timeAndSteps[6];

        NSString *time = [NSString stringWithFormat:@"%02ld-%02ld-%02ld %02ld:%02ld:%02ld", year2 *256+year1, month, day, hour, minute, second];
        
        UInt32 count = 0;
        memcpy(&count, &timeAndSteps[7], 4);
        /*
        Byte num[4] = {0};
        num[0] = timeAndSteps[10];
        num[1] = timeAndSteps[9];
        num[2] = timeAndSteps[8];
        num[3] = timeAndSteps[7];
        memcpy(&count, &num[0], 4);*/
        unsigned long step = (unsigned long)count;
        if (!self.synStepBlock) {
            //NSLog(@"self.synStepBlock nil");
            return;
        }
        self.synStepBlock(_currPeripheral,time, step);
    } else if (protocolTyte[0] == 0xE9) { // 连接状态下同步状态数据
        //连接状态下同步状态数据
        NSInteger flashRecordCount = length - 3;
        Byte flashRecord[flashRecordCount];
        memcpy(&flashRecord, &dataByte[3], flashRecordCount);
        NSData *flashRecordData = [[NSData alloc] initWithBytes:flashRecord length:flashRecordCount];
        
        //NSLog(@"flashRecord: %s", flashRecord);
        //NSLog(@"dataByte: %s", dataByte);
        //NSLog(@"flashRecordData: %@", flashRecordData);
        [self statusMosaic:flashRecord lenght:flashRecordCount comeFrom:NO];
    } else if (protocolTyte[0] == 0xEA) { // 设置马达震动
        if (!self.setMotorBlock) {
            //NSLog(@"self.setMotorBlock nil");
            return;
        }
        self.setMotorBlock(YES);
    } else if (protocolTyte[0] == 0xEB) { // 读取马达震动
        Byte motorVibration[1];
        memcpy(&motorVibration, &dataByte[4], 1);
        if (!self.getMotorBlock) {
            //NSLog(@"self.getMotorBlock nil");
            return;
        }
        self.getMotorBlock(motorVibration[0],dataByte[3]);
    } else if (protocolTyte[0] == 0xEC) { // 效准坐姿
        if (!self.setPostureBlock){
            //NSLog(@"self.setPostureBlock nil");
            return;
        }
        self.setPostureBlock(YES);
    } else if (protocolTyte[0] == 0xED) { // 取消效准坐姿
        if (!self.cancelSetPostureBlock){
            //NSLog(@"self.cancelSetPostureBlock nil");
            return;
        }
        self.cancelSetPostureBlock(YES);
    }  else if (protocolTyte[0] == 0xA0) { // 设置前倾角度
        if (!self.forwardBlock){
            //NSLog(@"self.forwardBlock nil");
            return;
        }
        self.forwardBlock(YES);
    } else if (protocolTyte[0] == 0xA1) { // 设置后倾角度
        if (!self.backwardBlock){
            //NSLog(@"self.backwardBlock nil");
            return;
        }
        self.backwardBlock(YES);
    } else if (protocolTyte[0] == 0xA2) { // 设置左倾角度
        if (!self.leftLeaningBlock){
            //NSLog(@"self.leftLeaningBlock nil");
            return;
        }
        self.leftLeaningBlock(YES);
    } else if (protocolTyte[0] == 0xA3) { // 设置右倾角度
        if (!self.rightDeviationBlock){
            //NSLog(@"self.rightDeviationBlock nil");
            return;
        }
        self.rightDeviationBlock(YES);
    } else if (protocolTyte[0] == 0xA5) { // 清除缓存
        if (!self.clearDataBlock){
            //NSLog(@"self.clearDataBlock nil");
            return;
        }
        self.clearDataBlock(YES);
    } else if (protocolTyte[0] == 0xA6) { // 修改名字
        //获取是否成功
        Byte rename[1];
        memcpy(&rename, &dataByte[3], 1);
        int renameInt = (int)rename[0];
        
        if(renameInt != 0) {
            NSError *error = [NSError errorWithDomain:@"CWYAPI" code:500 userInfo:@{NSLocalizedDescriptionKey:@"修改失败"}];
            self.renameBlock(NO, error);
        }
        
        if (!self.renameBlock){
            //NSLog(@"self.renameBlock nil");
            return;
        }
        self.renameBlock(YES, nil);
        /*[self restart:^(BOOL success) {
            
        }];
         */
    }


}

//拼接坐姿数据

- (void)statusMosaic:(Byte*)posture lenght:(NSUInteger)lenght comeFrom:(BOOL)comeFrom {
    
    NSInteger frame;
    static NSInteger frameCount;
    static NSString *timeString;
    
    static NSMutableData *postureData;
    frame = posture[0];

    if (frame == 0) {  //该天开始传输
        [self.postureDic removeAllObjects];
        
        if (comeFrom == YES) {
            long year1 = posture[1];
            long year2 = posture[2];
            long month = posture[3];
            long day = posture[4];
            
            frameCount = posture[6];
            timeString = [NSString stringWithFormat:@"%02ld-%02ld-%02ld", year2 *256+year1, month, day];
        } else {
            NSInteger month = posture[1];
            NSInteger day = posture[2];
            frameCount = posture[4];
            timeString = [NSMutableString stringWithFormat:@"%ld月%ld日",(long)month, (long)day];
        }
        
        postureData = [[NSMutableData alloc] init];
        
        NSMutableArray *status = [[NSMutableArray alloc] init];
        [self.postureDic setObject:status forKey:timeString];
    } else if(frame <= frameCount) { //该天传输过程
        
        Byte dataTyte[lenght - 1];
        memcpy(&dataTyte, &posture[1], lenght - 1);
        NSData *headerData = [[NSData alloc] initWithBytes:&dataTyte length:lenght - 1];
        [postureData appendData:headerData];
    }
    
    if(frame == frameCount) { //传输完该天
    
        NSMutableArray *status = [self.postureDic objectForKey:timeString];
        
        if (frame == 0) {
            [self.postureDic setObject:@[] forKey:timeString];
        } else {
            NSInteger statuCount = (postureData.length - 1) / 3;
            Byte *dataByte = (Byte *)[postureData bytes];
            for (NSInteger j = 0; j < statuCount; j ++) {
                NSDictionary *dic = @{@"hour": @(dataByte[j*3 ]), @"minute": @(dataByte[j*3 + 1]), @"status": @(dataByte[j*3 + 2])};
                [status addObject:dic];
            }
        }
//        //NSLog(@"1完全拼接好后的数据%@", self.postureDic);
        frameCount = 0;
        [self respondsynStatus];
        
        if (!comeFrom) {
            if (!self.postureBlock) {
                //NSLog(@"self.postureBlock nil");
                return;
            }
            self.postureBlock(_currPeripheral,[self.postureDic mutableCopy]);

        } else {
            if (!self.respondSynPostureBlock) {
                //NSLog(@"self.respondSynPostureBlock nil");
                return;
            }
            self.respondSynPostureBlock(_currPeripheral,[self.postureDic mutableCopy]);
        }
    }
}

//写入值
- (void)writeValueWith:(Byte *)byte lenght:(NSInteger)lenght {
    NSData *data = [NSData dataWithBytes:byte length:lenght];
    if(self.writeBusy) {
        return;
    }
    //NSLog(@"write data: %@",data);
    [self.currPeripheral writeValue:data forCharacteristic:self.currWriteCharacter type:CBCharacteristicWriteWithoutResponse];
}

// 同步时间应答
- (void)respondTimeToHardware {
    NSDate *dateNow = [[NSDate alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:dateNow];
    
    long year=[comps year];
    long year1 = year / 100;
    long year2 = year % 100;
    long month=[comps month];
    long day=[comps day];
    long hour=[comps hour];
    long minute=[comps minute];
    long second=[comps second];
    
    
    Byte time[] = {0xF1, 0x0A, 0xD1, year1, year2, month, day, hour, minute, second};
    [self writeValueWith:time lenght:sizeof(time)];
    
}

// 连接状态下同步计步数据应答
- (void)respondsynStep {
    Byte cancelActivation[] = {0xF1, 0x03, 0xD2};
    [self writeValueWith:cancelActivation lenght:sizeof(cancelActivation)];
}

// 连接状态下同步状态数据应答
- (void)respondsynStatus {
    Byte posture[] = {0xF1, 0x03, 0xD3};
    [self writeValueWith:posture lenght:sizeof(posture)];
}

// 同步历史坐姿数据应答
- (void)respondsynPosture {
    Byte posture[] = {0xF1, 0x03, 0xA4};
    [self writeValueWith:posture lenght:sizeof(posture)];
}

// 交换结束应答
- (void)respondComplete {
    Byte complete[] = {0xF1, 0x03, 0xD4};
    [self writeValueWith:complete lenght:sizeof(complete)];
}

// 获取电池电量
- (void)getBattary:(WZBattaryBlock)battaryBlock {
    self.battaryBlock = battaryBlock;
    Byte battary[] = {0xF1, 0x03, 0xD5};
    [self writeValueWith:battary lenght:sizeof(battary)];
}

// 激活命令
- (void)activation:(WZActivation)activationBlock {
    self.activationBlock = activationBlock;
    Byte activation[] = {0xF1, 0x04, 0xD6, 0xB2};
    [self writeValueWith:activation lenght:sizeof(activation)];
}


// 取消激活命令
- (void)cancelActivation:(WZCancelActivation)cancelActivationBlock {
    self.cancelActivationBlock = cancelActivationBlock;
    Byte cancelActivation[] = {0xF1, 0x04, 0xD7, 0xB3};
    [self writeValueWith:cancelActivation lenght:sizeof(cancelActivation)];
}

// 连接状态下同步计步数据
- (void)synStep:(WZSynStep)synStepBlock {
    self.synStepBlock = synStepBlock;
    Byte cancelActivation[] = {0xF1, 0x03, 0xD8};
    [self writeValueWith:cancelActivation lenght:sizeof(cancelActivation)];
}

// 连接状态下同步状态数据
- (void)synPosture:(WZPosture)postureBlock {
    self.postureBlock = postureBlock;
    Byte posture[] = {0xF1, 0x03, 0xD9};
    [self writeValueWith:posture lenght:sizeof(posture)];
}

// 设置马达震动
- (void)setMotor:(BOOL)open shockTime:(NSInteger)shockTime complete:(WZSetMotor)setMotorBlock{
    self.setMotorBlock = setMotorBlock;
    if (!open) {
        Byte motor[] = {0xF1, 0x04, 0xDA, 0xF0};
        [self writeValueWith:motor lenght:sizeof(motor)];
        return;
    }
    
    Byte motor[] = {0xF1, 0x05, 0xDA, 0xF5, shockTime};
    [self writeValueWith:motor lenght:sizeof(motor)];
}

// 读取马达震动
- (void)getMotor:(WZGetMotor)getMotorBlock {
    self.getMotorBlock = getMotorBlock;
    Byte motor[] = {0xF1, 0x03, 0xDB};
    [self writeValueWith:motor lenght:sizeof(motor)];
}

// 设置校准坐姿
- (void)setPosture:(WZSetPosture)setPostureBlock {
    self.setPostureBlock = setPostureBlock;
    Byte pos[] = {0xF1, 0x03, 0xDC};
    [self writeValueWith:pos lenght:sizeof(pos)];
}

// 取消设置校准坐姿
- (void)cancelSetPosture:(WZSetPosture)cancelSetPostureBlock {
    self.cancelSetPostureBlock = cancelSetPostureBlock;
    Byte pos[] = {0xF1, 0x03, 0xDD};
    [self writeValueWith:pos lenght:sizeof(pos)];
}

// 设置前倾角度
- (void)setAngle:(NSInteger)angle forward:(WZComplete)forwardBlock {
    self.forwardBlock = forwardBlock;
    Byte angleData[] = {0xF1, 0x04, 0x90, angle};
    [self writeValueWith:angleData lenght:sizeof(angleData)];
}

// 设置后倾角度
- (void)setAngle:(NSInteger)angle backward:(WZComplete)backwardBlock {
    self.backwardBlock = backwardBlock;
    Byte angleData[] = {0xF1, 0x04, 0x91, angle};
    [self writeValueWith:angleData lenght:sizeof(angleData)];
}

// 设置左倾角度
- (void)setAngle:(NSInteger)angle leftLeaning:(WZComplete)leftLeaningBlock {
    self.leftLeaningBlock = leftLeaningBlock;
    Byte angleData[] = {0xF1, 0x04, 0x92, angle};
    [self writeValueWith:angleData lenght:sizeof(angleData)];
}

// 设置右倾角度
- (void)setAngle:(NSInteger)angle rightDeviation:(WZComplete)rightDeviationBlock {
    self.rightDeviationBlock = rightDeviationBlock;
    Byte angleData[] = {0xF1, 0x04, 0x93, angle};
    [self writeValueWith:angleData lenght:sizeof(angleData)];
}

// 清除设备数据
- (void)clearData:(WZComplete)clearDataBlock {
    self.clearDataBlock = clearDataBlock;
    Byte clear[] = {0xF1, 0x03, 0x95};
    [self writeValueWith:clear lenght:sizeof(clear)];
}

// 改名字
- (void)renameWithName:(NSString *)name complete:(WZRename)renameBlock {
    const char *name_C =[name UTF8String];
    NSData *data = [NSData dataWithBytes:name_C  length:strlen(name_C)];
    if (data.length > 17) {
        NSError *error = [NSError errorWithDomain:@"CWYAPI" code:500 userInfo:@{NSLocalizedDescriptionKey:@"长度不能超过17"}];
        renameBlock(NO, error);
        return;
    }
    
    NSInteger renameLength = data.length + 3;
    
    Byte rename[] = {0xF1, renameLength, 0x96};
    NSData *renameData = [NSData dataWithBytes:rename length:3];
    NSMutableData *instructionsData = [renameData mutableCopy];
    
    [instructionsData appendData:data];
    
    Byte *dataByte = (Byte *)[instructionsData bytes];
    
    self.renameBlock = renameBlock;
    [self writeValueWith:dataByte lenght:instructionsData.length];
}


// 重启
- (void)restart:(WZRestart)restartBlock {
    self.restartBlock = restartBlock;
    self.restartBlock(YES);
    Byte restart[] = {0xF1, 0x03, 0xB2};
    [self writeValueWith:restart lenght:sizeof(restart)];
    [baby restartDidWrite:self.currPeripheral c:self.currWriteCharacter error:nil];
}

- (void)uploadWith:(NSString *)filePath upload:(WZUpload)uploadBlock complete:(WZComplete)uploadCompleteBlock {
    self.uploadCompleteBlock = uploadCompleteBlock;
    self.uploadBlock = uploadBlock;
    self.filePath = filePath;
    
    Byte upload[] = {0xF1, 0x03, 0xB1};
    [self writeValueWith:upload lenght:sizeof(upload)];
    //self.writeBusy = YES;
    
    //延时两秒，再扫描
    double delayInSeconds = 1.0;
    __weak typeof(self) weakSelf = self;
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        weakSelf.isUpload = YES;
        [weakSelf startBluetoothService];
    });
}

#pragma mark - get


- (NSMutableDictionary *)postureDic {
    if (_postureDic == nil) {
        _postureDic = [[NSMutableDictionary alloc] init];
    }
    return _postureDic;
}

@end
