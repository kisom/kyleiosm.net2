#lang pollen

◊h2{Getting Started}

◊h3['style: "text-align: center;"]{A Case Study in Ubuntu on a Thinkpad}

◊p{In my experience, the most useful development machines for TPM work
are Thinkpads (I've used an X60, a T410, an X230, and a pair of T440s
for this), on which I typically run the Ubuntu server
distribution. Doing the same thing on a Red Hat-based distribution,
Arch Linux, or Gentoo installation should be similar.}

◊p{The first step is to enable the TPM in the BIOS. On many systems,
this is called a ◊strong{Security Chip}, with the configuration set up
in the ◊q{"Security"} tab. It should be put in an active state; on
some machines, I had to explicitly choose to use the ◊|oq|Discrete
TPM◊|cq| option. I always chose to clear the security chip; on the
Thinkpads, this option is called (helpfully enough) ◊|oq|Clear
Security Chip◊|cq|. This same option is how the TPM is reset later
on. It's critical to know that, in order to clear the chip, the
machine must go through a full power cycle: shut down, then power on
and enter the BIOS. The TPM itself will not allow clearing except
immediately following from a powered down state (the ◊|oq|Clear
Security Chip◊|cq| disappears from the menu).}

◊h3{Enabling the TPM in the OS}

◊p{On Ubuntu, in order to access the TPM, ◊code{trousers} needs to be
installed at a minimum, and ◊code{libtspi} must be installed to use
any dynamically-linked applications that use the TPM:}

◊pre{
$ sudo apt-get install trousers libtspi1
}

◊p{Trousers is an open-source TSS, and it includes the TCSD needed to
communicate with the TPM; libtspi is the library that applications
will need to link against to use the TSS. At this state, if the
software that is to run on the machine handles all the TPM
interaction, nothing else needs to be installed. However, if
interacting with the TPM on the command line is desired, the
◊code{tpm-tools} package should be installed:}

◊pre{
$ sudo apt-get install tpm-tools
}

◊h3{The tpm-tools}

◊p{◊code{tpm-tools} offers a few utilities for interacting with the
TPM.  On first use, the ◊code{tpm_takeownership} utility should be
run. This will generate a new SRK and set up ownership of the TPM. The
◊code{-z} flag tells the utility to secure the SRK with the well-known
secret. There are quite a few other useful tools that come with the
package; I'll list them here and provide a brief description to
document their existence:}

◊ul{

  ◊li{◊code{tpm_changeownerauth}: change the secrets for the SRK or
  owner}

  ◊li{◊code{tpm_clear}: clear the ownership information and wipe the
  SRK; while this doesn't delete keys in persistent storage, those
  keys can no longer be used. After this is run, in order to use the
  TPM the machine should be powered off, and upon powering it back on,
  the TPM cleared in the BIOS.}

  ◊li{◊code{tpm_createek}: generate a new endorsement key (EK)}

  ◊li{◊code{tpm_getpubek}: returns the public part of the EK}

  ◊li{◊code{tpm_nvdefine}: define an NVRAM area}

  ◊li{◊code{tpm_nvinfo}: display information about different NVRAM
  areas; including permissions, size, and PCRs the area is tied to}

  ◊li{◊code{tpm_nvread}: read from an NVRAM area}

  ◊li{◊code{tpm_nvrelease}: release (remove) an NVRAM area}

  ◊li{◊code{tpm_nvwrite}: write to an NVRAM area}

  ◊li{◊code{tpm_resetdalock}: reset dictionary attack lock}

  ◊li{◊code{tpm_restrictpubek}: set restrictions on who can display
  the EK's public key}

  ◊li{◊code{tpm_restrictsrk}: set restrictions on who can read the
  SRK}

  ◊li{◊code{tpm_sealdata}: seal data with the SRK}

  ◊li{◊code{tpm_selftest}: run a TPM self test and report the results}

  ◊li{◊code{tpm_setactive}: report or change the TPM's active state}

  ◊li{◊code{tpm_setclear}: report or change the TPM's clear flags}

  ◊li{◊code{tpm_setenable}: report or change the TPM's enable states}

  ◊li{◊code{tpm_setoperatorauth}: set the operator's authorisation in the TPM}

  ◊li{◊code{tpm_setownable}: change whether the TPM accepts
  ◊code{take_ownership} commands}

  ◊li{◊code{tpm_setpresence}: change the TPM's physical presence state
  or settings}

  ◊li{◊code{tpm_takeownership}: take ownership of the TPM and generate
  a new SRK; this can only be done after the power cycle steps
  mentioned previously}

  ◊li{◊code{tpm_unsealdata}: decrypt data encrypted with
  ◊code{tpm_sealdata}}

  ◊li{◊code{tpm_version}: report the TPM's version and manufacturer
  information}

 }

◊h3{Installing development packages}

◊p{In order to write software that uses the TPM, the TSPI development
headers should be installed:}

◊pre{
$ sudo apt-get install libtspi-dev
}

◊h3{Packages}

◊p{On other distributions, the keywords to look for the TPM packages
are:}

◊ul{

  ◊li{trousers: TSS daemon}

  ◊li{libtspi: TSS library}

  ◊li{libtspi development headers}

  ◊li{tpm-tools}

}

◊h3{Initialising the TPM}

◊p{When I want to initialise a new TPM from the command line, I call
◊code{tpm_takeownership -z}, entering an owner secret. The TPM is now
ready for operation. Depending on whether I want to force generating a
new EK or not, I call ◊code{tpm_createek}. Finally, I store the EK and
SRK public keys (along with other metadata) in a central location to
keep track of the machine.}

◊p{◊small{Published: 2014-08-03◊br{}Last update: 2014-08-03}}

◊p{◊small{Up next: ◊link["tspi_life.html"]{TSPI life}:
development with the TSPI.}}

◊p{◊small{◊link["index.html"]{Adventures in Trusted Computing}}}
