# ==============================================================================
# GPIO Peripheral RTL Build Configuration
# ==============================================================================
# Placeholder for future GPIO peripheral implementation
# ==============================================================================

# Auto-discover GPIO RTL if present
file(GLOB GPIO_RTL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/*.sv"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.v"
)

if(GPIO_RTL_SOURCES)
    add_custom_target(rtl_gpio
        COMMENT "GPIO peripheral RTL"
        SOURCES ${GPIO_RTL_SOURCES}
    )
    
    set(RV64I_GPIO_RTL_SOURCES ${GPIO_RTL_SOURCES} PARENT_SCOPE)
    
    message(STATUS "GPIO RTL files: ${CMAKE_CURRENT_SOURCE_DIR}")
    foreach(rtl_file ${GPIO_RTL_SOURCES})
        get_filename_component(filename ${rtl_file} NAME)
        message(STATUS "  - ${filename}")
    endforeach()
else()
    message(STATUS "GPIO RTL: placeholder (no sources yet)")
endif()
