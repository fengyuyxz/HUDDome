//
//  PencelLoadingProgressView.h
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PencilLoadingProgressView : UIView
@property(nonatomic,assign)float progress;

-(void)start;
@end

NS_ASSUME_NONNULL_END
