//
//  ViewController.h
//  BallRolling
//
//  Created by Takeshi Bingo on 2013/08/24.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
//　加速度センサから値を取得する間隔
#define kAccelerometerFrequency 20.0f
//　加速度センサの感度を制限する
#define kFilteringFactor 0.2f
//　タイマーの間隔
#define kTimerInterval 0.01f
//　あたり判定用の玉の半径
#define kRadius 30.0f
//　壁反射の度合い
#define kWallRefPower 0.8f
// Pin反射の度合い
#define kRefPwoer 1.8f

@interface ViewController : UIViewController
<
// 加速度センサ
UIAccelerometerDelegate
>
{
    // あそびを付けた各軸座標の値
    UIAccelerationValue accelX, accelY, accelZ;
    // 玉の加速度
    CGSize vec;
    
    // タイマー
    NSTimer *aTimer;
    
    
    
    // 地面の画像用
    IBOutlet UIImageView *base;
    
    // 玉の画像用
    IBOutlet UIImageView *gem;
    
    // スタートの画像用
    IBOutlet UIImageView *start;
    
    // ゴールの画像用
    IBOutlet UIImageView *goal;
    
    // 障害物1~6の画像用
    
    IBOutlet UIImageView *pin1;
    IBOutlet UIImageView *pin2;
    IBOutlet UIImageView *pin3;
    IBOutlet UIImageView *pin4;
    IBOutlet UIImageView *pin5;
    IBOutlet UIImageView *pin6;
    // ゲームオーバーの画像用
    IBOutlet UIImageView *game_over;
    
    // スコア表示用のラベル
    IBOutlet UILabel *scoreLabel;
    
    // スタートボタン
    IBOutlet UIButton *startButton;
    
    //　スコア計算用
    NSInteger score;
    
}

//　ゲームをスタートさせるためのメソッド
- (IBAction)doStart:(id)sender;


@end
