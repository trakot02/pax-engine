package pax

import "core:log"

Resource :: struct
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
    values: [dynamic]int,
}

//
//
//
resource_init :: proc(self: ^Resource, allocator := context.allocator)
{
    self.values = make([dynamic]int, allocator)
}

//
//
//
resource_destroy :: proc(self: ^Resource)
{
    delete(self.values)

    self.count  = 0
    self.first  = 0
    self.values = {}
}

//
//
//
resource_create :: proc(self: ^Resource) -> (int, bool)
{
    if self.count <= 0 {
        index    := len(self.values)
        _, error := append(&self.values, index)

        if error != nil {
            log.errorf("Resource: Unable to create a new resource")

            return 0, false
        }

        return index + 1, true
    }

    index := self.first - 1
    next  := self.values[index]

    self.values[index] = index

    self.first  = next + 1
    self.count -= 1

    return index + 1, true
}

//
//
//
resource_delete :: proc(self: ^Resource, resource: int) -> bool
{
    index := resource - 1

    if 0 <= index && index < len(self.values) {
        value := self.values[index]

        if value == index {
            self.values[index] = self.first

            self.first  = resource
            self.count += 1

            return true
        }
    }

    log.errorf("Resource: Unable to delete resource %v",
        resource)

    return false
}

//
//
//
resource_clear :: proc(self: ^Resource)
{
    clear(&self.values)

    self.first = 0
    self.count = 0
}

Registry :: struct($T: typeid)
{
    //
    //
    //
    count: int,

    //
    //
    //
    transl: [dynamic]int,

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
    self.transl = make([dynamic]int, allocator)
    self.values = make([dynamic]T,   allocator)
}

//
//
//
registry_destroy :: proc(self: ^Registry($T))
{
    delete(self.values)
    delete(self.transl)

    self.count  = 0
    self.transl = {}
    self.values = {}
}

//
//
//
registry_insert :: proc(self: ^Registry($T), resource: int, value: T) -> (^T, bool)
{
    if resource <= 0 { return nil, false }

    if resource > self.count {
        error := resize(&self.transl, resource)

        if error == nil {
            error = resize(&self.values, self.count + 1)
        }

        if error != nil {
            log.errorf("Registry: Unable to insert a value for resource %v",
                resource)

            return nil, false
        }
    }

    index := self.count

    self.count += 1

    self.transl[resource - 1] = index + 1
    self.values[index]        = value

    return &self.values[index], true
}

//
//
//
registry_remove :: proc(self: ^Registry($T), resource: int) -> (^T, bool)
{
    log.errorf("Registry: Not implemented yet")

    return nil, false
}

//
//
//
registry_clear :: proc(self: ^Registry($T))
{
    clear(&self.values)
    clear(&self.transl)

    self.count = 0
}

//
//
//
registry_find :: proc(self: ^Registry($T), resource: int) -> (^T, bool)
{
    index := resource - 1

    if 0 <= index && index < len(self.transl) {
        index = self.transl[index] - 1

        if 0 <= index && index < self.count {
            return &self.values[index], true
        }
    }

    return nil, false
}
