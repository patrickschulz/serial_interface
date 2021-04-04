--[[ 
A -------------- NOR
                 NOR ---- Z
B1 ---- AND ---- NOR
        AND
B2 ---- AND
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 1})

    -- place cells
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate)
    pcell.pop_overwrites("logic/base")
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    local norgate = pcell.create_layout("logic/nor_gate"):move_anchor("left",
                                                                      andgate:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(norgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(1), {
        andgate:get_anchor("Z"), norgate:get_anchor("B")
    }, bp.sdwidth))

    --draw ports
    gate:add_port("A", generics.metal(1), norgate:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), norgate:get_anchor("Z"))
end
