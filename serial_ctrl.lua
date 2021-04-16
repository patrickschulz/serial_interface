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

    u167 = pcell.create_layout("and4"):flipy():move_anchor("right",
                                                           got_start_bit_reg:get_anchor(
                                                               "left"))
    gate:merge_into_update_alignmentbox(u167)

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

    u149 = pcell.create_layout("nor3"):move_anchor("right",
                                                        u153:get_anchor(
                                                            "left"))
    gate:merge_into_update_alignmentbox(u149)

    u152 = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                        u149:get_anchor(
                                                            "left"))
    gate:merge_into_update_alignmentbox(u152)

    u151 = pcell.create_layout("nand4"):move_anchor("right",
                                                        u170:get_anchor(
                                                            "left"))
    gate:merge_into_update_alignmentbox(u151)

    pcell.pop_overwrites("logic/base")
end
