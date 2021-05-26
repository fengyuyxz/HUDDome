//
//  PHUDWaveLoadingView.h
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHUDWaveLoadingView : UIView
+(instancetype)HUD;
-(void)startLoading:(UIView *)container;
@end

NS_ASSUME_NONNULL_END
