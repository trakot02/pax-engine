package demo

import       "core:fmt"
import       "core:log"
import mathl "core:math/linalg"

import "../pax"

MAIN_SCENE := int(0)

main :: proc()
{
    context.logger = log.create_console_logger()

    app        := pax.App {}
    main_value := Main_Scene {}

    if pax.app_init(&app) == false { return }

    MAIN_SCENE = pax.app_insert_scene(&app, main_scene(&main_value))

    pax.app_loop(&app, {
        first_scene    = MAIN_SCENE,
        max_frame_rate = 128,
        max_frame_skip = 16,
    })

    pax.app_destroy(&app)
}
