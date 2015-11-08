//
//  PoetrySpider.h
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/6.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PoetrySpider;
@protocol PoetrySpiderDelegate <NSObject>

-(void)poetrySpider:(PoetrySpider *)spider didGetPoetryListOfType:(NSString *)typeName;

@end

@interface PoetrySpider : NSObject
@property (nonatomic, weak) id<PoetrySpiderDelegate> delegate;
-(void)getPoetryListOfType:(NSString *)typeName;
//-(void)getPoetryListOfType:(NSString *)typeName atPageIndex:(int)pageIndex;
-(void)getPoetryDetailWithUrlString:(NSString *)url;

@end
