#lang pollen

◊h2{On Systems Programming}

◊p{Having spent a significant amount of time doing systems programming
(which remains my favourite type of programming), this is perhaps the
most eloquent quote on what systems programming entails. It comes from
James Micken's amazing column,
◊|oq|◊link["http://research.microsoft.com/en-us/people/mickens/thenightwatch.pdf"]{The Night Watch}◊|cq|
(◊link["thenightwatch.pdf"]{local mirror}).}

◊blockquote{As I paced the hallways, muttering Nixonian rants about my
code, one of my colleagues from the HCI group asked me what my problem
was. I described the bug, which involved concurrent threads and
corrupted state and asynchronous message delivery across multiple
machines, and my coworker said, ◊|oq|Yeah, that sounds bad. Have you
checked the log files for errors?◊|cq| I said, ◊|oq|Indeed, I would do
that if I ◊q{hadn't} broken every component that a logging system
needs to log data. I have a network file system, and I have broken the
network, and I have broken the file system, and my machines crash when
I make eye contact with them. I HAVE NO TOOLS BECAUSE ◊q{I'VE}
DESTROYED MY TOOLS WITH MY TOOLS. My only logging option is to hire
monks to transcribe the subjective experience of watching my machines
die as I weep tears of blood.◊|cq|}

◊p{For example, writing embedded software: how do you print when
you're trying t owrite the serial console driver? How do you blink an
LED when you are trying to figure out the GPIO systems? Is the problem
in the physical hardware? Has a chip blown out? Is the problem in the
power supply? Sometimes in embedded systems, debugging is done with a
multimeter and an oscillopscope, watching the actual electrical
signals traveling down the system. Other times, you're stuck in the
black box that is the processor. With SoC architectures, it's even
more difficult: your GPU, UARTs, and supporting hardware are all
contained in the same borders of a land that's the Silicon Iron
Curtain, and you have no spy satellites to peer inside. Yet, it is
particularly thrilling and fulfilling when it all finally works, when
you start receiving proper telemetry from a wireless sensor pod you've
built yourself: capturing the schematic, laying out the PCB and having
it fabricated, assembling the hardware yourself, and then breathing
life into the silicon, plastic and metal with a chunk of C.}

◊p{It's all such magic.}
