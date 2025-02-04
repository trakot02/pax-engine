package pax

//
// Definitions
//

Handle :: struct($T: typeid)
{
    ident: int,
    value: ^T,
}
