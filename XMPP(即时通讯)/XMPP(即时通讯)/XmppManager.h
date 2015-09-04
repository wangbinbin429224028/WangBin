//
//  XmppManager.h
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@protocol XmppManagerDelegate <NSObject>

- (void)jumpPage;

@end

@interface XmppManager : NSObject<XMPPStreamDelegate>

//建立通信管道
@property(nonatomic,strong)XMPPStream * xmppStream;

//设置代理属性
@property(nonatomic,assign)id<XmppManagerDelegate> delegate;

@property(nonatomic,strong)XMPPRoster * roster;//花名册(好友列表)

@property(nonatomic,strong)XMPPMessageArchiving * xmppMessageArchiving;//消息归档

@property(nonatomic,strong)NSManagedObjectContext * messageContext;//管理对象上下文



//单例
+ (instancetype)shareManager;


//注册用户  userName  passWord
- (void)registerWithUserName:(NSString *)userName PassWord:(NSString *)passWord;


//登陆
- (void)loginWithUserName:(NSString *)userName PassWord:(NSString *)passWord;



@end
