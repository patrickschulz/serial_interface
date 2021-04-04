
--[[
A1 ---- AND
        AND
A2 ---- AND ---- NAND 
                 NAND ---- Z
B1 ---- AND ---- NAND
        AND
B2 ---- AND
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- place cells
    local andgate_a = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate_a)
    pcell.pop_overwrites("logic/base")

    local andgate_b = pcell.create_layout("logic/and_gate"):move_anchor("left",
                                                                        andgate_a:get_anchor(
                                                                            "right"))
    gate:merge_into_update_alignmentbox(andgate_b)

    local norgate = pcell.create_layout("logic/nor_gate"):move_anchor("left",
                                                                      andgate_b:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(norgate)

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        andgate_a:get_anchor("Z"), norgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andgate_a:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        norgate:get_anchor("B")))

    gate:merge_into(geometry.path_xy(generics.metal(1), {
        andgate_b:get_anchor("Z"), norgate:get_anchor("A")
    }, bp.sdwidth))

    -- draw ports
    gate:add_port("A1", generics.metal(1), andgate_a:get_anchor("A"))
    gate:add_port("A2", generics.metal(1), andgate_a:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), andgate_b:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), andgate_b:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), norgate:get_anchor("Z"))
end