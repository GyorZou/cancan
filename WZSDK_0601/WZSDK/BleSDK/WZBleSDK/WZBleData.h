//
//  WZBleData.h
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#define ASSIGNPROP(type,name)  @property (nonatomic,assign) type name

#define STRONGPROP(type,name)  @property (nonatomic,strong) type name


#import <Foundation/Foundation.h>
#import "WZHistoryModel.h"
@interface WZBleData : NSObject

/*
 上一条指令的状态
 */
ASSIGNPROP(BOOL, isSuccess);
/*
 设备状态
 */
ASSIGNPROP(NSInteger, status);
/*
 电池电量
 */
ASSIGNPROP(NSInteger,battery);

STRONGPROP(NSNumber*, rssi);//信号强度

/*
 马达速度
 */
ASSIGNPROP(NSInteger,speed);//马达震动时长

STRONGPROP(NSString*, version);//固件版本号
ASSIGNPROP(NSInteger,motorFlag);//马达开关标识，F5，F0
@property (nonatomic,assign,readonly) BOOL isMotorOn;



STRONGPROP(NSString*, synTime);//坐姿同步时间
ASSIGNPROP(NSInteger,sitTime);//正坐时长
ASSIGNPROP(NSInteger,leftSitTime);//左倾时长
ASSIGNPROP(NSInteger,rightSitTime);//右倾时长
ASSIGNPROP(NSInteger,forwardSitTime);//前倾时长
ASSIGNPROP(NSInteger,backwardSitTime);//后倾时长



ASSIGNPROP(NSInteger, progress);//dfu进度:0~100

ASSIGNPROP(NSUInteger, postureStatus);//身姿：未知、坐、躺、走、跑
ASSIGNPROP(NSUInteger, sitStatus);//坐姿：未知、正、左、右、前、后

STRONGPROP(NSString*, stepTime);//步数时间
ASSIGNPROP(NSUInteger, steps);//步数

STRONGPROP(NSDictionary*, postures);//历史身姿

-(NSString*)postureStatusString;
-(NSString*)sitStatusString;


/**
 字典数组，
 字典只有一个key，key为日期，xx月xx日
 字典值为historyModel数组，value为:时-分-状态,
 0-4：未知 坐 躺 走 跑
 @return s
 */
-(NSArray<NSDictionary*>*)historyPos;


/**
 历史坐姿时间数据

 @return model 的value值为“总-前-右-后-左”，请自行分割
 */
-(NSArray<WZHistoryModel*>*)historySit;


/**
历史步数数据

 @return 包含历史步数数据的数组
 */
-(NSArray<WZHistoryModel*>*)historySteps;


@end
