function parameters() pcell.reference_cell("logic/base") end

local function generate_reg_vector(gate, width, own_anchor, to_anchor, _P)

    local vector = {}

    for i = 0, width - 1 do
        if i == 0 then
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
                                :move_anchor("bottom",
                                             vector[i - 1]:get_anchor("top"))
            else
                vector[i] = pcell.create_layout("logic/dff"):move_anchor(
                                "bottom", vector[i - 1]:get_anchor("top"))
            end
        end
        gate:merge_into_update_alignmentbox(vector[i])
    end
    return vector
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- generate bit_count_reg
    bit_count_reg = generate_reg_vector(gate, 5)

    -- generate curr_state_reg
    curr_state_reg = generate_reg_vector(gate, 3, "left",
                                         bit_count_reg[0]:get_anchor("right"))
    data_in_shift_reg_reg = generate_reg_vector(gate, 1, "left",
                                                curr_state_reg[0]:get_anchor(
                                                    "right"))
    data_inout_reg_reg = generate_reg_vector(gate, 1, "left",
                                             data_in_shift_reg_reg[0]:get_anchor(
                                                 "right"))
    cmd_rcv_done_reg = generate_reg_vector(gate, 1, "left",
                                           data_inout_reg_reg[0]:get_anchor("right"))
    cmd_reg_reg = generate_reg_vector(gate, 2, "left",
                                      cmd_rcv_done_reg[0]:get_anchor("right"))
    en_shift_reg_reg = generate_reg_vector(gate, 2, "left",
                                           cmd_reg_reg[0]:get_anchor("right"))
    got_start_bit_reg = generate_reg_vector(gate, 1, "left",
                                            en_shift_reg_reg[0]:get_anchor(
                                                "right"))
    rcv_done_reg = generate_reg_vector(gate, 1, "left",
                                       got_start_bit_reg[0]:get_anchor("right"))
    reset_shift_reg_reg = generate_reg_vector(gate, 1, "left",
                                              rcv_done_reg[0]:get_anchor("right"))
    send_done_reg = generate_reg_vector(gate, 1, "left",
                                        reset_shift_reg_reg[0]:get_anchor(
                                            "right"))
    update_shift_reg_reg = generate_reg_vector(gate, 1, "left",
                                               send_done_reg[0]:get_anchor(
                                                   "right"))

end
