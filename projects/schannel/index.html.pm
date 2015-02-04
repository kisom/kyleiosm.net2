#lang pollen

◊h2{S/Channel}
◊h3['style: "text-align: center;"]{Secure channels over TCP/IP}

◊ul{
  ◊li{◊link["https://github.com/kisom/go-schannel/"]{Go package on Github}}

  ◊li{◊link["https://github.com/kisom/libschannel/"]{C library on Github}}

  ◊li{◊link["/downloads/schannel/libschannel.pdf"]{C library manual}}

  ◊li{◊link["/downloads/schannel/libschannel-1.0.1.tar.gz"]{C library version 1.0.1 release tarball}
      (◊link["/downloads/schannel/libschannel-1.0.1.tar.gz.sig"]{signature})}

 }

◊p{While working on another project (building an HSM using the
◊link["https://inverse-path.com/usbarmory/"]{usbarmory}), I realised I
needed a secure channel overlaid on top of a TCP network. I wanted to
avoid the overhead of doing this with TLS, so I began to think about
how to go about doing this. I remembered the secure channel section of
◊emph{Cryptography Engineering}, and made sure the properties of this
software would match the properties given there.}

◊p{A secure channel has the following properties:}

◊ol{

  ◊li{A bi-directional channel has separate keys for each direction.}

  ◊li{Send and receive counters to prevent replayed messages; these
      message counters will be reset whenever the keys change.}

  ◊li{A regressed message counter is considered a decryption failure.}

  ◊li{The channel transmits discrete messages, and doesn't operate as
      a stream.}

  ◊li{New keys are generated for each channel.}

  ◊li{An eavesdropper can still perform traffic analysis to note when
     and how often the two sides communicate, and will be able to
     observe the size of the messages.}

}

◊p{There are three different types of keys that are used in this system;
users of this system need only worry about one of them. These three
key types are:}

◊ul{

  ◊li{◊strong{Identity} keys: these are signature keys used to
      identify peers. S/Channel uses
      ◊link["http://ed25519.cr.yp.to/"]{Ed25519} key pairs for
      identity. Users will need to supply a private key to sign
      the key exchange, and a public key that should be used to
      verify the key exchange. The initial key exchange is signed
      to provide authenticity. After this initial exchange, key
      rotation does not need to be signed as authenticity has
      already been provided.}

  ◊li{◊strong{Key exchange} keys: these are randomly generated at the
      start of each session and every time keys are rotated.  These
      keys are only used in the key exchange, and are wiped once the
      key exchange is complete. S/Channel currently uses a pair of
      ◊link["http://cr.yp.to/ecdh.html"]{Curve25519} keypairs for the
      key exchange, one pair per shared key.}

  ◊li{◊strong{Shared} keys: these are the symmetric encryption keys
      that are used for securing traffic. Each side has separate send
      and receive keys; once the initial session is established, all
      traffic is encrypted. These keys are computed from the key
      exchange ECDH operation; S/Channel currently uses the
      ◊link["http://nacl.cr.yp.to/"]{NaCl} secretbox module to provide
      symmetric security.}

}

◊h4['style: "text-align: center;"]{Key exchange high-level overview}

◊p{For this discussion, the ◊strong{client} is the peer that initiates
the secure channel, and ◊strong{server} is the other peer. They are
so-named because the corresponding functions are called ◊|oq|dial◊|cq|
and ◊|oq|listen◊|cq|. It is assumed both sides have set up a TCP
connection, e.g. using ◊code{connect(2)} and ◊code{accept(2)}.}

◊ol{

  ◊li{Both sides generate their key exchange pair. If a peer has an
      identity key, it will sign its keypair. Otherwise, an empty
      signature is used; this is the tuple
      ◊code{k◊sub{pub,1}||◊code{k◊sub{pub,2}}||signature}.}

  ◊li{The client sends its key exchange tuple to the server.}

  ◊li{The server receives the tuple, and verifies the signature as
  appropriate.}

  ◊li{The server now sends its tuple.}

  ◊li{The client receives this tuple, and verifies the signature as
      appropriate.}

  ◊li{Both sides can now compute their shared keys. The client
      computes its send key as
      ◊code{ECDH(k◊sub{priv,1},k◊sub{peer,1})}, and its receive key as
      ◊code{ECDH(k◊sub{priv,2},k◊sub{peer,2})}. The server necessarily
      reverses the order: its send key is computed as
      ◊code{ECDH(k◊sub{priv,2},k◊sub{peer,2})}, and its receive key as
      ◊code{ECDH(k◊sub{priv,1},k◊sub{peer,1})}.}

  ◊li{The secure channel is established and both sides can exchange
      messages.}

  ◊li{If at some point, one side determines that a key rotation is
      needed, the same basic steps are followed without the
      signatures. Key rotations are signaled via a key exchange message.}

}

◊h4['style: "text-align: center;"]{Message security}

◊p{Once the channel is established, all traffic will be authenticated
and encrypted. Messages are wrapped in an envelope before encryption
that pairs the message with a format version, sequence number, and
message type. The message type is used to provide additional messages
for managing the secure channel: the ◊strong{normal} message type is
used for all messages sent from one side to the other. A ◊strong{key
exchange} message triggers a key rotation, and a ◊strong{shutdown}
message signals the other side that the secure channel is being
closed.}
