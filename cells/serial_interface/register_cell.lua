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

    -- create references
    local dffmaster = pcell.create_layout("logic/dff", { enableQN = true, enableQ = false })
    local dffname = gate:add_child_reference(dffmaster, "dff")
    local orandinv221master = pcell.create_layout("logic/221_gate", { 
        flipconnection = true, 
        gate1 = "or_gate", 
        gate2 = "or_gate", 
        gate3 = "and_gate", 
        gate4 = "nand_gate"
    })
    local orandinv221name = gate:add_child_reference(orandinv221master, "orandinv221")
    local isogatemaster = pcell.create_layout("logic/isogate")
    local isoname = gate:add_child_reference(isogatemaster, "isogate")
    local invmaster = pcell.create_layout("logic/not_gate")
    local invname = gate:add_child_reference(invmaster, "inv")
    local frontnames = { 
        gate:add_child_reference(pcell.create_layout("logic/and_gate"), "front1"),
        gate:add_child_reference(pcell.create_layout("logic/21_gate", { gate1 = "or_gate", gate2 = "nand_gate" }), "front2"),
        gate:add_child_reference(pcell.create_layout("logic/not_gate"), "front3")
    }

    -- place cells
    local rows = {}
    local nfingers = {}
    for i = 1, 3 do
        local row = {}
        row.dff = gate:add_child_link(dffname)
        if i > 1 then
            row.dff:move_anchor("bottom", rows[i - 1].dff:get_anchor("top"))
        end
        row.orandinv221 = gate:add_child_link(orandinv221name)
        row.orandinv221:move_anchor("right", row.dff:get_anchor("left"))
        row.isogate1 = gate:add_child_link(isoname)
        row.isogate1:move_anchor("right", row.orandinv221:get_anchor("left"))
        row.inv = gate:add_child_link(invname)
        row.inv:move_anchor("right", row.isogate1:get_anchor("left"))
        row.isogate2 = gate:add_child_link(isoname)
        row.isogate2:move_anchor("right", row.inv:get_anchor("left"))
        row.front = gate:add_child_link(frontnames[i])
        row.front:move_anchor("right", row.isogate2:get_anchor("left"))

        row.lastisogate = row.front -- fake isogate for dummy placement
        rows[i] = row

        -- store number of fingers of row
        local width = row.dff:get_anchor("right"):getx() - row.front:get_anchor("left"):getx()
        nfingers[i] = math.floor(width / (bp.glength + bp.gspace))
    end

    -- fill up rows with dummies
    for i = 1, 3 do
        for j = 1, math.max(table.unpack(nfingers)) - nfingers[i] + 1 do
            local isogate = gate:add_child_link(isoname)
            isogate:move_anchor("right", rows[i].lastisogate:get_anchor("left"))
            rows[i].lastisogate = isogate
        end
    end

    -- flip second row
    for k, v in pairs(rows[2]) do
        v:flipy()
    end

    -- connections
    -- orandinv221 to dff
    for i = 1, 3 do
        gate:merge_into_shallow(geometry.path_yx(generics.metal(1), {
            rows[i].orandinv221:get_anchor("Z"),
            rows[i].dff:get_anchor("D"),
        }, bp.sdwidth))
    end

    gate:merge_into_shallow(geometry.path_xy(generics.metal(1), {
        rows[2].front:get_anchor("Z"),
        rows[2].inv:get_anchor("I")
    }, bp.sdwidth))

    gate:merge_into_shallow(geometry.path_yx(generics.metal(1), {
        rows[2].inv:get_anchor("O"),
        rows[2].orandinv221:get_anchor("C1"),
    }, bp.sdwidth))

    gate:merge_into_shallow(geometry.path_yx(generics.metal(1), {
        rows[1].front:get_anchor("Z"),
        rows[1].inv:get_anchor("I"),
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2].front:get_anchor("A"), {
            -separation / 2 - bp.nwidth / 1,
            rows[1].inv:get_anchor("O")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1].inv:get_anchor("O")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].front:get_anchor("A")))

    -- clk to ff_out
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[3].inv:get_anchor("O"), {
            -separation / 2 - bp.nwidth + bp.sdwidth / 2,
            rows[3].dff:get_anchor("CLK"),
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].inv:get_anchor("O")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].dff:get_anchor("CLK")))

    gate:merge_into_shallow(geometry.path_xy(generics.metal(2), {
        rows[3].inv:get_anchor("O") + point.create(0, -separation / 2 - bp.nwidth + bp.sdwidth / 2),
        rows[2].front:get_anchor("B1"),
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2].front:get_anchor("B2")))

    gate:merge_into_shallow(geometry.path(generics.metal(3), {
        rows[1].orandinv221:get_anchor("A"),
        rows[3].orandinv221:get_anchor("A"),
    }, bp.sdwidth))
    for i = 1, 3 do
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[i].orandinv221:get_anchor("A")))
    end

    -- reset
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2].front:get_anchor("B2"), {
        rows[2].front:get_anchor("Z") + point.create(0, separation / 2 + bp.nwidth - bp.sdwidth / 2),
        0,
        rows[2].orandinv221:get_anchor("A"),
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].orandinv221:get_anchor("A")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].front:get_anchor("B1")))

    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[1].front:get_anchor("A"), {
        -separation / 2 - bp.sdwidth / 2,
        rows[1].orandinv221:get_anchor("A")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1].front:get_anchor("A")))

    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2].front:get_anchor("Z"), {
            separation / 2 + bp.sdwidth / 2,
            rows[2].orandinv221:get_anchor("C2") + point.create(xpitch, -separation / 2 - bp.sdwidth / 2),
            rows[2].orandinv221:get_anchor("B1")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].orandinv221:get_anchor("B1")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].front:get_anchor("Z")))

    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(
        rows[3].front:get_anchor("O"), {
            separation / 2 + bp.sdwidth / 2,
            rows[3].orandinv221:get_anchor("C1")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].orandinv221:get_anchor("C1")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].front:get_anchor("O")))

    gate:merge_into_shallow(geometry.path_yx(generics.metal(3), {
        rows[3].front:get_anchor("O"),
        rows[1].orandinv221:get_anchor("C1")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1].orandinv221:get_anchor("C1")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3].front:get_anchor("O")))

    gate:merge_into_shallow(geometry.path_xy(generics.metal(3), {
        rows[3].orandinv221:get_anchor("B1"),
        rows[3].orandinv221:get_anchor("B1") + point.create(bp.sdwidth * -2, 0),
        rows[1].orandinv221:get_anchor("B1"), rows[1].orandinv221:get_anchor("B1")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3].orandinv221:get_anchor("B1")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1].orandinv221:get_anchor("B1")))

    gate:merge_into_shallow(geometry.path_xy(generics.metal(2),
        geometry.path_points_yx(rows[3].front:get_anchor("I"), {
            separation / 2 + bp.nwidth - bp.sdwidth / 2,
            rows[3].orandinv221:get_anchor("B1")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].orandinv221:get_anchor("B1")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].front:get_anchor("I")))

    gate:merge_into_shallow(geometry.path(generics.metal(3), {
        rows[3].orandinv221:get_anchor("C2"), rows[2].orandinv221:get_anchor("C2")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[3].orandinv221:get_anchor("C2")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2].orandinv221:get_anchor("C2")))

    -- ff_in_q    
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[1].dff:get_anchor("QN"), {
            separation / 2 + bp.pwidth - bp.sdwidth / 2,
            rows[1].orandinv221:get_anchor("B2")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1].dff:get_anchor("QN")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[1].orandinv221:get_anchor("B2")))

    gate:merge_into_shallow(geometry.path_xy(generics.metal(2), {
        rows[1].orandinv221:get_anchor("B2"),
        rows[2].orandinv221:get_anchor("C2")
    }, bp.sdwidth))

    -- bit_out
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[2].dff:get_anchor("QN"), {
            -separation / 2 - bp.pwidth + bp.sdwidth / 2,
            rows[2].orandinv221:get_anchor("B2")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].dff:get_anchor("QN")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].orandinv221:get_anchor("B2")))

    -- chain_out
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(rows[3].dff:get_anchor("QN"), {
            separation / 2 + bp.pwidth - bp.sdwidth / 2,
            rows[3].orandinv221:get_anchor("B2")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].dff:get_anchor("QN")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].orandinv221:get_anchor("B2")))

    -- clk connections
    gate:merge_into_shallow(geometry.path(generics.metal(3), {
        rows[2].dff:get_anchor("CLK"), rows[1].dff:get_anchor("CLK")
    }, bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[2].dff:get_anchor("CLK")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(rows[1].dff:get_anchor("CLK")))

    gate:merge_into_shallow(geometry.path(generics.metal(3), 
        geometry.path_points_yx(rows[3].inv:get_anchor("I"), {
            separation / 2 + bp.sdwidth / 2,
            rows[2].dff:get_anchor("CLK")
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[3].inv:get_anchor("I")))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(rows[2].dff:get_anchor("CLK")))

    gate:set_alignment_box(
        rows[1].lastisogate:get_anchor("bottomleft"),
        rows[3].dff:get_anchor("topright")
    )

    -- add ports
    gate:add_port("CLK", generics.metal(1), rows[3].inv:get_anchor("I"))
    gate:add_port("RST", generics.metal(1), rows[2].front:get_anchor("B1"))
    gate:add_port("UPD", generics.metal(1), rows[1].front:get_anchor("B"))
    gate:add_port("DIN", generics.metal(1), rows[1].orandinv221:get_anchor("C2"))
    gate:add_port("DOUT", generics.metal(1), rows[3].dff:get_anchor("QN"))
    gate:add_port("BOUT", generics.metal(1), rows[2].dff:get_anchor("QN"))
    gate:add_port("VDD", generics.metal(1), rows[3].dff:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1), rows[1].dff:get_anchor("bottom"))
end
