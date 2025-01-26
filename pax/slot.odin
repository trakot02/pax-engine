package pax

import "core:log"

Slot :: union ($T: typeid)
{
    T, int
}

Slot_Table :: struct ($T: typeid)
{
    first: int,
    count: int,

    items: [dynamic]Slot(T),
}

Slot_Table_It :: struct ($T: typeid)
{
    table: ^Slot_Table(T),
    index: int,
}

slot_table_init :: proc(self: ^Slot_Table($T), allocator := context.allocator)
{
    self.items = make([dynamic]Slot(T), allocator)
}

slot_table_destroy :: proc(self: ^Slot_Table($T))
{
    delete(self.items)

    self.first = 0
    self.count = 0
    self.items = {}
}

slot_table_clear :: proc(self: ^Slot_Table($T))
{
    clear(&self.items)

    self.first = 0
    self.count = 0
}

slot_table_insert :: proc(self: ^Slot_Table($T), value: T) -> Handle(T)
{
    slot := self.first

    switch self.count <= 0 {
        case true: {
            _, error := append(&self.items, value)

            if error != nil {
                log.errorf("Slot_Table: Unable to insert value")

                return {}
            }

            slot = len(self.items)
        }

        case false: {
            next := self.items[slot - 1].(int)

            self.items[slot - 1] = value

            self.first  = next + 1
            self.count -= 1
        }
    }

    return slot_table_find(self, slot)
}

slot_table_remove :: proc(self: ^Slot_Table($T), slot: int) -> (T, bool)
{
    if slot <= 0 || slot > len(self.items) {
        return {}, false
    }

    #partial switch value in self.items[slot - 1] {
        case T: {
            self.items[slot - 1] = self.first

            self.first  = slot
            self.count += 1

            return value, true
        }
    }

    return {}, false
}

slot_table_find :: proc(self: ^Slot_Table($T), slot: int) -> Handle(T)
{
    handle := Handle(T) {}

    if slot <= 0 || slot > len(self.items) {
        return handle
    }

    #partial switch &value in self.items[slot - 1] {
        case T: {
            handle.slot  = slot
            handle.value = &value
        }
    }

    return handle
}

slot_table_size :: proc(self: ^Slot_Table($T)) -> int
{
    return len(self.items) - self.count
}

slot_table_it :: proc(self: ^Slot_Table($T)) -> Slot_Table_It(T)
{
    return {
        table = self,
        index = 1,
    }
}

slot_table_next :: proc(self: ^Slot_Table_It($T)) -> (^T, int, bool)
{
    handle := Handle(T) {}

    for ; handle_test(&handle) == false; self.index += 1 {
        if self.index > slot_table_size(self.table) {
            return nil, 0, false
        }

        handle = slot_table_find(self.table, self.index)
    }

    return handle.value, handle.slot, handle.slot != 0
}
