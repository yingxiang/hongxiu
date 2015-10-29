//
//  utilEngine.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "utilEngine.h"

@implementation utilEngine

CGSize stringCalculate(NSString *string, CGFloat width, UIFont *font){
    CGSize size = CGSizeZero;
    if (string) {
        NSDictionary *fontAttributes = @{
                                         NSFontAttributeName:font
                                         };
        size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:fontAttributes context:nil].size;
    }
    return size;
}

#pragma mark - archive
//NSCoding used in method encodeWithCoder:
void encodeObject(NSCoder *aCoder, id object){
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString * name = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        NSString *type = [[NSString alloc]initWithCString:property_getAttributes(property)  encoding:NSUTF8StringEncoding];
        NSString *typeName = [type componentsSeparatedByString:@","][0];
        
        id value = [object valueForKey:name];
        
        if ([typeName isEqualToString:@"Tf"]){
            //float
            [aCoder encodeFloat:[value floatValue] forKey:name];
        }else if ([typeName isEqualToString:@"TB"]||[typeName isEqualToString:@"TC"]||[typeName isEqualToString:@"TI"]){
            //（BOOL、 bool）、Boolean、boolean_t
            [aCoder encodeBool:[value boolValue] forKey:name];
        }else if ([typeName isEqualToString:@"Td"]){
            //CGFloat、double
            [aCoder encodeDouble:[value doubleValue] forKey:name];
        }else if ([typeName isEqualToString:@"Tq"]||[typeName isEqualToString:@"TQ"]){
            //(NSInteger、tint64_t)、NSUInteger
            [aCoder encodeInteger:[value integerValue] forKey:name];
        }else if ([typeName isEqualToString:@"Ti"]){
            //int32_t、int
            [aCoder encodeInt:[value intValue]forKey:name];
        }else if ([typeName isEqualToString:@"T{CGRect={CGPoint=dd}{CGSize=dd}}"]){
            //CGRect
            [aCoder encodeCGRect:[value CGRectValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{CGSize=dd}"]){
            //CGSize
            [aCoder encodeCGSize:[value CGSizeValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{CGPoint=dd}"]){
            //CGPoint
            [aCoder encodeCGPoint:[value CGPointValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{CGVector=dd}"]){
            //CGVector
            [aCoder encodeCGVector:[value CGVectorValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{CGAffineTransform=dddddd} "]){
            //CGAffineTransform
            [aCoder encodeCGAffineTransform:[value CGAffineTransformValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{UIEdgeInsets=dddd}"]){
            //UIEdgeInsets
            [aCoder encodeUIEdgeInsets:[value UIEdgeInsetsValue] forKey:name];
        }else if ([typeName isEqualToString:@"T{UIOffset=dd}"]){
            //UIOffset
            [aCoder encodeUIOffset:[value UIOffsetValue] forKey:name];
        }else{
            [aCoder encodeObject:value forKey:name];
        }
    }
    free(properties);
}
//used in method initWithCoder:(如果发现其他需要使用的类型，继续补充)
void decodeObject(NSCoder *aCoder, id object){
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for (int i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString * name = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        NSString *type = [[NSString alloc]initWithCString:property_getAttributes(property)  encoding:NSUTF8StringEncoding];
        NSString *typeName = [type componentsSeparatedByString:@","][0];
        
        if ([typeName isEqualToString:@"Tf"]){
            //float
            float value = [aCoder decodeFloatForKey:name];
            [object setValue:@(value) forKey:name];
        }else if ([typeName isEqualToString:@"TB"]||[typeName isEqualToString:@"TC"]||[typeName isEqualToString:@"TI"]){
            //（BOOL、 bool）、Boolean、boolean_t
            BOOL value = [aCoder decodeBoolForKey:name];
            [object setValue:@(value) forKey:name];
        }else if ([typeName isEqualToString:@"Td"]){
            //CGFloat、double
            double value = [aCoder decodeDoubleForKey:name];
            [object setValue:@(value) forKey:name];
        }else if ([typeName isEqualToString:@"Tq"]||[typeName isEqualToString:@"TQ"]){
            //(NSInteger、tint64_t)、NSUInteger
            NSInteger value = [aCoder decodeIntegerForKey:name];
            [object setValue:@(value) forKey:name];
        }else if ([typeName isEqualToString:@"Ti"]){
            //int32_t、int
            int value = [aCoder decodeIntForKey:name];
            [object setValue:@(value) forKey:name];
        }else if ([typeName isEqualToString:@"T{CGRect={CGPoint=dd}{CGSize=dd}}"]){
            //CGRect
            NSValue *value = [NSValue valueWithCGRect:[aCoder decodeCGRectForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{CGSize=dd}"]){
            //CGSize
            NSValue *value = [NSValue valueWithCGSize:[aCoder decodeCGSizeForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{CGPoint=dd}"]){
            //CGPoint
            NSValue *value = [NSValue valueWithCGPoint:[aCoder decodeCGPointForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{CGVector=dd}"]){
            //CGVector
            NSValue *value = [NSValue valueWithCGVector:[aCoder decodeCGVectorForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{CGAffineTransform=dddddd} "]){
            //CGAffineTransform
            NSValue *value = [NSValue valueWithCGAffineTransform:[aCoder decodeCGAffineTransformForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{UIEdgeInsets=dddd}"]){
            //UIEdgeInsets
            NSValue *value = [NSValue valueWithUIEdgeInsets:[aCoder decodeUIEdgeInsetsForKey:name]];
            [object setValue:value forKey:name];
        }else if ([typeName isEqualToString:@"T{UIOffset=dd}"]){
            //UIOffset
            NSValue *value = [NSValue valueWithUIOffset:[aCoder decodeUIOffsetForKey:name]];
            [object setValue:value forKey:name];
        }else{
            //NSObjec
            id value = [aCoder decodeObjectForKey:name];
            if (value) {
                [object setValue:value forKey:name];
            }
        }
    }
    free(properties);
}

//Data 目录下
id unarchiveObjectForkey(NSString *key){
    NSString *filePath = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:key];
    if (file_exist(filePath)) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return nil;
}

//如果是子目录 key(@"dir/key")
void archiveObjectForKey(id object, NSString *key){
    dispatch_async(global_queue, ^{
        file_createDirectory(_HYBIRD_PATH_DATA);
        NSArray *paths = [key componentsSeparatedByString:@"/"];
        NSString *filePath = _HYBIRD_PATH_DATA;
        for (int i = 0 ;i < paths.count ;i++) {
            NSString *subPath = paths[i];
            filePath = [filePath stringByAppendingPathComponent:subPath];
            if (i != paths.count - 1) {
                file_createDirectory(filePath);
            }
        }
        if (file_exist(filePath)) {
            file_delete(filePath);
        }
        [NSKeyedArchiver archiveRootObject:object toFile:filePath];
    });
}

void archiveRemoveObjectForKey(NSString *key){
    NSString *filePath = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:key];
    file_delete(filePath);
}
@end
