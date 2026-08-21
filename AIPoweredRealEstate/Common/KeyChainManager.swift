//
//  KeyChainManager.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import Foundation
import Security

class KeyChainManager{
    //security framework provides 4 api save, gte,delete and update
    
    static let shared = KeyChainManager()
   
    func saveValue(value:String,key:String) -> Bool{
       
        guard let data = value.data(using: .utf8)else{
            return false
        }
        
        let query:[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String:key,
            kSecValueData as String:data
        ]
        
        //remove existing value
        SecItemDelete(query as CFDictionary)
        
        //save new value
        let sts = SecItemAdd(query as CFDictionary, nil)
        
        return sts == errSecSuccess
    }
    
    func getValue(key:String)->String?{
        
        let query:[String:Any] = [
            kSecClass as String:kSecClassGenericPassword,
            kSecAttrAccount as String:key,
            kSecReturnData as String:true,
            kSecMatchLimit as String:kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        
        let sts = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard  sts == errSecSuccess , let data = result as? Data else{
            return nil
        }
        
        return String(data:data,encoding: .utf8)
        
    }
    
}





/*
 import Foundation
 import Security

 final class KeychainManager {

     static let shared = KeychainManager()

     private init() {}

     func save(
         value: String,
         forKey key: String
     ) -> Bool {

         guard let data = value.data(using: .utf8) else {
             return false
         }

         let query: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: key,
             kSecValueData as String: data
         ]

         // Existing value ko remove karo
         SecItemDelete(query as CFDictionary)

         // New value save karo
         let status = SecItemAdd(
             query as CFDictionary,
             nil
         )

         return status == errSecSuccess
     }

     func get(forKey key: String) -> String? {

         let query: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: key,
             kSecReturnData as String: true,
             kSecMatchLimit as String: kSecMatchLimitOne
         ]

         var result: AnyObject?

         let status = SecItemCopyMatching(
             query as CFDictionary,
             &result
         )

         guard status == errSecSuccess,
               let data = result as? Data else {
             return nil
         }

         return String(data: data, encoding: .utf8)
     }

     func delete(forKey key: String) {

         let query: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccount as String: key
         ]

         SecItemDelete(query as CFDictionary)
     }
 }
 */
