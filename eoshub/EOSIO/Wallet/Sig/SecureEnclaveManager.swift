import Foundation
import Security



struct public_key_data {
    var data = [UInt8](repeating: 0x00, count: 33)
}

class SecureEnclaveManager {

    class func generateKeyPair(privateKeyLabel: String, accessControl: SecAccessControl) -> String? {
        
        let privateKeyParams: [String: Any] = [
            kSecAttrLabel as String: privateKeyLabel,
            kSecAttrIsPermanent as String: true,
            kSecAttrAccessControl as String: accessControl,
            ]
        
        let params: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: privateKeyParams
        ]
    
        guard let privateKey = SecKeyCreateRandomKey(params as CFDictionary, nil) else { return nil }
        
        guard let pub = getPublicKey(key: privateKey) else { return nil }
        
        return pub
    }
    
    class func accessControl(with protection: CFString = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags: SecAccessControlCreateFlags = [.biometryAny, .privateKeyUsage]) -> SecAccessControl?{
        
        var accessControlError: Unmanaged<CFError>?
        
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &accessControlError)
        
        guard accessControl != nil else {
            return nil
        }
        
        return accessControl!
    }
    
    class func trySignDigest(digest: Data, privateKeyLabel: String) -> String? {
        guard let priKey = getPrivateKey(label: privateKeyLabel) else {
            Log.e("cannot find private key with this label: \(privateKeyLabel)")
            return nil
        }
        
        return trySignDigest(d: digest, private_key: priKey)
    }
    
    
    
    //MARK: private 
    
    private class func getPrivateKey(label privateLabel: String) -> SecKey? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrLabel as String: privateLabel,
            kSecReturnRef as String: true,
            kSecUseOperationPrompt as String: "Authenticate to sign transaction",
            ]
        
        let raw = getSecKeyWithQuery(query)
        return raw
    }
    
    private class func getSecKeyWithQuery(_ query: [String: Any]) -> SecKey? {
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            Log.e("Could not get key for query: \(query)")
            return nil
        }
        
        return (result as! SecKey)
    }
    

    
    private class func trySignDigest(d: Data, private_key: SecKey) -> String? {
        
        guard let sig = ECDSA_SIG_new() else {
            Log.e("cannot create sig")
            return nil
        }
        
        let r = BN_new()
        let s = BN_new()
        
        var error: Unmanaged<CFError>? = nil
        
        guard let digestData = CFDataCreateWithBytesNoCopy(nil, Array(d), d.count, kCFAllocatorNull) else {
            Log.e("cannot create digest")
            return nil
        }
        
        guard let signature = SecKeyCreateSignature(private_key, SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256, digestData, &error) else {
            Log.e("Failed to sign digest in Secure Enclave 0")
            if error != nil {
                print("\(String(describing: error))")
                error?.release()
            }
            return nil
        }
        
        
        
        guard let der_bytes = CFDataGetBytePtr(signature) else {
            return nil
        }
        
        BN_bin2bn(der_bytes + 4, Int32(der_bytes[3]), r)
        BN_bin2bn(der_bytes + 6 + Int(der_bytes[3]), Int32(der_bytes[Int(4+der_bytes[3]+1)]), s)
        
        
        BN_clear_free(sig.pointee.r)
        BN_clear_free(sig.pointee.s)
        sig.pointee.r = r
        sig.pointee.s = s
        
        
        guard let kd = getPublicKeyData(privateKey: private_key) else {
            Log.e("Failed to get pub key dta")
            return nil
        }
        
        
        let key = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1)
        
        let pubData = Data(bytes: kd.data)
        let digest = d
       
        guard let compact_sig = R1Key().signature_from_ecdsa(with: key, pub_data: pubData, sig: sig, digest: digest) else {
            Log.e("cannot create compact sig")
            return nil
        }
        
        print(compact_sig)
        
        return compact_sig
    }
    
    private class func getPublicKeyData(privateKey: SecKey) -> public_key_data? {
        guard let pubKey = SecKeyCopyPublicKey(privateKey) else { return nil }
        
        var error: Unmanaged<CFError>?
        
        let keyrep = SecKeyCopyExternalRepresentation(pubKey, &error)
        
        var pub_key_data = public_key_data()
        
        if error == nil, let cfdata = CFDataGetBytePtr(keyrep) {
            let data = Array(Data(bytes: cfdata, count: 65))
            pub_key_data.data.replaceSubrange(1...32, with: data[0...31])
            pub_key_data.data[0] = 0x02 + (data[64] & 1)
            return pub_key_data
        } else {
            error?.release()
            return nil
        }
    }
    
    private class func getPublicKey(key: SecKey) -> String? {
        var serialized_pub_key = [UInt8](repeating: 0x00, count: 34)
        serialized_pub_key[0] = 0x01
        
        guard let pub_key_data = getPublicKeyData(privateKey: key) else { return nil }
        serialized_pub_key.replaceSubrange(1...33, with: pub_key_data.data)
        
        let serialized_pub_key_data = Data(bytes: serialized_pub_key[1...33])
        
        let eosKey = R1Key().getEOSPublicKey(withR1Data: serialized_pub_key_data)
        
        return eosKey
    }
    
   
    
    private class func forceSavePublicKey(publicKey: SecKey, label: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag as String: label,
            kSecValueRef as String: publicKey,
            kSecAttrIsPermanent as String: true,
            kSecReturnData as String: true,
            ]
        
        var raw: CFTypeRef?
        var status = SecItemAdd(query as CFDictionary, &raw)
        
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, &raw)
        }
        
        return status == errSecSuccess
        
    }
    
}


