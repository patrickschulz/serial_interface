function parameters() 
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "numcells", 2 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local registermaster = pcell.create_layout("serial_interface/register_cell")
    local registername = pcell.add_cell_reference(registermaster, "register")

    -- place cells
    local daisycells = {}
    for i = 1, _P.numcells do
        daisycells[i] = gate:add_child(registername)
        if i % 2 == 0 then
            daisycells[i]:flipy()
        end
        if i > 1 then
            daisycells[i]:move_anchor("bottom", daisycells[i - 1]:get_anchor("top"))
        end
    end

    -- place connections & vias
    for i = 2, _P.numcells do
        if i % 2 == 1 then
            gate:merge_into_shallow(geometry.path(generics.metal(4), 
                geometry.path_points_xy(daisycells[i - 1]:get_anchor("chain_in"), {
                    1000,
                    daisycells[i]:get_anchor("chain_out")
            }), bp.sdwidth))
        else
            gate:merge_into_shallow(geometry.path(generics.metal(4), 
                geometry.path_points_xy(daisycells[i - 1]:get_anchor("chain_in"), {
                    0,
                    daisycells[i]:get_anchor("chain_out")
            }), bp.sdwidth))
        end
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i - 1]:get_anchor("chain_in")))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("chain_out")))

        -- clock
        gate:merge_into_shallow(geometry.path(generics.metal(4), {
            daisycells[i]:get_anchor("clk"), daisycells[i - 1]:get_anchor("clk")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("clk")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("clk")))
        end

        -- reset
        gate:merge_into_shallow(geometry.path(generics.metal(3), {
            daisycells[i]:get_anchor("reset"), daisycells[i - 1]:get_anchor("reset")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("reset")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("reset")))
        end

        -- update
        gate:merge_into_shallow(geometry.path(generics.metal(3), {
            daisycells[i]:get_anchor("update"), daisycells[i - 1]:get_anchor("update")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("update")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("update")))
        end
    end

    -- add ports
    gate:add_port("clk", generics.metal(1), daisycells[_P.numcells]:get_anchor("clk"))
    gate:add_port("chain_in", generics.metal(1), daisycells[_P.numcells]:get_anchor("chain_in"))
    gate:add_port("chain_out", generics.metal(1), daisycells[1]:get_anchor("chain_out"))
    gate:add_port("update", generics.metal(1), daisycells[_P.numcells]:get_anchor("update"))
    gate:add_port("reset", generics.metal(1), daisycells[_P.numcells]:get_anchor("reset"))

    for i = 1, _P.numcells do
        gate:add_port(string.format("bitout%d", i), generics.metal(1), daisycells[i]:get_anchor("bit_out"))
    end
end
