//
//  YJNavigationViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/22.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "YJNavigationViewController.h"

@interface YJNavigationViewController ()

@end

@implementation YJNavigationViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //修改状态栏字体原色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

+ (void)initialize {
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    [navBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [[UIImage alloc] init];
    navBar.translucent = NO;
    navBar.barTintColor = [UIColor whiteColor];
    
    //3.2设置所有导航条的标题颜色
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[NSFontAttributeName] = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    md[NSForegroundColorAttributeName] = [UIColor blackColor];
    [navBar setTitleTextAttributes:md];
}

/*
 *  重写这个方法目的：能够拦截所有push进来的控制器
 *
 *  @param viewController 即将push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        // 这时push进来的控制器viewController，不是第一个子控制器（不是根控制器）
        /* 自动显示和隐藏tabbar */
        viewController.hidesBottomBarWhenPushed = YES;
        
        /* 设置导航栏上面的内容 */
        // 设置左边的返回按钮
        UIImage *img= [UIImage imageNamed:@"backImage"];
        img= [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIButton *navBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
        
        [navBtn setImage:img forState:UIControlStateNormal];
        navBtn.imageEdgeInsets= UIEdgeInsetsMake(0, -40, 0, 0);
        
        [navBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navBtn];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)backClick {
    
    // 因为self本来就是一个导航控制器，self.navigationController这里是nil的
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
