
#import <Foundation/Foundation.h>
#include <openssl/ec.h>
#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <openssl/conf.h>
#include <openssl/err.h>
#include <openssl/ecdsa.h>
#include <openssl/ecdh.h>
#include <openssl/sha.h>
#include <openssl/obj_mac.h>

@interface R1Key : NSObject

- (NSString*) getEOSPublicKeyWithR1Data:(NSData*) data;

- (NSString*) signature_from_ecdsaWith:(NSData*) pub_data  sigData:(NSData*) sigData  digest:(NSData*) d;

@end


