//
//  FGRoute.m
//  FGRoute
//
//  Created by Arthur Sahakyan on 6/8/17.
//  Copyright © 2017 Arthur Sahakyan. All rights reserved.
//

#import "FGRoute.h"
#import "IpHelper.h"
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation FGRoute

+ (NSString *)getGatewayIP {
    NSString *ipString = nil;
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r >= 0) {
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
    } else {
        NSLog(@"Wifi is not connected or you are using simulator Gateway ip address will be nil");
    }
    
    return ipString;
}

+ (NSString *)getSSID {
    NSDictionary *info = [self getInterfaces];
    if (info[@"SSID"] == nil) {
        NSLog(@"Wifi is not connected or you are using simulator SSID will be nil");
    }
    return info[@"SSID"];
}

+ (NSString *)getBSSID {
    NSDictionary *info = [self getInterfaces];
    if (info[@"BSSID"] == nil) {
        NSLog(@"Wifi is not connected or you are using simulator BSSID will be nil");
    }
    return info[@"BSSID"];
}

+ (NSString *)getSSIDDATA {
    NSDictionary *info = [self getInterfaces];
    if (info[@"SSIDDATA"] == nil) {
        NSLog(@"Wifi is not connected or you are using simulator SSIDDATA will be nil");
    }
    return info[@"SSIDDATA"];
}

+ (NSDictionary *)getInterfaces {
    NSArray *interFaceNames = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    for (NSString *name in interFaceNames) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
        return info;
    }
    return Nil;
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    if ([address  isEqual: @"error"]) {
        NSLog(@"Wifi is not connected or you are using simulator ip address will be nil");
    }
    return address;
}

+ (NSString *)getSubnetMask {
    NSString *subnetMask = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    subnetMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
                
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    if ([subnetMask  isEqual: @"error"]) {
        NSLog(@"Wifi is not connected or you are using simulator ip address will be nil");
    }
    return subnetMask;
}

//Getting all the hosts to ping and returns them as array
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask {
    
    //Check if valid IP
    if (![self isValidIPAddress:ipAddress] || ![self isValidIPAddress:subnetMask]) {
        return nil;
    }
    
    //Converting IP and Subnet to Binary
    NSArray *ipArray = [self ipToBinary:ipAddress];
    NSArray *subnetArray = [self ipToBinary:subnetMask];
    
    //Getting the first and last IP as array binary
    NSArray *firstIPArray = [self firstIPToPingForIPAddress:ipArray subnetMask:subnetArray];
    NSArray *lastIPArray = [self lastIPToPingForIPAddress:ipArray subnetMask:subnetArray];
    
    //Looping through all possible IPs and extracting them as NSString in NSArray
    NSMutableArray *ipArr = [[NSMutableArray alloc]init];
    
    NSArray *currentIP = [NSArray arrayWithArray:firstIPArray];
    
    while (![self isEqualBinary:currentIP :lastIPArray]) {
        
        [ipArr addObject:[self binaryToIP:currentIP]];
        currentIP = [NSArray arrayWithArray:[self increaseBitArray:currentIP]];
    }
    //Adding the last one
    [ipArr addObject:[self binaryToIP:currentIP]];
    
    return ipArr;
}

+ (BOOL)isWifiConnected {
    NSString *info = [self getGatewayIP];
    if (info) {
        return true;
    }
    return false;
}

#pragma mark - Helper Methods for Net Calc
+(NSArray*)firstIPToPingForIPAddress:(NSArray*)ipArray subnetMask:(NSArray*)subnetArray{
    
    NSMutableArray *firstIPArray = [[NSMutableArray alloc]init];
    
    //Performing bitwise AND on the IP and the Subnet to find the Network IP
    for (int i=0; i < [ipArray count]-1; i++) {
        
        [firstIPArray addObject:[NSNumber numberWithInt:[ipArray[i] intValue] & [subnetArray[i] intValue]]];
    }
    
    //Adding the last digit to 1 in order to get the first
    //The first IP
    [firstIPArray addObject:[NSNumber numberWithInt:1]];
    
    //return [self binaryToIP:firstIPArray];
    
    return firstIPArray;
}

+(NSArray*)lastIPToPingForIPAddress:(NSArray*)ipArray subnetMask:(NSArray*)subnetArray{
    
    NSMutableArray *lastIPArray = [[NSMutableArray alloc]init];
    
    //Reversing the subnet to wild card
    NSArray *wildCard = [self subnetToWildCard:subnetArray];
    
    //Performing bit wise OR on Wild card and IP to get the last host
    for (int i=0; i < [ipArray count]-1; i++) {
        
        [lastIPArray addObject:[NSNumber numberWithInt:[ipArray[i] intValue] | [wildCard[i] intValue]]];
    }
    
    //The Last IP
    [lastIPArray addObject:[NSNumber numberWithInt:0]];
    
    return lastIPArray;
}

