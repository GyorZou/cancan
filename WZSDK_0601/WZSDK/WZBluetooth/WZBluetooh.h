//
//  DXBluetooh.h
//  BabyBluetoothAppDemo
//
//  Created by 戴义兴 on 2017/4/5.
//  Copyright © 2017年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"

typedef void (^WZRespondStatuBlock)(CBPeripheral*,NSInteger battary, NSInteger speed, NSMutableString *versionString);
typedef void (^WZBattaryBlock)(NSInteger battary);
typedef void (^WZActivation)(BOOL success);
typedef void (^WZCancelActivation)(BOOL success);
typedef void (^WZSynStep)(NSString *time, unsigned long steps);
typedef void (^WZPosture)(NSDictionary *posture);
typedef void (^WZSetMotor)(BOOL success);
typedef void (^WZGetMotor)(NSInteger speed);
typedef void (^WZSetPosture)(BOOL success);
typedef void (^WZRestart)(BOOL success);
typedef void (^WZComplete)(BOOL success);
typedef void (^WZWriteReady)(BOOL success);
typedef void (^WZRename)(BOOL success, NSError *error);

typedef void (^WZReadRSSI)(CBPeripheral*,NSNumber *RSSI, NSError *error);
typedef void (^WZFail)(NSError *error);
typedef void (^WZDisconnect)(NSError *error,CBPeripheral*);
typedef void (^WZPeripheral)(CBPeripheral *peripheral, NSDictionary *advertisementData);
typedef void (^WZUpload)(NSInteger part, NSInteger totalParts, NSInteger progress, NSInteger currentSpeedBytesPerSecond, NSInteger avgSpeedBytesPerSecond);
typedef void (^WZSitting)(NSString *time, NSInteger sittingTime, NSInteger forwardTime, NSInteger backwardTime, NSInteger leftLeaningTime, NSInteger rightDeviationTime);
typedef void (^WZRealTime)(NSInteger status, NSInteger sitting);


@interface WZBluetooh : NSObject

@property (assign, readonly, nonatomic)BOOL writeBusy;
@property (strong, nonatomic) NSData *macAdress;
@property (nonatomic,copy) void (^centralStateblock)(CBManagerState state);
+ (instancetype)shareBabyBluetooth;

-(void)stopScan;
-(void)connectPeriperal:(CBPeripheral*)perial;
-(void)disConnectPeriperal:(CBPeripheral*)perial;
- (void)startBluetoothService;

- (void)startBluetoothServiceWithPeriphera:(WZPeripheral)peripheralBlock;

- (void)scanDeviceWithRespondStatuBlock:(WZRespondStatuBlock)respondStatuBlock
                                synStep:(WZSynStep)respondSynStepBlock
                                posture:(WZPosture)respondSynPostureBlock
                                sitting:(WZSitting)sittingBlock
                          replyComplete:(WZComplete)replyCompleteBlock
                             writeReady:(WZWriteReady)writeReadyBlock
                               readRSSI:(WZReadRSSI)readRSSIBlock
                                   fail:(WZFail)failBlock
                             disconnect:(WZDisconnect)disconnectBlock;

// 获取实时状态和坐姿
- (void)getRealTimeStatus:(WZRealTime)statusBlock;

- (void)writeValueWith:(Byte *)byte lenght:(NSInteger)lenght;

// 同步时间应答
//- (void)respondTimeToHardware;

// 连接状态下同步计步数据应答
//- (void)respondsynStep;

// 连接状态下同步状态数据应答
//- (void)respondsynStatus;

// 交换结束应答
//- (void)respondComplete;

// 获取电池电量
- (void)getBattary:(WZBattaryBlock)battaryBlock;

// 激活命令
- (void)activation:(WZActivation)activationBlock;

// 取消激活命令
- (void)cancelActivation:(WZCancelActivation)cancelActivationBlock;

// 连接状态下同步计步数据
- (void)synStep:(WZSynStep)synStepBlock;

// 连接状态下同步坐姿数据
- (void)synPosture:(WZPosture)postureBlock;

// 设置马达震动
- (void)setMotor:(BOOL)open shockTime:(NSInteger)shockTime complete:(WZSetMotor)setMotorBlock;

// 读取马达震动
- (void)getMotor:(WZGetMotor)getMotorBlock;

// 设置校准坐姿
- (void)setPosture:(WZSetPosture)cancelSetPostureBlock;

// 取消校准坐姿
- (void)cancelSetPosture:(WZSetPosture)setPostureBlock;

// 设置前倾角度
- (void)setAngle:(NSInteger)angle forward:(WZComplete)forwardBlock;

// 设置后倾角度
- (void)setAngle:(NSInteger)angle backward:(WZComplete)backwardBlock;

// 设置左倾角度
- (void)setAngle:(NSInteger)angle leftLeaning:(WZComplete)leftLeaningBlock;

// 设置右倾角度
- (void)setAngle:(NSInteger)angle rightDeviation:(WZComplete)rightDeviationBlockl;

//清除数据
- (void)clearData:(WZComplete)clearDataBlock;

// 重启
- (void)restart:(WZRestart)restartBlock;

//固件库升级
- (void)uploadWith:(NSString *)filePath upload:(WZUpload)uploadBlock complete:(WZComplete)uploadCompleteBlock;

// 改名字
- (void)renameWithName:(NSString *)name complete:(WZRename)renameBlock;

@end
