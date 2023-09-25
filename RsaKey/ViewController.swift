//
//  ViewController.swift
//  RsaKey
//
//  Created by Mahmut İhsan Dal on 25.09.2023.
//
import UIKit
import CryptoKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let keyPair = try generateRSAKeyPair()
            print("Private Key: \(keyPair.privateKey)")
            print("Public Key: \(keyPair.publicKey)")

            let originalText = "Merhaba, dünya!"
            let originalData = Data(originalText.utf8)

            let encryptedData = try encryptDataWithPublicKey(data: originalData, publicKey: keyPair.publicKey)
            let decryptedData = try decryptDataWithPrivateKey(encryptedData: encryptedData, privateKey: keyPair.privateKey)

            if let decryptedText = String(data: decryptedData, encoding: .utf8) {
                print("Decrypted Text: \(decryptedText)")
            } else {
                print("Decryption failed.")
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func generateRSAKeyPair() throws -> (privateKey: SecKey, publicKey: SecKey) {
        let parameters: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw KeyPairError.failedToExtractPublicKey
        }
        return (privateKey, publicKey)
    }

    func encryptDataWithPublicKey(data: Data, publicKey: SecKey) throws -> Data {//veriyi genel anahtar kullanarak şifreler
        let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA256, data as CFData, nil)

        return encryptedData! as Data
    }

    func decryptDataWithPrivateKey(encryptedData: Data, privateKey: SecKey) throws -> Data {//şifrelenmiş veriyi özel anahtar kullanarak çöze
        var error: Unmanaged<CFError>?
        //şifre çözülür ve çözülen veri döndürülür.
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, encryptedData as CFData, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return decryptedData as Data
    }
}

enum KeyPairError: Error {
    case failedToExtractPublicKey
}
