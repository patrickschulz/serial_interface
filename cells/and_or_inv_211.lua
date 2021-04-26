--[[ 
C1 ---- AND
        AND
C2 ---- AND ---- OR
                 OR 
B -------------- OR ---- NOR
                         NOR ---- Z
A ---------------------- NOR
 ]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {rightdummies = 1})

    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {leftdummies = 1, rightdummies = 1})
    local orgate = pcell.create_layout("logic/or_gate"):move_anchor("left",
                                                                    andgate:get_anchor(
                                                                        "right"))
    gate:merge_into_update_alignmentbox(orgate)
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {leftdummies = 1})
    local norgate = pcell.create_layout("logic/nor_gate"):move_anchor("left",
                                                                      orgate:get_anchor(
                                                                          "right"))
    gate:merge_into_update_alignmentbox(norgate)
    pcell.pop_overwrites("logic/base")

    -- draw connections
    gate:merge_into(geometry.path_yx(generics.metal(2), {
        andgate:get_anchor("Z"), orgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        andgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate:get_anchor("A")))

    gate:merge_into(geometry.path_yx(generics.metal(2), {
        orgate:get_anchor("Z"), norgate:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orgate:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        norgate:get_anchor("A")))

    -- place ports
    gate:add_port("C1", generics.metal(1), andgate:get_anchor("A"))
    gate:add_port("C2", generics.metal(1), andgate:get_anchor("B"))
    gate:add_port("B", generics.metal(1), orgate:get_anchor("B"))
    gate:add_port("A", generics.metal(1), norgate:get_anchor("B"))

    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))
end
