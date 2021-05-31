function parameters() 
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "numcells", 8 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local registermaster = pcell.create_layout("serial_interface/register_cell")
    local registername = gate:add_child_reference(registermaster, "register")

    -- place cells
    local daisycells = {}
    for i = 1, _P.numcells do
        daisycells[i] = gate:add_child_link(registername)
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
                geometry.path_points_xy(daisycells[i - 1]:get_anchor("DIN"), {
                    1000,
                    daisycells[i]:get_anchor("DOUT")
            }), bp.sdwidth))
        else
            gate:merge_into_shallow(geometry.path(generics.metal(4), 
                geometry.path_points_xy(daisycells[i - 1]:get_anchor("DIN"), {
                    0,
                    daisycells[i]:get_anchor("DOUT")
            }), bp.sdwidth))
        end
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i - 1]:get_anchor("DIN")))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("DOUT")))

        -- clock
        gate:merge_into_shallow(geometry.path(generics.metal(4), {
            daisycells[i]:get_anchor("CLK"), daisycells[i - 1]:get_anchor("CLK")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("CLK")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("CLK")))
        end

        -- reset
        gate:merge_into_shallow(geometry.path(generics.metal(3), {
            daisycells[i]:get_anchor("RST"), daisycells[i - 1]:get_anchor("RST")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("RST")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("RST")))
        end

        -- update
        gate:merge_into_shallow(geometry.path(generics.metal(3), {
            daisycells[i]:get_anchor("UPD"), daisycells[i - 1]:get_anchor("UPD")
        }, bp.sdwidth))
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("UPD")))
        if i == 2 then
            gate:merge_into_shallow(geometry.rectangle(generics.via(1, 3), bp.sdwidth, bp.sdwidth):translate(daisycells[1]:get_anchor("UPD")))
        end
    end

    -- add ports
    gate:add_port("CLK", generics.metal(1), daisycells[_P.numcells]:get_anchor("CLK"))
    gate:add_port("DIN", generics.metal(1), daisycells[_P.numcells]:get_anchor("DIN"))
    gate:add_port("DOUT", generics.metal(1), daisycells[1]:get_anchor("DOUT"))
    gate:add_port("UPD", generics.metal(1), daisycells[_P.numcells]:get_anchor("UPD"))
    gate:add_port("RST", generics.metal(1), daisycells[_P.numcells]:get_anchor("RST"))

    for i = 1, _P.numcells do
        gate:add_port(string.format("BOUT%d", i), generics.metal(1), daisycells[i]:get_anchor("BOUT"))
    end
end
