function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings

    local daisycells = {}
    local cell_amount = 8

    -- place cells
    local register = pcell.create_layout("register_cell")
    for i = 1, cell_amount do
        if i == 1 then
            daisycells[i] = register:copy():move_anchor("right")
        elseif i % 2 == 1 then
            daisycells[i] = register:copy():move_anchor("bottom", daisycells[i - 1]:get_anchor("top"))
        else
            daisycells[i] = register:copy():flipy():move_anchor("bottom", daisycells[i - 1]:get_anchor("top"))
        end
        gate:merge_into_update_alignmentbox(daisycells[i])
    end

    -- place connections & vias
    for i = 2, cell_amount do
        gate:merge_into(geometry.path_xy(generics.metal(4), {
            daisycells[i]:get_anchor("DOUT"),
            daisycells[i - 1]:get_anchor("DIN")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("DIN")))
        gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i - 1]:get_anchor("DOUT")))
        gate:merge_into(geometry.path(generics.metal(4), {
            daisycells[i]:get_anchor("CLK"), daisycells[i - 1]:get_anchor("CLK")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("CLK")))
        gate:merge_into(geometry.path(generics.metal(4), {
            daisycells[i]:get_anchor("RST"), daisycells[i - 1]:get_anchor("RST")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("RST")))
        gate:merge_into(geometry.path(generics.metal(4), {
            daisycells[i]:get_anchor("UPD"), daisycells[i - 1]:get_anchor("UPD")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 4), bp.sdwidth, bp.sdwidth):translate(daisycells[i]:get_anchor("UPD")))
    end

    -- add ports
    gate:add_port("CLK", generics.metal(1), daisycells[cell_amount]:get_anchor("CLK"))
    gate:add_port("DIN", generics.metal(1), daisycells[cell_amount]:get_anchor("DIN"))
    gate:add_port("DOUT", generics.metal(1), daisycells[1]:get_anchor("DOUT"))
    gate:add_port("UPD", generics.metal(1), daisycells[cell_amount]:get_anchor("UPD"))
    gate:add_port("RST", generics.metal(1), daisycells[cell_amount]:get_anchor("RST"))

    for i = 1, cell_amount do
        gate:add_port("BOUT" .. i, generics.metal(1),
                      daisycells[i]:get_anchor("BOUT"))
    end
end
