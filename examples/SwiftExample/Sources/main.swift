import Foundation
 import UniFFI

print("hello world")

let jwk = UniFFI.Jwk(alg: "ES256K", kty: "EC", crv: "secp256k1", d: "P3hRuve79GaggsVdQG_w-JpdM6dHXG33-1nwZ8Jw07g", x: "vA8umEbOhhQjFfk1-byvVxtJNRtwQSEE0UMVmxSN9K4", y: "A1qGUBx-wpznzVI0DLu8kEhDZ77ou533NKSCw90R33Q")
print(jwk)

let thumbprint = try UniFFI.computeThumbprint(jwk: jwk)
print("Thumbprint: \(thumbprint)")

let ed25519Jwk = try UniFFI.ed25519Generate()
let ed25519Thumbprint = try UniFFI.computeThumbprint(jwk: ed25519Jwk)
print("Thumbprint (Ed25519): \(ed25519Thumbprint)")

let payload = Data("hello world".utf8)
let signature = try UniFFI.ed25519Sign(privateJwk: ed25519Jwk, payload: payload)
print("Signature: \(signature.base64EncodedString())")

try UniFFI.ed25519Verify(publicJwk: ed25519Jwk, payload: payload, signature: signature)
print("verify() passed as expected")

do {
    try UniFFI.ed25519Verify(publicJwk: ed25519Jwk, payload: payload, signature: Data("invalid sig".utf8))
} catch {
    print("verify() failed as expected")
}

let keyManager = UniFFI.LocalJwkManager()
let keyAlias = try keyManager.generatePrivateKey(curve: Curve.ed25519, keyAlias: nil)
print("key alias \(keyAlias)")
let publicKey = try keyManager.getPublicKey(keyAlias: keyAlias)
print("public key \(publicKey)")
let signature2 = try keyManager.sign(keyAlias: keyAlias, payload: payload)
try UniFFI.ed25519Verify(publicJwk: publicKey, payload: payload, signature: signature2)
print("signed & verified \(signature2.base64EncodedString())")
let privateKeys = try keyManager.exportPrivateKeys()
print("private keys \(privateKeys)")
try keyManager.importPrivateKeys(privateKeys: privateKeys)
print("imported private keys")

let identifier = try UniFFI.identifierParse(didUri: "did:example:123456789abcdefghi;foo=bar;baz=qux?foo=bar&baz=qux#keys-1")
print(identifier)

let verificationMethod = UniFFI.VerificationMethod(id: "did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImRKZ3VIWDF0QTZORlRnWlU0ZkUzZkNTTEVnSlI2NU9EOC1uM1JmYjVaMlkifQ#0", type: "JsonWebKey", controller: "did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImRKZ3VIWDF0QTZORlRnWlU0ZkUzZkNTTEVnSlI2NU9EOC1uM1JmYjVaMlkifQ", publicKeyJwk: jwk)
let document = UniFFI.Document(id: "did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImRKZ3VIWDF0QTZORlRnWlU0ZkUzZkNTTEVnSlI2NU9EOC1uM1JmYjVaMlkifQ", context: ["https://www.w3.org/ns/did/v1"], controller: nil, alsoKnownAs: nil, verificationMethod: [verificationMethod], authentication: [verificationMethod.id], assertionMethod: [verificationMethod.id], keyAgreement: [verificationMethod.id], capabilityInvocation: [verificationMethod.id], capabilityDelegation: [verificationMethod.id], service: nil)
print(document)

let keySelector1 = UniFFI.KeySelector.keyId(keyId: verificationMethod.id)
let verificationMethod2 = try UniFFI.getVerificationMethod(document: document, keySelector: keySelector1)
print(verificationMethod2)

let keySelector2 = UniFFI.KeySelector.methodType(methodType: UniFFI.VerificationMethodType.authentication)
let verificationMethod3 = try UniFFI.getVerificationMethod(document: document, keySelector: keySelector2)
print(verificationMethod3)
