--[[ 
CO = A & B
S = A XOR B
 ]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    andgate = pcell.create_layout("logic/and_gate"):move_anchor("right")
    gate:merge_into_update_alignmentbox(andgate)

    xorgate = pcell.create_layout("logic/xor_gate"):move_anchor("left",
                                                                andgate:get_anchor(
                                                                    "right"))
    gate:merge_into_update_alignmentbox(xorgate)

end
