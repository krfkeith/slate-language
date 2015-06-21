# Overview #

This is the source management site for the [Slate programming language](http://www.slatelanguage.org).

# Getting Started #

To get started with Slate, you need:

  * A VM:
    * Some pre-built VMs are available in the Downloads section.
    * Or, get the sources via one of our repositories (cloning an hg or git repository or extracting a tarball), and build using 'make'.
  * A pre-made Slate image. Download the appropriate Slate image from our Downloads section.

Currently we support all little-endian systems with a GCC toolchain or Visual Studio out of the box, with either a 32-bit or 64-bit build of VM and image equally supported.

Build instructions are contained within the [README](http://code.google.com/p/slate-language/source/browse/README) in the source tree. If tweaks are required for your platform, please let us know so we can improve our support.

Finally, run "./slate -i imagefile.image"

# Release Practices #

We are not currently making versioned releases, but image snapshots with the latest core library updates are uploaded mid-month or at the end of the month after confirming basic stability. If the images are not dated recently, that should be because they're still compatible with source trees from that date onward.

# Issues #

Stability should be steadily improving, and any major crashes are worth [reporting](http://code.google.com/p/slate-language/issues/list).