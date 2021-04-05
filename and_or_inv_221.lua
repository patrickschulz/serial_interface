--[[
        C1 ---- AND 
                AND 
        C2 ---- AND ---- OR
                         OR ---- NOR
        A  ------------- OR      NOR
                                 NOR ---- Z
        B1 ---- AND              NOR
                AND ------------ NOR
        B2 ---- AND
]] -- 
function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    local andgate_c = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate_c)

    local andgate_b = pcell.create_layout("logic/and_gate"):move_anchor("left",
                                                                        andgate_c:get_anchor(
                                                                            "right"))
    gate:merge_into_update_alignmentbox(andgate_b)

    local orgate = pcell.create_layout("logic/or_gate"):move_anchor("left",
                                                                    andgate_b:get_anchor(
                                                                        "right"))
    gate:merge_into_update_alignmentbox(orgate)

    local norgate = pcell.create_layout("logic/nor_gate"):move_anchor("left",
                                                                      orgate:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(norgate)

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        andgate_c:get_anchor("Z"), orgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andgate_c:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate:get_anchor("A")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        andgate_b:get_anchor("Z"), norgate:get_anchor("B")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andgate_b:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        norgate:get_anchor("B")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        orgate:get_anchor("Z"), norgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        norgate:get_anchor("A")))

    -- ports
    gate:add_port("A", generics.metal(1), orgate:get_anchor("B"))
    gate:add_port("B1", generics.metal(1), andgate_b:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), andgate_b:get_anchor("B"))
    gate:add_port("C1", generics.metal(1), andgate_c:get_anchor("A"))
    gate:add_port("C2", generics.metal(1), andgate_c:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), norgate:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))
end
