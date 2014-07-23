#lang pollen

◊h2{TPMs: A Practical Introduction}

◊p{For a long time, I held the view that the TPM was a tool of the
Illumi^wRIAA to enslave people's computers, remotely take them over,
and conduct other nefarious triangular business. As such, I duly
disabled them in my BIOS and moved on with my life.}

◊p{It turns out that TPMs aren't quite that. A TPM is essentially a
smart card that is connected to the LPC (low pin count) bus on a
motherboard, making it available at boot time. As part of the system
board, is designed to be always-present, unlike a smart card (which is
designed to be moved between systems). Just as a smart card is
designed to perform cryptographic operations for a person, the TPM
fills a similar role for the server.}

◊p{One common misconception I've heard about TPMs is that they're a
secure key storage system; while they can store keys, this sells short
what they're capable of. Here's the one-liner:}

◊p{◊em{A TPM is a hardware RSA cryptoprocessor (with an RNG) attached
to the system board.}}

◊p{TPMs can encrypt, decrypt, sign, verify, and provide a source of
random bits to the host machine. When the TPM performs a cryptographic
operation, the key doesn't leave the TPM. This is really the strength
of the TPM. This sounds really great, so why aren't TPMs used for
everything? I'm glad you asked. Here's a partial list of the TPM's
limitations:}

◊ul{

  ◊li{They are quite slow. On one test machine, I clocked an RSA
  encrypt using RSA-OAEP with a 2048 bit key securing 32 bytes of data
  at 2.25 ◊em{seconds}.}

  ◊li{Without jumping through a lot of hoops, the TPM can only sign in
  PKCS #1 v1.5 mode.}

  ◊li{A TPM has limited onboard key storage. If you need keys
  available at boot time (or don't have persistant storage for the
  keys, à la PXE boot), you're out of luck. (Persistant storage? I
  thought the TPM stored the keys in hardware? Hang on◊|md|we're
  getting to that.)}

  ◊li{The largest key size a TPM is required to support according to
  the specs is 2048 bits. This is fine in most cases, but there might
  be a case where you need something bigger. In this case, the TPM
  won't be useful (it doesn't make sense to secure a 4096-bit key with
  a 2048-bit key).}

}

◊p{How can the TPM store multiple keys with limited memory? How does
the system interact with the TPM? What keeps an attacker from
accessing the TPM when it's unlocked? These are some of the questions
that I tried to answer when I first got started.}
