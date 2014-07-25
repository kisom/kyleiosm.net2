#lang pollen

◊h2{Know Your Enemy}
◊h3['style: "text-align: center;"]{Threat Modeling with a TPM}

◊p{The threat model is really going to dictate how you secure the keys
on the TPM. As mentioned previously, I've found a couple of ways to do
it based on what threats I wanted to protect against and how the TPM
fit into the larger picture. There a few basic scenarios I came up
with:}

◊ol{

  ◊li{The system is thought to be physically secure, perhaps in a cage
  with monitoring for PCI compliance or a laptop that is kept secure.}

  ◊li{The system has one primary application that should have access
  to several hierarchies of keys.}

  ◊li{No application trusts other applications.}

}

◊h3{Scenario 1: Physically Secure}

◊p{If the system is physically secure, it might make sense to have the
SRK use the well-known secret so that the machine can perform certain
activites unattended.}
