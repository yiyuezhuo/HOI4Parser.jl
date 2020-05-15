"""
Here we will focus on interested properties only.
"""

@kwdef struct LandUnit
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    Manpower::Int64
    MapIconCategory::String
    Categories::Vector{String}
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

function LandUnit(sub_unit::SubUnit, equip::Equipment)
    @assert Symbol(equip.archetype) in keys(sub_unit.need)

    LandUnit(
        HP = sub_unit.max_strength,
        Org = sub_unit.max_organisation,
        Recov = sub_unit.default_morale,
        Suppr = sub_unit.suppression,
        Weight = sub_unit.weight,
        Supply = sub_unit.supply_consumption,
        Width = sub_unit.combat_width,
        Manpower = sub_unit.manpower,
        MapIconCategory = sub_unit.map_icon_category,
        Categories = sub_unit.categories,
        Speed = sub_unit.maximum_speed,
        SoftAtk = (1. + sub_unit.soft_attack) * equip.soft_attack,
        HardAtk = (1. + sub_unit.hard_attack) * equip.hard_attack,
        AirAtk = (1. + sub_unit.air_attack) * equip.air_attack,
        Defense = (1. + sub_unit.defense) * equip.defense,
        Breakthr = (1. + sub_unit.breakthrough) * equip.breakthrough,
        Armor = equip.armor_value,
        Pierce = (1. + sub_unit.ap_attack) * equip.ap_attack,
        Hardness = equip.hardness,
        FuelUsage = equip.fuel_consumption,
        ProdCost = equip.build_cost_ic
    )
end

Base.@kwdef struct DivisionTemplate # kwdef make it possible to use keyword specify parameter
    unitList::Array{LandUnit,1}
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    Manpower::Int64
    Training::Int64
    Speed::Float64
    SoftAtk::Float64
    HardAtk::Float64
    AirAtk::Float64
    Defense::Float64
    Breakthr::Float64
    Armor::Float64
    Pierce::Float64
    Hardness::Float64
    FuelCapacity::Float64
    FuelUsage::Float64
    ProdCost::Float64
end

mutable struct Division
    T::DivisionTemplate # template, max HP, max Org, etc...
    HP::Float64
    Org::Float64
end

collect_property(unitList::Array, key::Symbol) = [getproperty(unit, key) for unit in unitList]

function DivisionTemplate(unitList::Array{SubUnit,1})
    # sum property
    kw_dict = Dict{Symbol, Real}()
    for key in [:HP, :Recov, :Suppr, :Weight, :Supply, :Width, :Manpower, :SoftAtk, :HardAtk, :AirAtk,
                :Defense, :Breakthr, :FuelCapacity, :FuelUsage, :ProdCost]
        kw_dict[key] = sum(collect_property(unitList, key))
    end
    
    # mean property
    for key in [:Org, :Hardness]
        kw_dict[key] = mean(collect_property(unitList, key))
    end
    
    # max property
    for key in [:Training]
        kw_dict[key] = maximum(collect_property(unitList, key))
    end
    
    # min property
    for key in [:Speed]
        kw_dict[key] = minimum(collect_property(unitList, key))
    end
    
    # speciel
    armor = collect_property(unitList, :Armor)
    pierce = collect_property(unitList, :Pierce)
    
    kw_dict[:Armor] = 0.3*maximum(armor) + 0.7*mean(armor)
    kw_dict[:Pierce] = 0.4*maximum(pierce) + 0.6*mean(pierce)
    
    return DivisionTemplate(;unitList=unitList, kw_dict...)
end

function DivisionTemplate(config_list::Tuple{SubUnit,Int64}...)
    unit_list = Array{SubUnit,1}()
    for (unit, count) in config_list
        for i in 1:count
            push!(unit_list, unit)
        end
    end
    DivisionTemplate(unit_list)
end

function Base.show(io::IO, ::MIME"text/plain", div::DivisionTemplate)
    print(io, "uniList: ")
    print(io, join([unit.Unit for unit in div.unitList], ","))
    for fn in fieldnames(typeof(div))
        if fn == :unitList
            continue
        end
        print(io, " $fn: $(getproperty(div, fn)),")
    end
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
