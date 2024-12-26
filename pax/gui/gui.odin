package gui

List_Direction :: enum
{
    //
    //
    //
    ROW,

    //
    //
    //
    COL,
}

List_Alignment :: enum
{
    //
    //
    //
    SIMPLE,

    //
    //
    //
    STRETCH,
}

List_Layout :: struct
{
    //
    //
    //
    direction: List_Direction,

    //
    //
    //
    alignment: List_Alignment,

    //
    //
    //
    spacing: f32,
}

//
//
//
compute_list_size :: proc(self: ^Element, layout: List_Layout)
{
    rect  := self.offset
    count := 0

    for elem := self.first; elem != nil; elem = elem.next {
        compute_size(elem)

        switch layout.direction {
            case .COL: {
                rect.w += elem.absolute.w
                rect.z  = max(rect.z, elem.absolute.z)
            }

            case .ROW: {
                rect.z += elem.absolute.z
                rect.w  = max(rect.w, elem.absolute.w)
            }
        }

        count += 1
    }

    if layout.alignment == .STRETCH {
        for elem := self.first; elem != nil; elem = elem.next {
            switch layout.direction {
                case .COL: elem.absolute.z = rect.z
                case .ROW: elem.absolute.w = rect.w
            }
        }
    }

    if count != 0 {
        switch layout.direction {
            case .COL: rect.w += layout.spacing * f32(count - 1)
            case .ROW: rect.z += layout.spacing * f32(count - 1)
        }
    }

    self.absolute = rect
}

//
//
//
compute_list_pos :: proc(self: ^Element, layout: List_Layout)
{
    compute_base_pos(self)

    rect := self.absolute

    for elem := self.first; elem != nil; elem = elem.next {
        switch layout.direction {
            case .COL: {
                elem.absolute.xy  = elem.offset.xy  + rect.xy
                elem.absolute.x  -= elem.origin.x   * elem.absolute.z
                elem.absolute.x  += elem.relative.x * self.absolute.z

                rect.y  = elem.absolute.y
                rect.y += elem.absolute.w + layout.spacing

                for elem := elem.first; elem != nil; elem = elem.next {
                    compute_pos(elem)
                }
            }

            case .ROW: {
                elem.absolute.xy  = elem.offset.xy  + rect.xy
                elem.absolute.y  -= elem.origin.y   * elem.absolute.w
                elem.absolute.y  += elem.relative.y * self.absolute.w

                rect.x  = elem.absolute.x
                rect.x += elem.absolute.z + layout.spacing

                for elem := elem.first; elem != nil; elem = elem.next {
                    compute_pos(elem)
                }
            }
        }
    }
}

Layout :: union
{
    //
    //
    //
    List_Layout,
}

//
//
//
compute_base_size :: proc(self: ^Element)
{
    self.absolute.zw = self.offset.zw

    if self.parent != nil {
        self.absolute.zw += self.parent.absolute.zw *
            self.relative.zw
    }
}

//
//
//
compute_base_pos :: proc(self: ^Element)
{
    self.absolute.xy  = self.offset.xy
    self.absolute.xy -= self.origin * self.absolute.zw

    if self.parent != nil {
        self.absolute.xy += self.parent.absolute.zw *
            self.relative.xy + self.parent.absolute.xy
    }
}

Element :: struct
{
    //
    //
    //
    absolute: [4]f32,

    //
    //
    //
    relative: [4]f32,

    //
    //
    //
    origin: [2]f32,

    //
    //
    //
    offset: [4]f32,

    //
    //
    //
    layout: Layout,

    //
    //
    //
    parent: ^Element,

    //
    //
    //
    first: ^Element,

    //
    //
    //
    last: ^Element,

    //
    //
    //
    prev: ^Element,

    //
    //
    //
    next: ^Element,
}

//
//
//
compute_size :: proc(self: ^Element)
{
    if self == nil { return }

    switch type in self.layout {
        case List_Layout: compute_list_size(self, type)

        case nil: {
            compute_base_size(self)

            for elem := self.first; elem != nil; elem = elem.next {
                compute_size(elem)
            }
        }
    }
}

//
//
//
compute_pos :: proc(self: ^Element)
{
    if self == nil { return }

    switch type in self.layout {
        case List_Layout: compute_list_pos(self, type)

        case nil: {
            compute_base_pos(self)

            for elem := self.first; elem != nil; elem = elem.next {
                compute_pos(elem)
            }
        }
    }
}

//
//
//
compute :: proc(root: ^Element)
{
    assert(root.parent == nil, "Given element is not root")

    compute_size(root)
    compute_pos(root)
}
