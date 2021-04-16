--[[ 
    logic FF logic
    logic FF logic
    logic FF logic
    logic FF logic
--]] 
function parameters()
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/dff")
end

-- generate stack of flipflops representing a vector with height=width, place bottom cells own_anchor to to_anchor
-- is_flip_y can be true if you need to flip the bottoms power rails
local function generate_reg_vector(gate, width, own_anchor, to_anchor,
                                   is_flip_y, _P)

    local vector = {}

    for i = 1, width do
        if i == 1 then
            if own_anchor and to_anchor then
                vector[i] = pcell.create_layout("logic/dff")
                vector[i]:move_anchor(own_anchor, to_anchor)
            else
                vector[i] =
                    pcell.create_layout("logic/dff"):move_anchor("right")
            end
        else
            if i % 2 == 0 then
                vector[i] = pcell.create_layout("logic/dff"):flipy()
                vector[i]:move_anchor("bottom", vector[i - 1]:get_anchor("top"))
            else
                vector[i] = pcell.create_layout("logic/dff")
                vector[i]:move_anchor("bottom", vector[i - 1]:get_anchor("top"))
            end
        end
        if is_flip_y then vector[i]:flipy() end
        gate:merge_into_update_alignmentbox(vector[i])
    end
    return vector
end

function layout(gate, _p)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- generate upper right part
    -- middle row
    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = false})

    rcv_done_reg = pcell.create_layout("logic/dff"):move_anchor("right")
    gate:merge_into_update_alignmentbox(rcv_done_reg)

    pcell.pop_overwrites("logic/dff")

    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = true})

    curr_state_reg_1 = pcell.create_layout("logic/dff"):flipy():move_anchor(
                           "top", rcv_done_reg:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(curr_state_reg_1)

    pcell.pop_overwrites("logic/dff")

    pcell.push_overwrites("logic/dff", {enableQ = false, enableQN = true})

    bidir_write_reg = pcell.create_layout("logic/dff"):move_anchor("top",
                                                                   curr_state_reg_1:get_anchor(
                                                                       "bottom"))
    gate:merge_into_update_alignmentbox(bidir_write_reg)

    cmd_rcv_done_reg = pcell.create_layout("logic/dff"):flipy():move_anchor(
                           "top", bidir_write_reg:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(cmd_rcv_done_reg)

    pcell.pop_overwrites("logic/dff")

    u167 = pcell.create_layout("and_or_inv_21"):move_anchor("right",
                                                            rcv_done_reg:get_anchor(
                                                                "left"))
    gate:merge_into_update_alignmentbox(u167)

    u129 = pcell.create_layout("logic/nand_gate"):flipy():move_anchor("top",
                                                                      u167:get_anchor(
                                                                          "bottom"))
    gate:merge_into_update_alignmentbox(u129)

    u175 = pcell.create_layout("and_or_inv_21"):move_anchor("top",
                                                            u129:get_anchor(
                                                                "bottom"))
    gate:merge_into_update_alignmentbox(u175)

    u174 = pcell.create_layout("logic/nand_gate"):flipy():move_anchor("top",
                                                                      u175:get_anchor(
                                                                          "bottom"))
    gate:merge_into_update_alignmentbox(u174)

    -- left row
    u132 = pcell.create_layout("nand4"):move_anchor("left",
                                                    rcv_done_reg:get_anchor(
                                                        "right"))
    gate:merge_into_update_alignmentbox(u132)

    pcell.push_overwrites("logic/base", {leftdummies = 1, rightdummies = 1})

    u135 = pcell.create_layout("and_or_inv_21"):flipy():move_anchor("top",
                                                                    u132:get_anchor(
                                                                        "bottom"))
    gate:merge_into_update_alignmentbox(u135)

    u141 = pcell.create_layout("and_or_inv_21"):move_anchor("top",
                                                            u135:get_anchor(
                                                                "bottom"))
    gate:merge_into_update_alignmentbox(u141)

    u142 = pcell.create_layout("and_or_inv_21"):flipy():move_anchor("top",
                                                                    u141:get_anchor(
                                                                        "bottom"))
    gate:merge_into_update_alignmentbox(u142)

    pcell.pop_overwrites("logic/base")

end
