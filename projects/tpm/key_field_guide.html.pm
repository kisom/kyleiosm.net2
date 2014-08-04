#lang pollen

◊h2{Keys, the TPM, and You}
◊h3['style: "text-align: center;"]{A field guide to how the TSS organises key material}

◊p{In order to understand how the TPM works, it helps to understand
where the keys fit into the system. Recall also that the maximum
guaranteed size of the SRK is 2048 bits; in every case where I've used
a TPM, I've used exclusively 2048-bit keys throughout the system, and
it may be safely assumed that the entire discussion here assumes
2048-bit keys.}

◊h3{Key types}

◊p{Keys in the TPM are organised hierarchically in a tree; the basic key types are}

◊ul{

  ◊li{◊strong{storage} keys are key encryption keys; they are used to
  ◊q{"wrap"} other keys.}

  ◊li{◊strong{binding} keys are encryption keys. Their algorithm
  (RSAES-OAEP or RSAES-PKCSV15) is set at key creation time and cannot
  be changed later.}

  ◊li{◊strong{signature} keys are used for signing, but you figured
  that out already, didn't you? Like binding keys, their algorithm
  type is set at key creation time and cannot be changed later.}

  ◊li{◊strong{identity} keys are a special (and complex) case of
  signature keys. I haven't done anything with these, opting instead
  to just use the signature keys for the same role.}

}

◊p{Every key in the TPM is part of a chain; signature, binding, and
identity keys must all be wrapped by a storage key. So what's at the
root of this chain? There is a special key, the ◊strong{Storage Root
Key} (SRK) that fills this role. One of the first things that has to
be done when initialising the TPM is to generate a new SRK.}

◊p{In the diagram below, we assume there are two applications that
want to use the TPM, and have their own separate keys. The key tree
might look like this:}

◊pre{
                            +---+                 
                            |SRK|                 
                            +---+                 
                           +     +                
                   +------+       +-----+         
        STORAGE    |APP 1 |       |APP 2|  STORAGE
          KEY      ++---+-+       +-+--++    KEY  
                    |   |           |  |          
               +----+   +----+  +---++ +----+     
               |BIND|   |SIGN|  |BIND| |SIGN|     
               +----+   +----+  +----+ +----+     

}

◊p{Both applications have a storage key with the SRK as their
parent. Each of these application storage keys has a pair of keys
below it: one for signatures, and one for encryption. More complex
hierarchies are possible; maybe application 1 has multiple
sub-applications that each get a storage key with binding and signing
keys.}

◊p{Binding keys can actually serve two closely-related functions:
◊strong{binding} and ◊strong{sealing}. Binding is a straightforward
encryption using the binding key. If you recall from the previous
article, the TPM has a number of PCRs that can be used to measure the
state of the system; sealing ties the ciphertext to a PCR state so
that the plaintext can only be decrypted when the TPM is a known
state.}

◊h3{Keys and memory}

◊p{There are different kinds of storage memory that a key can live in,
as well. First, there is the distinction between ◊strong{migrateable}
and ◊strong{non-migrateable} keys. Migrateable keys support migrating
the private key off the TPM; non-migrateable keys cannot leave the
TPM. There is also a notion of ◊strong{volatile} and
◊strong{non-volatile} memory. Keys in volatile memory will unloaded
when the TPM powers up; a key that is used for booting, for example,
might be stay in the TPM's memory through a powercycle, particularly
if persistent storage will not be available at boot time.}

◊p{Looking back at our example system, how are the two different
binding keys distinguished? All keys in the TPM are identified by what
is termed a UUID. Technically, they are of the type ◊code{TSS_UUID},
which are defined as}

◊pre{
typedef struct tdTSS_UUID 
{
    UINT32  ulTimeLow;
    UINT16  usTimeMid;
    UINT16  usTimeHigh;
    BYTE    bClockSeqHigh;
    BYTE    bClockSeqLow;
    BYTE    rgbNode[6];
} TSS_UUID;
}

◊p{It's helpful to know that a ◊code{BYTE} is a ◊code{typedef} for
◊code{uint8_t} in Trousers. When I was working with applications using
the TPM, I found it useful to treat UUIDs as ◊code{uint8_t uuid[16]}
(where 16 is the size of a UUID; if you add up the sizes of the
members of the ◊code{TSS_UUID}, you'll find they sum up to 16 bytes).
There is only one pre-defined UUID, and that is ◊code{TSS_UUID_SRK},
which is ◊code{00000000-0000-0000-0000-000000000001}.}

◊p{So, perhaps application 1's storage key has the UUID
◊code{f5100a2e-bdc0-e465-6fd5-a433c9f9fc0e}, the binding key has the
UUID ◊code{38567a18-460f-6734-e389-8d7f42c365a8}, and the signature
key has the UUID ◊code{c039f95d-fab3-76f4-c9e3-1bf5af1e4ada}. In order
to use a key, it's parent must be loaded first. So, in order to use
the binding key above, the SRK must be loaded first, followed by the
application storage key ◊code{f5100a2e-bdc0-e465-6fd5-a433c9f9fc0e},
and finally the binding key
◊code{38567a18-460f-6734-e389-8d7f42c365a8}.}

◊h3{Key secrets}

◊p{Of course, having any key immediately available without some means
of explicit authorisation besides being on the machine is
useful. Notably, there are two main secrets guarding the TPM: the
◊q{"owner"} and SRK secrets (and by secrets, I mean passwords◊|md|the
TCG calls them secrets, though). For applications where just
possessing the machine is enough authorisation, there is a so-called
◊strong{well-known secret} (which is 20 bytes of all zeroes). It may
also be the case that unlocking the SRK should grant access to all of
the keys to a user; in this case, it makes sense to require an SRK
secret but not require any secrets on subsequent keys. In order to any
key on the TPM, the SRK must be loaded, so this still requires an
unlock of the SRK. Alternatively, it might make sense instead for each
application storage key to require a secret; once the application key
is unlocked, the application has to pay less attention to the fact
that signatures and decryption are done with different keys. The
threat and security models for the system will drive the choice here.}

◊p{In terms of the TCG's roles, if your TPM owner and user are the
same entity, having a secret for the SRK and no secret on the keys
(that is, to use the keys requires the SRK to be unlocked, but that's
it), might make sense. If they're separate, it might be better to have
the SRK use the SRK well-known secret and have each user's keys
protected by a secret. Not all of the user keys need have secrets
either; if a user is an automated (d◊|ae|mon) account, perhaps its
authentication is done via other means and having access to the
persistent storage on disk is access enough.}

◊h3{Binding}

◊p{I said that binding was a straight-forward encryption operation,
but it's not quite. In a later installment where I go more in depth on
how to actually bind, I'll explain it further, but for now you should
know that there is a five-byte header that's required
(◊code{0101000002}) for the plaintext.}

◊h3{Key storage}

◊p{There are three places that keys can be stored:}

◊ul{

  ◊li{◊strong{NVRAM}: space here is rather limited, so only keys that
  should be available when the other storage places are unavailable
  should be here. It might also require some creativity in storing the
  keys (perhaps only storing the key's private exponent)}

  ◊li{◊strong{System persistent storage}: this uses the mass storage
  available on the platform to store keys; on Ubuntu, this is
  ◊code{/var/lib/tpm/system.data}. Keys here are available to all
  users of the system.}

  ◊li{◊strong{User persistent storage}: this also uses the mass
  storage on the platform, but keys are only available to the user
  that created them (and possible the platform administrator, as
  well). On Ubuntu, these keys are stored in
  ◊code{$HOME/.trousers/user.data}.}

}

◊p{It might seem that the persistent storage keys are actually
migrateable: why not just copy the keys off disk and use them
elsewhere? Recall that all keys exist in a hierarchy under the SRK;
the SRK being a storage key means that keys stored under directly it
are ◊strong{wrapped} (or encrypted) with the SRK. In our previous
example, the binding is wrapped with its parent application storage
key, which is then wrapped with the SRK (which is why the chain must
be followed to load a key). As the SRK doesn't leave the TPM, these
keys cannot be feasibly unwrapped on another machine without breaking
RSA. There are migrateable keys that support being moved between
machines, but I've always opted to generate such keys outside the TPM
and secure them with a TPM key to avoid having to jump through any
hoops and to maintain the expectation that TPM keys stay with the
TPM.}

◊h3{The endorsement key}

◊p{I haven't mentioned the ◊strong{endorsement key} (EK) yet. This key
falls outside the key hierarchy, and has a different purpose than the
keys under the SRK.}

◊p{Generally, an endorsement key is generated in the TPM by the
manufacturer. It used to ◊strong{endorse} other keys to prove that
they came from a TPM. If the manufacturer's EK is used, it should come
with a certificate from the manufacturer proving its veracity. Without
a manufacturer certificate, it is impossible to prove the key actually
came from a TPM, except perhaps in the case of centrally-managed
TPMs. If all the TPMs belong to a central organisation, and if, on
provisioning, the TPM sends out its endorsement key, there is a
measure of trust to be had in the key using this centralised PKI. This
just shifts the burden of PKI from the manufacturer to the
organisation, and shouldn't be considered lightly.}

◊p{◊small{Published: 2014-07-24◊br{}Last update: 2014-08-03}}

◊p{◊small{Up next: ◊link["know_your_enemy.html"]{Know your enemy}:
threat modeling with the TPM.}}

◊p{◊small{◊link["index.html"]{Adventures in Trusted Computing}}}
