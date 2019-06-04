"""
> Providers are pieces of information that a rule exposes 
> to other rules that depend on it.

This file defines the FDSDK provider which is used to store
data that bazel knows about the toolchain.
"""

FDSDK = provider(
    doc = "Contains information about the FD SDK used in the toolchain",
    fields = {
        "fdos": "The host OS the SDK was built for.",
        "fdarch": "The host architecture the SDK was built for.",
        "root_file": "A file in the SDK root directory",
        "tools": ("List of executable files in the SDK built for " +
                  "the execution platform."),
    }
)