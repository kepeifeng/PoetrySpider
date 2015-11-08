//
//  PoetrySpider.m
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/6.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import "PoetrySpider.h"
#import "PSArticleManager.h"

#import <HTMLReader/HTMLReader.h>

@implementation PoetrySpider{
    __weak PoetrySpider * weakSelf;
    
    NSMutableArray * _poetryList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        weakSelf = self;
    }
    return self;
}



-(void)getPoetryListOfType:(NSString *)typeName{

    NSLog(@"%@ ===============================================", typeName);
    _poetryList = [[NSMutableArray alloc] initWithCapacity:1000];
    [self getPoetryListOfType:typeName atPageIndex:1];
    
}

-(void)getPoetryListOfType:(NSString *)typeName atPageIndex:(int)pageIndex{

    NSString * urlString = [NSString stringWithFormat:@"http://so.gushiwen.org/type.aspx?p=%d&c=%@",pageIndex, [typeName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {

          if(error){
              
              NSLog(@"error:%@", error);
              return ;
          }
          
          HTMLDocument *home = [PoetrySpider htmlDocumentFromData:data response:response];
          NSArray * elements = [home nodesMatchingSelector:@".sons p a"];
          
          NSArray * titleElements = [elements filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(HTMLElement *  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
              if ([evaluatedObject.textContent isEqualToString:@"..."]) {
                  return NO;
              }
              return YES;
          }]];
          
        
          NSLog(@"Page %d", pageIndex);
          for (HTMLElement * link in titleElements) {
              NSLog(@"%@%@", link.textContent, link.attributes[@"href"]);
              [weakSelf getPoetryDetailWithUrlString:link.attributes[@"href"]];
          }
          
          
          if(titleElements.count){
              
              [_poetryList addObjectsFromArray:titleElements];
              
              [weakSelf getPoetryListOfType:typeName atPageIndex:pageIndex+1];
          }else{
          
              if ([weakSelf.delegate respondsToSelector:@selector(poetrySpider:didGetPoetryListOfType:)]) {
                  [weakSelf.delegate poetrySpider:self didGetPoetryListOfType:typeName];
              }
          }
              
          
      }] resume];
}

+(HTMLDocument *)htmlDocumentFromData:(NSData *)data response:(NSURLResponse *)response{

    NSString *contentType = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        contentType = headers[@"Content-Type"];
    }
    
    //          NSString * html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //          [html writeToFile:@"~/Desktop/shi.html" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //          NSLog(@"%@", html);
    
    HTMLDocument *home = [HTMLDocument documentWithData:data
                                      contentTypeHeader:contentType];
    return home;
}

///获取诗歌内容
-(void)getPoetryDetailWithUrlString:(NSString *)url{

    NSInteger entityId = [PoetrySpider getNumberFromString:url];
    
    NSString * urlString = [NSString stringWithFormat:@"http://so.gushiwen.org%@",url];
    // Load a web page.
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          
          if(error){
              
              NSLog(@"error:%@", error);
              return ;
          }
          
//          NSInteger poetryId = [[urlString substringWithRange:NSMakeRange(6, url.length - 11)] integerValue];
          
          HTMLDocument *home = [PoetrySpider htmlDocumentFromData:data response:response];
          
          //标题
          HTMLElement * titleElement = [home firstNodeMatchingSelector:@".main3 .son1 h1"];
          NSString * title = titleElement.textContent;
          NSLog(@"title:%@", titleElement.textContent);
          
          HTMLElement * articleElement = [home firstNodeMatchingSelector:@".main3 .son2"];
          
          NSArray * pElements = [articleElement nodesMatchingSelector:@"p"];
          
          //朝代
          HTMLElement * dynastyElement = [pElements firstObject];
          NSString * dynasty = [(HTMLTextNode *)dynastyElement.children[1] data];
          NSLog(@"dynasty:%@", dynasty);
          
          //作者
          HTMLElement * authorElement = pElements[1];
          NSString * author = [authorElement.textContent substringFromIndex:3];
          
          NSOrderedSet * childNodes = articleElement.children;
          //正文
          NSString * content;
          if (childNodes.count > 8) {
              NSRange range = NSMakeRange(8, childNodes.count - 8);
              
              NSOrderedSet * contentNodes = [NSOrderedSet orderedSetWithOrderedSet:childNodes range:range copyItems:NO];
              content = [PoetrySpider stringFromNodes:contentNodes];

          }
          
          
          WTArticleEntity * article = [WTArticleEntity new];
          article.entityId = entityId;
          article.title = title;
          article.content = content;
          article.author = author;
          article.dynasty = dynasty;
          [[WTArticleManager sharedManager] addPoetry:article];
          
          //获取详情列表
          NSArray * summaryElements = [home nodesMatchingSelector:@".son5"];
          NSMutableArray * translateUrls = [[NSMutableArray alloc] initWithCapacity:3];
          NSMutableArray * shanxiUrls = [[NSMutableArray alloc] initWithCapacity:3];
          for (HTMLElement * divElement in summaryElements) {
              
              NSString * elementId = divElement.attributes[@"id"];
              HTMLElement * link = [divElement firstNodeMatchingSelector:@"a"];
              NSString * urlString = link.attributes[@"href"];
              
              if (urlString.length == 0) {
                  continue;
              }
              
              if([elementId hasPrefix:@"fanyi"]){
                  [translateUrls addObject:urlString];
                  [self getTranslateFromUrl:urlString forEntityId:entityId type:DetailEntityTypeNote];
              }else if ([elementId hasPrefix:@"shangxi"]){
                  [shanxiUrls addObject:urlString];
                  [self getTranslateFromUrl:urlString forEntityId:entityId type:DetailEntityTypeAnalysis];
              }
              
              NSLog(@"elementId:%@, urlString:%@", elementId, urlString);
              
          }
          
          
          //          HTMLElement *div = [home firstNodeMatchingSelector:@".repository-description"];
          //          NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
          //          NSLog(@"%@", [div.textContent stringByTrimmingCharactersInSet:whitespace]);
          // => A WHATWG-compliant HTML parser in Objective-C.
      }] resume];
    


}

