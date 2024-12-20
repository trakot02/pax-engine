package pax

import "core:log"

Registry :: struct($T: typeid)
{
    //
    //
    //
    instance: rawptr,

    //
    //
    //
    clear_proc: proc(self: rawptr, value: ^T),

    //
    //
    //
    read_proc: proc(self: rawptr, name: string) -> (T, bool),

    //
    // todo (trakot02): In the future...
    //
    // write_proc: proc(self: rawptr, name: string, value: ^T) -> bool,

    //
    //
    //
    values: [dynamic]T,
}

//
//
//
registry_init :: proc(self: ^Registry($T), allocator := context.allocator)
{
    self.values = make([dynamic]T, allocator)
}

//
//
//
registry_destroy :: proc(self: ^Registry($T))
{
    delete(self.values)
}

//
//
//
registry_insert :: proc(self: ^Registry($T), value: T) -> (int, bool)
{
    index, error := append(&self.values, value)

    if error != nil {
        log.errorf("Registry(%v): Unable to insert %v\n", typeid_of(T), value)

        return 0, false
    }

    return index + 1, true
}

//
//
//
registry_remove :: proc(self: ^Registry($T), resource: int)
{
    log.errorf("Registry(%v): Not implemented yet", typeid_of(T))
}

//
//
//
registry_clear :: proc(self: ^Registry($T))
{
    for &value in self.values {
        self.clear_proc(self.instance, &value)
    }

    clear(&self.values)
}

//
//
//
registry_find :: proc(self: ^Registry($T), resource: int) -> (^T, bool)
{
    count := len(self.values)
    index := resource - 1

    if 0 <= index && index < count {
        return &self.values[index], true
    }

    return nil, false
}

//
//
//
registry_read :: proc(self: ^Registry($T), name: string) -> bool
{
    value, state := self.read_proc(self.instance, name)

    switch state {
        case true:
            registry_insert(self, value) or_return

        case false:
            log.errorf("Registry(%v): Unable to read %q\n", typeid_of(T), name)
    }

    return state
}

//
//
//
registry_read_many :: proc(self: ^Registry($T), names: []string) -> bool
{
    for name in names {
        registry_read(self, name) or_return
    }

    return true
}
