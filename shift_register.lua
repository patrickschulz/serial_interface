function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    local daisycells = {}
    local cell_amount = 8

    -- place cells
    for i = 0, cell_amount - 1 do
        if i == 0 then
            daisycells[i] = pcell.create_layout("register_cell"):move_anchor(
                                "right")
        elseif i % 2 == 0 then
            daisycells[i] = pcell.create_layout("register_cell"):move_anchor(
                                "bottom", daisycells[i - 1]:get_anchor("top"))
        else
            daisycells[i] = pcell.create_layout("register_cell"):flipy()
            daisycells[i]:move_anchor("bottom", daisycells[i - 1]:get_anchor(
                                          "top"))
        end
        gate:merge_into_update_alignmentbox(daisycells[i])
    end

    -- place connections & vias
    for i = 1, cell_amount - 1 do

        gate:merge_into(geometry.path_xy(generics.metal(5), {
            daisycells[i]:get_anchor("DOUT"),
            daisycells[i - 1]:get_anchor("DIN")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                           bp.sdwidth):translate(
                            daisycells[i]:get_anchor("DIN")))
        gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                           bp.sdwidth):translate(
                            daisycells[i - 1]:get_anchor("DOUT")))

        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("CLK"), daisycells[i - 1]:get_anchor("CLK")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                           bp.sdwidth):translate(
                            daisycells[i]:get_anchor("CLK")))

        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("RST"), daisycells[i - 1]:get_anchor("RST")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                           bp.sdwidth):translate(
                            daisycells[i]:get_anchor("RST")))

        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("UPD"), daisycells[i - 1]:get_anchor("UPD")
        }, bp.sdwidth))
        gate:merge_into(geometry.rectangle(generics.via(1, 5), bp.sdwidth,
                                           bp.sdwidth):translate(
                            daisycells[i]:get_anchor("UPD")))
    end

    -- add ports
    gate:add_port("CLK", generics.metal(1),
                  daisycells[cell_amount - 1]:get_anchor("CLK"))
    gate:add_port("DIN", generics.metal(1),
                  daisycells[cell_amount - 1]:get_anchor("DIN"))
    gate:add_port("DOUT", generics.metal(1), daisycells[0]:get_anchor("DOUT"))
    gate:add_port("UPD", generics.metal(1),
                  daisycells[cell_amount - 1]:get_anchor("UPD"))
    gate:add_port("RST", generics.metal(1),
                  daisycells[cell_amount - 1]:get_anchor("RST"))

    for i = 0, cell_amount - 1 do
        gate:add_port("BOUT" .. i, generics.metal(1),
                      daisycells[i]:get_anchor("BOUT"))
    end
end
