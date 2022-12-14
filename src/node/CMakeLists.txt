add_library(realm-js SHARED
    node_init.cpp
    platform.cpp
    ${CMAKE_JS_SRC}
)

set_target_properties(realm-js PROPERTIES
    OUTPUT_NAME "realm"
    PREFIX ""
    SUFFIX ".node"
)

if(WIN32)
    set_source_files_properties(node_init.cpp PROPERTIES
        # see https://docs.microsoft.com/en-us/cpp/build/reference/bigobj-increase-number-of-sections-in-dot-obj-file?view=msvc-160#remarks
        COMPILE_FLAGS "/bigobj"
    )

    find_package(OpenSSL REQUIRED)
    target_link_libraries(realm-js OpenSSL::SSL)
    target_link_options(realm-js PRIVATE "/WHOLEARCHIVE:libssl.lib")
endif()

target_compile_definitions(realm-js PRIVATE
    REALM_HAVE_UV=1
    REALM_PLATFORM_NODE=1
)

if(REALM_JS_BUILD_CORE_FROM_SOURCE AND TARGET ObjectStore)
    # we need to tell ObjectStore to use the libuv provided by Node.js
    target_link_libraries(ObjectStore PUBLIC NodeJS)
    target_compile_definitions(ObjectStore PUBLIC
        REALM_HAVE_UV=1
        REALM_PLATFORM_NODE=1
    )
endif()

target_link_libraries(realm-js realm-js-shared NodeJS)
