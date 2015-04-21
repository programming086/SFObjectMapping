//
//  SFMappingCasesSpec.m
//  SFObjectMapping
//
//  Created by Paul Taykalo on 4/21/15.
//  Copyright 2015 Stanfy LLC. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SFMappingCore.h"
#import "TestProperty.h"
#import "NSObject+SFMapping.h"
#import "SFMapping.h"
#import "SFDateMapper.h"


SPEC_BEGIN(SFMappingCasesSpec)

describe(@"SFMappingCore", ^{
    it(@"should be able to get intance of specified class", ^{
        [SFMappingCore instanceOfClass:TestProperty.class fromObject:nil];
    });
    it(@"should return instance of class was specified", ^{
        id o = [SFMappingCore instanceOfClass:TestProperty.class fromObject:nil];
        [[o shouldNot] beNil];
        [[o should] beKindOfClass:TestProperty.class];
    });

    context(@"When mapping BOOL property", ^{
        __block TestProperty * object;
        context(@"And mapping is found", ^{
            beforeEach(^{
                [TestProperty setSFMappingInfo:[SFMapping property:@"boolProperty" toKeyPath:@"value"], nil];
            });
            it(@"should be mapped from dictionary @YES", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @YES}];
                [[theValue(object.boolProperty) should] beTrue];
            });
            it(@"should be mapped from dictionary @NO", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @NO}];
                [[theValue(object.boolProperty) should] beFalse];
            });
            it(@"should be mapped from dictionary (True)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"True"}];
                [[theValue(object.boolProperty) should] beTrue];
            });
            it(@"should be mapped from dictionary (False)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"False"}];
                [[theValue(object.boolProperty) should] beFalse];
            });
            it(@"should be mapped from dictionary (YES)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"y"}];
                [[theValue(object.boolProperty) should] beTrue];
            });
            it(@"should be mapped from dictionary (NO)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"n"}];
                [[theValue(object.boolProperty) should] beFalse];
            });
            it(@"should be mapped from dictionary '1'", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"2"}];
                [[theValue(object.boolProperty) should] beTrue];
            });
            it(@"should be mapped from dictionary '0'", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"0"}];
                [[theValue(object.boolProperty) should] beFalse];
            });
        });
    });


    context(@"When mapping Numbers property", ^{
        __block TestProperty * object;
        context(@"And mapping is found", ^{
            beforeEach(^{
                [TestProperty setSFMappingInfo:
                    [SFMapping property:@"numberProperty" toKeyPath:@"value"],
                    [SFMapping property:@"intProperty" toKeyPath:@"value"],
                    [SFMapping property:@"longProperty" toKeyPath:@"value"],
                    [SFMapping property:@"floatProperty" toKeyPath:@"value"],
                    [SFMapping property:@"doubleProperty" toKeyPath:@"value"],
                        nil];
            });
            it(@"should be mapped from dictionary [NSNull null]", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : [NSNull null]}];
                [[object.numberProperty should] equal:@0];
                [[theValue(object.intProperty) should] equal:theValue(0)];
                [[theValue(object.longProperty) should] equal:theValue(0)];
                [[theValue(object.floatProperty) should] equal:theValue(0)];
                [[theValue(object.doubleProperty) should] equal:theValue(0)];
            });


            it(@"should be mapped from dictionary when value is float (15.5)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @15.5}];
                [[object.numberProperty should] equal:@15.5];
                [[theValue(object.intProperty) should] equal:theValue(15)];
                [[theValue(object.longProperty) should] equal:theValue(15)];
                [[theValue(object.floatProperty) should] equal:theValue(15.5)];
                [[theValue(object.doubleProperty) should] equal:theValue(15.5)];
            });

            it(@"should be mapped from dictionary when value is float (-20)", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @(-20)}];
                [[object.numberProperty should] equal:@-20];
                [[theValue(object.intProperty) should] equal:theValue(-20)];
                [[theValue(object.longProperty) should] equal:theValue(-20)];
                [[theValue(object.floatProperty) should] equal:theValue(-20)];
                [[theValue(object.doubleProperty) should] equal:theValue(-20)];
            });

            it(@"should be mapped from dictionary when value is string '15.5'", ^{
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : @"15.5"}];
                [[object.numberProperty should] equal:@15.5];
                [[theValue(object.intProperty) should] equal:theValue(15)];
                [[theValue(object.longProperty) should] equal:theValue(15)];
                [[theValue(object.floatProperty) should] equal:theValue(15.5)];
                [[theValue(object.doubleProperty) should] equal:theValue(15.5)];
            });

        });
    });


    context(@"When mapping with custom mapper", ^{
        __block TestProperty * object;
        __block id<SFMapper> customMapper;
        __block id mapping;
        context(@"And mapping is found", ^{
            beforeEach(^{
                customMapper = [KWMock nullMockForProtocol:@protocol(SFMapper)];
                mapping = [[SFMapping property:@"dateProperty" toKeyPath:@"value"] applyCustomMapper:customMapper];
                [TestProperty setSFMappingInfo:mapping, nil];
            });
            it(@"should call custom mapper with mapping and value", ^{
                NSNull *value = [NSNull null];
                [[(KWMock *)customMapper should] receive:@selector(applyMapping:onObject:withValue:error:) withArguments:mapping, [KWAny any], value, nil];
                object = [SFMappingCore instanceOfClass:[TestProperty class] fromObject:@{@"value" : value}];
            });
        });
    });

    afterEach(^{
        [TestProperty setSFMappingInfo:nil];
    });

});

SPEC_END
