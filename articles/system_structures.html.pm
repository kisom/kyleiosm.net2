#lang pollen

◊h3{On the structure of computer systems}

◊p{One of the most inspiring quotes from
◊link["http://mitpress.mit.edu/sicp"]{The Structure and Interpretation of Computer Programs}
occurs early in the book:}

◊blockquote{

Pascal is for building pyramids◊|md|imposing, breathtaking, static
structures built by armies pushing heavy blocks into place. Lisp is
for building organisms◊|md|imposing, breathtaking dynamic structures
built by squads fitting fluctating myraids of simpler organisms into
place.

}

◊p{

Reading SICP again has me thinking about this idea. ◊q{I've} been
particularly considering the roles that Go and Lisp play in complex
systems that I build (although, unfortunately, this is only for my own
systems as professionally I use only the former). Ultimately, this
comes down to an idea of ◊q{"static"} programming, such as the
programs built with Go that cannot be elegantly updated mid-execution,
and the more "dynamic" components of these systems, such as those
written in Lisp. I have been thinking of these along the lines of a
series of ports strung along a river.

}

◊p{

The infrastructure of these ports are built of concrete and steel, and
serve singular, simple purposes. The concrete is well worn from years
of channeling water, and almost no maintenance is done on these
parts. The capacity handling and mechanical characteristics of
concrete and steel are well known, and the ◊q{port's} infrastructure
is built on a reliance that these properties will hold. Similarly, I
employ Go programs in much the same way: building singularly-purposed,
static systems whose job is to channel data in some very specific
way. This allows the construction of much faster, practically
maintenance-free programs that are rarely, if ever, updated◊|md|their
power is in that they do one well-specified thing; in practice, I have
Go programs that have run for over a year without attention, and in
some cases, their presence all but forgotten. For example, one such
system provides an encrypted one-way transport byte stream. It is
designed to receive logs and sling them across the Internet securely
to a collector. This collector sits behind another Go system that
decrypts these messages and forwards this to the collector. The Go
system does not know the structure or meaning of the data it is
pushing; it merely takes some binary data via a local network socket
and handles the encryption and forwarding. It uses a well-known and
strongly vetted ciphersuite (◊q{NaCl's} secretbox), the host
◊q{system's} random number facilties, and has a simple protocol for
transporting these messages. In fact, it is designed such that the
collector never needs to know that the data was broken into messages;
by forwarding the data as a TCP socket, it breaks none of the
assumptions regarding the means in which TCP messages are sent. It is
used to communicate between several of our port-analogues (in reality,
various servers); were the protocol to change, it would need to be
changed on all the machines. It is the background machinery that
ensures data flows securely and safely.

}

◊p{
The consumers of the water in this analogue are Lisp systems. They are
the commerce and society upon which the flow of water is predicated;
they take the data and provide meaning to it. They are fluid systems;
one day there might be a revolution that completely changes the
political dynamic, or perhaps a technological breakthrough that
revolutionises the course of the society. For example, one of the log
producers is a web application, and the collector is a log
aggregator. The log transport system ◊q{doesn't} know or care about the
form of these logs, or the policies of their collection; however,
these systems are dynamic. As the logging requirements change, the
application changes◊|md|without stopping or restarting◊|md|the
only limitating is the (known) capacity of the transport system. Lisp
allows these systems to organically and dynamically change their
behaviour, producing or consuming data in various ways. Perhaps one
day, steamships are sent down the river; the next, a nuclear-powered
aircraft carrier. Or perhaps, the cargo ships carry textile loads one
day, and lumber the next. The waterways ◊q{don't} care: they give the
society flexibility to expand, grow, and adapt as needed.

}

◊p{

To summarise, the static components built from Go serve as
long-running, low-maintenance infrastructure that ensures data is
moved around appropriately while remaining unchanged for long periods
of time. Lisp produces and consumes this data, while developed
interactively. This site started as a simple, barely-functioning
application and was slowly hacked at to bring it to its current
form. The current log collector is a small Lisp program that does very
little; there are plans to rewrite it (in Erlang, or potentially
Clojure) into a more full-fledged analytic system with a web
interface. As I discovered other information that would be useful to
collect, I adapted the logging policy to suit. The logs are currently
serialised to JSON and sent to the Go system, which ensures that logs
make it to the collector; however, it ◊q{isn't} aware that the logs are in
JSON. Both types of components fill important roles in the system as a
whole.

}

◊p{◊small{Published 2014-05-27}}
