package pax

BACKEND :: Backend.SDL2

Backend :: enum
{
    SDL2,
}

when BACKEND == .SDL2 {
    backend_init    :: sdl2_backend_init
    backend_destroy :: sdl2_backend_destroy

    poll_event :: sdl2_poll_event

    keyboard_key_to_button :: sdl2_keyboard_key_to_button

    Window_Handle :: sdl2_Window_Handle

    window_init    :: sdl2_window_init
    window_destroy :: sdl2_window_destroy
    window_size    :: sdl2_window_size
}
