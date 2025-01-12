package res

import "core:log"

Item :: union ($T: typeid)
{
    T, int
}

Holder :: struct ($T: typeid)
{
    //
    //
    //
    first: int,

    //
    //
    //
    count: int,

    //
    //
    //
    items: [dynamic]Item(T)
}

Handle :: struct ($T: typeid)
{
    //
    //
    //
    value: ^T,

    //
    //
    //
    slot: int,
}

//
//
//
holder_init :: proc(self: ^Holder($T), allocator := context.allocator)
{
    self.items = make([dynamic]Item(T), allocator)
}

//
//
//
holder_destroy :: proc(self: ^Holder($T))
{
    delete(self.items)

    self.first = 0
    self.count = 0
    self.items = {}
}

//
//
//
holder_clear :: proc(self: ^Holder($T))
{
    clear(&self.items)

    self.first = 0
    self.count = 0
}

//
//
//
holder_insert :: proc(self: ^Holder($T), value: T) -> (int, bool)
{
    slot  := self.first
    index := slot - 1

    switch self.count <= 0 {
        case true: {
            _, error := append(&self.items, value)

            slot = len(self.items)

            if error != nil {
                log.errorf("Holder: Unable to insert value")

                return {}, false
            }
        }

        case false: {
            // The item should be in the list.
            next := self.items[index].(int)

            self.items[index] = value

            self.first  = next + 1
            self.count -= 1
        }
    }

    return slot, true
}

//
//
//
holder_remove :: proc(self: ^Holder($T), slot: int) -> (T, bool)
{
    index := slot - 1

    if 0 <= index && index < len(self.items) {
        // The item could be inside the list.
        #partial switch value in self.items[index] {
            case T: {
                self.items[index] = self.first

                self.first  = slot
                self.count += 1

                return value, true
            }
        }
    }

    return {}, false
}

//
//
//
holder_find :: proc(self: ^Holder($T), slot: int) -> Handle(T)
{
    handle := Handle(T) {}
    index  := slot - 1

    if 0 <= index && index < len(self.items) {
        // The slot could be inside the list.
        #partial switch &value in self.items[index] {
            case T: {
                handle.slot  = slot
                handle.value = &value
            }
        }
    }

    return handle
}
