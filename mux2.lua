--[[
S ---- NOT ---- AND_OR_INV_22
|               AND_OR_INV_22
|        A ---- AND_OR_INV_22
|               AND_OR_INV_22 ---- NOT ---- Z
--------------- AND_OR_INV_22
                AND_OR_INV_22
         B ---- AND_OR_INV_22
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- place cells
    local not_left = pcell.create_layout("logic/not_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(not_left)

    local andorinv22 = pcell.create_layout("and_or_inv_22"):move_anchor("left",
                                                                        not_left:get_anchor(
                                                                            "right"))
    gate:merge_into_update_alignmentbox(andorinv22)

    local not_right = pcell.create_layout("logic/not_gate"):move_anchor("left",
                                                                        andorinv22:get_anchor(
                                                                            "right"))
    gate:merge_into_update_alignmentbox(not_right)

    -- draw connections
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        not_left:get_anchor("O"), 
        andorinv22:get_anchor("A2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andorinv22:get_anchor("A2")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        not_left:get_anchor("O")))

    gate:merge_into(geometry.path_yx(generics.metal(2), {
        not_left:get_anchor("I"),
        not_left:get_anchor("I") + point.create(0, 6 * bp.sdwidth),
        andorinv22:get_anchor("B1"),
        andorinv22:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        not_left:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andorinv22:get_anchor("B1")))

    gate:merge_into(geometry.path(generics.metal(2), {
        andorinv22:get_anchor("Z"), not_right:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        not_right:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andorinv22:get_anchor("Z")))

    -- draw ports
    gate:add_port("A", generics.metal(1), andorinv22:get_anchor("A1"))
    gate:add_port("S", generics.metal(1), not_left:get_anchor("I"))
    gate:add_port("B", generics.metal(1), andorinv22:get_anchor("B2"))
    gate:add_port("Z", generics.metal(1), not_right:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))
end
