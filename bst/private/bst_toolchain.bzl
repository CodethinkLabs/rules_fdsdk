"""

"""

load("@rules_bst//bst/private:providers.bzl", "FDSDK")

def _fdsdk_toolchain_impl(ctx):
    sdk = ctx.attr.sdk[FDSDK]
    cross_compile = ctx.attr.fdos != sdk.fdos or ctx.attr.fdarch != sdk.fdarch
    return [platform_common.ToolchainInfo(
        # Public fields
        name = ctx.label.name,
        cross_compile = cross_compile,
        default_fdos = ctx.attr.fdos,
        default_fdarch = ctx.attr.fdarch,
        actions = struct(
            # TODO decide on actions
        ),
        flags = struct(
            # TODO flags
        ),
        sdk = sdk,

        # Internal fields -- may be read by emit functions.
        _builder = ctx.executable.builder,
    )]

_fdsdk_toolchain = rule(
    _fdsdk_toolchain_impl,
    attrs = {
        "fdos": attr.string(
            mandatory = True,
            doc = "Default target OS",
        ),
        "fdarch": attr.string(
            mandatory = True,
            doc = "Default target architecture",
        ),
        "sdk": attr.label(
            mandatory = True,
            providers = [FDSDK],
            doc = "The SDK this toolchain is based on",
        ),
    },
    doc = "Defines a FD toolchain.",
    provides = [platform_common.ToolchainInfo],
)

def fdsdk_toolchain(name, target, sdk, host = None, constraints = [], **kwargs):
    """See go/toolchains.rst#go-toolchain for full documentation."""

    if not host:
        host = target
    fdos, _, fdarch = target.partition("_")
    target_constraints = constraints + [
        "@rules_bst//bst/toolchain:" + fdos,
        "@rules_bst//bst/toolchain:" + fdarch,
    ]
    host_fdos, _, host_fdarch = host.partition("_")
    exec_constraints = [
        "@rules_bst//bst/toolchain:" + host_fdos,
        "@rules_bst//bst/toolchain:" + host_fdarch,
    ]

    impl_name = name + "-impl"
    _fdsdk_toolchain(
        name = impl_name,
        fdos = fdos,
        fdarch = fdarch,
        sdk = sdk,
        tags = ["manual"],
        visibility = ["//visibility:public"],
        **kwargs
    )
    native.toolchain(
        name = name,
        toolchain_type = "@rules_bst//bst:toolchain",
        exec_compatible_with = exec_constraints,
        target_compatible_with = target_constraints,
        toolchain = ":" + impl_name,
    )

def generate_toolchains(host, sdk):
    host_fdos, _, host_fdarch = host.partition("_")
    toolchains = []
    for target_fdos, target_fdarch in [("linux", "amd64")]: #TODO make dynamic
        target = "{}_{}".format(target_fdos, target_fdarch)
        toolchain_name = "fdsdk_" + target

        # Add the primary toolchain
        toolchains.append(dict(
            name = toolchain_name,
            host = host,
            target = target,
            sdk = sdk,
        ))
    return toolchains

def declare_toolchains(host, sdk):
    # Use the final dictionaries to create all the toolchains
    for toolchain in generate_toolchains(host, sdk):
        fdsdk_toolchain(**toolchain)
