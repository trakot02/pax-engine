package pax

//
// Variables
//

BACKEND :: Backend.SDL2

//
// Definitions
//

Backend :: enum
{
    SDL2,
    SDL3,
}

when BACKEND == .SDL2 {
    backend_init    :: sdl2_backend_init
    backend_destroy :: sdl2_backend_destroy

    keyboard_key_to_button :: sdl2_keyboard_key_to_button

    poll_event :: sdl2_poll_event

    Window :: sdl2_Window

    window_main          :: sdl2_window_main
    window_init          :: sdl2_window_init
    window_destroy       :: sdl2_window_destroy
    window_swap_buffers  :: sdl2_window_swap_buffers
    window_get_title     :: sdl2_window_get_title
    window_get_rect      :: sdl2_window_get_rect
    window_get_position  :: sdl2_window_get_position
    window_get_dimension :: sdl2_window_get_dimension
    window_get_visible   :: sdl2_window_get_visible
    window_get_decorated :: sdl2_window_get_decorated
    window_set_title     :: sdl2_window_set_title
    window_set_rect      :: sdl2_window_set_rect
    window_set_position  :: sdl2_window_set_position
    window_set_dimension :: sdl2_window_set_dimension
    window_set_visible   :: sdl2_window_set_visible
    window_set_decorated :: sdl2_window_set_decorated
}

when BACKEND == .SDL3 {}
