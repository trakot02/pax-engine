package pax

Handle :: struct($T: typeid)
{
    slot:  int,
    value: ^T,
}

handle_test :: proc(self: ^Handle($T)) -> bool
{
    return self.slot != 0
}
