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
function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

<<<<<<< HEAD
    local xpitch = bp.gspace + bp.glength

    -- or gate c
    pcell.push_overwrites("logic/base", {rightdummies = 1})
    local orgate_c = pcell.create_layout("logic/or_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(orgate_c)
    pcell.pop_overwrites("logic/base")

    -- and gate
    pcell.push_overwrites("logic/base", {leftdummies = 1, rightdummies = 1})
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("left", orgate_c:get_anchor( "right"))
    gate:merge_into_update_alignmentbox(andgate)
    pcell.pop_overwrites("logic/base")

    -- or gate b
    pcell.push_overwrites("logic/base", {leftdummies = 1, rightdummies = 1})
    local orgate_b = pcell.create_layout("logic/or_gate"):move_anchor("left", andgate:get_anchor( "right"))
    gate:merge_into_update_alignmentbox(orgate_b)
    pcell.pop_overwrites("logic/base")

    -- nand gate
    pcell.push_overwrites("logic/base", {leftdummies = 1})
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left", orgate_b:get_anchor( "right"))
    gate:merge_into_update_alignmentbox(nandgate)
=======
    -- or gate c
    pcell.push_overwrites("logic/base", { rightdummies = 1})
    local orgate_c = pcell.create_layout("logic/or_gate"):move_anchor("right")
    gate:merge_into(orgate_c)
    pcell.pop_overwrites("logic/base")

    -- and gate
    pcell.push_overwrites("logic/base", { leftdummies = 1, rightdummies = 1})
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("left", orgate_c:get_anchor( "right"))
    gate:merge_into(andgate)
    pcell.pop_overwrites("logic/base")

    -- or gate b
    pcell.push_overwrites("logic/base", { leftdummies = 1, rightdummies = 1})
    local orgate_b = pcell.create_layout("logic/or_gate"):move_anchor("left", andgate:get_anchor( "right"))
    gate:merge_into(orgate_b)
    pcell.pop_overwrites("logic/base")

    -- nand gate
    pcell.push_overwrites("logic/base", { leftdummies = 1 })
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left", orgate_b:get_anchor( "right"))
    gate:merge_into(nandgate)
>>>>>>> 6654b638eb623f73641a4b81aecbf3c15510c65e
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        orgate_c:get_anchor("Z"), andgate:get_anchor("B")
    }, bp.sdwidth))
<<<<<<< HEAD
    gate:merge_into(geometry.path_xy(generics.metal(1), {
        orgate_b:get_anchor("Z"), nandgate:get_anchor("B")
=======
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        orgate_b:get_anchor("Z"), nandgate:get_anchor("A")
>>>>>>> 6654b638eb623f73641a4b81aecbf3c15510c65e
    }, bp.sdwidth))
    gate:merge_into(geometry.path_yx(generics.metal(2), {
        andgate:get_anchor("Z"), nandgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength,
                                       bp.sdwidth):translate(
                        andgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength,
                                       bp.sdwidth):translate(
                        nandgate:get_anchor("B")))

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
