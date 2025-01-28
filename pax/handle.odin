package pax

//
// Definitions
//

Handle :: struct($T: typeid)
{
    slot:  int,
    value: ^T,
}
