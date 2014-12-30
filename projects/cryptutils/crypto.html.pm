#lang pollen

◊h2{Cryptography in the cryptutils}

◊p{The ◊code{common} subpackage contains the cryptographic packages.}

◊ul{

  ◊li{◊link["https://github.com/kisom/cryptutils/blob/master/common/secret/"]{◊code{common/secret}}
  contains the secret key code.}

  ◊li{◊link["https://github.com/kisom/cryptutils/blob/master/common/public/"]{◊code{common/public}}
  contains the public key code.}

}

◊h3{Principles}

◊p{These are the basic principles guiding the cryptography in these
programs.}

◊ol{

  ◊li{NaCl is used for most cryptographic primitives.}

  ◊li{Ed25519 should be used for digital signatures.}

  ◊li{SHA-256 may be used to generate an identifier for data, though
  this is only used in the experimental public key programs as a key
  identifier.}

  ◊li{Random nonces should be generated for each new message. The
  nonce is prepended to the ciphertext.}

  ◊li{Scrypt should be used to derive symmetric keys from
  passphrases. Passphrases are UTF-8 encoded octet strings. The salt
  is a randomly-generated 32-byte octet string; the salt will be
  prepended to any data encrypted using a passphrase. The Scrypt
  parameters are N=32768, r=8, p=4 to provide a high cost for deriving
  symmetric keys.}

  ◊li{The operating system's PRNG (on Linux, this is
  ◊code{/dev/urandom}) is used as the source of randomness.}

  ◊li{Cryptographic operations return boolean success indicators: the
  cause of the error is not returned.}

}

◊h3{Symmetric cryptography}

◊p{Symmetric cryptography uses NaCl's secretbox, which means XSalsa20
and Poly1305. Plaintext is encrypted as such:}

◊ol{

  ◊li{A 24-byte nonce for the message is randomly generated.}

  ◊li{The message is encrypted with the key.}

  ◊li{The resulting ciphertext is appended to the nonce.}

}

◊p{Files are encrypted similarly, but the package only provides
functions for encrypting and decrypting using passphrases.}

◊ol{

  ◊li{The user presents a file path, a UTF-8-encoded passphrase, and
  an octet string containing the plaintext.}

  ◊li{A random, 32-byte salt is generated.}

  ◊li{This newly-generated salt and the passphrase are sent to Scrypt
  (N=32768, r=8, p=4) to generate a 32-byte secretbox key.}

  ◊li{The plaintext is encrypted as per the previous section.}

  ◊li{The ciphertext is appended to the salt, and the resulting octet
  string is written to disk to the path requested.}

}

◊h3{Public-key cryptography}

◊p{The public-key cryptography used in these programs employ the
following key structure:}

◊pre{
type PrivateKey struct {
    // Curve25519
    D   *[32]byte // Decryption key (encryption private key).
    // Ed25519
    S   *[64]byte // Signature key (signing private key).
    *PublicKey
}

type PublicKey struct {
    // Curve25519
    E   *[32]byte // Encryption key (encryption public key).
    // Ed25519
    V   *[32]byte // Verification key (signing public key).
}
}

◊p{These keys are passed around as octet strings, where the private
key packs the ◊code{D}, ◊code{S}, ◊code{E}, and ◊code{V} values in;
public keys pack in the ◊code{E} and ◊code{V} values in. Packing is
done by appending the values to each other.}

◊p{Encryption is done as follows:}

◊ol{

  ◊li{An ephemeral Curve25519 key pair is generated.}

  ◊li{The ephemeral key pair is used to perform a key exchange with
  the peer's public key. The private key is then discarded.}

  ◊li{The key exchange produces a symmetric key, and the plaintext is
  encrypted as in the symmetric section.}

  ◊li{The resulting ciphertext is appended to the ephemeral public
  key.}

}

◊p{There is an encrypt-and-verify operation that expects a signature
to be appended to the plaintext. There is currently no way to
distinguish between a signed and unsigned message. The
encrypt-and-sign is done exactly as encryption, except that the
message is signed prior to encryption and this signature is appended
to the message. Signatures are a fixed size (64 bytes), so the
decrypt-and-verify decrypts the message, then verifies the plaintext
is large enough to have a signature and uses the final 64 bytes as the
signature.}
