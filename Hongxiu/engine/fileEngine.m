//
//  fileEngine.m
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "fileEngine.h"
#import "NSString+TPCategory.h"
#import "ftpEngine.h"
#import <ZipArchive/ZipArchive.h>
#import <CommonCrypto/CommonDigest.h>

@implementation fileEngine

/**
 * 下载文件
 */
AFHTTPRequestOperation* downloadFile(NSString *aUrl,ProgressBlock progressBlock,FinishBlock completeBlock)
{    
    //下载附件
    if (!aUrl || aUrl.length == 0) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:aUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSString *cachefile = [NSTemporaryDirectory() stringByAppendingString:[url.absoluteString stringFromMD5]];

    unsigned long long downloadedBytes = 0;
    if (file_exist(cachefile)) {
        //获取已下载的文件长度
        downloadedBytes = file_size(cachefile);
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:cachefile append:YES];
    
    //下载进度控制
    if (progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            progressBlock(aUrl,totalBytesRead + downloadedBytes,totalBytesExpectedToRead + downloadedBytes);
        }];
    }
    
    //已完成下载
    if (completeBlock) {
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *requestUrl = operation.request.URL.absoluteString;
            NSString *cacheFilePath = [NSTemporaryDirectory() stringByAppendingString:[requestUrl stringFromMD5]];
            completeBlock(operation,cacheFilePath);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //下载失败
            completeBlock(operation,nil);
        }];
    }
    
    [operation start];
    return operation;
}

void uploadData(NSString *aUrl,NSDictionary *header,Block_progress progressBlock,Block_complete completeBlock){
    if (header) {
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:aUrl]];
        
        NSDictionary *parameters = nil;
        
        NSURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:aUrl parameters:parameters constructingBodyWithBlock:^(id formData) {
            [formData appendPartWithFileData:header[@"data"] name:header[@"key"] fileName:header[@"fileName"] mimeType:header[@"contentType"]];
        }];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (progressBlock) {
                progressBlock(PROGRESS_TYPE_UPLOAD,totalBytesWritten,totalBytesExpectedToWrite);
            }
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                completeBlock(YES,responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(NO,error);
            }
        }];
        
        [client.operationQueue addOperation:operation];
    }
}

void uploadFile(NSString *aUrl,NSString *aFilePath,Block_progress progressBlock,Block_complete completeBlock){

    //检查本地文件是否已存在
    if (file_exist(aFilePath)) {
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:aUrl]];
        
        NSDictionary *parameters = nil;
        
         NSURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:aUrl parameters:parameters constructingBodyWithBlock:^(id formData) {
             NSString *aFileName = [[NSFileManager defaultManager] displayNameAtPath:aFilePath];
             [formData appendPartWithFileURL:[NSURL fileURLWithPath:aFilePath] name:aFileName error:nil];
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                             
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                completeBlock(YES,responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(NO,error);
            }
        }];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (progressBlock) {
                progressBlock(PROGRESS_TYPE_UPLOAD,totalBytesWritten,totalBytesExpectedToWrite);
            }
        }];
        [client.operationQueue addOperation:operation];
    }
}

void ftpupload(NSString *aUrl,NSString *aFilePath,Block_progress progressBlock,Block_complete completeBlock){
    [[ftpEngine shareInstance] uploadUrl:aUrl filePath:aFilePath];
    [ftpEngine shareInstance].blockProgress = progressBlock;
    [ftpEngine shareInstance].blockComplete = completeBlock;
}

void unarchivezip (NSString *srcPath,NSString *dstPath,Block_progress progress,Block_complete complete){
    ZipArchive *archive = [[ZipArchive alloc] init];
    if([archive UnzipOpenFile:srcPath]){
        if (progress) {
            archive.progressBlock = ^(int percentage, int filesProcessed, unsigned long numFiles){
                progress(PROGRESS_TYPE_UNZIP,filesProcessed,numFiles);
            };
        }
        dispatch_async(global_queue, ^{
            file_createDirectory(dstPath);
            BOOL result = [archive UnzipFileTo:dstPath overWrite:YES];
            [archive UnzipCloseFile];
            file_delete(srcPath);
            if (result) {
                NSLog(@"archive success");
            }
            if (complete) {
                complete(result,nil);
            }
        });
    }else{
        if (complete) {
            complete(NO,nil);
        }
    }
}

