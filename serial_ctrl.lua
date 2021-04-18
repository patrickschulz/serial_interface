function parameters()
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/dff")
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

    pcell.push_overwrites("logic/dff", {enableQ = false, enableQN = true})

    got_start_bit_reg = pcell.create_layout("logic/dff"):flipy():move_anchor(
                            "top", rcv_done_reg:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(got_start_bit_reg)

    cmd_rcv_done_reg = pcell.create_layout("logic/dff"):move_anchor("top",
                                                                    got_start_bit_reg:get_anchor(
                                                                        "bottom"))
    gate:merge_into_update_alignmentbox(cmd_rcv_done_reg)

    pcell.pop_overwrites("logic/dff")

    u128 = pcell.create_layout("logic/xor_gate"):move_anchor("left",
                                                             rcv_done_reg:get_anchor(
                                                                 "right"))
    gate:merge_into_update_alignmentbox(u128)

    u131 = pcell.create_layout("nor4"):flipy():move_anchor("top",
                                                           u128:get_anchor(
                                                               "bottom"))
    gate:merge_into_update_alignmentbox(u131)

    u132 = pcell.create_layout("nor4"):move_anchor("top",
                                                   u131:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(u132)

    u136 = pcell.create_layout("logic/nand_gate"):move_anchor("left",
                                                              u132:get_anchor(
                                                                  "right"))
    gate:merge_into_update_alignmentbox(u136)

    u142 = pcell.create_layout("logic/nor_gate"):flipy():move_anchor("left",
                                                                     u131:get_anchor(
                                                                         "right"))
    gate:merge_into_update_alignmentbox(u142)

    u143 = pcell.create_layout("and_or_inv_211"):move_anchor("left",
                                                             u128:get_anchor(
                                                                 "right"))
    gate:merge_into_update_alignmentbox(u143)

    u167 = pcell.create_layout("and_or_inv_211"):move_anchor("right",
                                                             rcv_done_reg:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u167)

    u124 = pcell.create_layout("and4"):flipy():move_anchor("right",
                                                           got_start_bit_reg:get_anchor(
                                                               "left"))
    gate:merge_into_update_alignmentbox(u124)

    u175 = pcell.create_layout("and_or_inv_21"):move_anchor("right",
                                                            cmd_rcv_done_reg:get_anchor(
                                                                "left"))
    gate:merge_into_update_alignmentbox(u175)

    u174 = pcell.create_layout("logic/nand_gate"):move_anchor("right",
                                                              u175:get_anchor(
                                                                  "left"))
    gate:merge_into_update_alignmentbox(u174)

    u171 = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                             u174:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u171)

    pcell.push_overwrites("logic/dff", {enableQ = false, enableQN = true})

    bidir_write_reg = pcell.create_layout("logic/dff"):flipy():move_anchor(
                          "top", cmd_rcv_done_reg:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(bidir_write_reg)

    pcell.pop_overwrites("logic/dff")

    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = false})

    data_in_shift_reg_reg = pcell.create_layout("logic/dff"):move_anchor("top",
                                                                         bidir_write_reg:get_anchor(
                                                                             "bottom"))
    gate:merge_into_update_alignmentbox(data_in_shift_reg_reg)

    update_shift_reg_reg = pcell.create_layout("logic/dff"):flipy():move_anchor(
                               "top", data_in_shift_reg_reg:get_anchor("bottom"))
    gate:merge_into_update_alignmentbox(update_shift_reg_reg)

    pcell.pop_overwrites("logic/dff")

    u169 = pcell.create_layout("nor3"):flipy():move_anchor("right",
                                                           update_shift_reg_reg:get_anchor(
                                                               "left"))
    gate:merge_into_update_alignmentbox(u169)

    u170 = pcell.create_layout("logic/nor_gate"):move_anchor("right",
                                                             data_in_shift_reg_reg:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u170)

    u153 = pcell.create_layout("logic/nor_gate"):move_anchor("right",
                                                             bidir_write_reg:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u153)

    u149 = pcell.create_layout("nor3"):flipy():move_anchor("right",
                                                           u153:get_anchor(
                                                               "left"))
    gate:merge_into_update_alignmentbox(u149)

    u152 = pcell.create_layout("logic/not_gate"):flipy():move_anchor("right",
                                                                     u153:get_anchor(
                                                                         "left"))
    gate:merge_into_update_alignmentbox(u152)

    u151 = pcell.create_layout("nand4"):move_anchor("right",
                                                    u170:get_anchor("left"))
    gate:merge_into_update_alignmentbox(u151)

    u139 = pcell.create_layout("or_and_inv_21"):flipy():move_anchor("right",
                                                                    u149:get_anchor(
                                                                        "left"))
    gate:merge_into_update_alignmentbox(u139)

    u138 = pcell.create_layout("logic/nor_gate"):move_anchor("right",
                                                             u167:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u138)

    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = true})
    pcell.push_overwrites("logic/base", {rightdummies = 3, leftdummies = 0})

    bit_count_reg_3 = pcell.create_layout("logic/dff"):move_anchor("right",
                                                                   u151:get_anchor(
                                                                       "left"))

    gate:merge_into_update_alignmentbox(bit_count_reg_3)
    pcell.pop_overwrites("logic/dff")
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {rightdummies = 1, leftdummies = 0})
    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = false})

    bit_count_reg_2 = pcell.create_layout("logic/dff"):flipy():move_anchor(
                          "right", u139:get_anchor("left"))

    gate:merge_into_update_alignmentbox(bit_count_reg_2)

    bit_count_reg_1 = pcell.create_layout("logic/dff"):move_anchor("bottom",
                                                                   bit_count_reg_2:get_anchor(
                                                                       "top"))
    gate:merge_into_update_alignmentbox(bit_count_reg_1)

    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/dff")
    pcell.push_overwrites("logic/dff", {enableQ = true, enableQN = true})

    bit_count_reg_0 = pcell.create_layout("logic/dff"):flipy():move_anchor(
                          "bottom", bit_count_reg_1:get_anchor("top") +
                              point.create(-0.5 * xpitch, 0))
    gate:merge_into_update_alignmentbox(bit_count_reg_0)

    bit_count_reg_4 = pcell.create_layout("logic/dff"):flipy():move_anchor(
                          "top", bit_count_reg_3:get_anchor("bottom") +
                              point.create(-2.5 * xpitch, 0))
    gate:merge_into_update_alignmentbox(bit_count_reg_4)

    u158 = pcell.create_layout("logic/not_gate"):flipy():move_anchor("right",
                                                             bit_count_reg_4:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u158)

    u164 = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                             bit_count_reg_3:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u164)
    u166 = pcell.create_layout("logic/not_gate"):flipy():move_anchor("right",
                                                                     bit_count_reg_2:get_anchor(
                                                                         "left"))
    gate:merge_into_update_alignmentbox(u166)
    u162 = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                             bit_count_reg_1:get_anchor(
                                                                 "left"))
    gate:merge_into_update_alignmentbox(u162)
    u160 = pcell.create_layout("logic/not_gate"):flipy():move_anchor("right",
                                                                     bit_count_reg_0:get_anchor(
                                                                         "left"))
    gate:merge_into_update_alignmentbox(u160)

    u161 = pcell.create_layout("and_or_inv_22"):move_anchor("right",
                                                            u162:get_anchor(
                                                                "left"))
    gate:merge_into_update_alignmentbox(u161)

    u165 = pcell.create_layout("and_or_inv_22"):flipy():move_anchor("right",
                                                                    u166:get_anchor(
                                                                        "left"))
    gate:merge_into_update_alignmentbox(u165)

    u163 = pcell.create_layout("and_or_inv_22"):move_anchor("right",
                                                            u164:get_anchor(
                                                                "left"))
    gate:merge_into_update_alignmentbox(u163)

    u159 = pcell.create_layout("and_or_inv_22"):flipy():move_anchor("right",
                                                                    u160:get_anchor(
                                                                        "left"))
    gate:merge_into_update_alignmentbox(u159)

    u157 = pcell.create_layout("and_or_inv_22"):flipy():move_anchor("right",
                                                                    u158:get_anchor(
                                                                        "left"))
    gate:merge_into_update_alignmentbox(u157)

    pcell.pop_overwrites("logic/dff")

    pcell.pop_overwrites("logic/base")
end
