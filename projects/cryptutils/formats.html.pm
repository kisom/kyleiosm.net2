#lang pollen

◊h2{Data Formats}

◊p{Most of the data structures are encoded as JSON prior to being
encrypted. The primary data structure used by the ◊code{secrets},
◊code{otpc}, and ◊code{journal} programs is the ◊|oq|secret
store◊|cq|.}

◊h3{The secret store (version 1)}

◊p{The secret store has two pieces: the store, and secret records.}

◊p{A ◊code{SecretRecord} is used store a secret and a label, to keep
track of when it was last updated, and to optionally associate some
metadata with it. The metadata has no specific structure, and is
stored as key-value pairs; values are byte strings and are to be
interpreted by clients in whatever manner they see fit.}

◊pre{
// A SecretRecord stores a secret in the secret store.
type SecretRecord struct {
        // The label is used to identify the secret in the store.
        Label string
         
        // The timestamp stores the Unix timestamp of when the record
        // was modified last.
        Timestamp int64
         
        // Secret contains the secret being stored.
        Secret []byte
         
        // Metadata contains any additional information that should be
        // stored alongside the secret.
        Metadata map[string][]byte
}
}

◊p{The ◊code{SecretStore} associates a set of secrets with a version
indicator, a timestamp of last update, and a key-value listing of
secrets with string identifiers. Note that the passphrase is often
stored in this structure, but only as long as the store is in
memory. The passphrase is zeroised prior to serialising the store (and
due to the way that Go serialises JSON, it would not be encoded with
the rest of the store). Including this simplifies certain operations.}

◊pre{
// A SecretStore contains a collection of secrets protected by a
// passphrase. The passphrase is kept with the store until it is
// either marshalled (at which point the store is zeroised), or until
// the store is zeroised manually.
type SecretStore struct {
        // Version should reflect the version of the secret store
        // format in use.
        Version int

        // Timestamp is a Unix timestamp pointing to the last time the
        // secret store was updated.
        Timestamp int64

        // Store is a hash map of secret records, indexed by label.
        Store map[string]*SecretRecord
}
}

◊p{An example encoded secret store prior to encryption looks like:}

◊pre{
{
    "Version": 1,
    "Timestamp": 1400529440,
    "Store": {
        "example.net": {
            "Label": "example.net",
            "Timestamp": 1400529440,
            "Secret": "cGFzc3dvcmQ=",
            "Metadata": {
                "email": "bWVAZXhhbXBsZS5uZXQ="
            }
        },
        "example.org": {
            "Label": "example.org",
            "Timestamp":  1400537177,
            "Secret": "cGFzc3dvcmQy"
        }
    }
}
}

◊p{The tools and libraries do not provide facilities for exporting the
JSON prior to encryption.}

