//
//  ICESingleTon.m
//  monMode
//
//  Created by Muthu Sabari on 9/11/14.
//  Copyright (c) 2014 EveryDay. All rights reserved.
//

#import "ICESingleTon.h"

@implementation ICESingleTon
@synthesize str_CelciusTemperature,str_CelciusTemperature2,str_CelciusTemperature3,str_FahrenheitTemperature,str_FahrenheitTemperature2,str_FahrenheitTemperature3;

+ (id)sharedManager {
    static ICESingleTon *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
	if (self = [super init])
    {
		str_CelciusTemperature = @"";
        str_CelciusTemperature2 = @"";
        str_CelciusTemperature3 = @"";
        str_FahrenheitTemperature = @"";
        str_FahrenheitTemperature2 = @"";
        str_FahrenheitTemperature3 = @"";
    }
	return self;
}

- (void)dealloc {
	// Should never be called, but just here for clarity really.
}

@end
