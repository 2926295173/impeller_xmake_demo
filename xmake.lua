-- 项目设置
set_xmakever("2.7.8")
set_project("impeller_demo")

-- Impeller SDK 配置
add_rules("mode.debug", "mode.release")

-- 定义平台和架构变量
rule("impeller_sdk")
    on_load(function(target)
        local platform_map = {
            ["macosx"] = "darwin",
            ["linux"] = "linux",
            ["windows"] = "windows"
        }
        local arch_map = {
            ["arm64"] = "arm64",
            ["x86_64"] = "x64"
        }
        
        -- 设置平台和架构
        target:set("IMPELLER_PLATFORM", platform_map[get_plat()] or "unknown")
        target:set("IMPELLER_ARCH", arch_map[get_arch()] or "unknown")
        target:set("IMPELLER_SDK_SHA", "b7c3af43f90ac9aaf66dbd10b922c25addd9c3db")

        
        -- 动态库名称设置
        target:set("IMPELLER_DYLIB", format("libimpeller.%s", get_plat() == "macosx" and "dylib" or (get_plat() == "windows" and "dll" or "so")))
    end)

-- 下载 Impeller SDK
add_requires("impeller_sdk", {
    system = false,
    url = "https://storage.googleapis.com/flutter_infra_release/flutter/${IMPELLER_SDK_SHA}/${IMPELLER_PLATFORM}-${IMPELLER_ARCH}/impeller_sdk.zip",
    configs = {
        IMPELLER_SDK_SHA = "${IMPELLER_SDK_SHA}",
        impeller_platform = "${IMPELLER_PLATFORM}",
        impeller_arch = "${IMPELLER_ARCH}",
    }
})

-- GLFW 配置
add_requires("glfw 3.4", {system = false, url = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz"})

-- 目标配置
target("impeller_demo")
    set_kind("binary")
    add_files("demo.c")
    add_includedirs("$(env IMPELLER_SDK)/include")
    add_links("glfw", "impeller")
    add_linkdirs("$(env IMPELLER_SDK)/lib")
    add_rpathdirs("$(env IMPELLER_SDK)/lib")
    add_packages("impeller_sdk", "glfw")

    -- macOS 特殊处理
    if is_plat("macosx") then
        add_ldflags("-pagezero_size 10000 -image_base 100000000")
    end