+(NSInteger)getNumberFromString:(NSString *)string{

    static NSRegularExpression * numberExpress;
    if (!numberExpress) {
        numberExpress = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:0 error:nil];
    }
    
    NSTextCheckingResult * result = [numberExpress firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    NSInteger number = [[string substringWithRange:result.range] integerValue];
    return number;

}

+(NSString *)stringFromNodes:(id<NSFastEnumeration>)nodes{

    NSMutableString * text = [[NSMutableString alloc] init];
    
    BOOL shouldBreakLine = NO;
    for (HTMLNode * node in nodes) {
        
        if (shouldBreakLine) {
            [text appendString:@"\n"];
        }
        
        if ([node isKindOfClass:[HTMLTextNode class]]) {
            [text appendString:[(HTMLTextNode *)node data]];
            shouldBreakLine = NO;
        }else if([node isKindOfClass:[HTMLElement class]]){
            HTMLElement * element = (HTMLElement *)node;
            NSString * elementText = [element textContent];
            if ([elementText hasPrefix:@"本页内容整理自网络"]) {
                continue;
            }
            [text appendString:elementText];
            if([element.tagName isEqualToString:@"p"]) {
                shouldBreakLine = YES;
            }else{
                shouldBreakLine = NO;
            }
        }
    }
    
    return text;
}

///获取诗歌详情
-(void)getTranslateFromUrl:(NSString *)urlString forEntityId:(int64_t)entityId type:(DetailEntityType)type{
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://so.gushiwen.org%@", urlString]];
    NSInteger postId = [PoetrySpider getNumberFromString:urlString];

    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          
          if(error){
              
              NSLog(@"error:%@", error);
              return ;
          }
          
          HTMLDocument *home = [PoetrySpider htmlDocumentFromData:data response:response];
          
          
          HTMLElement * titleElement = [home firstNodeMatchingSelector:@"div.main3 .son1 h1"];
          NSString * title = [titleElement textContent];
          
          HTMLElement * contentDiv = [home firstNodeMatchingSelector:@".shangxicont"];
          
          NSOrderedSet * children = [contentDiv children];
          
          NSOrderedSet * contentElements = [NSOrderedSet orderedSetWithOrderedSet:children range:(NSMakeRange(2, children.count - 6)) copyItems:NO];
          NSMutableString * text = [[NSMutableString alloc] init];
          
          BOOL shouldBreakLine = NO;
          for (HTMLNode * node in contentElements) {
              
              if (shouldBreakLine) {
                  [text appendString:@"\n"];
              }
              
              if ([node isKindOfClass:[HTMLTextNode class]]) {
                  [text appendString:[(HTMLTextNode *)node data]];
                  shouldBreakLine = NO;
              }else if([node isKindOfClass:[HTMLElement class]]){
                  HTMLElement * element = (HTMLElement *)node;
                  NSString * elementText = [element textContent];
                  if ([elementText hasPrefix:@"本页内容整理自网络"]) {
                      continue;
                  }
                  [text appendString:elementText];
                  if([element.tagName isEqualToString:@"p"]) {
                      shouldBreakLine = YES;
                  }else{
                      shouldBreakLine = NO;
                  }
              }
          }
          
          
          
          NSLog(@"\n%@", title);
          
          WTPoetryDetailEntity * detail = [WTPoetryDetailEntity new];
          detail.entityId = postId;
          detail.poetryId = entityId;
          detail.title = title;
          detail.content = text;
          detail.author = @"";
          detail.detailType = type;
          [[WTArticleManager sharedManager] addPoetryDetail:detail];
          
          
          //          NSArray * contents = [contentDiv nodesMatchingSelector:@"p"];
          //          contents = [contents subarrayWithRange:(NSMakeRange(1, contents.count - 2))];
          //
          //          NSLog(@"%@", urlString);
          //          for (HTMLElement * p in contents) {
          //              NSLog(@"%@", p.textContent);
          //          }
          //
          //          for (NSString * textNode in contentDiv.textComponents){
          //              NSLog(@"%@", textNode);
          //          }
          //          
          
          
          
          
      }] resume];
}

@end
