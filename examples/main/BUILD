cc_library(
    name = "hello-greet",
    srcs = ["hello-greet.cc"],
    hdrs = ["hello-greet.h"],
)

cc_binary(
    name = "hello-world",
    srcs = ["hello-world.cc"],
    toolchains = ["@fdsdk_sdk//:fdsdk_linux_amd64"],
    deps = [
        ":hello-greet",
        "//examples/lib:hello-time",
    ],
)
