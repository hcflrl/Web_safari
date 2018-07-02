//
//  ViewController.m
//  Web_safari
//
//  Created by 黄乘风 on 2018/7/2.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "ViewController.h"
#import "HistoryTableTableViewController.h"
#import "LikeTableViewController.h"

@interface ViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    UIWebView * _webView;
    UITextField * _searchBar;
    BOOL _isUp;
    UILabel * _titleLable;
    UISwipeGestureRecognizer * _upSwipe;
    UISwipeGestureRecognizer * _downSwipe;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    _webView.scrollView.bounces=NO;
    _webView.delegate=self;
    _isUp=NO;
    _titleLable =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 20)];
    //设置lable为透明按钮
    _titleLable.backgroundColor=[UIColor clearColor];
    //font---字体类型
    _titleLable.font = [UIFont systemFontOfSize:14];
    //对齐模式
    _titleLable.textAlignment=NSTextAlignmentCenter;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.baidu.com"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    [self creatSearchBar];
    [self creatGesture];
    [self creatToolBar];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)creatSearchBar{
    _searchBar = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 30)];
    _searchBar.borderStyle = UITextBorderStyleRoundedRect;
    UIButton * goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [goBtn addTarget:self action:@selector(goWeb) forControlEvents:UIControlEventTouchUpInside];
    goBtn.frame = CGRectMake(0, 0, 30, 30);
    [goBtn setTitle:@"GO" forState:UIControlStateNormal];
    _searchBar.rightView = goBtn;
    _searchBar.rightViewMode = UITextFieldViewModeAlways;
    //placeholder---占位文字
    _searchBar.placeholder = @"请输入网址";
    self.navigationItem.titleView=_searchBar;
}

-(void)goWeb{
    if(_searchBar.text.length>0)
    {
        NSURL * url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",_searchBar.text]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    else{
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"输入网址不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alter addAction:action];
        [self presentViewController:alter animated:YES completion:nil];
        return;
    }
}

-(void)creatGesture{
    //在webview上创建一个上滑逻辑
    _upSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(upSwipe)];
    _upSwipe.delegate=self;
    _upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [_webView addGestureRecognizer:_upSwipe];
    
    _downSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(downSwipe)];
    _downSwipe.delegate=self;
    _downSwipe.direction=UISwipeGestureRecognizerDirectionDown;
    [_webView addGestureRecognizer:_downSwipe];
}

-(void)upSwipe{
    if(_isUp)
    {
        return;
    }
    self.navigationItem.titleView=nil;
    _webView.frame=CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
    //用于处理渐变动画的方法
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBar.frame=CGRectMake(0, 0,
                                                                 self.navigationController.navigationBar.frame.size.width, 40);
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:7 forBarMetrics:UIBarMetricsDefault];
    } completion:^(BOOL finished){
        self.navigationItem.titleView = self->_titleLable;
    }
     ];
    [self.navigationController setToolbarHidden:YES animated:YES];
    _isUp=YES;
}

-(void)downSwipe{
    //contentoffset表示滚动界面的相对便宜亮，以下表达式表示y轴滚动为0
    if(_webView.scrollView.contentOffset.y==0&&_isUp){
        self.navigationItem.titleView=nil;
        _webView.frame=CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationBar.frame=CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 64);
            [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
        } completion:^(BOOL finished){
            self.navigationItem.titleView = self->_searchBar;
        }];
        [self.navigationController setToolbarHidden:NO animated:YES];
        _isUp=NO;
    }
}

-(void)creatToolBar
{
    self.navigationController.toolbarHidden=NO;
    UIBarButtonItem * itemHistory = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(goHistory)];
    UIBarButtonItem * itemLike = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(goLike)];
    UIBarButtonItem * itemBack = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    UIBarButtonItem * itemForward = [[UIBarButtonItem alloc]initWithTitle:@"forward" style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    UIBarButtonItem * empty = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * empty2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * empty3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[itemHistory,empty,itemLike,empty2,itemBack,empty3,itemForward];
}

-(void)goHistory{
    HistoryTableTableViewController * controller = [[HistoryTableTableViewController alloc]init];
    [self.navigationController pushViewController:controller  animated:YES];
}

-(void)goLike{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请选择你要进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"添加收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        NSArray *array = [[NSUserDefaults standardUserDefaults]valueForKey:@"Like"];
        if(!array){
            array = [[NSArray alloc]init];
        }
        NSMutableArray * newArray = [[NSMutableArray alloc]initWithArray:array];
        [newArray addObject:self->_webView.request.URL.absoluteString];
        [[NSUserDefaults standardUserDefaults]setValue:newArray forKey:@"Like"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"查看收件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        LikeTableViewController * controller = [[LikeTableViewController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:action2];
    [alert addAction:action3];
    //弹出对话框
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)goBack{
    if([_webView canGoBack]){
        [_webView goBack];
    }
}

-(void)goForward{
    if([_webView canGoForward]){
        [_webView goForward];
    }
}

-(void)loadURL:(NSString *)urlStr{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    _titleLable.text = webView.request.URL.absoluteString;
    NSArray * array = [[NSUserDefaults standardUserDefaults]valueForKey:@"History"];
    if(!array){
        array = [[NSArray alloc]init];
    }
    NSMutableArray * newArray = [[NSMutableArray alloc]initWithArray:array];
    [newArray addObject:_titleLable.text];
    [[NSUserDefaults standardUserDefaults]setValue:newArray forKey:@"History"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if(gestureRecognizer==_upSwipe||gestureRecognizer==_downSwipe){
        return YES;
    }
    return NO;
}

@end
