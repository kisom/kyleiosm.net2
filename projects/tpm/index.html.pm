#lang pollen

◊h2{Adventures in Trusted Computing}

◊blockquote{◊em{◊|oq|YOU ARE AT WITT'S END. PASSAGES LEAD OFF IN
◊strong{*NO*} DIRECTIONS.◊|cq|}◊br{}-- Colossal Cave, if it had been
implemented by the TCG}

◊blockquote{◊em{◊|oq|IÄ! IÄ! CTHULHU FHTAGN! PH'NGLUI MGLW'NAFH CTHULHU R'LYEH
WGAH'NAGL FHTAGN!◊|cq|}◊br{}-- ancient lore regarding TPMs}

◊p{TPMs (Trusted Platform Modules) are maddening to work with; the
documentation and source code are terrible, and companies that have
incorporated TPMs generally don't talk about it. There is next-to-no
documentation for what's expected in many cases, and a lot of times I
worked out how to proceed using trial-and-error. I set out to
integrate TPMs into our systems, armed with only a copy of
◊link["http://www.amazon.com/dp/0132398427/"]{A Practical Guide to Trusted Computing},
the ◊link["http://trousers.sourceforge.net/"]{Trousers} source code,
and ◊link["http://cscope.sourceforge.net/"]{cscope}, and slowly began
to work out how to use them. In this series, I'd like to share what
I've learned in the hopes that you, too, don't pull out all your
hair.}

◊h3{TPM overview}

◊p{The following articles cover the basics of the TPM: what it is, how
keys are organised, threat models, and getting set up to use the TPM.}

◊ul{

  ◊li{◊link["introduction.html"]{Introduction to TPMs}: what are they
  and what are they good for? Our tale begins, as most do, with some
  expository background to set the stage.}

  ◊li{◊link["key_field_guide.html"]{Keys, the TPM, and You}: a field
  guide to how the TSS organises key material.}

  ◊li{◊link["know_your_enemy.html"]{Know your enemy}: threat modeling
  with the TPM.}

  ◊li{◊link["getting_started.html"]{Getting started}: setting up TPM
  support on a machine. This is aimed at Thinkpads running Ubuntu, but
  should be relevant to other systems as well.}

}

◊h3{TPM development}

◊p{The following sections go more in depth on developing with TPM, and
are illustrated with C. The discussion also goes further in depth on
various topics than the overview sections.}

◊ul{

  ◊li{◊link["tspi_life.html"]{TSPI life}: an introduction to writing
  applications with the TSPI}

  ◊li{◊link["connecting.html"]{Connecting to the TPM with the TSPI}}

  ◊li{Key hierarchies with the TSPI}

  ◊li{Encryption and decryption with the TSPI}

  ◊li{Signatures and verification with the TSPI}

  ◊li{PCRs and known-good states}

  ◊li{NVRAM}

}

◊p{◊strong{Disclaimer}: Documentation on the subject is hard to come
by. What's presented here is my best understanding of the system so
far. If I'm wrong, I would ◊strong{love} (seriously) to be made aware
of where my understanding falls short. If you have documentation,
comments, or really anything useful about the TPMs, I'd love to hear
from you.}

◊p{◊small{Published: 2014-07-23◊br{}Last update: 2014-07-24}}
