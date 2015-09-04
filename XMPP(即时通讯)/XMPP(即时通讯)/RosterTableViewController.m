//
//  RosterTableViewController.m
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import "RosterTableViewController.h"
#import "ChatTableViewController.h"
#import "XmppManager.h"
@interface RosterTableViewController ()<XMPPRosterDelegate>

@property(nonatomic,strong)NSMutableArray * RostersArray;//用来存放好友


@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rosterCell"];
    [ [XmppManager shareManager].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.navigationItem.title =@"好友列表";
    
    
}

#pragma mark---xmppRosterDelegate 
#pragma mark---开始检索
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
}

#pragma mark---结束检索
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    
}


#pragma mark----获取到好友
//每次获取一个
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    
   NSString *userName =[[item attributeForName:@"jid"]stringValue];
   
    //拿到一个好友的JID
    XMPPJID *rosterJid =[XMPPJID jidWithString:userName resource:kResource];
    
    //判断是否添加过
    if ([self.RostersArray containsObject:rosterJid]) {
        return;
    }
    
    [self.RostersArray addObject:rosterJid];
    
    //获取indexPath
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:self.RostersArray.count-1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView reloadData];
   NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return  self.RostersArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];

    XMPPJID *jid=self.RostersArray[indexPath.row];
    cell.textLabel.text =jid.user;
    
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatTableViewController * chatVC =[[ChatTableViewController alloc]init];
    //向聊天界面传聊天对象的jid
    XMPPJID *chatToJid =self.RostersArray[indexPath.row];
    
    chatVC.chatToJid =chatToJid;

    [self.navigationController pushViewController:chatVC animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //获取聊天界面
    ChatTableViewController * chatTVC =(ChatTableViewController *)segue.destinationViewController;
  
    UITableViewCell *selectCell=(UITableViewCell *)sender;
    
   //获取indexpath
    NSIndexPath * indexPath=[self.tableView indexPathForCell:selectCell];
    
    //向聊天界面传聊天对象的jid
    XMPPJID *chatToJid =self.RostersArray[indexPath.row];
    chatTVC.chatToJid =chatToJid;
    [self.navigationController pushViewController:chatTVC animated:YES];
    
}

//懒加载
-(NSMutableArray *)RostersArray{
    if (!_RostersArray) {
        
        self.RostersArray =[NSMutableArray array];
    }
    
    return _RostersArray;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
