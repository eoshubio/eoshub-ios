
#import "R1Key.h"
#include <string>
#include "ripemd160.hpp"



@interface R1Key() {
   
}
@end

@implementation R1Key

using namespace std;
using namespace ripemd160;

char base58_chars[] = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
char base58_map[256] = {0};

- (instancetype)init
{
    self = [super init];
    if (self) {
        for (unsigned i = 0; i < 256; ++i)
            base58_map[i] = -1;
        for (unsigned i = 0; i < sizeof(base58_chars); ++i)
            base58_map[base58_chars[i]] = i;
    }
    return self;
}



std::string binary_to_base58(const unsigned char* bin, int size) {
    std::string result("");
    for (int i = 0 ; i < size; i++) {
        unsigned char byte = bin[i];
        int carry = byte;
        for (auto& result_digit : result) {
            int x = (base58_map[result_digit] << 8) + carry;
            result_digit = base58_chars[x % 58];
            carry = x / 58;
        }
        while (carry) {
            result.push_back(base58_chars[carry % 58]);
            carry = carry / 58;
        }
    }
    
    for (int i = 0 ; i < size; i++) {
        unsigned char byte = bin[i];
        if (byte) {
            break;
        } else {
            result.push_back('1');
        }
    }
        
    std::reverse(result.begin(), result.end());
    return result;
}

///pramaeter
/// - suffix: "R1"
template <int suffix_size>
unsigned char* digest_suffix_ripemd160(unsigned char* data, int size, const char (&suffix)[suffix_size]) {
    
    unsigned char* digest = (unsigned char*)malloc(20 * sizeof(unsigned char));
    
    ripemd160_state state;
    ripemd160_init(&state);
    ripemd160_update(&state, data, size);
    ripemd160_update(&state, (uint8_t*)suffix, suffix_size - 1);
    ripemd160_digest(&state, digest);
    
    return digest;
}
///pramaeter
/// - size: 33 or 65
/// - suffix: "R1"
/// - prefix: "PUB_R1_" , "PVT_R1_", "SIG_R1_"
template <int suffix_size>
std::string key_to_string(unsigned char* key, int size, const char (&suffix)[suffix_size], const char* prefix) {
    
    unsigned char* ripe_digest = digest_suffix_ripemd160(key, size, suffix);
    int sigSize = size + 4;
    unsigned char* whole = (unsigned char*)malloc(sigSize);
    memcpy(whole, key, size);
    memcpy(whole + size, ripe_digest, 4);
    std::string encodedKey = binary_to_base58(whole, sigSize);
    std::string prefixString(prefix);
    free(whole);
    return prefixString + encodedKey;
}


- (NSString*) getEOSPublicKeyWithR1Data:(NSData*) data {
    
    unsigned char* key = (unsigned char*)data.bytes;
    
    int size = (int)data.length;
    
    string eosKey = key_to_string(key, size, "R1", "PUB_R1_");
  
    NSString* eosKeyString = [NSString stringWithCString:eosKey.c_str() encoding:[NSString defaultCStringEncoding]];
    
    return eosKeyString;
    
}


- (NSString*) signature_from_ecdsaWith:(EC_KEY*) key  pub_data:(NSData*) pub_data  sig:(ECDSA_SIG*) sig  digest:(NSData*) d {
    NSData* data = signature_from_ecdsa(key, pub_data, sig, d);
    
    unsigned char* bin = (unsigned char*)data.bytes;
    
    int size = (int)data.length;
    
    string eosKey = key_to_string(bin, size, "R1", "SIG_R1_");
    
    NSString* eosSigString = [NSString stringWithCString:eosKey.c_str() encoding:[NSString defaultCStringEncoding]];
    
    return eosSigString;
}


//MARK sign
NSData* signature_from_ecdsa(const EC_KEY* key, NSData* pub_data, ECDSA_SIG* sig, NSData* d) {
    //We can't use ssl_bignum here; _get0() does not transfer ownership to us; _set0() does transfer ownership to fc::ecdsa_sig
    const BIGNUM *sig_r, *sig_s;
    BIGNUM *r = BN_new(), *s = BN_new();
    ECDSA_SIG_get0(sig, &sig_r, &sig_s);
    BN_copy(r, sig_r);
    BN_copy(s, sig_s);
    
    //want to always use the low S value
    const EC_GROUP* group = EC_KEY_get0_group(key);
    fc::ssl_bignum order, halforder;
    EC_GROUP_get_order(group, order, nullptr);
    BN_rshift1(halforder, order);
    if(BN_cmp(s, halforder) > 0)
        BN_sub(s, order, s);
    
    unsigned char csig[65] = { 0 };
    
    int nBitsR = BN_num_bits(r);
    int nBitsS = BN_num_bits(s);
    if(nBitsR > 256 || nBitsS > 256) {
        return nil;
    }

    ECDSA_SIG_set0(sig, r, s);
    
    int nRecId = -1;
    for (int i=0; i<4; i++)
    {
        EC_KEY* keyRec;
        keyRec = EC_KEY_new_by_curve_name( NID_X9_62_prime256v1 );
        
        if (ECDSA_SIG_recover_key_GFp(keyRec, sig, (unsigned char*)d.bytes, (int)d.length, i, 1) == 1)
        {
            
//            if (keyRec.serialize() == pub_data )
            {
                nRecId = i;
                break;
            }
        }
    }
    
    if (nRecId == -1) {
        //"unable to construct recoverable key"
        return nil;
    }
    
    csig[0] = nRecId+27+4;
    BN_bn2bin(r,&csig[33-(nBitsR+7)/8]);
    BN_bn2bin(s,&csig[65-(nBitsS+7)/8]);
    
    NSData* sigData = [NSData dataWithBytes:csig length:65];
    
    return sigData;
}

int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check)
{
    if (!eckey) {
        return -1;
    }
    
    int ret = 0;
    BN_CTX *ctx = NULL;
    
    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    int n = 0;
    int i = recid / 2;
    
    const BIGNUM *r, *s;
    ECDSA_SIG_get0(ecsig, &r, &s);
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, r)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check)
    {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
    if (!BN_zero(zero)) { ret=-1; goto err; }
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, r, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, s, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }
    
    ret = 1;
    
err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    return ret;
}




void ECDSA_SIG_get0(const ECDSA_SIG *sig, const BIGNUM **pr, const BIGNUM **ps) {
    if (pr != NULL)
        *pr = sig->r;
    if (ps != NULL)
        *ps = sig->s;
}

int ECDSA_SIG_set0(ECDSA_SIG *sig, BIGNUM *r, BIGNUM *s) {
    if (r == NULL || s == NULL)
        return 0;
    BN_clear_free(sig->r);
    BN_clear_free(sig->s);
    sig->r = r;
    sig->s = s;
    return 1;
}

namespace fc {
    template <typename ssl_type>
    struct ssl_wrapper
    {
        ssl_wrapper(ssl_type* obj):obj(obj) {}
        
        operator ssl_type*() { return obj; }
        operator const ssl_type*() const { return obj; }
        ssl_type* operator->() { return obj; }
        const ssl_type* operator->() const { return obj; }
        
        ssl_type* obj;
    };
    
    /** allocates a bignum by default.. */
    struct ssl_bignum : public ssl_wrapper<BIGNUM>
    {
        ssl_bignum() : ssl_wrapper(BN_new()) {}
        ~ssl_bignum() { BN_free(obj); }
    };

}



@end
