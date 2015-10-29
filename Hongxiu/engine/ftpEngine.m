//
//  ftpEngine.m
//  HybirdNamibox
//
//  Created by xiang ying on 15/9/10.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "ftpEngine.h"

#define FTP_ACCOUNT @""
#define FTP_SECRET  @""
#define kSendBufferSize  32768


@interface ftpEngine ()<NSStreamDelegate>{
    uint8_t _buffer[kSendBufferSize];
}

nonatomic_readonly (uint8_t, *buffer)
nonatomic_strong   (NSOutputStream, *networkStream)
nonatomic_strong   (NSInputStream , *fileStream)
nonatomic_assign   (size_t, bufferOffset)
nonatomic_assign   (size_t, bufferLimit)

@end

@implementation ftpEngine

DECLARE_SINGLETON(ftpEngine)

- (uint8_t *)buffer{
    return self->_buffer;
}

- (void)uploadUrl:(NSString*)fileUrl filePath:(NSString*)filePath{
    NSURL *url;//ftp服务器地址
    NSString *account;//账号
    NSString *password;//密码
    CFWriteStreamRef ftpStream;
    
    //获得输入
    url = [NSURL URLWithString:fileUrl];
    account = FTP_ACCOUNT;
    password = FTP_SECRET;
    
    //添加后缀（文件名称）
//    url = NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) url, (CFStringRef) [filePath lastPathComponent], false));
    
    //读取文件，转化为输入流
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    [self.fileStream open];
    
    //为url开启CFFTPStream输出流
    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    self.networkStream = (__bridge NSOutputStream *) ftpStream;
    
    //设置ftp账号密码
    [self.networkStream setProperty:account forKey:(id)kCFStreamPropertyFTPUserName];
    [self.networkStream setProperty:password forKey:(id)kCFStreamPropertyFTPPassword];
    
    //设置networkStream流的代理，任何关于networkStream的事件发生都会调用代理方法
    self.networkStream.delegate = self;
    
    //设置runloop
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.networkStream open];
    
    //完成释放链接
    CFRelease(ftpStream);
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    //aStream 即为设置为代理的networkStream
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"NSStreamEventOpenCompleted");
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"NSStreamEventHasBytesAvailable");
            assert(NO);     // 在上传的时候不会调用
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            NSLog(@"bufferOffset is %zd",self.bufferOffset);
            NSLog(@"bufferLimit is %zu",self.bufferLimit);
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    //读取文件错误
                    [self _stopSendWithStatus:@"读取文件错误"];
                } else if (bytesRead == 0) {
                    //文件读取完成 上传完成
                    [self _stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }else {
                //写入数据
                NSInteger bytesWritten;//bytesWritten为成功写入的数据
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self _stopSendWithStatus:@"网络写入错误"];
                } else {
                    self.bufferOffset += bytesWritten;
                    if (self.blockProgress) {
                        self.blockProgress(PROGRESS_TYPE_UPLOAD,self.bufferOffset,self.bufferLimit);
                    }
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self _stopSendWithStatus:@"Stream打开错误"];
            assert(NO);
        } break;
        case NSStreamEventEndEncountered: {
            // 忽略
        } break;
        default: {
            assert(NO);
        } break;
    }
}

//结果处理
- (void)_stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self _sendDidStopWithStatus:statusString];
}

- (void)_sendDidStopWithStatus:(NSString *)statusString
{
    BOOL complete = (statusString == nil);
    if (statusString == nil) {
        statusString = @"上传成功";
    }
    if (self.blockComplete) {
        self.blockComplete(complete,statusString);
    }
}

@end
