function parameters() pcell.reference_cell("logic/base") end

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

    -- generate variable registers
    bit_count_reg = generate_reg_vector(gate, 5)

    curr_state_reg = generate_reg_vector(gate, 3, "bottom",
                                         bit_count_reg[#bit_count_reg]:get_anchor(
                                             "top"), true)

    data_in_shift_reg_reg = generate_reg_vector(gate, 1, "bottom",
                                                curr_state_reg[#curr_state_reg]:get_anchor(
                                                    "top"))

    data_inout_reg_reg = generate_reg_vector(gate, 1, "bottom",
                                             data_in_shift_reg_reg[#data_in_shift_reg_reg]:get_anchor(
                                                 "top"), true)

    cmd_rcv_done_reg = generate_reg_vector(gate, 1, "bottom",
                                           data_inout_reg_reg[#data_inout_reg_reg]:get_anchor(
                                               "top"))

    cmd_reg_reg = generate_reg_vector(gate, 2, "bottom",
                                      cmd_rcv_done_reg[#cmd_rcv_done_reg]:get_anchor(
                                          "top"), true)

    en_shift_reg_reg = generate_reg_vector(gate, 2, "bottom",
                                           cmd_reg_reg[#cmd_reg_reg]:get_anchor(
                                               "top"), true)
    got_start_bit_reg = generate_reg_vector(gate, 1, "bottom",
                                            en_shift_reg_reg[#en_shift_reg_reg]:get_anchor(
                                                "top"), true)

    rcv_done_reg = generate_reg_vector(gate, 1, "bottom",
                                       got_start_bit_reg[#got_start_bit_reg]:get_anchor(
                                           "top"))

    reset_shift_reg_reg = generate_reg_vector(gate, 1, "bottom",
                                              rcv_done_reg[#rcv_done_reg]:get_anchor(
                                                  "top"), true)

    send_done_reg = generate_reg_vector(gate, 1, "bottom",
                                        reset_shift_reg_reg[#reset_shift_reg_reg]:get_anchor(
                                            "top"))

    update_shift_reg_reg = generate_reg_vector(gate, 1, "bottom",
                                               send_done_reg[#send_done_reg]:get_anchor(
                                                   "top"), true)
end
