cmake_minimum_required(VERSION 3.8)

project(theCrunchGame VERSION 2.4.1)

# set(CMAKE_CONFIGURATION_TYPES "Debug;RelWithDebInfo" CACHE STRING "" FORCE)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin")

include(GNUInstallDirs)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_subdirectory(extern/glad)
add_subdirectory(extern/glfw)
add_subdirectory(extern/imgui)
add_subdirectory(extern/sajson)
add_subdirectory(extern/box2d)
add_subdirectory(extern/portaudio)

set (TCG_SOURCE_FILES
	src/include/imgui_impl/imgui_impl_glfw.cpp
	src/include/imgui_impl/imgui_impl_glfw.h
	src/include/imgui_impl/imgui_impl_opengl3.cpp
	src/include/imgui_impl/imgui_impl_opengl3.h
	src/include/settings.h
	src/include/draw.h
	src/include/camera.h
	src/include/game.h
	src/include/part.h
	src/include/input.h
	src/include/ui.h
	src/include/action.h
	src/camera.cpp
	src/settings.cpp
	src/draw.cpp
	src/game.cpp
	src/part.cpp
	src/input.cpp
	src/ui.cpp
	src/action.cpp
	src/main.cpp
)

add_executable(theCrunchGame ${TCG_SOURCE_FILES})
target_include_directories(theCrunchGame PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(theCrunchGame PUBLIC box2d glfw imgui sajson glad portaudio)
set_target_properties(theCrunchGame PROPERTIES
	CXX_STANDARD 11
    	CXX_STANDARD_REQUIRED YES
	CXX_EXTENSIONS NO
)

# message(STATUS "runtime = ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
# message(STATUS "binary = ${CMAKE_CURRENT_BINARY_DIR}")

# Copy font files, etc
add_custom_command(
        TARGET theCrunchGame POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_CURRENT_SOURCE_DIR}/data/
                ${CMAKE_CURRENT_BINARY_DIR}/data/)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${TCG_SOURCE_FILES})
