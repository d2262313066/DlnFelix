//
//  ViewController.m
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/6.
//  Copyright © 2019 Dln. All rights reserved.
//

#import "ViewController.h"
#import "TryCrash.h"
#import "HotFixManager.h"
#import "DlnFelix.h"
#import "AssociationKey.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[HotFixManager shareManager] setValue:self forKey:NSStringFromClass(self.class)];
    
    [self instanceMethod];
    
}


// 崩溃修复
- (void)tryCrash {
    TryCrash *mc = [[TryCrash alloc] init];
    [mc divideUsingDenominator:0];
    [mc divideUsingDenominator:1 count2:2];
    
}

// 类方法
- (void)classMethod {
    NSString *fixScriptString2 = @"runVoidClassWith1Paramter('ViewController', 'Method1:',' \
    {\"type\":\"instance\",        \
    \"class\":\"NSString\",             \
    \"selector\":\"initWithString:\",   \
    \"parameters\":[\"hello world\"],   \
    }')";
    [DlnFelix evalString:fixScriptString2];
}

// 实例方法
- (void)instanceMethod {
    //调用setColor方法
    NSString *fixScriptString1 = @"runInstanceWith1Paramter('ViewController','setColor:',' \
    {\"type\":\"class\",        \
    \"class\":\"UIColor\",             \
    \"selector\":\"greenColor\",   \
    \"parameters\":[],   \
    }')";
    // 调用setString方法
//    NSString *fixScriptString2 = @"runInstanceWith1Paramter('ViewController','setString:', ' \
//    {\"type\":\"instance\",        \
//    \"class\":\"NSString\",             \
//    \"selector\":\"initWithString:\",   \
//    \"parameters\":[\"hello world\"],   \
//    }')";
    [DlnFelix evalString:fixScriptString1];
}

- (void)replaceMethod {
    /**
     此方法简单的hook掉了因为传参不当而导致的crash
     */
    // js方法
    NSString *fixScriptString = @" \
    fixInstanceMethodReplace('TryCrash', 'divideUsingDenominator:', function(instance, originInvocation, originArguments){ \
    if (originArguments[0] == 0) { \
    originArguments[0] = 1; \
    console.log('☁️🚲✨zero goes here'); \
    } else { \
    runInvocation(originInvocation); \
    } \
    });";
    
    //这种方法满足修改方法的需求
    //runInvocation  [invocation invoke]
    //originArguments 传参，有几个参数，数组就有几个对象
    
    // 调用js方法
    [DlnFelix evalString:fixScriptString];
    
}


+ (void)Method1:(NSString *)str {
    NSLog(@"%@",str);
}

- (void)setColor:(UIColor *)color {
    self.view.backgroundColor = color;
}

- (void)setString:(NSString *)string {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 100)];
    label.text = string;
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
}

@end

