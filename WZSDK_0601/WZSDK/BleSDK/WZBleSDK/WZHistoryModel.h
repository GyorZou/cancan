//
//  HistoryModel.h
//  WZSDK
//
//  Created by zougyor on 2017/6/7.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZHistoryModel : NSObject



//这就是一个数据模型而已，用几个字段来保存数据，可以不太关注字段是啥，使用的时候知道保存的是什么，到时候去读取即可

/**
 日期
 */
@property (nonatomic,strong) NSString * date;

/**
 时间
 */
@property (nonatomic,strong) NSString * time;

/**
 值
 */
@property (nonatomic,strong) NSString * value;
@end
