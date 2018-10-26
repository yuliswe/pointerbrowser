//
//  CppPtr.m
//  Pointer
//
//  Created by Yu Li on 2018-08-06.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "CppData.mm.h"

@implementation CppData

@synthesize ptr = m_ptr;

+ (nonnull CppData*)wrap:(nonnull void*)ptr
{
    return [[CppData alloc] initWithPtr:ptr];
}

- (CppData*) initWithPtr:(void *)ptr {
    self = [self init];
    self->m_ptr = ptr;
    return self;
}

@end


@implementation CppSharedData

@synthesize ptr = m_ptr;

+ (instancetype)wrap:(std::shared_ptr<void>)ptr
{
    return [[CppSharedData alloc] initWithPtr:ptr];
}

- (instancetype)initWithPtr:(std::shared_ptr<void>)ptr {
    self = [self init];
    self->m_ptr = ptr;
    return self;
}

@end

@implementation QSharedPointerWrapper

@synthesize ptr = m_ptr;

+ (instancetype)wrap:(QSharedPointer<QObject>)ptr
{
    return [[QSharedPointerWrapper alloc] initWithPtr:ptr];
}

- (instancetype)initWithPtr:(QSharedPointer<QObject>)ptr {
    self = [self init];
    self->m_ptr = ptr;
    return self;
}

@end
