#lang pollen

◊h2{Glossary}

◊ul{
  
   ◊li{◊strong{cryptoprocessor}: a microprocessor or hardware chip
   dedicated to performing cryptographic operations, typically with
   tamper resistance so that it can form a secure foundation for the
   system using it.}

   ◊li{◊strong{LPC}: Low Pin Count bus}

   ◊li{◊strong{Low Pin Count bus}: a communications pathway on the
   motherboard that enables simple devices, such as TPMs and boot
   ROMs, to connect to the CPU.}
 
   ◊li{◊strong{non-volatile random-access memory}: a type of memory
   technology using random-access memory that retains information even
   when powered off. Flash memory is an example of NVRAM. The RAM used
   in computers, in contrast, is an example of volatile (information
   is lost on power off) random-access memory.}

   ◊li{◊strong{NVRAM}: non-volatile random-access memory}

   ◊li{◊strong{PCB}: printed circuit board}

   ◊li{◊strong{PCR}: Platform Configuration Register}
  
   ◊li{◊strong{Platform Configuration Register}: special volatile memory
   locations in the TPM that can only be ◊strong{extended}. These are
   used to measure the state of a system.}

   ◊li{◊strong{PKCS #1}: the Public Key Cryptography Standard #1, the
   specification for RSA cryptographic operations and key formats. RFC
   3447 contains version 2.1 of PKCS #1.}

   ◊li{◊strong{preboot execution environment}: a means for sending a
   boot image for a computer over the network, i.e. for use with
   thin-clients or servers that do not need a persistent operating
   system.}

   ◊li{◊strong{PXE}: preboot execution environment}

   ◊li{◊strong{remote attestation}: the ability for a remote system to
   cryptographically identify itself to some other machine}

   ◊li{◊strong{RSAES-OAEP}: RSA encryption scheme optimal asymmetric
   encryption padding, an encryption scheme used by RSA that is the
   preferred encryption scheme.}

   ◊li{◊strong{secure boot}: ensures the system only boots a verified
   image, for example, one that is signed with a known key. Measured
   boot is a form of this in which the PCRs are used to ensure the
   system boots into a known state.}

   ◊li{◊strong{TCG}: Trusted Computing Group}

   ◊li{◊strong{TCG Core Services}: common set of services per platform
   for all service providers. This should provide a threadsafe
   interface to the TPM, which is not required to be multithreaded.}

   ◊li{◊strong{TCS}: TCG Core Services}

   ◊li{◊strong{TCSD}: the TCS daemon, a userspace daemon that is intended to
   be the only portal to the TPM device driver}

   ◊li{◊strong{TCS Service Provider Interface}: the API for accessing
   the TCS}

   ◊li{◊strong{TDDL}: Trusted Device Driver Layer}

   ◊li{◊strong{TPM}: Trusted Platform Module}

   ◊li{◊strong{Trusted Computing Group}: the standards body responsible for the
   TPM specification.}

   ◊li{◊strong{Trusted Device Driver Layer}: intermediary between the operating
   system TPM device driver and the TCS}

   ◊li{◊strong{Trusted Platform Module}: hardware RSA cryptoprocessor (with an
   RNG) attached to the system board.}

   ◊li{◊strong{Trusted Software Stack}: the software used to interact with a TPM;
   this includes the TCSD and TSPI.}

   ◊li{◊strong{TSPI}: TCS Service Provider Interface}

   ◊li{◊strong{TSS}: Trusted Software Stack}
}
