//
//  WTPoetryDetailEntity.h
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/7.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, DetailEntityType){

    DetailEntityTypeNote,
    DetailEntityTypeAnalysis,
    DetailEntityTypeAuthor
};

@interface WTPoetryDetailEntity : NSObject
@property (nonatomic, assign) int64_t entityId;
@property (nonatomic, assign) int64_t poetryId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, assign) DetailEntityType detailType;
@end