//
//  fileEngine.h
//  HybirdPrj
//
//  Created by xiang ying on 15/7/18.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


typedef void(^ProgressBlock)(NSString *aUrl,long long currentprogress,long long totalprogress);
typedef void(^FinishBlock)(AFHTTPRequestOperation *operation,id data);

@interface fileEngine : NSObject

/**
 * 下载文件
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址
 * @param string aFileName 文件名
 */

AFHTTPRequestOperation* downloadFile(NSString *aUrl,ProgressBlock progressBlock,FinishBlock completeBlock);

/**
 *  post上传文件
 *
 *
 */
void uploadFile(NSString *aUrl,NSString *aFilePath,Block_progress progressBlock,Block_complete completeBlock);

void uploadData(NSString *aUrl,NSDictionary *header,Block_progress progressBlock,Block_complete completeBlock);

//ftp 上传
void ftpupload(NSString *aUrl,NSString *aFilePath,Block_progress progressBlock,Block_complete completeBlock);

void unarchivezip (NSString *srcPath,NSString *dstPath,Block_progress progress,Block_complete complete);

bool file_exist(NSString *dscPath);

bool file_copy(NSString *srcPath,NSString *dstPath);

bool file_dirclear(NSString *dscPath);

bool file_delete(NSString *dscPath);

bool file_move(NSString *srcPath,NSString *dstPath);

bool file_createDirectory(NSString *dstPath);

id file_read(NSString *filepath);

void file_write(id data,NSString *filepath);

unsigned long long file_size(NSString *path);

NSString *file_md5(NSString *path);

@end
