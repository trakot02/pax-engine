package test

import "core:fmt"

import "../pax"

Entity :: struct
{
    health: int,
}

main :: proc()
{
    table := pax.slot_table_init(Entity)

    e1 := pax.slot_table_insert(&table, Entity { health =  5 })
    e2 := pax.slot_table_insert(&table, Entity { health = 15 })
    e3 := pax.slot_table_insert(&table, Entity { health = 10 })

    iter := pax.slot_table_iter(&table)

    fmt.printf("loop: ")

    for value in pax.slot_table_next(&iter) {
        fmt.printf("%v ", value)
    }

    fmt.printf("\n%v, %v\n", pax.slot_table_remove(&table, e1))

    iter = pax.slot_table_iter(&table)

    fmt.printf("loop: ")

    for value in pax.slot_table_next(&iter) {
        fmt.printf("%v ", value)
    }

    fmt.printf("\n%v, %v\n", pax.slot_table_remove(&table, e3))

    iter = pax.slot_table_iter(&table)

    fmt.printf("loop: ")

    for value in pax.slot_table_next(&iter) {
        fmt.printf("%v ", value)
    }

    fmt.printf("\n%v, %v\n", pax.slot_table_remove(&table, e2))

    iter = pax.slot_table_iter(&table)

    fmt.printf("loop: ")

    for value in pax.slot_table_next(&iter) {
        fmt.printf("%v ", value)
    }

    fmt.printf("\n")
}
