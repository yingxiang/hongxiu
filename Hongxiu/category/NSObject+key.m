//
//  NSObject+key.m
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "NSObject+key.h"
#import <objc/runtime.h>

static const void *keyKey = &keyKey;
static const void *blocksKey    = &blocksKey;

@implementation NSObject (key)

#pragma mark - category properties

- (NSString *)identify {
    return objc_getAssociatedObject(self, keyKey);
}

- (void)setIdentify:(NSString *)identify{
    objc_setAssociatedObject(self, keyKey, identify, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)blocks{
    return objc_getAssociatedObject(self, blocksKey);
}

- (void)setBlocks:(NSMutableDictionary *)blocks{
    objc_setAssociatedObject(self, blocksKey, blocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - get properties (safe)

- (NSInteger)obj_integer:(Block_complete)block{
    NSInteger integervalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        integervalue = [(NSString*)self integerValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        integervalue = [(NSNumber*)self integerValue];
        success = YES;
    }
    
    if (block) {
        block(success,nil);
    }
    return integervalue;
}

- (CGFloat)obj_float:(Block_complete)block{
    CGFloat floatvalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        floatvalue = [(NSString*)self floatValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        floatvalue = [(NSNumber*)self floatValue];
        success = YES;
    }
    if (block) {
        block(success,nil);
    }
    return floatvalue;
}

- (CGFloat)obj_double:(Block_complete)block{
    CGFloat doublevalue = 0;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        doublevalue = [(NSString*)self doubleValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        doublevalue = [(NSNumber*)self doubleValue];
        success = YES;
    }
    if (block) {
        block(success,nil);
    }
    return doublevalue;
}

- (BOOL)obj_bool:(Block_complete)block{
    BOOL boolvalue = NO;
    BOOL success = NO;
    if ([self isKindOfClass:[NSString class]]) {
        boolvalue = [(NSString*)self boolValue];
        success = YES;
    }else if ([self isKindOfClass:[NSNumber class]]){
        boolvalue = [(NSNumber*)self boolValue];
        success = YES;
    }
    if (block) {
        block(success,nil);
    }
    return boolvalue;
}

- (id)obj_copy{
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [(NSDictionary*)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [dic setObject:[obj obj_copy] forKey:[key obj_copy]];
        }];
        return dic;
    }else if([self isKindOfClass:[NSString class]]){
        return [self copy];
    }else if ([self isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [NSMutableArray array];
        for (id obj in (NSArray*)self) {
            [array addObject:[obj obj_copy]];
        }
        return array;
    }
    return self;
}

#pragma mark - add methods for exception
//for Exception
- (id)objectForKey:(NSString*)aKey{
    return nil;
}

//obj[aKey]
- (id)objectForKeyedSubscript:(NSString*)aKey{
    return nil;
}

- (void)setObject:(id)obj forKey:(NSString*)aKey{
}

- (NSUInteger)length{
    return 0;
}

#pragma mark - thread block
- (void)backgroundSelector:(NSArray*)args{
    NSString *key = [args firstObject];
    Block_complete block = self.blocks[key];
    if (block) {
        if (args.count == 2) {
            block(YES,[args lastObject]);
        }else{
            block(YES,nil);
        }
        [self.blocks removeObjectForKey:key];
    }
}

- (void)mainSelector:(NSArray*)args{
    NSString *key = [args firstObject];
    Block_complete block = self.blocks[key];
    if (block) {
        if (args.count == 2) {
            block(YES,[args lastObject]);
        }else{
            block(YES,nil);
        }
        [self.blocks removeObjectForKey:key];
    }
}

- (void)runmain:(id)arg selector:(Block_complete)block{
    if (block) {
        SEL selector = @selector(mainSelector:);
        if (!self.blocks) {
            self.blocks = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%p",block];
        [self.blocks setObject:block forKey:key];
        if (arg) {
            [self performSelectorOnMainThread:selector withObject:@[key,arg] waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:selector withObject:@[key] waitUntilDone:YES];
        }
    }
}

- (void)runbackground:(id)arg selector:(Block_complete)block{
    if (block) {
        SEL selector = @selector(backgroundSelector:);
        if (!self.blocks) {
            self.blocks = [NSMutableDictionary dictionary];
        }
        NSString *key = [NSString stringWithFormat:@"%p",block];
        [self.blocks setObject:block forKey:key];
        if (arg) {
            [self performSelectorInBackground:selector withObject:@[key,arg]];
        }else{
            [self performSelectorInBackground:selector withObject:@[key]];
        }
    }
}


@end
