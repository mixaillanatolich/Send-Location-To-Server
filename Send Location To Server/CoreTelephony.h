//
//  CoreTelephony.h
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//
/*
struct CTServerConnection
{
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};

struct CTResult
{
    int flag;
    int a;
};

struct CTServerConnection * _CTServerConnectionCreate(CFAllocatorRef, void *, int *);

void _CTServerConnectionCopyMobileIdentity(struct CTResult *, struct CTServerConnection *, NSString **);

int *  _CTServerConnectionCopyMobileEquipmentInfo(
                                                  struct CTResult * Status,
                                                  struct CTServerConnection * Connection,
                                                  CFMutableDictionaryRef *Dictionary
                                                  );

struct CTServerConnection *sc=NULL;
struct CTResult result;

void callback() { }

extern NSString *kCTMobileEquipmentInfoIMEI;
*/