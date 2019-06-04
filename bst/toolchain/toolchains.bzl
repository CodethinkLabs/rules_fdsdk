"""
Declares the constraints (os, arch) for this toolchain
"""

def declare_constraints():
    native.alias(
        name = "linux",
        actual = "@bazel_tools//platforms:linux",
    )

    native.alias(
        name = "amd64",
        actual = "@bazel_tools//platforms:x86_64",
    )

    native.platform(
        name = "linux_amd64",
            constraint_values = [
                ":linux",
                ":amd64",
            ],
    )