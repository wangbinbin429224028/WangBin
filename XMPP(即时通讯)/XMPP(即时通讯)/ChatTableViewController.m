//
//  ChatTableViewController.m
//  XMPP(即时通讯)
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 wangbinbin. All rights reserved.
//

#import "ChatTableViewController.h"
#import "XmppManager.h"
@interface ChatTableViewController ()<XMPPMessageArchivingStorage,XMPPStreamDelegate>

//接收消息的数组
@property(nonatomic,strong)NSMutableArray *messagesArray;
@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"消息";
    
    //添加代理
//    [[XmppManager shareManager].xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.messagesArray =[NSMutableArray array];
    //添加通信管道代理
    [[XmppManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    UIBarButtonItem *rightBt=[[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(didClick)];
    
    self.navigationItem.rightBarButtonItem=rightBt;
    
    self.messageContext =[XmppManager shareManager].messageContext;

  
    
}

//发送消息
-(void)didClick{
    
    //创建消息
    XMPPMessage *xmppMessage =[[XMPPMessage alloc]initWithType:@"chat" to:self.chatToJid];
    //发送消息
    [xmppMessage addBody:@"研发26"];
    [[XmppManager shareManager].xmppStream sendElement:xmppMessage];
    
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
    return self.messagesArray.count;
}


#pragma mark--XMPPMessageArchivingStorge

#pragma mark 消息发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    //刷新界面
    [self reloadMessage];
    
}

- (void)reloadMessage{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:self.messageContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    XMPPStream * stream =[XmppManager shareManager].xmppStream;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr =%@ AND bareJidStr = %@",stream.myJID.bare, self.chatToJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.messageContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        
        
        return;
    }
    
    if (self.messagesArray.count !=0) {
        
        [self.messagesArray removeAllObjects];
    }
    
    [self.messagesArray addObjectsFromArray:fetchedObjects];
    [self.tableView reloadData];
}


//-(void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)stream{
//}


#pragma mark 消息接收成功
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    NSLog(@"function==%s,  line==%d",__FUNCTION__,__LINE__);
    //刷新界面
    [self reloadMessage];
    
}

//-(void)setPreferences:(DDXMLElement *)prefs forUser:(XMPPJID *)bareUserJid{
//}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" ];
    
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chatCell"];
        
    }
    
    cell.detailTextLabel.textAlignment=NSTextAlignmentLeft;
    XMPPMessageArchiving_Message_CoreDataObject * messageCoreData =self.messagesArray[indexPath.row];
   
    if (messageCoreData.isOutgoing) {
        //消息是我发
        
        cell.detailTextLabel.hidden=YES;
        cell.textLabel.hidden=NO;
        cell.textLabel.text=messageCoreData.body;
        
    }else{
        //消息是我收
        cell.textLabel.hidden=YES;
        cell.detailTextLabel.hidden =NO;
        cell.detailTextLabel.text =messageCoreData.body;
    }
    
    return cell;
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
