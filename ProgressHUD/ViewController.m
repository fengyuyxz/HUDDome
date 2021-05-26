//
//  ViewController.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/21.
//

#import "ViewController.h"
#import "PHUDHeadTailRotaing.h"
#import "PHUDWaveLoadingView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)startClick:(id)sender {
    [[PHUDWaveLoadingView HUD]startLoading:self.view];
}

- (IBAction)cancelClick:(id)sender {
}
- (IBAction)sucClick:(id)sender {
    [[PHUDHeadTailRotaing HUD]loadSUC];
}
- (IBAction)failClick:(id)sender {
    [[PHUDHeadTailRotaing HUD]loadFail];
}


@end
