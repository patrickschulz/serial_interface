--[[
        C1 ---- OR 
                OR 
        C2 ---- OR ---- AND
                        AND ---- NAND
        A  ------------ AND      NAND
                                 NAND ---- Z
        B1 ---- OR               NAND
                OR ------------- NAND
        B2 ---- OR
]] -- 
function parameters() 
    pcell.reference_cell("logic/base") 
    pcell.add_parameter("flipconnection", false)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- or gate c
    pcell.push_overwrites("logic/base", {rightdummies = 0})
    local orgate_c = pcell.create_layout("logic/or_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(orgate_c)
    pcell.pop_overwrites("logic/base")

    local isogate = pcell.create_layout("logic/isogate")
    isogate:move_anchor("left", orgate_c:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- and gate
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(andgate)
    pcell.pop_overwrites("logic/base")

    isogate:move_anchor("left", andgate:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- or gate b
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})
    local orgate_b = pcell.create_layout("logic/or_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(orgate_b)
    pcell.pop_overwrites("logic/base")

    isogate:move_anchor("left", orgate_b:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- nand gate
    pcell.push_overwrites("logic/base", {leftdummies = 0})
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into_update_alignmentbox(nandgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        orgate_c:get_anchor("Z"), andgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        orgate_b:get_anchor("Z"), nandgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(andgate:get_anchor("Z"), {
            (_P.flipconnection and -1 or 1) * (bp.separation / 2 + bp.sdwidth / 2),
            nandgate:get_anchor("A")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength,
                                       bp.sdwidth):translate(
                        andgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength,
                                       bp.sdwidth):translate(
                        nandgate:get_anchor("A")))

    -- ports
    gate:add_port("A", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), orgate_b:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), orgate_b:get_anchor("B"))
    gate:add_port("C1", generics.metal(1), orgate_c:get_anchor("A"))
    gate:add_port("C2", generics.metal(1), orgate_c:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), nandgate:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end