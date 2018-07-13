//
//  uECCAPI.m
//  eosio-api
//
//  Created by kein on 2018. 7. 5..
//  Copyright © 2018년 kein. All rights reserved.
//

#import "Crypto.h"
#import "uECC.h"
#import "rmd160.h"
#import "libbase58.h"

@implementation Crypto


+ (NSString*) signWithPrivateKey: (NSData*) private_key hash: (NSData*) message_hash{
    
    uint8_t signature[uECC_BYTES * 2] = { 0 };
    uint8_t* pri_key = (uint8_t*)[private_key bytes];
    uint8_t* hash = (uint8_t*)[message_hash bytes];
    int recId = uECC_sign_forbc(pri_key, hash, signature);
    if (recId < 0) {
        return NULL;
    } else {
        unsigned char bin[65+4] = { 0 };
        unsigned char *rmdhash = NULL;
        int binlen = 65+4;
        int headerBytes = recId + 27 + 4;
        bin[0] = (unsigned char)headerBytes;
        memcpy(bin + 1, signature, uECC_BYTES * 2);
        
        unsigned char temp[67] = { 0 };
        memcpy(temp, bin, 65);
        memcpy(temp + 65, "K1", 2);
        
        rmdhash = RMD(temp, 67);
        memcpy(bin + 1 +  uECC_BYTES * 2, rmdhash, 4);
        
        char sigbin[100] = { 0 };
        size_t sigbinlen = 100;
        b58enc(sigbin, &sigbinlen, bin, binlen);
        
        NSString *sig = [NSString stringWithFormat:@"SIG_K1_%@", [NSString stringWithUTF8String:sigbin]];
        
        return sig;
    }
}

@end
