//
//  PoetrySpiderTests.m
//  PoetrySpiderTests
//
//  Created by Kent Peifeng Ke on 15/11/5.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PSArticleManager.h"

@interface PoetrySpiderTests : XCTestCase

@end

@implementation PoetrySpiderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testAddPoetry{

    WTArticleEntity * article = [WTArticleEntity new];
    article.entityId = 124;
    article.title = @"title";
    article.content = @"content";
    article.author = @"author";
    article.dynasty = @"朝代";
    [[WTArticleManager sharedManager] addPoetry:article];

}


-(void)testAddDynasty{

    WTDynastyEntity * dynasty = [WTDynastyEntity new];
    dynasty.entityId = 345;
    dynasty.title = @"某朝代";
    dynasty.desc = @"描述";
    [[WTArticleManager sharedManager] addDynasty:dynasty];
}

-(void)testAddDetail{

    WTPoetryDetailEntity * detail = [WTPoetryDetailEntity new];
    detail.entityId = 432;
    detail.poetryId = 123;
    detail.title = @"主食";
    detail.content = @"没事";
    detail.author = @"礼拜";
    [[WTArticleManager sharedManager] addPoetryDetail:detail];
}

-(void)testAddAuthor{

    WTAuthorEntity * author = [WTAuthorEntity new];
    author.entityId = 873;
    author.author = @"李白";
    author.intro = @"很好";
    author.dynasty = @"唐朝";
    [[WTArticleManager sharedManager] addAuthor:author];
    
}

@end
