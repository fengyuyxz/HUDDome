//
//  ProgressTestController.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/24.
//

#import "ProgressTestController.h"
#import "PencilLoadingProgressView.h"
@interface ProgressTestController ()
@property(nonatomic,strong) PencilLoadingProgressView * progressView;

@end

@implementation ProgressTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    PencilLoadingProgressView *view=[[PencilLoadingProgressView alloc]initWithFrame:CGRectMake(15, 100, self.view.bounds.size.width-30, 100)];
    [self.view addSubview:view];
    _progressView=view;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_progressView start];
}
- (IBAction)progressChange:(UISlider *)sender {
    _progressView.progress =sender.value;
}


@end
