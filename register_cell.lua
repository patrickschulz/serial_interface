--[[
    INV   INV    OAI_221     FF_OUT  
   OAI_21 INV    OAI_221     FF_BUF
          NAND   OAI_221     FF_IN
--]] function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- ff_in row = bottom
    local orandinv221_in = pcell.create_layout("or_and_inv_221"):move_anchor(
                               "top")
    gate:merge_into_update_alignmentbox(orandinv221_in)

    local ff_in = pcell.create_layout("logic/dff"):move_anchor("left",
                                                               orandinv221_in:get_anchor(
                                                                   "right"))
    gate:merge_into_update_alignmentbox(ff_in)

    -- add 3 dummies to the left to match width of middle row
    pcell.push_overwrites("logic/base", {leftdummies = 3, rightdummies = 0})
    local nand_in = pcell.create_layout("logic/nand_gate"):move_anchor("right",
                                                                       orandinv221_in:get_anchor(
                                                                           "left"))
    gate:merge_into_update_alignmentbox(nand_in)
    pcell.pop_overwrites("logic/base")

    -- ff_buf row = middle
    local orandinv221_buf = pcell.create_layout("or_and_inv_221")
    orandinv221_buf:flipy()
    orandinv221_buf:move_anchor("bottom")
    gate:merge_into_update_alignmentbox(orandinv221_buf)

    local ff_buf = pcell.create_layout("logic/dff"):move_anchor("left",
                                                                orandinv221_buf:get_anchor(
                                                                    "right"))
    ff_buf:flipy()
    gate:merge_into_update_alignmentbox(ff_buf)

    local inv_buf = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                                      orandinv221_buf:get_anchor(
                                                                          "left"))
    inv_buf:flipy()
    gate:merge_into_update_alignmentbox(inv_buf)

    local orandinv21 = pcell.create_layout("or_and_inv_21"):move_anchor("right",
                                                                        orandinv221_buf:get_anchor(
                                                                            "left"))
    orandinv21:flipy()
    gate:merge_into_update_alignmentbox(orandinv21)

    -- ff_out row = top
    local orandinv221_out = pcell.create_layout("or_and_inv_221"):move_anchor(
                                "VSS", orandinv221_buf:get_anchor("VSS"))
    gate:merge_into_update_alignmentbox(orandinv221_out)

    local ff_out = pcell.create_layout("logic/dff"):move_anchor("left",
                                                                orandinv221_out:get_anchor(
                                                                    "right"))
    gate:merge_into_update_alignmentbox(ff_out)

    local inv_out_right = pcell.create_layout("logic/not_gate"):move_anchor(
                              "right", orandinv221_out:get_anchor("left"))
    gate:merge_into_update_alignmentbox(inv_out_right)

    -- add 3 dummies to the left to match width of middle row
    pcell.push_overwrites("logic/base", {leftdummies = 3, rightdummies = 0})

    local inv_out_left = pcell.create_layout("logic/not_gate"):move_anchor(
                             "right", inv_out_right:get_anchor("left"))
    gate:merge_into_update_alignmentbox(inv_out_left)

    pcell.pop_overwrites("logic/base")

    -- draw connections
    -- n13
    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_buf:get_anchor("Z"),
        orandinv221_buf:get_anchor("Z") + point.create(0, -2 * bp.sdwidth),
        ff_buf:get_anchor("D") + point.create(0, -2 * bp.sdwidth),
        ff_buf:get_anchor("D")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("D")))
    -- n12
    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_out:get_anchor("Z"),
        orandinv221_out:get_anchor("Z") + point.create(0, -2 * bp.sdwidth),
        ff_out:get_anchor("D") + point.create(0, -2 * bp.sdwidth),
        ff_out:get_anchor("D")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_out:get_anchor("D")))

    -- n11
    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_in:get_anchor("Z"),
        orandinv221_in:get_anchor("Z") + point.create(0, -2 * bp.sdwidth),
        ff_in:get_anchor("D") + point.create(0, -2 * bp.sdwidth),
        ff_in:get_anchor("D")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_in:get_anchor("D")))

    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv21:get_anchor("Z"), inv_buf:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv21:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_buf:get_anchor("I")))

    gate:merge_into(geometry.path_xy(generics.metal(3), {
        inv_buf:get_anchor("O"), orandinv221_buf:get_anchor("C1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_buf:get_anchor("O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("C1")))

    gate:merge_into(geometry.path_yx(generics.metal(3), {
        nand_in:get_anchor("Z"),
        orandinv21:get_anchor("A") + point.create(bp.sdwidth * -2, 0),
        orandinv21:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        nand_in:get_anchor("Z")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv21:get_anchor("A")))

    gate:merge_into(geometry.path(generics.metal(3), {
        inv_out_right:get_anchor("O"),
        inv_out_right:get_anchor("O") + point.create(0, bp.sdwidth * 4),
        ff_out:get_anchor("CLK") + point.create(0, bp.sdwidth * 4),
        ff_out:get_anchor("CLK")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_right:get_anchor("O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_out:get_anchor("CLK")))

    gate:merge_into(geometry.path_yx(generics.metal(3), {
        inv_out_right:get_anchor("O"),
        inv_out_right:get_anchor("O") + point.create(0, bp.sdwidth * 4),
        orandinv21:get_anchor("B2"), orandinv21:get_anchor("B2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv21:get_anchor("B2")))

    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_buf:get_anchor("A"), orandinv221_in:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_buf:get_anchor("A"), orandinv221_out:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("A")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("A")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("A")))

    -- reset
    gate:merge_into(geometry.path(generics.metal(3), {
        orandinv221_buf:get_anchor("A"),
        orandinv221_buf:get_anchor("A") + point.create(0, 6 * bp.sdwidth),
        orandinv21:get_anchor("B1") + point.create(0, 6 * bp.sdwidth),
        orandinv21:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("A")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv21:get_anchor("B1")))

    gate:merge_into(geometry.path_yx(generics.metal(3), {
        nand_in:get_anchor("A"),
        nand_in:get_anchor("A") + point.create(0, bp.sdwidth * 2),
        orandinv221_in:get_anchor("A"), orandinv221_in:get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        nand_in:get_anchor("A")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("A")))

    gate:merge_into(geometry.path_yx(generics.metal(4), {
        orandinv21:get_anchor("Z"), orandinv221_buf:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv21:get_anchor("Z")))

    gate:merge_into(geometry.path_yx(generics.metal(3), {
        inv_out_left:get_anchor("O"),
        inv_out_left:get_anchor("O") + point.create(0, -bp.sdwidth * 4),
        orandinv221_out:get_anchor("C1"), orandinv221_out:get_anchor("C1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("C1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_left:get_anchor("O")))

    gate:merge_into(geometry.path_xy(generics.metal(4), {
        inv_out_left:get_anchor("O"),
        orandinv221_in:get_anchor("C1") + point.create(0, bp.sdwidth * -4),
        orandinv221_in:get_anchor("C1"), orandinv221_in:get_anchor("C1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("C1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_left:get_anchor("O")))

    gate:merge_into(geometry.path_xy(generics.metal(3), {
        orandinv221_out:get_anchor("B1"),
        orandinv221_out:get_anchor("B1") + point.create(bp.sdwidth * -2, 0),
        orandinv221_in:get_anchor("B1"), orandinv221_in:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("B1")))

    gate:merge_into(geometry.path_xy(generics.metal(4), {
        inv_out_left:get_anchor("I"), orandinv221_out:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_left:get_anchor("I")))

    gate:merge_into(geometry.path(generics.metal(4), {
        orandinv221_out:get_anchor("C2"), orandinv221_buf:get_anchor("C2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("C2")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("C2")))

    -- ff_in_q    
    gate:merge_into(geometry.path_yx(generics.metal(3), {
        orandinv221_in:get_anchor("B2"),
        orandinv221_in:get_anchor("B2") + point.create(0, bp.sdwidth * -4),
        ff_in:get_anchor("QN") + point.create(0, bp.sdwidth * -4),
        ff_in:get_anchor("QN")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_in:get_anchor("QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_in:get_anchor("B2")))

    
    gate:merge_into(geometry.path_xy(generics.metal(4), {
        orandinv221_in:get_anchor("B2"),
        orandinv221_in:get_anchor("B2") + point.create(bp.sdwidth*12,0),
        orandinv221_buf:get_anchor("C2") + point.create(0, bp.sdwidth*6),
        orandinv221_buf:get_anchor("C2"),
    }, bp.sdwidth))

    -- bit_out
    gate:merge_into(geometry.path_xy(generics.metal(5), {
        ff_buf:get_anchor("QN"),
        orandinv221_buf:get_anchor("B2"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("B2")))

    -- chain_out
    gate:merge_into(geometry.path_xy(generics.metal(4), {
        ff_out:get_anchor("QN"),
        orandinv221_out:get_anchor("B2"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_out:get_anchor("QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("B2")))

    -- clk connections
    gate:merge_into(geometry.path(generics.metal(4), {
        ff_buf:get_anchor("CLK"),
        ff_in:get_anchor("CLK"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("CLK")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_in:get_anchor("CLK")))

    gate:merge_into(geometry.path_xy(generics.metal(5), {
        inv_out_right:get_anchor("I"),
        ff_buf:get_anchor("CLK"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_right:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("CLK")))

    -- add ports
    gate:add_port("CLK", generics.metal(1), inv_out_right:get_anchor("I"))
    gate:add_port("RST", generics.metal(1), orandinv21:get_anchor("B1"))
    gate:add_port("UPD", generics.metal(1), nand_in:get_anchor("B"))
    gate:add_port("CIN", generics.metal(1), orandinv221_in:get_anchor("C2"))
    gate:add_port("COUT", generics.metal(1), ff_out:get_anchor("QN"))
    gate:add_port("BOUT", generics.metal(1), ff_buf:get_anchor("QN"))
end