//Increasing by one the IP on binary representation and returns the IP on string
+(NSString*)increaseBit:(NSArray*)ipArray {
    
    NSMutableArray *ipArr = [[NSMutableArray alloc]initWithArray:ipArray];
    
    int ipCount = (int)[ipArr count];
    
    for (int i= ipCount-1; i > 0; i--) {
        
        if ([ipArr[i] intValue]==0) {
            
            ipArr[i]=[NSNumber numberWithInt:1];
            break;
        }
        else {
            
            ipArr[i]=[NSNumber numberWithInt:0];
            if (ipArray[i-1]==0) {
                ipArr[i-1]=[NSNumber numberWithInt:1];
                break;
            }
        }
    }
    
    return [self binaryToIP:ipArr];
}

//Increasing by one the IP on binary representation and returns the IP on NSArray (Binarry)
+(NSArray*)increaseBitArray:(NSArray*)ipArray {
    
    NSMutableArray *ipArr = [[NSMutableArray alloc]initWithArray:ipArray];
    
    int ipCount = (int)[ipArr count];
    
    for (int i= ipCount-1; i > 0; i--) {
        
        if ([ipArr[i] intValue]==0) {
            
            ipArr[i]=[NSNumber numberWithInt:1];
            break;
        }
        else {
            
            ipArr[i]=[NSNumber numberWithInt:0];
            if (ipArray[i-1]==0) {
                ipArr[i-1]=[NSNumber numberWithInt:1];
                break;
            }
        }
    }
    
    return ipArr;
}
//Checks if IP is valid
+(BOOL)isValidIPAddress:(NSString*)ipAddress {
    
    NSArray *ipArray = [ipAddress componentsSeparatedByString:@"."];
    
    if ([ipArray count] != 4) {
        
        return NO;
    }
    
    for (NSString *sub in ipArray) {
        
        int part = [sub intValue];
        
        if (part<0 || part>255) {
            return NO;
        }
    }
    
    return YES;
}

//This function convert decimals to binary
+(NSString *)print01:(int)int11{
    
    int n =128;
    char array12[8];
    NSString *str;
    
    if(int11==0)
        return str= [NSString stringWithFormat:@"00000000"];
    
    for(int j=0;j<8;j++) {
        if ((int11-n)>=0){
            array12[j]='1';
            int11-=n;
            
        }
        else
            array12[j]='0';
        
        n=n/2;
    }
    
    str= [[NSString stringWithFormat:@"%s",array12] substringWithRange:NSMakeRange(0,8)];
    
    return str;
};

//Converts an IP NSString to binary
+(NSArray*)ipToBinary:(NSString*)ipAddress {
    
    NSArray *ipArray = [ipAddress componentsSeparatedByString:@"."];
    
    //Convert the string to the 4(integer) numbers of IP
    int int1 = [ipArray[0] intValue];
    int int2 = [ipArray[1] intValue];
    int int3 = [ipArray[2] intValue];
    int int4 = [ipArray[3] intValue];
    
    NSString *t1,*t2,*t3,*t4;
    
    t1= [self print01:int1];
    t2= [self print01:int2];
    t3= [self print01:int3];
    t4= [self print01:int4];
    
    NSMutableArray *ipBinary = [[NSMutableArray alloc]initWithCapacity:32];
    
    for(int i=0;i<=7;i++) {
        
        [ipBinary addObject:[NSNumber numberWithInt:[t1 characterAtIndex:i]- '0']];
    }
    
    for(int i=0;i<=7;i++) {
        
        [ipBinary addObject:[NSNumber numberWithInt:[t2 characterAtIndex:i]- '0']];
    }
    
    for(int i=0;i<=7;i++) {
        
        [ipBinary addObject:[NSNumber numberWithInt:[t3 characterAtIndex:i]- '0']];
    }
    
    for(int i=0;i<=7;i++) {
        
        [ipBinary addObject:[NSNumber numberWithInt:[t4 characterAtIndex:i]- '0']];
    }
    
    return ipBinary;
    
}

//Converts binary IP to NSString
+(NSString*)binaryToIP:(NSArray*)binaryArray {
    
    int bits=128;
    
    int t1=0,t2=0,t3=0,t4=0;
    
    for(int i=0;i<=7;i++){
        
        if ([binaryArray[i] intValue]==1)
            t1+=bits;
        if ([binaryArray[i+8] intValue]==1)
            t2+=bits;
        if ([binaryArray[i+16] intValue]==1)
            t3+=bits;
        if ([binaryArray[i+24] intValue]==1)
            t4+=bits;
        
        bits=bits/2;
    }
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d",t1,t2,t3,t4];
    
}

//Check if the binary IP is equal with another binary IP
+(BOOL)isEqualBinary:(NSArray*)binArray1 :(NSArray*)binArray2{
    
    for (int i=0; i < [binArray1 count]; i++) {
        
        if ([binArray1[i] intValue]!= [binArray2[i] intValue]) {
            
            return NO;
        }
    }
    
    return YES;
}

//Converts Subnet to Wild Card
+(NSArray*)subnetToWildCard:(NSArray*)subnetArray {
    
    NSMutableArray *subArray = [NSMutableArray arrayWithArray:subnetArray];
    
    for(int i=0; i < [subArray count]; i++) {
        
        int intNum = [[subArray objectAtIndex:i] intValue];
        
        if (intNum==0) {
            
            [subArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];
        }
        else {
            
            [subArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
        }
    }
    
    return subArray;
}

@end
