//
//  CppPtr.h
//  Pointer
//
//  Created by Yu Li on 2018-08-06.
//  Copyright © 2018 Yu Li. All rights reserved.
//
#include <docviewer/docviewer.h>
#import <Foundation/Foundation.h>

@interface CppData : NSObject
{
    void* m_ptr;
}

+ (nonnull instancetype)wrap:(nonnull void*)ptr;
- (nonnull instancetype)initWithPtr:(nonnull void*)ptr;
@property (readonly,nonnull) void* ptr;

@end

@interface CppSharedData : NSObject
{
    std::shared_ptr<void> m_ptr;
}

+ (nonnull instancetype)wrap:(std::shared_ptr<void>)ptr;
- (nonnull instancetype)initWithPtr:(std::shared_ptr<void>)ptr;
@property (readonly) std::shared_ptr<void> ptr;

@end

@interface QSharedPointerWrapper : NSObject
{
    QSharedPointer<QObject> m_ptr;
}

+ (nonnull instancetype)wrap:(QSharedPointer<QObject>)ptr;
- (nonnull instancetype)initWithPtr:(QSharedPointer<QObject>)ptr;
@property (readonly) QSharedPointer<QObject> ptr;

@end
