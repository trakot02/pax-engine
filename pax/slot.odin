package pax

import "core:log"

//
// Definitions
//

Slot_Table :: struct ($T: typeid)
{
    first: int,
    count: int,
    last:  int,
    outer: [dynamic]int,
    inner: [dynamic]int,
    items: [dynamic]T,
}

Slot_Table_Iter :: struct ($T: typeid)
{
    table: ^Slot_Table(T),
    index: int,
}

//
// Functions
//

slot_table_init :: proc($T: typeid, allocator := context.allocator) -> Slot_Table(T)
{
    return Slot_Table(T) {
        outer = make([dynamic]int, allocator),
        inner = make([dynamic]int, allocator),
        items = make([dynamic]T, allocator),
    }
}

slot_table_destroy :: proc(self: ^Slot_Table($T))
{
    delete(self.items)
    delete(self.inner)
    delete(self.outer)

    self.first = 0
    self.count = 0
    self.last  = 0
    self.outer = {}
    self.inner = {}
    self.items = {}
}

slot_table_len :: proc(self: ^Slot_Table($T)) -> int
{
    return self.last
}

slot_table_clear :: proc(self: ^Slot_Table($T))
{
    clear(&self.outer)
    clear(&self.inner)
    clear(&self.items)

    self.first = 0
    self.count = 0
    self.last  = 0
}

slot_table_insert :: proc(self: ^Slot_Table($T), value: T) -> int
{
    slot := len(self.items) + 1

    switch self.count <= 0 {
        case true: {
            _, error := append(&self.items, value)

            if error == nil { _, error = append(&self.outer, slot) }
            if error == nil { _, error = append(&self.inner, slot) }

            if error != nil {
                resize(&self.outer, slot - 1)
                resize(&self.inner, slot - 1)
                resize(&self.items, slot - 1)

                log.errorf("Slot_Table: Unable to insert value")

                return {}
            }
        }

        case false: {
            slot := self.first
            next := self.outer[slot - 1]

            self.outer[slot - 1] = self.last + 1

            self.inner[self.last] = slot
            self.items[self.last] = value

            self.first  = next + 1
            self.count -= 1
        }
    }

    self.last += 1

    return slot
}

slot_table_remove :: proc(self: ^Slot_Table($T), slot: int) -> (T, bool)
{
    if slot <= 0 || slot > len(self.outer) {
        return {}, false
    }

    index := self.outer[slot - 1]

    if index <= 0 || index > len(self.inner) {
        return {}, false
    }

    other := self.inner[index - 1]

    if other == slot && self.last > 0 {
        value := self.items[index - 1]

        self.items[index - 1] = self.items[self.last - 1]
        self.inner[index - 1] = self.inner[self.last - 1]

        self.outer[slot - 1] = self.first

        self.first  = slot
        self.count += 1
        self.last  -= 1

        return value, true
    }

    return {}, false
}

slot_table_find :: proc(self: ^Slot_Table($T), slot: int) -> Handle(T)
{
    handle := Handle(T) {}

    if slot <= 0 || slot > len(self.outer) {
        return handle
    }

    index := self.outer[slot - 1]

    if index <= 0 || index > len(self.inner) {
        return handle
    }

    other := self.inner[index - 1]

    if other == slot {
        handle.slot  = slot
        handle.value = &self.items[index - 1]
    }

    return handle
}

slot_table_iter :: proc(self: ^Slot_Table($T)) -> Slot_Table_Iter(T)
{
    return Slot_Table_Iter(T) {
        table = self,
        index = 0,
    }
}

slot_table_next :: proc(self: ^Slot_Table_Iter($T)) -> (^T, int, bool)
{
    if self.index < 0 || self.index >= self.table.last {
        return nil, 0, false
    }

    value := &self.table.items[self.index]
    slot  := self.index + 1

    self.index = slot

    return value, slot, true
}
