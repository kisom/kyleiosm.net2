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

◊p{}
