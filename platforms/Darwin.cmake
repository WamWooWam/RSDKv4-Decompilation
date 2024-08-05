# PKG-CONFIG IS USED AS THE MAIN DRIVER
# bc cmake is inconsistent as fuuuckkk

find_package(PkgConfig REQUIRED)

add_executable(RetroEngine ${RETRO_FILES} ../dependencies/mac/cocoahelpers.mm)

#target_compile_options(RetroEngine PRIVATE -g -gdwarf-2 -gstrict-dwarf)
#target_link_options(RetroEngine PRIVATE -g -gdwarf-2 -gstrict-dwarf)

target_compile_options(RetroEngine PRIVATE -O3 -flto)
target_link_options(RetroEngine PRIVATE -O3 -flto)

target_compile_options(RetroEngine PRIVATE -I../dependencies/mac)
target_link_options(RetroEngine PRIVATE -L/opt/local/lib -lobjc -Wl,-framework,Foundation -Wl,-framework,OpenGL -Wl,-framework,AppKit)

target_compile_options(RetroEngine PRIVATE -mmacosx-version-min=10.4)
target_link_options(RetroEngine PRIVATE -mmacosx-version-min=10.4)

pkg_check_modules(OGG ogg)

if(NOT OGG_FOUND)
    set(COMPILE_OGG TRUE)
    message(NOTICE "libogg not found, attempting to build from source")
else()
    message("found libogg")
    target_link_libraries(RetroEngine ${OGG_STATIC_LIBRARIES})
    target_link_options(RetroEngine PRIVATE ${OGG_STATIC_LDLIBS_OTHER})
    target_compile_options(RetroEngine PRIVATE ${OGG_STATIC_CFLAGS})
endif()

pkg_check_modules(VORBIS vorbis vorbisfile) #idk what the names are

if(NOT VORBIS_FOUND)
    set(COMPILE_VORBIS TRUE)
    message(NOTICE "libvorbis not found, attempting to build from source")
else()
    message("found libvorbis")
    target_link_libraries(RetroEngine ${VORBIS_STATIC_LIBRARIES})
    target_link_options(RetroEngine PRIVATE ${VORBIS_STATIC_LDLIBS_OTHER})
    target_compile_options(RetroEngine PRIVATE ${VORBIS_STATIC_CFLAGS})
endif()

if(RETRO_USE_HW_RENDER)
    pkg_check_modules(GLEW glew)

    if(NOT GLEW_FOUND)
        message(NOTICE "could not find glew, attempting to build from source")

    else()
        message("found GLEW")
        target_link_libraries(RetroEngine ${GLEW_STATIC_LIBRARIES})
        target_link_options(RetroEngine PRIVATE ${GLEW_STATIC_LDLIBS_OTHER})
        target_compile_options(RetroEngine PRIVATE ${GLEW_STATIC_CFLAGS})
    endif()
endif()

if(RETRO_SDL_VERSION STREQUAL "2")
#    pkg_check_modules(SDL2 sdl2 REQUIRED)
   
    target_link_libraries(RetroEngine "")
    target_link_options(RetroEngine PRIVATE ./dependencies/mac/libSDL2-2.0.0.dylib)
    target_compile_options(RetroEngine PRIVATE -I/usr/local/include -D_THREAD_SAFE)
elseif(RETRO_SDL_VERSION STREQUAL "1")
    pkg_check_modules(SDL1 sdl1 REQUIRED)
    target_link_libraries(RetroEngine ${SDL1_STATIC_LIBRARIES})
    target_link_options(RetroEngine PRIVATE ${SDL1_STATIC_LDLIBS_OTHER})
    target_compile_options(RetroEngine PRIVATE ${SDL1_STATIC_CFLAGS})
endif()

if(RETRO_MOD_LOADER)
    set_target_properties(RetroEngine PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
endif()