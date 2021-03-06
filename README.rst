=============================
Haskell SPAKE2 implementation
=============================

Implementation of SPAKE2 key exchange protocol.

Status
======

Working implementation that interoperates with python-spake2
using the default settings, i.e. with Ed25519.

No other groups implemented.

Goals
=====

* compatibility with `python-spake2 <https://github.com/warner/python-spake2>`_
* (stretch) submit to `cryptonite <https://github.com/haskell-crypto/cryptonite>`_

Non-goals
=========

Right now:

* PAKE2+
* any `Elligator Edition <https://moderncrypto.org/mail-archive/curves/2015/000424.html>`_ variants

How to use it
=============

The `interoperability harness entry point <cmd/interop-entrypoint/Main.hs>`_
is the best working example of how to use the code.

The `main module documentation <src/Crypto/Spake2.hs>`_ might also help.

Testing for interoperability
----------------------------

Requires the `LeastAuthority interoperability harness <https://github.com/leastauthority/spake2-interop-test>`_.

Assumes that haskell-spake2 has been compiled (``stack build`` will do it)
and that you know where the executable lives (``stack install`` might be helpful here).

.. these instructions are not yet verified

To show that Python works as Side A and Haskell works as Side B:

.. code-block:: console

   $ runhaskell TestInterop.hs ./python-spake2-interop-entrypoint.hs A abc -- /path/to/haskell-spake2-interop-entrypoint B abc
   ["./python-spake2-interop-entrypoint.py","A","abc"]
   ["/path/to/haskell-spake2-interop-entrypoint","B","abc"]
   A's key: 8a2e19664f0a2bc6e446d2c44900c67604fe42f6d7e0a1328a5253b21f4131a5
   B's key: 8a2e19664f0a2bc6e446d2c44900c67604fe42f6d7e0a1328a5253b21f4131a5
   Session keys match.

**Note**: if you want to run ``runhaskell`` with ``stack``,
you will need to invoke it like::

   stack runhaskell TestInterop.hs -- ./python-spake2-interop-entrypoint.hs A abc -- /path/to/haskell-spake2-interop-entrypoint B abc

The above results are genuine,
and demonstrate that the Haskell SPAKE2 implementation *does* work.
Specifically, that it interoperates with python-spake2.

Contributing
============

We use `stack <https://docs.haskellstack.org/en/stable/GUIDE/>`_ for building and testing.

High-quality documentation with examples is very strongly encouraged,
because this stuff is pretty hard to figure out, and we need all the help we can get.
