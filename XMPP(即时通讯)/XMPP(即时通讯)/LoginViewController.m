//
//  LoginViewController.m
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import "LoginViewController.h"
#import "XmppManager.h"
#import "XMPPFramework.h"
#import "RosterTableViewController.h"


@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *passWord;
- (IBAction)loginButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@property(nonatomic,strong)id<XmppManagerDelegate> delegate;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [XmppManager shareManager].delegate =self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//登陆
- (IBAction)loginButton:(UIButton *)sender {
    
    [[XmppManager shareManager]loginWithUserName:self.userName.text PassWord:self.passWord.text];
    
   
}

- (void)jumpPage{
    if ([[XmppManager shareManager].xmppStream isAuthenticated]  ) {
        
        RosterTableViewController * rosterTVC =[[RosterTableViewController alloc]init];
        
        [self.navigationController pushViewController:rosterTVC animated:YES];
        
    }else{
        
        UIAlertView * aletr =[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或者密码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [aletr show];
        
        NSLog(@"+++++登录失败!");
    }
    
    
    
}

@end
