"""
This file hosts functions for creating and importing
toolchains. Useful parts:

    - fdsdk_register_toolchains: registers the imported toolchain with bazel
    - _fdsdk_import_sdk_impl: loads a toolchain from a tarball
"""

load("@rules_bst//bst/private:providers.bzl", "FDSDK")

def _detect_sdk_platform(rctx):
    """TODO dynamic sdk detection"""
    return "linux_amd64"

def _fdsdk_import_sdk_impl(rctx):
    print("Loading fdsdk from {}".format(rctx.attr.path))
    rctx.report_progress("Extracting")
    rctx.extract(rctx.attr.path)
    platform = _detect_sdk_platform(rctx)
    _sdk_build_file(rctx, platform)

_fdsdk_import_sdk = repository_rule(
    _fdsdk_import_sdk_impl,
    attrs = {
        "path": attr.string(),
    },
)

def _fdsdk_download_sdk_impl(rctx):
    print("Downloading fdsdk from {}".format(rctx.attr.url))
    rctx.report_progress("Downloading")
    rctx.download_and_extract(rctx.attr.url)
    platform = _detect_sdk_platform(rctx)
    _sdk_build_file(rctx, platform)

_fdsdk_download_sdk = repository_rule(
    _fdsdk_download_sdk_impl,
    attrs = {
        "url": attr.string(),
    },
)

def _sdk_build_file(rctx, platform):
    rctx.file("ROOT")
    fdos, _, fdarch = platform.partition("_")
    print("Building template")
    rctx.template(
        "BUILD.bazel",
        Label("@rules_bst//bst/private:BUILD.sdk.bazel"),
        executable = False,
        substitutions = {
            "{fdos}": fdos,
            "{fdarch}": fdarch,
            "{exe}": ".exe" if fdos == "windows" else "",
        },
    )

def fdsdk_import_sdk(name, **kwargs):
    """Declares the import sdk repository rule and registers the toolchains."""
    print("Import and register SDK")
    _fdsdk_import_sdk(name = name, **kwargs)
    _register_toolchains(name)

def fdsdk_download_sdk(name, **kwargs):
    """Declares the import sdk repository rule and registers the toolchains."""
    print("Download and register SDK")
    _fdsdk_download_sdk(name = name, **kwargs)
    _register_toolchains(name)

def _register_toolchains(repo):
    labels = [
        "@{}//:{}".format(repo, name)
        for name in ["fdsdk_linux_amd64"]  # TODO make dynamic
    ]
    print("Generated labels: {}".format(labels))
    native.register_toolchains(*labels)  # TODO not loading? ...
    print("Registered new labels")

def fdsdk_register_toolchains(url = None, path = None):
    """
    Finds and registers the given FDSDK toolchain from a
    path or git ref, 

    :param git_ref: TODO If a git ref is given, it will build a new toolchain
    from that ref using buildstream.
    :param path: The path of a fdsdk tarball.
    """
    sdk_kinds = ("_fdsdk_download_sdk", "_fdsdk_import_sdk")
    existing_rules = native.existing_rules()
    sdk_rules = [r for r in existing_rules.values() if r["kind"] in sdk_kinds]

    print("Found {} rules, {} from fdsdk : {}".format(len(existing_rules), len(sdk_rules), sdk_rules))

    if len(sdk_rules) > 0:
        fail("Only one FDSDK can be loaded")
        
    if url:
        fdsdk_download_sdk(name = "fdsdk_sdk", url = url)
    elif path:
        fdsdk_import_sdk(name = "fdsdk_sdk", path = path)
    else:
        fail("Must define either the url or path")

def _fdsdk_sdk_impl(ctx):
    # TODO
    # package_list = ctx.file.package_list
    # if package_list == None:
    #     package_list = ctx.actions.declare_file("packages.txt")
    #     _build_package_list(ctx, ctx.files.srcs, ctx.file.root_file, package_list)
    return [FDSDK(
        fdos = ctx.attr.fdos,
        fdarch = ctx.attr.fdarch,
        tools = ctx.files.tools,
        root_file = ctx.file.root_file,
    )]

fdsdk_sdk = rule(
    _fdsdk_sdk_impl,
    attrs = {
        "fdos": attr.string(
            mandatory = True,
            doc = "The host OS the SDK was built for",
        ),
        "fdarch": attr.string(
            mandatory = True,
            doc = "The host architecture the SDK was built for",
        ),
        "root_file": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "A file in the SDK root directory.",
        ),
        "tools": attr.label_list(
            allow_files = True,
            cfg = "host",
            doc = ("List of executable files in the SDK built for " +
                   "the execution platform."),
        ),
    },
    doc = ("Collects information about a FD SDK."),
    provides = [FDSDK],
)
