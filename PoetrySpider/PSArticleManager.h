//
//  PSArticleManager.h
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/7.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTArticleEntity.h"
#import "WTDynastyEntity.h"
#import "WTPoetryDetailEntity.h"
#import "WTAuthorEntity.h"

@interface WTArticleManager : NSObject

+ (instancetype)sharedManager;

-(void)addPoetry:(WTArticleEntity *)entity;
-(void)addDynasty:(WTDynastyEntity *)entity;
-(void)addPoetryDetail:(WTPoetryDetailEntity *)entity;
-(void)addAuthor:(WTAuthorEntity *)entity;
    
@end
