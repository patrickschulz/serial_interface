--[[  
A1 ---- OR
        OR
A2 ---- OR ---- NOR
                NOR ---- Z
A3 ------------ NOR
]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    pcell.push_overwrites("logic/base", { rightdummies = 1 })
    local orgate = pcell.create_layout("logic/or_gate")
    gate:merge_into_update_alignmentbox(orgate)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", { leftdummies = 1 })
    local norgate = pcell.create_layout("logic/nor_gate"):move_anchor("left", orgate:get_anchor( "right"))
    gate:merge_into_update_alignmentbox(norgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        orgate:get_anchor("Z"), norgate:get_anchor("A")
    }, bp.sdwidth))

    gate:add_port("A1", generics.metal(1), orgate:get_anchor("A"))
    gate:add_port("A2", generics.metal(1), orgate:get_anchor("B"))
    gate:add_port("A3", generics.metal(1), norgate:get_anchor("B"))
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