#pragma mark - NSFile methods

/**
 *  assign readjsonFile to dic
 *
 *  @param filepath
 *  @param filename
 */
id file_read(NSString *filepath){
    if (file_exist(filepath)) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            NSError *error = nil;
            id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {

            }else {
                return dic;
            }
        }else {
        }
    }
    return nil;
}

void file_write(id object,NSString *filepath){
    if (!object) {
        return;
    }
    dispatch_async(global_queue, ^{
        if (file_exist(filepath)) {
            file_delete(filepath);
        }
        NSError *error;
        NSData* data = nil;
        if ([object isKindOfClass:[NSData class]]) {
            data = object;
        }else{
            @try {
                data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        if([data writeToFile:filepath atomically:YES]){
            
        }
        if (error) {
        }
    });
}

bool file_exist(NSString *dscPath){
    bool exist = [[NSFileManager defaultManager] fileExistsAtPath:dscPath];
    //    if (!exist) {
    //        showException(dscPath)
    //    }
    return exist;
}

bool file_copy(NSString *srcPath,NSString *dstPath){
    NSError *error = nil;
    bool result = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
    if (error) {
    }
    return result;
}

bool file_dirclear(NSString *dscPath){
    bool result = YES;
    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dscPath error:nil];
    for (NSString *subPath in array) {
        if(!file_delete([dscPath stringByAppendingPathComponent:subPath])){
            result = NO;
        }
    }
    return result;
}

bool file_delete(NSString *dscPath){
    bool result = YES;
    if (file_exist(dscPath)) {
        NSError *error = nil;
        result = [[NSFileManager defaultManager] removeItemAtPath:dscPath error:&error];
        if (error) {
        }
    }
    return result;
}

bool file_move(NSString *srcPath,NSString *dstPath){
    NSError *error = nil;
    if (file_exist(dstPath)) {
        file_delete(dstPath);
    }
    BOOL result = NO;
    if (file_exist(srcPath)) {
        result = [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:&error];
        if (error) {
        }
    }else {
    }
    return result;
}

bool file_createDirectory(NSString *dstPath){
    bool result = YES;
    if (!file_exist(dstPath)) {
        NSError *error = nil;
        result =  [[NSFileManager defaultManager] createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
        }
    }
    return result;
}

//获取文件大小
unsigned long long file_size(NSString *path){
    signed long long fileSize = 0;
    if (file_exist(path)) {
        NSError *error = nil;
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            if ([fileDict.fileType isEqualToString:NSFileTypeDirectory]) {
                NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
                for (NSString *subPath in array) {
                    fileSize = fileSize + file_size([path stringByAppendingPathComponent:subPath]);
                }
            }else{
                fileSize = [fileDict fileSize];
            }
        }
    }
    return fileSize;
}

#define CHUNK_SIZE 1024

NSString *file_md5(NSString *path){
    if (file_exist(path)) {
        NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];
        if(handle == nil)
            return nil;
        CC_MD5_CTX md5_ctx;
        CC_MD5_Init(&md5_ctx);
        NSData* filedata;
        do
        {
            filedata = [handle readDataOfLength:CHUNK_SIZE];
            CC_MD5_Update(&md5_ctx, [filedata bytes], (CC_LONG)[filedata length]);
        }
        while([filedata length]);
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(result, &md5_ctx);
        [handle closeFile];
        NSMutableString *hash = [NSMutableString string];
        for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
        {
            [hash appendFormat:@"%02x",result[i]];
        }
        return [hash lowercaseString];
    }
    return nil;
}

@end
