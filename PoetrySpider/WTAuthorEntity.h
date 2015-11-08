//
//  WTAuthorEntity.h
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/7.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTAuthorEntity : NSObject
@property (nonatomic, assign) int64_t entityId;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * intro;
@property (nonatomic, strong) NSString * dynasty;
@end
