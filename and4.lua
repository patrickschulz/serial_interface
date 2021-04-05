function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- place cells
    local nand = pcell.create_layout("nand4"):move_anchor("right")
    gate:merge_into_update_alignmentbox(nand)

    local notgate = pcell.create_layout("logic/not_gate"):move_anchor("left",
                                                                      nand:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(notgate)

    gate:merge_into(geometry.path(generics.metal(1), {
        nand:get_anchor("Z"), notgate:get_anchor("I")
    }, bp.sdwidth))

    gate:add_port("A1", generics.metal(1), nand:get_anchor("A1"))
    gate:add_port("A2", generics.metal(1), nand:get_anchor("A2"))
    gate:add_port("A3", generics.metal(1), nand:get_anchor("A3"))
    gate:add_port("A4", generics.metal(1), nand:get_anchor("A4"))
    gate:add_port("Z", generics.metal(1), notgate:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))
end
