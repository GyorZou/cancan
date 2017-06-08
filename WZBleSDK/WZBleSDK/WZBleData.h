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


ASSIGNPROP(BOOL, isSuccess);
/*
 设备状态
 */
ASSIGNPROP(NSInteger, status);
/*
 电池电量
 */
ASSIGNPROP(NSInteger,battery);

STRONGPROP(NSNumber*, rssi);

/*
 马达速度
 */
ASSIGNPROP(NSInteger,speed);

STRONGPROP(NSString*, version);




STRONGPROP(NSString*, synTime);
ASSIGNPROP(NSInteger,sitTime);
ASSIGNPROP(NSInteger,leftSitTime);
ASSIGNPROP(NSInteger,rightSitTime);
ASSIGNPROP(NSInteger,forwardSitTime);
ASSIGNPROP(NSInteger,backwardSitTime);



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
 字典值为historyModel数组，value为时-分-姿势

 @return <#return value description#>
 */
-(NSArray<NSDictionary*>*)historyPos;


/**
 历史坐姿时间数据

 @return model 的value值为“总-前-右-后-左”，请自行分割
 */
-(NSArray<WZHistoryModel*>*)historySit;
-(NSArray<WZHistoryModel*>*)historySteps;


@end
