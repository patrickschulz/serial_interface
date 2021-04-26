

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

    pcell.push_overwrites("logic/base", {rightdummies = 1})
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate)
    pcell.pop_overwrites("logic/base")


    pcell.push_overwrites("logic/base", {leftdummies = 1})
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left",
                                                                      andgate:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(nandgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(1), {
        andgate:get_anchor("Z"), nandgate:get_anchor("B")
    }, bp.sdwidth))


    -- draw ports
    gate:add_port("A1", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("A2", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("A3", generics.metal(1), nandgate:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), nandgate:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))
end