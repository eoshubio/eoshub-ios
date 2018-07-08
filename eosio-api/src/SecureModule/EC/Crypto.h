//
//  uECCAPI.h
//  eosio-api
//
//  Created by kein on 2018. 7. 5..
//  Copyright © 2018년 kein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sha2.h"

@interface Crypto : NSObject

+ (void)sha256_Raw: (const uint8_t*)data size: (size_t)size digest: (uint8_t[SHA256_DIGEST_LENGTH]) digest;
+ (NSString*) signWithPrivateKey: (NSData*) private_key hash: (NSData*) message_hash;

@end
