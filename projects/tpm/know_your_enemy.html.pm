#lang pollen

◊h2{Know Your Enemy}
◊h3['style: "text-align: center;"]{Threat Modeling with a TPM}

◊p{When designing applications to use the TPM, I spent some time
looking at what attacks it would defend against (and where it would
fail), and how this applied to the problem of determining an effective
means of securing the TPM keys.}

◊p{One possible attack on the TPM is to set up between the TPM and the
motherboard:}

◊pre{
   +-------+                  +-------+
   |  TPM  |                  |  TPM  |
   |       |                  |       |
   +-------+                  +-------+
    | | | |                    | | | |
   +-------+                   +-+-+-+---> to attacker
   | system|                   | | | |
   | board |                  +-------+
                              | system|
                              | board |

TPM in normal operation       TPM interception
}

◊p{The LPC bus is so-called because the pins on it have a low pin
count. In the case of the TPM, there are pins for clock, reset, start
of frame (for LPC communications), and address/data pins. An attacker
could hijack[1] this to either intercept TPM communications, piggyback on
TPM communications, or inject commands[2]. This attack is intrusive, and inspection of the hardware would reveal this.}

◊p{It's also possible for an attacker with access to a lab that can
peel away the chip's housing and examine the TPM chip with a
microscope can get to the keys stored in the TPM itself or the NVRAM,
as demonstrated by Chris Tarnovsky at BlackHat in 2010. This is
serious lab work, but it is doable.}

◊p{If both of these attacks are outside the scope of your threat
model, then the TPM should be suitable for your application. Referring
back to the rule of thumb in the introduction, a machine that's gone
down unexpectedly should be treated as untrusted. Depending on the
system, it might be prudent to reset the TPM with new secrets and
keys. If it's been down for a sufficiently long period of time
(perhaps an hour), it should be cause to no longer trust the TPM.}

◊p{In version 1.2 of the TPM specification, there is a secure
transport between applications and the TCSD (which communicates using
SOAP, typically on port 30003); however, the data structures used in
the TSPI are all integers containing handles to TPM resources. If an
attacker can grab those handles (such as by being root, attaching to
the process, and dumping that part of memory), they could gain access
that way. Again, the TPM isn't a solution to all the security
problems.}

◊p{The next question is how to set up secrets. If applications are
segregated by user, with multiple users, the SRK might use the
well-known secret (while the owner maintains their own secret for
administrative purposes, i.e. so that users can't clear the TPM) and
each user might use their own secret for their keys (whether the same
secret for all keys, or one user wrapping key that wraps multiple
application keys). If the TPM owner is the TPM user, then it might
make sense to store keys in the system persistent storage and use an
SRK secret.}

◊p{If the threat of secret extraction from a TPM is in scope, it would
be wise to not trust the TPM with secrets. However, it may still be
useful for remote attestation and authentication◊|md|so long as any
unexpected downtime is treated as a compromise of the TPM. If this is
the case, when the TPM is no longer trusted, it should be
◊q{"burned"}: the TPM should be deauthorised ◊strong{on the remote
end} and the TPM cleared. This will require human intervention on next
boot (which should be done to inspect or replace the TPM), and a new
set of keys provisioned then.}

◊p{The safest route, then, is to use the TPM for authentication (and
perhaps ersable or long-term storage) in cases where authentication
should be predicated on ownership of a particular machine (or
guarantees that can be made about that machine using the TPM). Success
stories with TPMs include secure boot and using the TPM for disk
encryption; it would be safest to not rely on the TPM for encrypting
data that should persist through a reboot (for example, using the TPM
to generate a temporary configuration management encryption key).}

◊h3{More Links}

◊ol{

  ◊li{◊link["https://online.tugraz.at/tug_online/voe_main2.getvolltext?pCurrPk=59565"]{A Hijacker's Guide to the LPC bus}}

  ◊li{◊link["http://rdist.root.org/2007/07/17/tpm-hardware-attacks-part-2/"]{TPM hardware attacks (part 2)}}

}

◊p{◊small{Published: 2014-07-24◊br{}Last update: 2014-07-03}}

◊p{◊small{Up next: ◊link["getting_started.html"]{Getting started}:
A case study in Ubuntu on a thinkpad.}}

◊p{◊small{◊link["index.html"]{Adventures in Trusted Computing}}}
