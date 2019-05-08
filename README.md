# DlnFelix
基于JSContext与Aspects对热更新的一点理解
本文是因为受到 https://www.jianshu.com/p/d7b24016854e 的启发，于是对热修复跟热更新产生了一点兴趣
可能个人水平不足的原因，并不能理解有一部分怎么使用，其中有利用JSContext调用iOS的方法到时候，传了id对象，
据我所知JSContext与iOS交互靠的是字符串，没办法传对象
于是乎按照自己的理解，对代码重新改了一下

1.将id对象改为了json字符串，调用的时候根据json字符串的内容与iOS端交互
2.将实例调用performSelector 改为了 NSInvocation，并且不接收返回值（接收返回值有大概率崩溃）
3.多了一些demo啦，保证能使用
4.因为这个是轻量级的热更新，所以并不能保证能调用所有办法，只能说把想到的写了出来
