if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

if ("etw" IN_LIST FEATURES)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "linux" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "OSX") 
	    message(FATAL_ERROR "Feature 'ewt' does not support 'linux & osx'")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF v1.1.1
    SHA512 e14712f2085134ef0061a36a8ec77195e7a4def9cecb05c37e9c9c0752e59a42621c92166d2166eb8df4767e7b6ea2b39fdc9bcf925c6d66ccaf9f250421db55
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        etw WITH_ETW
        zipkin WITH_ZIPKIN
        prometheus WITH_PROMETHEUS
        elasticsearch WITH_ELASTICSEARCH
        jaeger WITH_JAEGER
        otlp WITH_OTLP
        zpages WITH_ZPAGES
)

# opentelemetry-proto is a third party submodule and opentelemetry-cpp release did not pack it.
if(WITH_OTLP)
    set(OTEL_PROTO_VERSION "0.11.0")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/open-telemetry/opentelemetry-proto/archive/v${OTEL_PROTO_VERSION}.tar.gz"
        FILENAME "opentelemetry-proto-${OTEL_PROTO_VERSION}.tar.gz"
        SHA512 ff6c207fe9cc2b6a344439ab5323b3225cf532358d52caf0afee27d9b4cd89195f6da6b6e383fe94de52f60c772df8b477c1ea943db67a217063c71587b7bb92
    )

    vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH}/third_party)
    file(REMOVE_RECURSE ${SOURCE_PATH}/third_party/opentelemetry-proto)
    file(RENAME ${SOURCE_PATH}/third_party/opentelemetry-proto-${OTEL_PROTO_VERSION} ${SOURCE_PATH}/third_party/opentelemetry-proto)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
