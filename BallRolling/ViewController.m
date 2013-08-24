//
//  ViewController.m
//  BallRolling
//
//  Created by Takeshi Bingo on 2013/08/24.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


//終了するときに呼ばれるメソッド
-(void)doStop {
    [startButton setHidden:NO];
    //ゲームオーバー用の画像を表示させる
    [game_over setHidden:NO];
    //　加速度センサを終了する
    [self stopAccelerometer];
    [self stopTimer];
}


//　スタートボタンが押されたときに呼ばれるメソッド
-(IBAction)doStart:(id)sender {
    [startButton setHidden:YES];
    //　ゲームオーバー用の画像を非表示にする
    [game_over setHidden:YES];
    //　玉をスタート画像の上に配置する
    [gem setCenter:[start center]];
    //　加速度を0にする
    vec = CGSizeMake(0.0f, 0.0f);
    //　スコアの初期値を200にする
    score = 200;
    //　スコア計算のメソッドを呼び、最初の減算を0にする
    [self calcScore:0];

    
    
    //　加速度センサを開始する
    [self startAccelerometer];
    [self startTimer];
}

// タイマーをストップさせるメソッド
-(void)stopTimer {
    //　もしタイマーが存在するとき
    if ( aTimer ) {
        //　タイマーを無効にする
        [aTimer invalidate];
        //　タイマーに何もセットしない
        aTimer = nil;
    }
}
// タイマーを開始するメソッド
-(void)startTimer {
    //　もしタイマーが存在するなら
    if ( aTimer )
        //タイマーを終了させるメソッドを呼ぶ
        [self stopTimer];
    //タイマーをセットする
    aTimer = [NSTimer scheduledTimerWithTimeInterval:
              kTimerInterval target:self selector:@selector(tick:)
                                            userInfo:nil repeats:YES];
}
// タイマーを使って玉を動かすメソッド
- (void)tick:(NSTimer *)theTimer {
    //　ボールの中心点のx座標に加速度で取得した値を加算する
    CGFloat x = [gem center].x+vec.width;
    //　ボールの中心点y座標に加速度で取得した値を加算する
    CGFloat y = [gem center].y+vec.height;
    // もし、移動先の座標（ボールの半径も加味）が320よりも大きい時
    if ( (x+kRadius) > 320 ) {
        //　点数を減点する処理
        [self calcScore:(-10)];
        // 反射させるための座標を設定
        vec.width = fabs(vec.width)*(-1) * kWallRefPower;
        //　玉を移動させる先の座標
        x = [gem center].x+vec.width;
    }
    if ( (x-kRadius) < 0 ) {
        [self calcScore:(-10)];
        vec.width = fabs(vec.width)*kWallRefPower;
        x = [gem center].x+vec.width;
    }
    //画面サイズ（縦の幅）を取得（iPhone5も考慮して端末の画面サイズを取得）
    int screenSizeHeight =[[UIScreen mainScreen]bounds].size.height;
    if ( (y+kRadius) > screenSizeHeight ) {
        [self calcScore:(-10)];
        vec.height = fabs(vec.height)*(-1) * kWallRefPower;
        y = [gem center].y+vec.height;
    }
    if ( (y-kRadius) < 0 ) {
        [self calcScore:(-10)];
        vec.height = fabs(vec.height)* kWallRefPower;
        y = [gem center].y+vec.height;
    }
    // checkPinメソッドを呼び、障害物のピンの情報も読み込む
    [self checkPin:pin1];
    [self checkPin:pin2];
    [self checkPin:pin3];
    [self checkPin:pin4];
    [self checkPin:pin5];
    [self checkPin:pin6];
    
    
     [self checkGoal];
    //　玉の中心座標を指定する
    [gem setCenter:CGPointMake(x,y)];
}



//　加速度に変化が起こったときに呼ばれるメソッド
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleratio
{
    // 取得した加速度の値に制限を加えて「あそび」をつくる（x,y,z軸それぞれ）
    accelX = (accelX * kFilteringFactor) + ([acceleratio x] * (1.0f - kFilteringFactor));
    accelY = (accelY * kFilteringFactor) + ([acceleratio y] * (1.0f - kFilteringFactor));
    accelZ = (accelZ * kFilteringFactor) + ([acceleratio z] * (1.0f - kFilteringFactor));
    //　加速度により玉を動かすための座標を生成する
    vec = CGSizeMake(vec.width+accelX, vec.height-accelY);
}
//　加速度センサを終了するメソッド
-(void)stopAccelerometer {
    
    // 加速度センサを利用するために読み込む
    UIAccelerometer *theAccelerometer = [UIAccelerometer sharedAccelerometer];
    //　加速度センサのデリゲートに何もセットせず、値を取得しない処理
    [theAccelerometer setDelegate:nil];
}

//　加速度センサを開始するメソッド
-(void)startAccelerometer {
    //　加速度センサを利用するために読み込む
    UIAccelerometer *theAccelerometer = [UIAccelerometer sharedAccelerometer];
    //　加速度センサを読み込む間隔を設定
    [theAccelerometer setUpdateInterval:(1.0f / kAccelerometerFrequency)];
    //　自分自身をデリゲートにセットして加速度センサを利用する
    [theAccelerometer setDelegate:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//ピンの当たり判定判別メソッド
- (void)checkPin:(UIImageView *)pin {
    //　ピンと玉の距離を求める
    CGFloat dx = ([pin center].x - [gem center].x);
    CGFloat dy = ([pin center].y - [gem center].y);
    //　もし、ピンと玉の距離が一定以上近づいたら
    if ( sqrt(dx*dx+dy*dy) < (9+kRadius) ) {
        CGFloat inp =  vec.width*dx+vec.height*dy;
        if ( inp > 0 ) {
            //　スコアから10点減点する処理
            [self calcScore:(-10)];
            //　内積を使ったベクトル演算
            CGFloat ddl = dx*dx+dy*dy;
            //　跳ね返りの度合いを加味して方向を反転させる
            vec.width -= dx * inp / ddl * kRefPwoer;
            vec.height -= dy * inp / ddl * kRefPwoer;
        }
    }
}

//　スコアを計算するメソッド
-(void)calcScore:(NSInteger)value {
    //　スコアの合計を計算する
    score += value;
    //　もし、スコアが0点以上なら
    if ( score > 0 ) {
        //　スコアのラベルに点数を表示する
        [scoreLabel setText:[NSString stringWithFormat:@"%d 点",score]];
        //　それ以外なら
    } else {
        //　スコアラベルに0点と表示させる
        [scoreLabel setText:@"0 点"];
        //　ゲームを終了するメソッドを呼ぶ
        [self doStop];
    }
}

//　ゴールを判別するメソッド
-(void)checkGoal {
    //　ゴールと玉の距離を計算する
    CGFloat dx = ([goal center].x - [gem center].x);
    CGFloat dy = ([goal center].y - [gem center].y);
    //　もし、ゴールと玉の距離が一定距離以下になったら
    if ( sqrt(dx*dx+dy*dy) < 12 ) {
        //　スコアに100点加算する
        [self calcScore:(+100)];
        // ゴールの中心の座標を取得する
        CGPoint pos = [goal center];
        //　ゴールの中心点を、スタート画像の中心点に移動させる
        [goal setCenter:[start center]];
        // スタート画像を、ゴールの中心点があった場所に移動する
        [start setCenter:pos];
    }
}
@end
