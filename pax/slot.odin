package pax

import "core:log"

//
// Definitions
//

Slot_Table :: struct ($Val: typeid)
{
    // Head of the free identifiers' implicit list.
    list_head: int,

    // Size of the free identifiers' implicit list. If it's zero, the list is empty.
    list_size: int,

    // Logical size of the "items" array also used to track its next usable index.
    items_size: int,

    // Sparse array which maps a identifier to an index. If "inner[outer[x]] == x" the
    // identifier x has a value inside the table.
    outer: [dynamic]int,

    // Dense array which maps an index to a identifier. If "inner[outer[x]] == x" the
    // identifier x has a value inside the table.
    inner: [dynamic]int,

    // Dense array of values.
    items: [dynamic]Val,
}

Slot_Table_Iter :: struct ($Val: typeid)
{
    table: ^Slot_Table(Val),
    index: int,
}

//
// Functions
//

slot_table_init :: proc($Val: typeid, allocator := context.allocator) -> Slot_Table(Val)
{
    return Slot_Table(Val) {
        outer = make([dynamic]int, allocator),
        inner = make([dynamic]int, allocator),
        items = make([dynamic]Val, allocator),
    }
}

slot_table_destroy :: proc(self: ^Slot_Table($Val))
{
    delete(self.items)
    delete(self.inner)
    delete(self.outer)

    self.list_head  = {}
    self.list_size  = {}
    self.items_size = {}
    self.outer      = {}
    self.inner      = {}
    self.items      = {}
}

slot_table_len :: proc(self: ^Slot_Table($Val)) -> int
{
    return self.items_size
}

slot_table_clear :: proc(self: ^Slot_Table($Val))
{
    clear(&self.outer)
    clear(&self.inner)
    clear(&self.items)

    self.list_head  = {}
    self.list_size  = {}
    self.items_size = {}
}

slot_table_insert :: proc(self: ^Slot_Table($Val), value: Val) -> int
{
    ident := self.items_size + 1

    switch self.list_size <= 0 {
        // There are no identifiers to reuse.
        case true: {
            _, error := append(&self.items, value)

            if error == nil { _, error = append(&self.outer, ident) }
            if error == nil { _, error = append(&self.inner, ident) }

            if error != nil {
                resize(&self.outer, ident - 1)
                resize(&self.inner, ident - 1)
                resize(&self.items, ident - 1)

                log.errorf("Slot_Table: Unable to insert value")

                return 0
            }
        }

        // The list's head contains an identifier to reuse.
        case false: {
            ident := self.list_head

            self.list_head  = self.outer[ident - 1]
            self.list_size -= 1

            self.outer[ident - 1] = self.items_size + 1

            self.inner[self.items_size] = ident
            self.items[self.items_size] = value
        }
    }

    self.items_size += 1

    return ident
}

slot_table_remove :: proc(self: ^Slot_Table($Val), ident: int) -> (Val, bool)
{
    index := int {}
    other := int {}

    if self.items_size <= 0 { return {}, false }

    if 0 < ident && ident <= len(self.outer) {
        index = self.outer[ident - 1]

        if 0 < index && index <= len(self.inner) {
            other = self.inner[index - 1]
        }
    }

    if ident == other && other != 0 {
        value := self.items[index - 1]

        self.items_size -= 1

        self.items[index - 1] = self.items[self.items_size]
        self.inner[index - 1] = self.inner[self.items_size]

        self.outer[ident - 1] = self.list_head

        self.list_head  = ident
        self.list_size += 1

        return value, true
    }

    return {}, false
}

slot_table_find :: proc(self: ^Slot_Table($Val), ident: int) -> ^Val
{
    index  := int {}
    other  := int {}

    if self.items_size <= 0 { return nil }

    if 0 < ident && ident <= len(self.outer) {
        index = self.outer[ident - 1]

        if 0 < index && index <= len(self.inner) {
            other = self.inner[index - 1]
        }
    }

    if other == ident && other != 0 {
        return &self.items[index - 1]
    }

    return nil 
}

slot_table_iter :: proc(self: ^Slot_Table($Val)) -> Slot_Table_Iter(Val)
{
    return Slot_Table_Iter(Val) {
        table = self,
    }
}

slot_table_next :: proc(self: ^Slot_Table_Iter($Val)) -> (^Val, int, bool)
{
    count := self.table.items_size

    if self.index >= 0 && self.index < count {
        value := &self.table.items[self.index]
        ident := self.index + 1

        self.index = ident

        return value, ident, true
    }

    return nil, 0, false
}
