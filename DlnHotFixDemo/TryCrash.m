//
//  TryCrash.m
//  LYFix
//
//  Created by Dln on 2019/5/6.
//  Copyright © 2018 Xly. All rights reserved.
//

#import "TryCrash.h"

@implementation TryCrash

- (float)divideUsingDenominator:(NSInteger)denominator {
    NSLog(@"%s",__func__);
    return 1.f/denominator;
}

- (float)divideUsingDenominator:(NSInteger)denominator count2:(NSInteger)count2 {
    return denominator/count2;
}
@end
