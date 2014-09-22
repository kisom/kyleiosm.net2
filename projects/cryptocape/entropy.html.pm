#lang pollen

◊h2{Entropy Sharing}

◊p{For running small single-purpose applications, I tend to fire up
new ◊link["https://digitalocean.com"]{Digital Ocean} VPSes. However,
VPSes tend to have poor and disfunctional PRNGs. I needed a way to get
entropy from a higher-quality PRNG to these VPSes, particularly since
once runs an instance of
◊link["https://github.com/cloudflare/cfssl/"]{◊code{cfssl}} that's
used for generating keys.}

◊p{Fortunately, the CryptoCape has a TPM with a HWRNG, and several
other fun hardware crypto chips that can be mixed into the operating
system PRNG.}

◊p{I ended up building a system to do this. The VPSes run a server
program (the "◊strong{sink}") that listens for incoming connections,
and the BBB runs a d◊|ae|mon (the "◊strong{source}") that periodically
(every six hours, in my case) sends a packet of random data to the
VPSes. The BBB has a signing RSA key, which I plan on migrating to a
TPM signature key later, and each VPS has an RSA key pair to which
entropy packets are encrypted.}

◊p{The randomness packets are defined as}

◊pre{
packet ::= SEQUENCE {
       timestamp INTEGER        -- int64
       counter   INTEGER        -- int64
       chunk     OCTET STRING   -- [256]byte
}
}

◊p{When the ◊strong{source} prepares a new randomness packet, it signs
the packet with its signature key, then encrypts the packet to the
appropriate sink. Naturally, a new packet is prepared for each sink
that the source is tracking. A 16-bit unsigned integer indicating the
length of the packet is written to sink first, followed by the
encrypted packet. The source ensures the counter hasn't regressed,
that the timestamp is within an acceptable drift range, and then
decrypts and verifies the signature on the packet. If all goes well,
the chunk of randomness is written to the system PRNG.}

◊p{The source runs a copy of the
◊link["https://github.com/gokyle/gofortuna"]{Fortuna} PRNG, stirring
in entropy occasionally from the system PRNG and the TPM. In the
future, I'd like to add support for reading data from the ATSHA204.}

◊p{The first proof-of-concept version of this code is
◊link["https://github.com/kisom/entropysharing"]{available on Github}.}

◊p{◊small{Back to ◊link["index.html"]{CryptoCape projects}.}}
