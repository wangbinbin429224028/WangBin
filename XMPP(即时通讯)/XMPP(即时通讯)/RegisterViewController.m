//
//  RegisterViewController.m
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *passWord;
- (IBAction)registerButton:(UIButton *)sender;

- (IBAction)backAction:(UIBarButtonItem *)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//注册按钮点击事件
- (IBAction)registerButton:(UIButton *)sender {
    
    //传用户名和密码进行注册
    [[XmppManager shareManager]registerWithUserName:self.userName.text PassWord:self.passWord.text];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//返回
- (IBAction)backAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    

}
@end
