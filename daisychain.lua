function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    local daisycells = {}
    local cell_amount = 8
    local bottom_add = 2200

    -- place cells
    for i = 0, cell_amount - 1 do
        if i == 0 then
            daisycells[i] = pcell.create_layout("register_cell"):move_anchor(
                                "right")
        elseif i % 2 == 0 then
            daisycells[i] = pcell.create_layout("register_cell"):move_anchor(
                                "bottom",
                                daisycells[i - 1]:get_anchor("bottom") +
                                    point.create(0, bottom_add))
        else
            daisycells[i] = pcell.create_layout("register_cell"):flipy()
            daisycells[i]:move_anchor("bottom", daisycells[i - 1]:get_anchor(
                                          "top") + point.create(0, 1100))
        end
        gate:merge_into_update_alignmentbox(daisycells[i])
    end

    -- place connections
    for i = 1, cell_amount - 1 do
        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("COUT"), daisycells[i-1]:get_anchor("CIN")
        }, bp.sdwidth))
        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("CLK"), daisycells[i-1]:get_anchor("CLK")
        }, bp.sdwidth))
        gate:merge_into(geometry.path(generics.metal(5), {
            daisycells[i]:get_anchor("RST"), daisycells[i-1]:get_anchor("RST")
        }, bp.sdwidth))
    end

end
