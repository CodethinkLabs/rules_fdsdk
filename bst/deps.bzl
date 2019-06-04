load(
    "@rules_bst//bst/private:sdk.bzl",
    _fdsdk_download_sdk = "fdsdk_download_sdk",
    _fdsdk_import_sdk = "fdsdk_import_sdk",
    _fdsdk_register_toolchains = "fdsdk_register_toolchains",
)

fdsdk_register_toolchains = _fdsdk_register_toolchains
fdsdk_download_sdk = _fdsdk_download_sdk
fdsdk_import_sdk = _fdsdk_import_sdk
