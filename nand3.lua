

--[[
A1 ---- AND
        AND
A2 ---- AND ---- NAND 
                 NAND ---- Z
A3 ------------- NAND
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- place cells
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate)


    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left",
                                                                      andgate:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(nandgate)

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        andgate:get_anchor("Z"), nandgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        nandgate:get_anchor("A")))


    -- draw ports
    gate:add_port("A1", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("A2", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("A3", generics.metal(1), nandgate:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), nandgate:get_anchor("Z"))
end