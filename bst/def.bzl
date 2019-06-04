load(
    "@rules_bst//bst/private:providers.bzl",
    _FDSDK = "FDSDK",
)

load(
    "@rules_bst//bst/private:bst_toolchain.bzl",
    _declare_toolchains = "declare_toolchains",
    _fdsdk_toolchain = "fdsdk_toolchain",
)

declare_toolchains = _declare_toolchains