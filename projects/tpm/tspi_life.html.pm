#lang pollen

◊h2{TSPI Life}
◊h3['style: "text-align: center"]{Developing applications that use the TPM}

◊p{In the following sections, I'll talk about what I've learned so far
writing code that uses the TPM. In this part, I'll give a brief
overview of things that are generally useful to know, and then cover
specific things in different sections.}

◊p{In general, C programs will include two header files:}

◊pre{
#include <trousers/tss.h>
#include <trousers/trousers.h>
}

◊p{Working with the TSS involves working with handles to TPM
objects. Internally, these are implemented as unsigned 32-bit
integers. This means that they can be initialised to ◊code{0}, which
provides a way to check whether they need to be cleaned up with the
rest of the cleanup code. I'll demonstrate this a bit later on, but
it's useful to know.}

◊p{TPM programs will also need to link the TSPI library in, e.g. via
◊code{-ltspi}.}

◊p{Most TPM functions return a ◊code{TSS_RESULT} value; on success,
they will return the value ◊code{TSS_SUCCESS}. More generally useful
than the error code value is the message that is returned using
◊code{Trspi_Error_String}, which is called on the ◊code{TSS_RESULT}
value. Often times, when I wasn't sure what an error message was
telling me, I used ◊code{cscope} to look up the error message in the
Trousers source code, and then worked backwards from the Trousers
source to figure what had gone wrong. To spare others from the same
fate, I'll try to elucidate some of the failures I ran into.}

◊p{The work that I've done is limited to code running on a local
machine that connects to a locally-attached TPM. The specification
permits connecting to remote instances, but that's not a situation
I've run into, nor a scenario that I'd like to be involved with. The
code here will reflect this.}

◊p{◊small{Published: 2014-08-03◊br{}Last update: 2014-08-03}}

◊p{◊small{Up next: ◊link["connecting.html"]{Setting up a TPM connection}}}

◊p{◊small{◊link["index.html"]{Adventures in Trusted Computing}}}

