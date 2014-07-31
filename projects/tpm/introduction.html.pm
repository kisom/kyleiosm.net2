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
of the TPM. They also have special volatile memory locations called
◊strong{Platform Configuration Registers} (PCR), which store a SHA-1
hash of the data that has been written to them. They basically provide
a means for ensuring the TPM is in a known state. I know this all
sounds really great, so why aren't TPMs used for everything? I'm glad
you asked. Here's a partial list of the TPM's limitations:}

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

  ◊li{The TPM specification does not provide for a real-time clock.}

}

◊p{The TPM specification was written by the ◊strong{Trusted Computing
Group} (TCG). What were their goals when designing the TPM? Why did
they make them so limited? The primary design goal was to provide
smartcard-like capabilities in a hardware package that would be
affordable, and would fit the majority of users' security
requirements. For reference, when I looked on a couple of online
stores, a TPM retailed for less than 20 USD◊|md|between 16 and 19 USD,
actually. There are attacks that can be done on a TPM if an attacker
has access to the hardware, but these mostly apply to hardware that is
in an attacker's hands for an appreciable length of time. A proper
security model will take this into account; we'll discuss the attacks
later, but a rule of thumb is that if a server unexpectedly goes down,
the TPM should be inspected, and if it's gone down for a while the TPM
should be treated as untrusted and replaced.}

◊p{The actual security goals of the TPM are ensuring platform
integrity through secure boot, some measure of ◊strong{remote
attestation}◊|md|the ability for a remote system to cryptographically
identify itself to some other machine◊|md|and finally, decryption and
signature operations limited to specific machine (and to some extent,
a specific user on the machine). When the TPM is used in concert with
other security mechanisms (such as code signing, sandboxing, process
confinement, and so forth), it's useful in building robust secure
systems. Keep in mind that the TPM is designed as a ◊strong{low-cost}
cryptoprocessor. There are only so many threats that it can defend
against; if you're going up against a powerful, determined adversary
(normally I'd use the example of a James Bond supervillain, but things
are getting out of hand with certain governments, so let's go with
that), it just won't be able to provide that level of security. For
example, on servers, the TPM is often a small PCB that plugs into a
header. This might be epoxied, but at the end of the day, a skilled
attacker can circumvent this. There are attacks that can be
successfully carried out when the attacker has access to the system
board and can get the system to reboot and authenticate. You get what
you pay for.}

◊p{The TCG has defined a number of roles in what value the TPM should
bring:}

◊ul{

  ◊li{◊strong{TPM owner}: the owner of the platform with the TPM}

  ◊li{◊strong{TPM user}: some entity that can use the objects
  (i.e. keys) in the TPM}

  ◊li{◊strong{Platform administrator}: the entity that controls the
  operating system, file system, data, etc◊|etc|}

  ◊li{◊strong{Platform user}: an entity that is allowed the use of
  data or resources on the platform}

  ◊li{◊strong{Operator}: the person physically present at the console
  of the platform}

  ◊li{◊strong{Public}: entities that can perform some operation on the
  platform's operating syste, file system, data, ◊|etc| without
  authentication or identity}

}

◊p{When these roles pop up in this documentation, remember that they
have specific meaning.}

◊p{How can the TPM store multiple keys with limited memory? How does
the system interact with the TPM? What keeps an attacker from
accessing the TPM when it's unlocked? These are some of the questions
that I tried to answer when I first got started.}

◊p{The physical TPM is only the tip of the iceberg; as a low-cost
processor, it's slow and not guaranteed to be multi-threaded. The TCG
specification dictates that the TCG device driver layer (TDDL) is the
operating system interface to the TPM. The specifications also dictate
the existence of the user-space TCG core service d◊|ae|mon (TCSD),
which ◊|oq|◊strong{should} be the only portal to the TPM device
driver.◊|cq| This isn't a guarantee, and it's possible an attacker can
work around this. The TCG service provider interface (TSPI) is the
programming interface to the TCSD, and it's the part that most
developers will end up interacting with. The software components are
called the TCG Software Stack, or TSS. The TSS is supposed to provide
a multi-threaded interface to the TPM and provide all the appropriate
context handling for user-space applications to access the TPM. So
there's the answer to the second question: the system interacts via
the TSPI through the TCSD. Too many acronyms? We haven't yet even
begun to acronym!}

◊p{What about the first question? Well, the answer is that we can use
a chain of keys (which I'll talk about in a future installment) to
secure keys ◊strong{outside}, which the TPM will only decrypt and load
inside the TPM. That is, they never exist decrypted outside of the
TPM. However, this poses a problem: if the machine is PXE-booted,
those keys may not be available at boot time (unless there is
dedicated persistent storage). Version 1.2 of the specification (which
is the version that's most useful these days, until version 2.0 is
finalised and becomes widely available) specifies a variable-length
area of special NVRAM. On my Lenovo Thinkpad T440s and X230, I have
1123 bytes available, while a PKCS #1 DER-encoded private key is 1192
bytes. In fact, the only keys that are required to be stored in the
TPM itself are the SRK and endorsement key (which will be described in
a later section). The NVRAM does have authorisation requirements though,
and can be tied to a specific TPM state.}

◊p{TPM state bears some explanation before going too deep into the
rabbit hole; the state is based entirely on the value of one or more
PCRs. A PCR can store 20 bytes of data and can only be
◊strong{extended}, the operation in which data is written to the
register: data has the current PCR value appended, and the SHA-1
digest is taken of this. When an operation expects a PCR to be in a
known state, it means that PCR has been extended with known data in a
set order of operations. This is used, for example, with trusted boot
to ensure the integrity of the bootloader and kernel.}

◊p{To answer the last question, what protections are there to prevent
an attacker on the box from gaining access to the TPM? The answer is
◊|oq|◊strong{not much}◊|cq|. There are the system protections I'll
talk about in a future segment, but once the TPM is unlocked, anyone
can (in theory) connect to it. In practice, it's not quite that easy,
but again◊|md|this will be an article all its own.}

◊p{Finally, I'll close out this introduction with this: for the most
part, you'll be hard-pressed to find examples on using the TPM in the
real world. It seems most places that use them don't talk about it, so
while the TPM provides some tangible security benefits, as of now
it'll mostly be up to you to build the infrastructure and applications
to make use of it.}

◊p{◊small{Published: 2014-07-23◊br{}Last update: 2014-07-30}}
