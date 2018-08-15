
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

- (NSString*) signature_from_ecdsaWith:(EC_KEY*) key  pub_data:(NSData*) pub_data  sig:(ECDSA_SIG*) sig  digest:(NSData*) d;

@end


