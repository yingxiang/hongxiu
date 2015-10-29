//
//  NSObject+key.h
//  HybirdPrj
//
//  Created by xiangying on 15/6/19.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (key)

nonatomic_strong(NSString, *identify)

- (NSInteger)obj_integer:(Block_complete)block;

- (CGFloat)obj_float:(Block_complete)block;

- (CGFloat)obj_double:(Block_complete)block;

- (BOOL)obj_bool:(Block_complete)block;

- (id)obj_copy;

#pragma mark - for Exception

- (id)objectForKey:(NSString*)aKey;

- (id)objectForKeyedSubscript:(NSString*)aKey;

- (void)setObject:(id)obj forKey:(NSString*)aKey;

#pragma mark - for thread methodes (block)

- (void)runmain:(id)arg selector:(Block_complete)block;

- (void)runbackground:(id)arg selector:(Block_complete)block;

@end
