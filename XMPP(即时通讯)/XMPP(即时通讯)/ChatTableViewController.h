//
//  ChatTableViewController.h
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
@interface ChatTableViewController : UITableViewController
@property(nonatomic,strong)XMPPJID * chatToJid;//聊天对象的jid
@property(nonatomic,strong)NSManagedObjectContext * messageContext;//管理对象上下文
@end
