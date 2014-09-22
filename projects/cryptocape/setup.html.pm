#lang pollen

◊h2{Setting up the CryptoCape}

◊h3['style: "text-align: center;"]{First boot}

◊p{On first boot, you can determine whether the CryptoCape was
detected properly:}

◊pre{
root@beaglebone:~# dmesg | grep CRYPTO
[    0.701470] bone-capemgr bone_capemgr.9: slot #3: 'BB-BONE-CRYPTO,00A0,SparkFun,BB-BONE-CRYPTO'
[    0.702141] bone-capemgr bone_capemgr.9: loader: before slot-3 BB-BONE-CRYPTO:00A0 (prio 0)
[    0.702156] bone-capemgr bone_capemgr.9: loader: check slot-3 BB-BONE-CRYPTO:00A0 (prio 0)
[    0.702877] bone-capemgr bone_capemgr.9: loader: after slot-3 BB-BONE-CRYPTO:00A0 (prio 0)
[    0.702896] bone-capemgr bone_capemgr.9: slot #3: Requesting part number/version based 'BB-BONE-CRYPTO-00A0.dtbo
[    0.702912] bone-capemgr bone_capemgr.9: slot #3: Requesting firmware 'BB-BONE-CRYPTO-00A0.dtbo' for board-name 'BB-BONE-CRYPTO', version '00A0'
[    0.702941] bone-capemgr bone_capemgr.9: slot #3: dtbo 'BB-BONE-CRYPTO-00A0.dtbo' loaded; converting to live tree
[    0.739216] bone-capemgr bone_capemgr.9: loader: done slot-3 BB-BONE-CRYPTO:00A0 (prio 0)
}

◊p{The next step is to verify whether the TPM was detected. You should
issue the following command, and see something like the response
below:}

◊pre{
root@beaglebone:~# dmesg | grep TPM
[    5.686495] tpm_i2c_atmel 1-0029: TPM is disabled/deactivated (0x6)
}

◊h3['style: "text-align: center;"]{If that doesn't work}

◊p{If the previous step fails, start the BBB ◊strong{without} the
CryptoCape. Then, issue the following command as ◊strong{root}:}

◊pre{
echo tpm_i2c_atmel 0x29 > /sys/class/i2c-adapter/i2c-1/new_device
}

◊p{Now, attach the CryptoCape.}

◊h3['style: "text-align: center;"]{Taking ownership}

◊p{Before the TPM can be used, it must be}

◊ul{

  ◊li{◊strong{Enabled}}
  ◊li{◊strong{Activated}}
  ◊li{◊strong{Owned}}

}

◊p{TPMs require an assertion that the operator is physically present
on the console to take ownership. This is traditionally done in the
BIOS, but the BBB doesn't have a BIOS (though there is work to
integrate this into UBoot). Therefore, a physical presence assertion
has to be sent to the TPM over the I2C bus. After a physical presence
assertion, the TPM must be enabled and activated. Furthermore, the
newer model CryptoCapes ship with
◊link["http://cryptotronix.com/2014/08/28/compliance_mode/"]{compliance vectors}
that should be removed (otherwise, the TPM will generate known values
for various operations; this is used to test the TPM).}

◊p{Josh Datko has provided a script to handle this:
◊link["https://github.com/cryptotronix/cryptocape-init/"]{cryptocape-init}.
You can run this, or you can do this by hand:}

◊pre{
$ sudo apt-get install trousers tpm-tools
$ wget https://gist.githubusercontent.com/jbdatko/4e6f4fb7f58248213f11/raw/64e376d94f17f7ee151d7c8da37af23a08ac92e9/tpm_assertpp.c
$ gcc -o tpm_assertpp tpm_assertpp.c
$ service trousers stop
$ ./tpm_assertpp
$ service trousers start
$ tpm_clear -f
$ tpm_setenable -e -f
$ tpm_setactive -a
$ sudo poweroff
}

◊p{At this point, the BBB needs a complete power cycle: after the
poweroff command, wait a few seconds, pull the power cable, and plug
it back in to bring the BBB back up. Once back in the console, you
should check to make sure the TPM is found:}

◊pre{
$ dmesg | grep TPM
[    5.576050] tpm_i2c_atmel 1-0029: Issuing TPM_STARTUP
}

◊p{Now, it's time to generate an endorsement key (EK), and then take
ownership. A compliance EK (which can be checked with the ◊code{tpm_getpubek})
will be the bytes 0xAB567C...30D899. If the EK doesn't match, a new EK
doesn't need to be generated.}

◊pre{
$ tpm_createek
$ tpm_takeownership -z
}

◊p{Here, I've used the well-known secret for the TPM.}

◊p{A quick way to ensure that everything is working:}
◊pre{
$ dd if=/dev/urandom of=secret.key bs=32 count=1
$ tpm_sealdata -z -i secret.key -o secret.enc
$ tpm_unsealdata -z -i secret.enc -o secret.out
$ diff secret.key secret.out
}

◊p{◊small{Back to ◊link["index.html"]{CryptoCape projects}.}}
