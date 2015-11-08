//
//  PSArticleManager.m
//  PoetrySpider
//
//  Created by Kent Peifeng Ke on 15/11/7.
//  Copyright © 2015年 Kent Peifeng Ke. All rights reserved.
//

#import "PSArticleManager.h"
#import <FMDB/FMDB.h>
#import "NSFileManager+Utility.h"


@implementation WTArticleManager{
    
    FMDatabase * _database;
}


+ (instancetype)sharedManager
{
    static dispatch_once_t onceQueue;
    static WTArticleManager *gArticleManager = nil;
    
    dispatch_once(&onceQueue, ^{ gArticleManager = [[self alloc] init]; });
    return gArticleManager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString * dbFilename = @"poetry.db";
        
        NSString * supportFolderPath = [[[NSFileManager defaultManager] supportFolderPath] stringByAppendingPathComponent:@"PoetrySpider"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:supportFolderPath] == NO) {
            NSError * error;
            [[NSFileManager defaultManager] createDirectoryAtPath:supportFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString * dbCopyPath = [supportFolderPath stringByAppendingPathComponent:dbFilename];
        NSLog(@"Database Path:%@", dbCopyPath);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:dbCopyPath] == NO) {
            
 
            
            NSString * path = [[NSBundle mainBundle] pathForResource:dbFilename ofType:nil];
            NSError * error;
            [[NSFileManager defaultManager] copyItemAtPath:path toPath:dbCopyPath error:&error];
            if (error) {
                NSLog(@"Copy Database failed: %@", error);
            }
            
        }
        
        _database = [FMDatabase databaseWithPath:dbCopyPath];
        
        if (![_database openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE]) {
            NSLog(@"Database open failed.");
            return nil;
        }
        
    }
    return self;
}

-(void)addPoetry:(WTArticleEntity *)entity{

//    NSString * idString = (entity.entityId)?[@(entity.entityId) stringValue]:@"NULL";

    
    [_database executeUpdate:@"INSERT INTO `T_SHI`(`D_ID`,`D_TITLE`,`D_SHI`,`D_AUTHOR`,`D_DYNASTY`) VALUES (?,?,?,?,?);",
     (entity.entityId)?@(entity.entityId):[NSNull null],
     entity.title,
     entity.content,
     entity.author,
     entity.dynasty];
    
}

-(void)addDynasty:(WTDynastyEntity *)entity{


    [_database executeUpdate:@"INSERT INTO `T_DYNASTY`(`D_ID`,`D_DYNASTY`,`D_INTRO`) VALUES (?, ?,?);",
     (entity.entityId)?[@(entity.entityId) stringValue]:[NSNull null], entity.title, entity.desc];
    
}

-(void)addPoetryDetail:(WTPoetryDetailEntity *)entity{
    
    
    [_database executeUpdate:@"INSERT INTO `T_SHI_DETAIL`(`D_ID`,`D_SHI_ID`,`D_TITLE`,`D_CONTENT`,`D_AUTHOR`, `D_TYPE`) VALUES (?,?,?,?,?,?);",
     (entity.entityId)?[@(entity.entityId) stringValue]:[NSNull null],
     @(entity.poetryId),
     entity.title,
     entity.content,
     entity.author,
     @(entity.detailType)];
    
}

-(void)addAuthor:(WTAuthorEntity *)entity{
    

    [_database executeUpdate:@"INSERT INTO `T_AUTHOR`(`D_ID`,`D_AUTHOR`,`D_INTRO`,`D_DYNASTY`) VALUES (?,?,?,?);",
     (entity.entityId)?[@(entity.entityId) stringValue]:[NSNull null], entity.author, entity.intro, entity.dynasty];
    

}

@end
