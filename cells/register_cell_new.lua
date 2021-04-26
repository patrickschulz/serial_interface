--[[
    INV   INV    OAI_221     FF_OUT  
   OAI_21 INV    OAI_221     FF_BUF
          NAND   OAI_221     FF_IN

    alternative (more regular):
    INV   INV    OAI_221     FF_OUT  
   OAI_21 INV    OAI_221     FF_BUF
    AND   INV    OAI_221     FF_IN
--]] 
function parameters() 
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/dff")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })

    -- create rows
    local rows = {}
    local fronts = { "logic/and_gate", "or_and_inv_21", "logic/not_gate" }
    local nfingers = {}
    local anchors = {}
    for i = 1, 3 do
        rows[i] = object.create()
        -- place cells
        local dff = pcell.create_layout("logic/dff", { enableQN = true, enableQ = false })
        local orandinv221 = pcell.create_layout("or_and_inv_221")
        local isogate = pcell.create_layout("logic/isogate")
        local inv = pcell.create_layout("logic/not_gate")
        local front = pcell.create_layout(fronts[i])
        rows[i]:merge_into_update_alignmentbox(dff)
        rows[i]:merge_into_update_alignmentbox(orandinv221:move_anchor("right", dff:get_anchor("left")))
        isogate:move_anchor("right", orandinv221:get_anchor("left"))
        rows[i]:merge_into(isogate:copy())
        rows[i]:merge_into_update_alignmentbox(inv:move_anchor("right", isogate:get_anchor("left")))
        isogate:move_anchor("right", inv:get_anchor("left"))
        rows[i]:merge_into(isogate:copy())
        rows[i]:merge_into_update_alignmentbox(front:move_anchor("right", isogate:get_anchor("left")))

        -- store anchors for conenctions
        for name, obj in pairs({ dff = dff, orandinv221 = orandinv221 }) do
            for anchorname, anchor in pairs(obj:get_all_anchors()) do
                anchors[string.format("%s_%d:%s", name, i, anchorname)] = anchor
            end
        end

        -- store number of fingers of row
        local width = rows[i]:width_height()
        nfingers[i] = math.floor(width / (bp.glength + bp.gspace))
    end

    -- fill up rows with dummies
    for i = 1, 3 do
        local isogate = pcell.create_layout("logic/isogate")
        for j = 1, math.max(table.unpack(nfingers)) - nfingers[i] do
            isogate:move_anchor("right", rows[i]:get_anchor("left"))
            rows[i]:merge_into_update_alignmentbox(isogate:copy())
        end
    end
    pcell.pop_overwrites("logic/base")

    -- place rows
    gate:merge_into(rows[1])
    gate:merge_into(rows[2]:flipy():move_anchor("bottomright", rows[1]:get_anchor("topright")))
    gate:merge_into(rows[3]:move_anchor("bottomright", rows[2]:get_anchor("topright")))
    gate:set_alignment_box(rows[1]:get_anchor("bottomleft"), rows[3]:get_anchor("topright"))

    -- connections
    -- orandinv221 to dff
    for i = 1, 3 do
        gate:merge_into(geometry.path_yx(generics.metal(3), {
            anchors[string.format("orandinv221_%d:Z", i)],
            anchors[string.format("dff_%d:D", i)],
        }, bp.sdwidth))
    end

    --[[
    -- draw connections
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
        orandinv221_in:get_anchor("C1") + point.create(0, bp.sdwidth * -6),
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
        orandinv221_in:get_anchor("B2") + point.create(bp.sdwidth * 12, 0),
        orandinv221_buf:get_anchor("C2") + point.create(0, bp.sdwidth * 6),
        orandinv221_buf:get_anchor("C2")
    }, bp.sdwidth))

    -- bit_out
    gate:merge_into(geometry.path_xy(generics.metal(2), {
        ff_buf:get_anchor("QN"),
        orandinv221_buf:get_anchor("B2") + point.create(0, bp.sdwidth * 4),
        orandinv221_buf:get_anchor("B2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_buf:get_anchor("B2")))

    -- chain_out
    gate:merge_into(geometry.path_xy(generics.metal(4), {
        ff_out:get_anchor("QN"), orandinv221_out:get_anchor("B2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_out:get_anchor("QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        orandinv221_out:get_anchor("B2")))

    -- clk connections
    gate:merge_into(geometry.path(generics.metal(4), {
        ff_buf:get_anchor("CLK"), ff_in:get_anchor("CLK")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("CLK")))
    gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_in:get_anchor("CLK")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        inv_out_right:get_anchor("I"),
        inv_out_right:get_anchor("I") + point.create(bp.sdwidth * 2, 0),
        ff_buf:get_anchor("CLK") + point.create(0, bp.sdwidth * -8),
        ff_buf:get_anchor("CLK")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        inv_out_right:get_anchor("I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth,
                                       bp.sdwidth):translate(
                        ff_buf:get_anchor("CLK")))

    -- add ports
    gate:add_port("CLK", generics.metal(1), inv_out_right:get_anchor("I"))
    gate:add_port("RST", generics.metal(1), orandinv21:get_anchor("B1"))
    gate:add_port("UPD", generics.metal(1), nand_in:get_anchor("B"))
    gate:add_port("DIN", generics.metal(1), orandinv221_in:get_anchor("C2"))
    gate:add_port("DOUT", generics.metal(1), ff_out:get_anchor("QN"))
    gate:add_port("BOUT", generics.metal(1), ff_buf:get_anchor("QN"))
    --]]
end
