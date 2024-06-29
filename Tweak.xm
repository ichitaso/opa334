#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define Notify_Call "com.ichitaso.opa334.changed"

BOOL isBirthdayMessageDisplayed = NO;
UIWindow *keyWindow = nil;
UILabel *label = nil;

@interface SpringBoard : UIApplication
- (void)updateLabelAppearance:(UILabel *)label;
- (void)addSparkleEffectToKeyWindow:(UIWindow *)window;
@end

@interface SBFTouchPassThroughView : UIView
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)app {
    %orig;
    // ラベルの作成と設定
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    label.text = @"June 29 ❓";
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.layer.cornerRadius = 10.0;  // 角丸にする半径
    label.clipsToBounds = YES;  // 角丸を効かせるために必要
    // ダークモード変更時の通知を追加
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLabelAppearance:)
                                                 name:@Notify_Call
                                               object:label];

    // iOS 13 - 16
    UIUserInterfaceStyle userInterfaceStyle = [UIScreen mainScreen].traitCollection.userInterfaceStyle;
    if (userInterfaceStyle == UIUserInterfaceStyleDark) {
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];  // Dark Mode
        label.textColor = [UIColor whiteColor];
    } else {
        label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];  // Light Mode
        label.textColor = [UIColor blackColor];
    }
    // タップジェスチャーの追加
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [label addGestureRecognizer:tapGesture];
    // パンジェスチャーの追加
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [label addGestureRecognizer:panGesture];
    // ウィンドウシーンからのキーワウンドウの取得
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    #pragma clang diagnostic pop
    if (!keyWindow) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                keyWindow = scene.windows.firstObject;
                break;
            }
        }
    }
    [keyWindow addSubview:label];
}
// ラベルの外観を更新する関数
%new
- (void)updateLabelAppearance:(UILabel *)label {
    for (label in keyWindow.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            [label removeFromSuperview];
        }
    }
    // ラベルの作成と設定
    isBirthdayMessageDisplayed = NO;
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    label.text = @"June 29 ❓";
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.layer.cornerRadius = 10.0;  // 角丸にする半径
    label.clipsToBounds = YES;  // 角丸を効かせるために必要

    // タップジェスチャーの追加
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [label addGestureRecognizer:tapGesture];
    // パンジェスチャーの追加
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [label addGestureRecognizer:panGesture];

    // iOS 13 - 16
    UIUserInterfaceStyle userInterfaceStyle = [UIScreen mainScreen].traitCollection.userInterfaceStyle;
    if (userInterfaceStyle == UIUserInterfaceStyleDark) {
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];  // Dark Mode
        label.textColor = [UIColor whiteColor];
    } else {
        label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];  // Light Mode
        label.textColor = [UIColor blackColor];
    }
    [keyWindow addSubview:label];
}
// タップジェスチャーのハンドラ
%new
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    UILabel *label = (UILabel *)gesture.view;

    if (isBirthdayMessageDisplayed) {
        label.text = @"June 29 ❓";
    } else {
        label.text = @"Happy Birthday, opa334! 🎉";
    }

    isBirthdayMessageDisplayed = !isBirthdayMessageDisplayed;

    // Haptic feedback
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [generator impactOccurred];

    // バウンスアニメーション
    [UIView animateWithDuration:0.2 animations:^{
        label.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            label.transform = CGAffineTransformIdentity;
        }];
    }];

    // 光のエフェクトを追加
    if (isBirthdayMessageDisplayed) {
        [self addSparkleEffectToKeyWindow:keyWindow];
    }
}
// パンジェスチャーのハンドラ
%new
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *label = gesture.view;
    CGPoint translation = [gesture translationInView:label.superview];
    label.center = CGPointMake(label.center.x + translation.x, label.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:label.superview];
}
// 光のエフェクトを追加するメソッド
%new
- (void)addSparkleEffectToKeyWindow:(UIWindow *)window {
    CGFloat screenWidth = CGRectGetWidth(window.bounds);
    CGFloat screenHeight = CGRectGetHeight(window.bounds);
    CGFloat sparkleSize = 100.0;
    
    // 光のエフェクトを描画するためのビューを作成
    UIView *sparkleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    sparkleView.backgroundColor = [UIColor clearColor];
    sparkleView.userInteractionEnabled = NO;
    [window addSubview:sparkleView];
    
    // 光のパーティクルをランダムに配置する
    for (int i = 0; i < 50; i++) {
        CGFloat sparkleX = arc4random_uniform(screenWidth);
        CGFloat sparkleY = arc4random_uniform(screenHeight);
        UIView *sparkle = [[UIView alloc] initWithFrame:CGRectMake(sparkleX, sparkleY, sparkleSize, sparkleSize)];
        sparkle.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0
                                                   green:arc4random_uniform(255)/255.0
                                                    blue:arc4random_uniform(255)/255.0
                                                   alpha:0.5];
        sparkle.layer.cornerRadius = sparkleSize / 2.0;
        [sparkleView addSubview:sparkle];
        
        // アニメーションを追加
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sparkle.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished) {
            [sparkle removeFromSuperview];
        }];
    }
}
%end

%hook SBFTouchPassThroughView
// traitCollection の変更時に呼ばれるメソッド
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    %orig;

    UIUserInterfaceStyle currentStyle = self.traitCollection.userInterfaceStyle;
    UIUserInterfaceStyle previousStyle = previousTraitCollection.userInterfaceStyle;
    if (currentStyle != previousStyle) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@Notify_Call object:label];
    }
}
%end