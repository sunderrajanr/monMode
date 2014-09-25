//
//  ICESingleTon.h
//  monMode
//
//  Created by Muthu Sabari on 9/11/14.
//  Copyright (c) 2014 EveryDay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICESingleTon : NSObject

@property (strong, nonatomic) NSString *str_CelciusTemperature;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature;
@property (strong, nonatomic) NSString *str_CelciusTemperature2;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature2;
@property (strong, nonatomic) NSString *str_CelciusTemperature3;
@property (strong, nonatomic) NSString *str_FahrenheitTemperature3;

+ (id)sharedManager;

@end
