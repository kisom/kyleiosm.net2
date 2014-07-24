#lang pollen

◊h2{Keys, the TPM, and You}
◊h3['style: "text-align: center;"]{a field guide to how the TSS organises key material}

◊p{In order to understand how the TPM works, it helps to understand
where the keys fit into the system.}

◊h3{Key types}

◊p{Keys in the TPM are organised hierarchically in a tree; the basic key types are}

◊ul{

  ◊li{◊strong{storage} keys are key encryption keys; they are used to
  ◊q{"wrap"} other keys.}

  ◊li{◊strong{binding} keys are encryption keys.}

  ◊li{◊strong{signature} keys are used for signing, but you figured
  that out already, didn't you?}

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
below it: one for signatures, and one for encryption.}

◊p{Binding keys can actually serve two closely-related functions:
◊strong{binding} and ◊strong{sealing}. Binding is a straightforward
encryption using the binding key. If you recall from the previous
article, the TPM has a number of PCRs that can be used to measure the
state of the system; sealing ties the ciphertext to a PCR state so
that the plaintext can only be decrypted when the TPM is a known
state.}

◊h3{Keys and Memory}

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
which is ◊code{00000000000000000000000000000001}.}

◊p{So, perhaps application 1's storage key has the UUID
◊code{f5100a2ebdc0e4656fd5a433c9f9fc0e}, the binding key has the UUID
◊code{38567a18460f6734e3898d7f42c365a8}, and the signature key has the
UUID ◊code{c039f95dfab376f4c9e31bf5af1e4ada}.}
