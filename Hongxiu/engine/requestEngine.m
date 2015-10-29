//
//  requestEngine.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "requestEngine.h"
#import "NSString+TPCategory.h"

@implementation requestEngine

/**
 *  请求
 *
 *  @param dic       dic description
 *  @param container container description
 */
AFHTTPRequestOperation* request (NSString *url, NSString *method , id parmeters, FinishBlock completeBlock){
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    url = [url URLString];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:@"UserAgent"]) {
        [client setDefaultHeader:@"User-Agent" value:[userDefaults objectForKey:@"UserAgent"]];
    }
    AFHTTPRequestOperation *operaton = nil;
    if ([method isEqualToString:@"POST"]) {
        client.parameterEncoding = AFJSONParameterEncoding;
        operaton = [client postPath:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                completeBlock(operation,[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(operation,error);
            }
        }];
    }else if ([method isEqualToString:@"PUT"]){
        operaton = [client putPath:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                completeBlock(operation,[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(operation,error);
            }
        }];
    }else{
        operaton = [client getPath:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completeBlock) {
                NSError *error = nil;

                id value = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    NSString *jsonString = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\v" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\f" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\b" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\a" withString:@""];
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\e" withString:@""];
                    value = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                }
                completeBlock(operation,value);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completeBlock) {
                completeBlock(operation,error);
            }
        }];
    }
    obj_msgSend(operaton.request, @selector(setTimeoutInterval:),[NSNumber numberWithFloat:5]);
    return operaton;
}

void obj_msgSend(id self, SEL op, ...){
    if ([self respondsToSelector:op]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:op];
        NSUInteger length = [signature numberOfArguments];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:op];
        
        va_list arg_ptr;
        va_start(arg_ptr, op);
        for (NSUInteger i = 2; i < length; ++i) {
            id parameter = va_arg(arg_ptr, id);
            if ([parameter isKindOfClass:[NSNull class]]) {
                continue;
            }
            NSString *type = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]];
            if ([[type lowercaseString] isEqualToString:@"f"]
                ||[[type lowercaseString] isEqualToString:@"d"]) {
                float Value = [parameter floatValue];
                [invocation setArgument:&Value atIndex:i];
            }else if ([[type lowercaseString] isEqualToString:@"b"]
                      ||[[type lowercaseString] isEqualToString:@"c"]){
                BOOL Value = [parameter boolValue];
                [invocation setArgument:&Value atIndex:i];
            }else if ([[type lowercaseString] isEqualToString:@"q"]
                      ||[[type lowercaseString] isEqualToString:@"i"]){
                NSInteger Value = [parameter integerValue];
                [invocation setArgument:&Value atIndex:i];
            }else{
                [invocation setArgument:&parameter atIndex:i];
            }
        }
        va_end(arg_ptr);
        [invocation invokeWithTarget:self];
    }
}
@end
