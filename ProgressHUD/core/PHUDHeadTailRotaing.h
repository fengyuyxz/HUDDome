//
//  PHUDHeadTailRotaing.h
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHUDHeadTailRotaing : UIView
+(instancetype)HUD;
-(void)startLoading:(UIView *)container;
-(void)loadSUC;
-(void)loadFail;
-(void)cancel;
@end

NS_ASSUME_NONNULL_END
