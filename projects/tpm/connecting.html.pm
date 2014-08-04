#lang pollen

◊h2{Setting Up a TPM Connection}

◊p{There are code patterns that are generally applicable to any
program using the TPM; this code sets up and tears down connections to
the TCS. These connections always use a context handle and a TPM
handle.}

◊h3{A basic skeleton}

◊p{First, here is a skeleton program that connects to the TPM, prints
a message about being connected, then disconnects:}

◊pre{
/*
 * Copyright (c) 2014 by Kyle Isom <kyle@tyrfingr.is>.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND INTERNET SOFTWARE CONSORTIUM DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL INTERNET SOFTWARE
 * CONSORTIUM BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
 * ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
 * SOFTWARE.
 */


#include <trousers/tss.h>
#include <trousers/trousers.h>
#include <stdio.h>
#include <stdlib.h>


/*
 * This skeleton code connects to the TPM, then closes down the connection.
 */
int
main(void)
{
	TSS_HCONTEXT	ctx = 0;
	TSS_HTPM	tpm = 0;
	TSS_RESULT	res = 0;

	res = Tspi_Context_Create(&ctx);
	if (TSS_SUCCESS != res) {
		goto exit;
	}

	res = Tspi_Context_Connect(ctx, NULL);
	if (TSS_SUCCESS != res) {
		goto exit;
	}

	res = Tspi_Context_GetTpmObject(ctx, &tpm);
	if (TSS_SUCCESS != res) {
		goto exit;
	}

	printf("Connected to TPM.\n");

	res = Tspi_Context_FreeMemory(ctx, NULL);
	if (TSS_SUCCESS != res) {
		goto exit;
	}

	res = Tspi_Context_Close(ctx);
	if (TSS_SUCCESS != res) {
		goto exit;
	}

	printf("Disconnected from TPM.\n");

exit:
	if (TSS_SUCCESS != res) {
		fprintf(stderr, "Failure: %s\n", Trspi_Error_String(res));
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}
}

◊p{I'll break this into chunks, and describe at what each piece is
doing.}

◊pre{

	TSS_HCONTEXT	ctx = 0;
	TSS_HTPM	tpm = 0;
	TSS_RESULT	res = 0;
}

◊p{In the ◊link["tspi_life.html"]{previous} section, I mentioned that
working with the TPM involved working with TPM objects; the base type
for most TPM objects is TSS_HOBJECT. This is defined as}

◊pre{
typedef		uint32_t	UINT32;
typedef		UINT32		TSS_HOBJECT;
typedef		TSS_HOBJECT	TSS_HCONTEXT;
typedef		TSS_HOBJECT	TSS_HTPM;
typedef		TSS_HOBJECT	TSS_HKEY;
// more object types follow
typedef		UINT32		TSS_RESULT;
}

◊p{These handles are used by the TSS to manage connections to the
TPM. Initialising an object to 0 is a way to check later whether the
object needs to be cleared out. This doesn't show up in this skeleton
code, but it'll come up later.}

◊pre{
	res = Tspi_Context_Create(&ctx);
	if (TSS_SUCCESS != res) {
		goto exit;
	}
}

◊p{◊code{Tspi_Context_Create} initialises the context, which is used
to manage a connection to the TCSD. This context will be supplied
quite often.}

◊pre{
	res = Tspi_Context_Connect(ctx, NULL);
	if (TSS_SUCCESS != res) {
		goto exit;
	}
}

◊p{The ◊code{Tspi_Context_Connect} function connects the context to
the TCSD. The use of ◊code{NULL} here tells the TSPI to connect to a
local TCS; it could also be a NULL-terminated string that contains
connection information for a remote TCS. I've never tried to connect
to a remote TCS, so I can't say what the connection string should look
like.}

◊pre{
	res = Tspi_Context_GetTpmObject(ctx, &tpm);
	if (TSS_SUCCESS != res) {
		goto exit;
	}
}

◊p{This loads a handle to the TPM object for a context.}

◊p{At this point, a connection to the TPM has been established. The
remaining code properly tears down the context.}

◊pre{
	res = Tspi_Context_FreeMemory(ctx, NULL);
	if (TSS_SUCCESS != res) {
		goto exit;
	}
}

◊p{The call to ◊code{Tspi_Context_FreeMemory} doesn't do anything
here; no memory was allocated. It's included because it's a good idea
to always clear out any memory allocated to the context when shutting
down the context. The use of NULL here deallocated ◊strong{any} memory
allocated for this context.}

◊pre{
	res = Tspi_Context_Close(ctx);
	if (TSS_SUCCESS != res) {
		goto exit;
	}
}

◊p{The final step is to actually close the context.}

◊h3{Abstracting into a library}

◊p{I wanted to coalesce this into an actual library. As will be
obvious later, the context and TPM objects will be frequently used. It
would also be nice to delineate the TPM-specific code into a separate
package, such that the parent program doesn't have to worry about all
the TPM-specific parts. This will become a layer over the TSPI, but
the added simplicity will be worthwhile. It's worth noting that the
library presented here is a little different from the library I
actually use (which does things specific to the task at hand and has
an opaque TPM object).}

◊p{To start, I decided to create a structure to hold the context, the
TPM object, and the result of the last TPM operation. The last field
isn't strictly required in this version of the library, but I included
it to facilitate making the object opaque later, should that be
desired.}

◊pre{
typedef struct sTPM {
	TSS_HCONTEXT	ctx;	// The context for the current connection.
	TSS_HTPM	hdl;	// The TPM object for the current context.
	TSS_RESULT	res;	// The result from the last TPM operation.
} * TPM;
}
