//
//  uECCAPI.h
//  eosio-api
//
//  Created by kein on 2018. 7. 5..
//  Copyright © 2018년 kein. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Crypto : NSObject

+ (NSString*) signWithPrivateKey: (NSData*) private_key hash: (NSData*) message_hash;


@end
