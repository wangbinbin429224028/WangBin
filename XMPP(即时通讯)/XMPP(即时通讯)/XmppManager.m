//
//  XmppManager.m
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import "XmppManager.h"
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger ,ConnectToServerPopurse){
    
    ConnectToServerPopurseLogin,//登陆
    ConnectToServerPopurseRegister//注册
    
};
@interface XmppManager ()<XMPPRosterDelegate,UIAlertViewDelegate>
{

}

//连接服务器的目的
@property(nonatomic,assign)ConnectToServerPopurse connetctPopurse;

@property(nonatomic,copy)NSString *loginPassWord;
@property(nonatomic,copy)NSString *registerPassWord;
@property(nonatomic,strong)XMPPJID * fromJid;

@end

@implementation XmppManager


#pragma mark--单例
+ (instancetype)shareManager{
    static XmppManager *manager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        manager =[[XmppManager alloc]init];
        
    });
    return manager;
}

- (instancetype)init{
    self=[super init];
    if (self) {
        
        //通信管道初始化
        self.xmppStream =[[XMPPStream alloc]init];
        //服务器名称 域名,
        self.xmppStream.hostName =kHostName;
        
        //IP地址
        //端口号
        self.xmppStream.hostPort =kHostPort;
    
        //添加代理 (xmppStream 可以设置多个代理 )
       [self.xmppStream addDelegate:self delegateQueue: dispatch_get_main_queue()];
        
        //创建管理助手
        XMPPRosterCoreDataStorage * rosterCoreDataStorage =[XMPPRosterCoreDataStorage sharedInstance];
        //初始化花名册
        self.roster =[[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        //设置代理
        [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //激活通信管道
        [self.roster activate:self.xmppStream];
       
        //初始化消息归档
        XMPPMessageArchivingCoreDataStorage *coreDataStorage =[XMPPMessageArchivingCoreDataStorage sharedInstance];
        
        self.xmppMessageArchiving =[[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:coreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        [self.xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [self.xmppMessageArchiving activate:self.xmppStream];
        
        self.messageContext =coreDataStorage.mainThreadManagedObjectContext;
        
        
    }
    return self;
}

#pragma mark--xmppStreamDelegate
#pragma mark---connect sucess
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    NSLog(@"function ==%s line ==%d",__FUNCTION__,__LINE__);
    
    //判断注册 还是登陆
    switch (self.connetctPopurse) {
        case 0:
        {//登陆
            [self.xmppStream authenticateWithPassword:self.loginPassWord error:nil];
            
            break;
        }
        case 1:
        {   //注册
            
            [self.xmppStream registerWithPassword:self.registerPassWord error:nil];
            break;
        }
        default:
            break;
    }
    
    
}



#pragma mrak---connect fail
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
     NSLog(@"function ==%s line ==%d error==%@",__FUNCTION__,__LINE__,error);
    
    
}

#pragma mark connect timeOut  连接超时
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    
    NSLog(@"function ==%s line ==%d",__FUNCTION__,__LINE__);
    
     
    
}

#pragma mark --注册用户 
- (void)registerWithUserName:(NSString *)userName PassWord:(NSString *)passWord{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    self.registerPassWord=passWord;

    self.connetctPopurse =ConnectToServerPopurseRegister;
    [self creatJidWithUserName:userName];
    
    
}

#pragma mark--登陆
- (void)loginWithUserName:(NSString *)userName PassWord:(NSString *)passWord{
    self.loginPassWord =passWord;
    self.connetctPopurse =ConnectToServerPopurseLogin;
    [self creatJidWithUserName:userName];
    
}


- (void)creatMyJid:(NSString *)userName {
    //创建地址 XMPPJID
    XMPPJID * myjid =[XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    
    self.xmppStream.myJID =myjid;
    //连接服务器
    [self connectToserver];

}

- (void)creatJidWithUserName:(NSString *)userName{
    
    [self creatMyJid:userName];
    
}

#pragma mark---连接服务器
- (void)connectToserver{
    //判断当前连接状态  如果有连接 先断开连接 在建立新的连接
    if ([self.xmppStream isConnected]) {
        //断开连接
        [self.xmppStream disconnect];
        
        //下线 unavailabel
        //上线 available
        //下线
        XMPPPresence * presence =[XMPPPresence presenceWithType:@"unavailabel"];
        
        //发送
        [self.xmppStream sendElement:presence];
        
    }
        //没有连接  直接建立连接
    NSError *error=nil;
    [self.xmppStream connectWithTimeout:30.f error:&error];
    
}

#pragma mark--注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    
    
}

#pragma mark--注册失败

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    
    
}

#pragma mark--验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    XMPPPresence *prence =[XMPPPresence presenceWithType:@"availabel"];
    
    [self.xmppStream sendElement:prence];
    [self.delegate  jumpPage];
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
}


#pragma mark--验证失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    
    [self.delegate jumpPage];
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
}


#pragma mark ----xmppRosterDelegate

#pragma mark---接收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    
   NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    //请求方的JID
    
    self.fromJid=presence.from;
    
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"好友请求" message:@"是否同意好友请求" delegate:self cancelButtonTitle:@"同意" otherButtonTitles:@"拒绝", nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //同意请求
            [self.roster acceptPresenceSubscriptionRequestFrom:self.fromJid andAddToRoster:YES];
            break;
        case 1:
            
            
            //拒绝好友请求
            [self.roster  rejectPresenceSubscriptionRequestFrom:self.fromJid];
            break;
            
        default:
            break;
    }
    
  
}



#pragma mark






@end
