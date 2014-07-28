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
activites unattended. Alternatively, a single unlock when the system
starts to unlock the TPM might be appropriate. The latter typically
requires human intervention but provides a greater measure of
security. Note that any program that wishes to use the TPM must unlock
the TPM.}

◊h3{Scenario 2: Single primary application}

◊p{In this case, the security model is similar to the previous case;
the application's keys may be protected by an SRK secret, or an
additional or separate secret for the application's top-level storage
key(s) should be provided.}

◊h3{Separate applications}

◊p{Here, each application has its own key, and must both unlock the
SRK and the relevant keys.}

◊h3{Applying the security model}

◊p{Generally, human intervention is preferred such that the secret(s)
required to unlock the appropriate keys are kept in memory for the
shortest possible time; perhaps something akin to the following C
code:}

◊pre{
        /*
         * Eliding the particulars of connecting a TPM, it will just
         * be represented as an opaque structure pointer.
         */
        static TPM tpm;

        int
        unlock_tpm()
        {
                uint8_t	secret[MAX_SECRET_LENGTH];
                size_t  seclen = 0;

                while (1) {
                      if (-1 == read_password(&secret, &seclen)) {
                              fprintf(stderr, "Failed to read the password");
                              return -1;
                      }
                      
                      if (0 == unlock_tpm(secret, seclen)) {
                              memset(&secret, 0, seclen)
                              break;
                      }

                      fprintf(stderr, "Invalid secret.\n");
                }
                return 0;
        }
}

◊p{As long as the application maintains the TPM handle and barring any
failures of the TPM or TSS, the application should now be able to
perform cryptographic operations with the TPM.}

◊p{However, if the threat model is based on a physically secure
system, the secret might be baked into the program. However, if the
binary or source is ever leaked, the TPM is no longer
trustworthy. Furthermore, the security gained by keeping the private
key out of memory is now lost as an attacker who has access to the box
will likely be able to recover the secret. This is why I
◊strong{strongly} prefer human intervention here; the threat model
should justify deviations.}
