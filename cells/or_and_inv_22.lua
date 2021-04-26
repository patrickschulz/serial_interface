--[[
A1 ---- OR
        OR
A2 ---- OR ---- NAND 
                NAND ---- Z
B1 ---- OR ---- NAND
        OR
B2 ---- OR
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settin

    -- place cells
    pcell.push_overwrites("logic/base", {rightdummies = 1})
    local orgate_a = pcell.create_layout("logic/or_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(orgate_a)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {leftdummies = 1, rightdummies = 1})
    local orgate_b = pcell.create_layout("logic/or_gate"):move_anchor("left",
                                                                      orgate_a:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(orgate_b)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {leftdummies = 1})
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left",
                                                                        orgate_b:get_anchor(
                                                                            "right"))
    gate:merge_into_update_alignmentbox(nandgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        orgate_a:get_anchor("Z"), nandgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate_a:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        nandgate:get_anchor("B")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        orgate_b:get_anchor("Z") + point.create(0, bp.sdwidth),
        nandgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate_b:get_anchor("Z") + point.create(0, bp.sdwidth)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        nandgate:get_anchor("A")))

    -- draw ports
    gate:add_port("A1", generics.metal(1), orgate_a:get_anchor("A"))
    gate:add_port("A2", generics.metal(1), orgate_a:get_anchor("B"))
    gate:add_port("B1", generics.metal(1), orgate_b:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), orgate_b:get_anchor("B"))
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
