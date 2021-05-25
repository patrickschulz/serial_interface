--[[
    INV   INV    OAI_221     FF_OUT  
   OAI_21 INV    OAI_221     FF_BUF
          NAND   OAI_221     FF_IN

    alternative (more regular):
   INV    INV    OAI_221     FF_OUT  
   OAI_21 INV    OAI_221     FF_BUF
   AND    INV    OAI_221     FF_IN

                U17
                U19
                U16
--]] 
function parameters() 
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/dff")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace

    local xpitch = bp.gspace + bp.glength

    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })

    -- create rows
    local rows = {}
    local fronts = { 
        { gate = "logic/and_gate", options = {} }, 
        { gate = "logic/21_gate", options = { gate1 = "or_gate", gate2 = "nand_gate" } }, 
        { gate = "logic/not_gate", options = {} },
    }
    local nfingers = {}
    local dff = pcell.create_layout("logic/dff", { enableQN = true, enableQ = false })
    local orandinv221 = pcell.create_layout("logic/221_gate", { 
        flipconnection = true, 
        gate1 = "or_gate", 
        gate2 = "or_gate", 
        gate3 = "and_gate", 
        gate4 = "nand_gate"
    })
    local isogate = pcell.create_layout("logic/isogate")
    local inv = pcell.create_layout("logic/not_gate")
    for i = 1, 3 do
        rows[i] = object.create()
        -- place cells
        local front = pcell.create_layout(fronts[i].gate, fronts[i].options)
        local dffcopy = dff:copy()
        local orandinv221copy = orandinv221:copy()
        local invcopy = inv:copy()
        rows[i]:merge_into_update_alignmentbox(dffcopy)
        rows[i]:merge_into_update_alignmentbox(orandinv221copy:move_anchor("right", dff:get_anchor("left")))
        isogate:move_anchor("right", orandinv221copy:get_anchor("left"))
        rows[i]:merge_into(isogate:copy())
        rows[i]:merge_into_update_alignmentbox(invcopy:move_anchor("right", isogate:get_anchor("left")))
        isogate:move_anchor("right", invcopy:get_anchor("left"))
        rows[i]:merge_into(isogate:copy())
        rows[i]:merge_into_update_alignmentbox(front:move_anchor("right", isogate:get_anchor("left")))

        -- store anchors for conenctions
        for name, obj in pairs({ dff = dffcopy, orandinv221 = orandinv221copy, inv = invcopy, front = front }) do
            for anchorname, anchor in pairs(obj:get_all_anchors()) do
                rows[i]:add_anchor(string.format("%s.%s", name, anchorname), anchor)
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
        gate:merge_into(geometry.path_yx(generics.metal(1), {
            rows[i]:get_anchor("orandinv221.Z"),
            rows[i]:get_anchor("dff.D"),
        }, bp.sdwidth))
    end

    gate:merge_into(geometry.path_xy(generics.metal(1), {
        rows[2]:get_anchor("front.Z"),
        rows[2]:get_anchor("inv.I")
    }, bp.sdwidth))

    gate:merge_into(geometry.path_yx(generics.metal(1), {
        rows[2]:get_anchor("inv.O"),
        rows[2]:get_anchor("orandinv221.C1"),
    }, bp.sdwidth))

    gate:merge_into(geometry.path_yx(generics.metal(1), {
        rows[1]:get_anchor("front.Z"),
        rows[1]:get_anchor("inv.I"),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2]:get_anchor("front.A"), {
            -separation / 2 - bp.nwidth / 1,
            rows[1]:get_anchor("inv.O")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("inv.O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("front.A")))

    -- clk to ff_out
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[3]:get_anchor("inv.O"), {
            -separation / 2 - bp.nwidth + bp.sdwidth / 2,
            rows[3]:get_anchor("dff.CLK"),
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("inv.O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("dff.CLK")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        rows[3]:get_anchor("inv.O") + point.create(0, -separation / 2 - bp.nwidth + bp.sdwidth / 2),
        rows[2]:get_anchor("front.B1"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("front.B2")))

    gate:merge_into(geometry.path(generics.metal(3), {
        rows[1]:get_anchor("orandinv221.A"),
        rows[3]:get_anchor("orandinv221.A"),
    }, bp.sdwidth))
    for i = 1, 3 do
        gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[i]:get_anchor("orandinv221.A")))
    end

    -- reset
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2]:get_anchor("front.B2"), {
        rows[2]:get_anchor("front.Z") + point.create(0, separation / 2 + bp.nwidth - bp.sdwidth / 2),
        0,
        rows[2]:get_anchor("orandinv221.A"),
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("orandinv221.A")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("front.B1")))

    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[1]:get_anchor("front.A"), {
        -separation / 2 - bp.sdwidth / 2,
        rows[1]:get_anchor("orandinv221.A")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("front.A")))

    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2]:get_anchor("front.Z"), {
            separation / 2 + bp.sdwidth / 2,
            rows[2]:get_anchor("orandinv221.C2") + point.create(xpitch, -separation / 2 - bp.sdwidth / 2),
            rows[2]:get_anchor("orandinv221.B1")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("orandinv221.B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("front.Z")))

    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(
        rows[3]:get_anchor("front.O"), {
            separation / 2 + bp.sdwidth / 2,
            rows[3]:get_anchor("orandinv221.C1")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("orandinv221.C1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("front.O")))

    gate:merge_into(geometry.path_yx(generics.metal(3), {
        rows[3]:get_anchor("front.O"),
        rows[1]:get_anchor("orandinv221.C1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("orandinv221.C1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("front.O")))

    gate:merge_into(geometry.path_xy(generics.metal(3), {
        rows[3]:get_anchor("orandinv221.B1"),
        rows[3]:get_anchor("orandinv221.B1") + point.create(bp.sdwidth * -2, 0),
        rows[1]:get_anchor("orandinv221.B1"), rows[1]:get_anchor("orandinv221.B1")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("orandinv221.B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("orandinv221.B1")))

    gate:merge_into(geometry.path_xy(generics.metal(2),
        geometry.path_points_yx(rows[3]:get_anchor("front.I"), {
            separation / 2 + bp.nwidth - bp.sdwidth / 2,
            rows[3]:get_anchor("orandinv221.B1")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("orandinv221.B1")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("front.I")))

    gate:merge_into(geometry.path(generics.metal(3), {
        rows[3]:get_anchor("orandinv221.C2"), rows[2]:get_anchor("orandinv221.C2")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("orandinv221.C2")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("orandinv221.C2")))

    -- ff_in_q    
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[1]:get_anchor("dff.QN"), {
            separation / 2 + bp.pwidth - bp.sdwidth / 2,
            rows[1]:get_anchor("orandinv221.B2")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("dff.QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("orandinv221.B2")))

    gate:merge_into(geometry.path_xy(generics.metal(2), {
        rows[1]:get_anchor("orandinv221.B2"),
        rows[2]:get_anchor("orandinv221.C2")
    }, bp.sdwidth))

    -- bit_out
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2]:get_anchor("dff.QN"), {
            -separation / 2 - bp.pwidth + bp.sdwidth / 2,
            rows[2]:get_anchor("orandinv221.B2")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("dff.QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("orandinv221.B2")))

    -- chain_out
    gate:merge_into(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[3]:get_anchor("dff.QN"), {
            separation / 2 + bp.pwidth - bp.sdwidth / 2,
            rows[3]:get_anchor("orandinv221.B2")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("dff.QN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("orandinv221.B2")))

    -- clk connections
    gate:merge_into(geometry.path(generics.metal(3), {
        rows[2]:get_anchor("dff.CLK"), rows[1]:get_anchor("dff.CLK")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("dff.CLK")))
    gate:merge_into(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1]:get_anchor("dff.CLK")))

    gate:merge_into(geometry.path(generics.metal(3), 
        geometry.path_points_yx(rows[3]:get_anchor("inv.I"), {
            separation / 2 + bp.sdwidth / 2,
            rows[2]:get_anchor("dff.CLK")
    }), bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3]:get_anchor("inv.I")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2]:get_anchor("dff.CLK")))

    -- add ports
    gate:add_port("CLK", generics.metal(1), rows[3]:get_anchor("inv.I"))
    gate:add_port("RST", generics.metal(1), rows[2]:get_anchor("front.B1"))
    gate:add_port("UPD", generics.metal(1), rows[1]:get_anchor("front.B"))
    gate:add_port("DIN", generics.metal(1), rows[1]:get_anchor("orandinv221.C2"))
    gate:add_port("DOUT", generics.metal(1), rows[3]:get_anchor("dff.QN"))
    gate:add_port("BOUT", generics.metal(1), rows[2]:get_anchor("dff.QN"))
    gate:add_port("VDD", generics.metal(1), rows[3]:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1), rows[1]:get_anchor("bottom"))

    gate:move_anchor("CLK")
end
