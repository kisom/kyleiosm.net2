#lang pollen

◊h2{Entropy Sharing}

◊p{For running small single-purpose applications, I tend to fire up
new ◊link["https://digitalocean.com"]{Digital Ocean} VPSes. However,
VPSes tend to have poor and disfunctional PRNGs. I needed a way to get
entropy from a higher-quality PRNG to these VPSes, particularly since
one runs an instance of
◊link["https://github.com/cloudflare/cfssl/"]{◊code{cfssl}} ◊q{that's}
used for generating keys.
Fortunately, the CryptoCape has a TPM with a HWRNG, and several
other fun hardware crypto chips that can be mixed into the operating
system PRNG, and this can be used to my advantage.}

◊p{I ended up building a system to use the CryptoCape and a Beaglebone
to distribute randomness to the VPSes, which run a server program (the
"◊strong{sink}") that listens for incoming connections; the BBB runs a
d◊|ae|mon (the ◊|oq|◊strong{source}◊|cq|) that periodically (every six hours)
sends a packet of random data to the VPSes. The BBB has a signing RSA
key, which I plan on migrating to a TPM signature key later, and each
VPS has a Curve25519 key pair to which entropy packets are encrypted.}

◊p{The randomness packets are defined as}

◊pre{
packet ::= SEQUENCE {
       timestamp INTEGER        -- int64
       counter   INTEGER        -- int64
       chunk     OCTET STRING   -- [1024]byte
}
}

◊p{When the ◊strong{source} prepares a new randomness packet, it signs
the packet with its signature key, generates an ephemeral encryption
keypair, and encrypts the packet to the appropriate sink. Naturally, a
new packet is prepared for each sink that the source is tracking. A
16-bit unsigned integer indicating the length of the packet is written
to the sink first, followed by the encrypted packet. The sink decrypts
the packet and checks its signature, ensures the counter ◊q{hasn't}
regressed, and verifies that the timestamp is within an acceptable
drift range. If all goes well, the chunk of randomness is written to
the system PRNG. A packet containing 1K of random data is serialised
to 1041 bytes; after being signed and encrypted, it is 1381 bytes.}

◊p{The source runs a copy of the
◊link["https://github.com/gokyle/gofortuna"]{Fortuna} PRNG, stirring
in entropy occasionally from the system PRNG and the TPM. In the
future, ◊q{I'd} like to add a Fortuna source that reads data from the
ATSHA204 on the cape.}

◊p{The first proof-of-concept version of this code is
◊link["https://github.com/kisom/entropysharing"]{available on Github}.
This proof of concept works, but there are some improvements
planned:}

◊ul{

  ◊li{The code is a first pass, mashing together a few other projects,
  and the code could do with some serious cleaning.}

  ◊li{The sinks should use TLS-protected HTTPS endpoints with client
  authentication.}

  ◊li{The TPM should be used for packet signatures.}

  ◊li{The ATSHA204 should be used as another source of entropy.}

}

◊p{◊small{Back to ◊link["index.html"]{CryptoCape projects}.}}
