#WZBleSDK使用说明

[TOC]


备注：
>因为需要用到固件升级功能，需要用到nordic芯片官方的sdk(iOSDFULibrary),此sdk用swift语言编写，因此需要以此作为依赖库，推荐使用cocoapods来导入。
>同时，因为固件升级为zip格式，因此还需要导入zip库。

##Cocoapods的使用方法
略（请参考百度搜索）

##引入sdk步骤
###一、编辑podfile文件，写入以下代码

```
target 'ProjectName' do
use_frameworks!
pod 'iOSDFULibrary', '~> 3.1.0'
pod 'Zip', '~> 0.7.0'
end
```
其中，“ProjectName”需要以实际项目名称为准，如demo里为“WZSDK”；
并将此文件拷入项目所在目录。
###二、pod install安装依赖库
（前提，已安装cocoapods）在终端中，cd进入项目目录，执行命令：pod install；
###三、将BleSDK文件夹，拖入工程里
如图：
![](https://ws1.sinaimg.cn/large/006tNbRwly1fgcxrewmqvj31go0qiqaa.jpg)


##sdk核心类介绍
###1、WZBleSDKInterface类
全局单例，用来操作sdk，具体方法参考头文件描述，

###2、WZBleSDKInterfaceListener协议
处理蓝牙交互过程的回调事件，如蓝牙状态变化、设备连接状态变化等，具体回调请查看头文件

###3、WZBleDevice类
对于当前与手机连接的蓝牙设备的封装，可通过.data属性（WZBleData）来获取该设备的所有数据。
###4、WZBleData类
用于封装手机与设备交互产生的数据，可通过属性的读写来修改和获取


##sdk使用步骤



主要流程图如下：

![-w250](https://ws4.sinaimg.cn/large/006tNbRwgy1fgd0buoipuj30lk11i78m.jpg)
对应到sdk代码，步骤如下：

###1、在需要使用sdk的地方，导入头文件


```
#import "WZBleSDK.h"
```
###2、创建sdk接口单例：

```
   WZBleSDKInterface* face = [[WZBleSDKInterface alloc]  init];
   
```	
###3、监听事件

```
  [face addListner:self ];
```
只有在此处的`self`需要遵从`WZBleSDKInterfaceListener`协议,只有遵从协议才能处理相关的回调事件，根据事件结果做出对应的处理。


###4、处理蓝牙状态回调函数

```
-(void)bleStatusChanged:(WZBleStatus)state{

//通过if进行判断，并对不同state对用户进行对应的UI提醒

}
```
只有当`state`等于`WZBleStatusPowerOn`,也即用户打开了蓝牙且已同意App使用蓝牙的状态，才能进行下一步扫描操作。


###5、扫描设备


```
if (state==WZBleStatusPowerOn) {//蓝牙可用
    [face clearDevices];
    [face startScan]; 
}
```
每次扫描，需要清空上次的扫描结果，重新扫描。
>注：本sdk已限制只扫描本公司设备

###6、处理扫描结果回调

-(void)bleDevicesChanged:(WZBleDevice *)device{
	//扫描到了device或device被移除
	//face.devices来获取所有设备，进行列表展示或其他操作，或连接设备
	
	
}


###7、连接设备


```
[face connectDevice:device];
```
>注：因为连接设备是一个异步过程，且有一定时间，可根据需要，进行正在连接设备的UI提示

###8、连接结果回调处理

```
-(void)bleDidConnectDevice:(WZBleDevice *)device
{
   //设备连接成功，接下来可以进行指令发送及数据接受了
}
-(void)bleFailConnectDevice:(WZBleDevice *)device error:(NSError *)err
{
//连接失败，根据err进行处理
}

```
>注：如果在连接过程进行了UI进度提示，此处应UI隐藏提示框

###9、发送指令

```
/**
 发送指令

 @param device 指令发送目标设备
 @param command 指令代码
 @param data 指令附加内容
 */
-(void)bleDevice:(WZBleDevice*)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data;

```
用户根据实际情况进行设备支持的指令发送，目前支持的指令列表请参考`WZBluetoohCommand`枚举说明。
>有些设置指令如，设置名称、设置马达、设置角度等命令需要带对应的值，通过`data`参数传递即可。
>如：设置名称为“test name”：
```
[face bleDevice:curDevice sendCommandCode:WZBluetoohCommandSetName extraData:@"test name" ]
```



###10、接受数据回调

```
/**
 对应的设备，接收到某指令的回复后，更新了用户数据
 
 @param device 当前连接的设备
 @param data 数据模型
 @param command 指令代码
 */
-(void)bleDevice:(WZBleDevice*)device didRefreshData:(WZBleData*)data comandCode:(WZBluetoohCommand)command
{
//通过if语句对command进行区分，然后根据不同指令通过data参数进行值的获取并显示

}
```
###11、蓝牙断开回调
当设备断电或其他异常情况与手机断开连接，需要对用户进行一些UI提示：

```
-(void)bleDevice:(WZBleDevice *)device didDisconneted:(NSError *)error
{
	//在这进行一些UI提示或变化
}

```

##Demo说明书


整体如图：
![-w200](https://ww1.sinaimg.cn/large/006tNbRwgy1fgdvessesyj30gk0oetbn.jpg)
第一个红框为三个控制器，第二个红框控制器相关的cell。

###1、搜索页面 `DemoViewController`
启动Demo，会自动进行蓝牙设备搜索（如果不支持，会有提示，且无搜索按钮）
![-w200](https://ww4.sinaimg.cn/large/006tNbRwgy1fgdw82673tj30ke0ygwff.jpg) (模拟器不支持)  ![-w200](https://ww2.sinaimg.cn/large/006tNbRwgy1fgdvljeraaj30nc0z6t9k.jpg)（真机）



当搜索到蓝牙则出现如下界面：
![-w200](https://ww2.sinaimg.cn/large/006tNbRwgy1fgdvm96fqoj30mo0x8757.jpg)

###2、链接成功、指令测试页面 `ResultViewController`

如果此设备为你需要的设备，点击则进行连接，当链接成功，则会出现如下界面：
![-w200](https://ww3.sinaimg.cn/large/006tNbRwgy1fgdvmwsq3qj30m811ujuw.jpg)

点击任何一个指令，则会进行指令的发送，且会有对应的UI提示是否发送成功。


三个绿色按钮分别对应三个历史数据，如果暂时无历史数据，则按钮不可点，可手动发送对应指令进行数据更新，在收到数据后，按钮则变得可点。


###3、历史数据页面 `HistoryViewController`
点击对应的按钮，进入如下界面：
此处只是demo大概显示，用户可根据项目需要，进行完善。
![-w200](https://ww3.sinaimg.cn/large/006tNbRwgy1fgdvp7mgstj30ny0u4dha.jpg)


>当返回设备列表页，app设置为自动断开当前连接并重新搜索设备。





##SDK类对象详细说明
###WZBleSDKInterface类
1、用来定义设备可以支持哪些指令及其枚举值`WZBluetoohCommand`，分别为：

```
WZBluetoohCommandRestartDevice,//重启设备
    WZBluetoohCommandGetBattery,//电池
    WZBluetoohCommandSynSteps,//同步步数
    WZBluetoohCommandSynStatus,//同步设备
     WZBluetoohCommandSynPostures,//同步历史坐姿
    WZBluetoohCommandActivateDevice,//激活设备
    WZBluetoohCommandCancelActivateDevice,//取消设备激活
    WZBluetoohCommandReadMotor,//读取马达
    WZBluetoohCommandOpenMotor,//马达打开
    WZBluetoohCommandCloseMotor,//马达关闭
    WZBluetoohCommandAdjustPosture,//坐姿校正
    WZBluetoohCommandCancelAdjustPosture,//取消坐姿矫正
    WZBluetoohCommandGetRTPosture,//刷新实时坐姿
    WZBluetoohCommandClearData,//清除缓存
    WZBluetoohCommandUploadDFUData,//空中升级
    WZBluetoohCommandSetName,//设置名字
    WZBluetoohCommandSetMotorDuration,//马达震动时长，单位s
    WZBluetoohCommandSetLeftAngel,//左倾角
    WZBluetoohCommandSetRightAngel,//右
    WZBluetoohCommandSetForwardAngel,//前
    WZBluetoohCommandSetBackwardAngel,//后
    WZBluetoohCommandNone,//空指令
```

2、定义手机蓝牙状态，枚举值分别为`WZBleStatus`

```
    WZBleStatusUnSupport,//不支持，比如模拟器，iPhone4等
    WZBleStatusPowerOn,//可用
    WZBleStatusPowerOff,//未打开
    WZBleStatusUnauthorized,//打开未授权

```
3、主要的属性及成员变量有：

```
    NSMutableArray<WZBleDevice*> * _devices;//扫描的设备
    NSMutableArray<id<WZBleSDKInterfaceListener>> * _listeners;//代理成员列表
    BOOL _markForScan;//是否需要扫描的标记，比如当APP启动时候，蓝牙未开启，当监听到蓝牙开启后会自动扫描设备，不需要用户手动触发扫描动作
    
    
    
    /**
 当前手机蓝牙的状态
 */
    @property (nonatomic,assign) WZBleStatus status;
```

4、主要方法有：

```
/**
 单例

 @return 共享单例
 */
+(instancetype)sharedInterface;
/**
 添加事件监听者对象

 @param listener 监听者
 */
-(void)addListner:(id<WZBleSDKInterfaceListener>)listener;


/**
 页面关闭时，移除监听者，避免内存泄漏

 @param listener 监听者
 */
-(void)removeListener:(id<WZBleSDKInterfaceListener>)listener;



/**
 获取扫描到的所有设备

 @return 所有设备
 */
-(NSArray<WZBleDevice*>*)devices;


/**
 清空扫描到的设备，
 */
-(void)clearDevices;



/**
 开始扫描设备

 @return 操作码，如果蓝牙不可用，会返回错误代码
 */
-(WZErrorCode)startScan;


/**
 停止扫描
 */
-(void)stopScan;



/**
 连接设备

 @param device 被连接的设备
 */
-(void)connectDevice:(WZBleDevice*)device;


/**
 主动断开连接

 @param device 当前设备
 */
-(void)disConnectDevice:(WZBleDevice*)device;




/**
 对设备发送指令

 @param device 链接的设备
 @param command 需要发送的指令枚举值
 @param data 有些指令需要的额外数据，比如设置姓名等
 */
-(void)bleDevice:(WZBleDevice*)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data;
```


###WZBleDevice
这是一个对蓝牙设备进行封装的对象，只要是保存数据，数据字段有：


```
/**
 当前保存的蓝牙设备模型对象
 */
@property (nonatomic,strong) CBPeripheral * periral;

/**
 当前保存的蓝牙设备广播的内容
 */
@property (nonatomic,strong) NSDictionary * advertisment;

/**
 当前保存的蓝牙设备交互产生的一些数据，具体查看WZBleData的定义
 */
@property (nonatomic,strong) WZBleData * data;


/**
 当前设备的名称

 @return 名称
 */
-(NSString*)name;

/**
 当前设备的信号强度
 
 @return 信号强度
 */
-(NSNumber*)rssi;

/**
 当前设备的提供的服务UUID列表
 
 @return uuid列表
 */
-(NSArray*)services;
```


###WZBleData

对数据封装的对象，主要用来保存蓝牙交互产生的临时数据，sdk均通过此对象读取交互产生的数据，主要字段描述为：

>注:为了效率，在该类定义了两个宏，方便快捷的去定义对象的属性


```
 ASSIGNPROP(type,name) 创建名为name,类型为type的赋值型属性对象
 
 
  STRONGPROP(type,name) 创建名为name,类型为type的强引用型属性对象 
```



```
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

ASSIGNPROP(NSInteger,speed);//马达震动时长
STRONGPROP(NSString*, version);//固件版本号
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
 字典值为historyModel数组，value为时-分-姿势

 @return <#return value description#>
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

```



###WZHistoryModel
这就是一个数据模型而已，用几个字段来保存数据，可以不太关注字段是啥，使用的时候知道保存的是什么，到时候去读取即可

```
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
```


###WZBleDeviceTools
这是一个工具类，主要进行设备数值、命令与文字描述的一个转换

```
/**
 命令描述

 @param cmd 命令的枚举值
 @return 该命令的描述
 */
+(NSString*)descriptionOfCMD:(WZBluetoohCommand)cmd;



/**
 根据设备传递的数字值，转化为中文描述

 @param posState 设备传出来的对应姿态的数值
 @return 这个数值的中文描述，比如设备传的0，就是状态未知
 */
+(NSString*)postureString:(NSInteger)posState;


/**
 根据设备传递的数字值，转化为中文描述
 
 @param sitState 设备传出来的对应坐姿的数值
 @return 这个数值的中文描述，比如设备传的0，就是坐姿未知
 */
+(NSString*)sitStringWithStatus:(NSInteger)sitState;
```

##联系方式
<!--如对sdk使用或对demo有疑问，请加QQ：511107989（安静）进行联系。
或者扫一扫：
![-w200](https://ws4.sinaimg.cn/large/006tNbRwgy1fgd08fx448j30ke0qg429.jpg)-->


<!--```flow
st=>start: 初始化sdk
e=>end: 
op=>operation: 扫描设备
op1=>operation: 连接设备
op2=>operation: 收发数据

cond=>condition: 扫描到设备？
cond2=>condition: 连接成功？
st->op->cond
cond(yes)->op1
cond(no)->op
op1->cond2
cond2(yes)->op2
cond2(no)->op

```

-->



