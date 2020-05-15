@kwdef struct DivisionTemplate # kwdef make it possible to use keyword specify parameter
    unitList::Array{LandUnit,1}
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    Manpower::Int64
    Speed::Float64 # 8.0/10.0/12.0 -> 8.0
    SoftAtk::Float64
    HardAtk::Float64
    AirAtk::Float64
    Defense::Float64
    Breakthr::Float64
    Armor::Float64 # 10/15/20 -> 10
    Pierce::Float64
    Hardness::Float64 # 64% -> 0.64
    FuelUsage::Float64
    ProdCost::Float64
end

function DivisionTemplate(unitList::Vector{LandUnit})
    armor_arr = [unit.Armor for unit in unitList]
    pierce_arr = [unit.Pierce for unit in unitList]

    DivisionTemplate(
        unitList = unitList,
        HP = sum([unit.HP for unit in unitList]),
        Org = mean([unit.Org for unit in unitList]),
        Recov = sum([unit.Recov for unit in unitList]),
        Suppr = mean([unit.Suppr for unit in unitList]),
        Weight = sum([unit.Weight for unit in unitList]),
        Supply = sum([unit.Supply for unit in unitList]),
        Width = sum([unit.Width for unit in unitList]),
        Manpower = sum([unit.Manpower for unit in unitList]),
        Speed = minimum([unit.Speed for unit in unitList]),
        SoftAtk = sum([unit.SoftAtk for unit in unitList]),
        HardAtk = sum([unit.HardAtk for unit in unitList]),
        AirAtk = sum([unit.AirAtk for unit in unitList]),
        Defense = sum([unit.Defense for unit in unitList]),
        Breakthr = sum([unit.Breakthr for unit in unitList]),
        Armor = 0.3 * maximum(armor_arr) + 0.7 * mean(armor_arr),
        Pierce = 0.4 * maximum(pierce_arr) + 0.6 * mean(pierce_arr),
        Hardness = mean([unit.Hardness for unit in unitList]),
        FuelUsage = sum([unit.FuelUsage for unit in unitList]),
        ProdCost = sum([unit.ProdCost for unit in unitList]),
    )
end

function DivisionTemplate(config_list::Tuple{LandUnit,Int64}...)
    unit_list = LandUnit[]
    for (unit, count) in config_list
        for i in 1:count
            push!(unit_list, unit)
        end
    end
    DivisionTemplate(unit_list)
end

#=
function Base.show(io::IO, ::MIME"text/plain", div::DivisionTemplate)
    # print(io, "uniList: ")
    # print(io, join([unit.Unit for unit in div.unitList], ","))
    for fn in fieldnames(typeof(div))
        if fn == :unitList
            continue
        end
        print(io, " $fn: $(getproperty(div, fn)),")
    end
end
=#

mutable struct Division
    T::DivisionTemplate # template, max HP, max Org, etc...
    HP::Float64
    Org::Float64
end


function Division(template::DivisionTemplate)
    Division(template, template.HP, template.Org)
end

function reset!(div::Division)
    div.HP = div.T.HP
    div.Org = div.T.Org
end

function broken(div::Division)
    return div.Org <= 0
end

function eliminated(div::Division)
    return div.HP <= 0
end

function defeated(div::Division)
    return broken(div) || eliminated(div)
end

function Base.show(io::IO, media::MIME"text/plain", div::Division)
    f(x) = round(x, digits=1)
    
    println(io, "HP: $(f(div.HP))/$(f(div.T.HP))")
    println(io, "Org: $(f(div.Org))/$(f(div.T.Org))")
    println(io, "SoftAtk, HardAtk: $(f(div.T.SoftAtk)), $(f(div.T.HardAtk))")
    println(io, "Breakthr, Defense: $(f(div.T.Breakthr)), $(f(div.T.Defense))")
    println(io, "Pierce, Armor: $(f(div.T.Pierce)), $(f(div.T.Armor))")
    println(io, "Hardness, Width: $(round(div.T.Hardness, digits=3)), $(f(div.T.Width))")
    print(io, "T:")
    show(io, media, div.T)
end
