

@kwdef struct TerrianModifier{T}
    attack::T = 0.
    defence::T = 0.
    movement::T = 0.
end

Base.convert(::Type{TerrianModifier{T}}, kwargs::Dict) where T = TerrianModifier{T}(;kwargs...)
Base.convert(::Type{TerrianModifier{T}}, kwargs::NamedTuple) where T = TerrianModifier{T}(;kwargs...)


@kwdef struct SubUnit{T}
    sprite::String = ""
    map_icon_category::String = ""
    priority::T = 0.
    ai_priority::T = 0.
    active::Bool = true
    affects_speed::Bool = true

    special_forces::Bool = false

    cavalry::Bool = false
    marines::Bool = false
    mountaineers::Bool = false

    type::Vector{String} = String[]

    group::String = ""

    categories::Vector{String} = String[]

    combat_width::T = 0.

    # Size Definitions
    max_organisation::T = 0.
    max_strength::T = 0.
    default_morale::T = 0.
    manpower::T = 0.

    # Misc Ailities
    maximum_speed::T = 0.
    training_time::T = 0.
    weight::T = 0.

    supply_consumption::T = 0.
    recon::T = 0.
    
    # Those attributes is just "bonus", base value is determined by equipment
    # Support nerfs to combat abilities
    entrenchment::T = 0.
    defense::T = 0.
    breakthrough::T = 0.
    soft_attack::T = 0.
    hard_attack::T = 0.
    ap_attack::T = 0.
    air_attack::T = 0.

    # Important Ability
    reliability_factor::T = 0.
    equipment_capture_factor::T = 0.
    suppression_factor::T = 0.
    casualty_trickleback::T = 0.
    experience_loss_factor::T = 0.
    own_equipment_fuel_consumption_mult::T = 0.
    supply_consumption_factor::T = 0.
    fuel_consumption_factor::T = 0.
    initiative::T = 0.

    essential::Vector{String} = String[]

    # Offensive Abilities
    suppression::T = 0.

    # this is what moves us and sets speed
    transport::String = ""

    #need::NamedTuple = NamedTuple()
    need::Dict = Dict()

    can_be_parachuted::Bool = false

    # TerrianModifier list
    forest::TerrianModifier{T} = TerrianModifier()
    hills::TerrianModifier{T} = TerrianModifier()
    mountain::TerrianModifier{T} = TerrianModifier()
    jungle::TerrianModifier{T} = TerrianModifier()
    marsh::TerrianModifier{T} = TerrianModifier()
    plains::TerrianModifier{T} = TerrianModifier()
    urban::TerrianModifier{T} = TerrianModifier()
    desert::TerrianModifier{T} = TerrianModifier()
    fort::TerrianModifier{T} = TerrianModifier()
    river::TerrianModifier{T} = TerrianModifier()
    amphibious::TerrianModifier{T} = TerrianModifier()

    same_support_type::String = ""

    # ship specific
    #need_equipment::NamedTuple = NamedTuple()
    need_equipment::Dict = Dict()
    #need_equipment_modules::NamedTuple = NamedTuple()
    need_equipment_modules::Dict = Dict()
    critical_parts::Vector{String} = String[]
    critical_part_damage_chance_mult::T = 0.
    hit_profile_mult::T = 0.
end

function SubUnit(type::Type, dict::Dict)
    #dict_adapted = adapt(SubUnit, dict)
    SubUnit{type}(;dict...)
end

SubUnit(dict::Dict) = SubUnit(Float64, dict)


# SubUnit(;kwargs...) = SubUnit{Float64}(;kwargs...)

function parse_sub_units_from_dir(root::String)
    f_map = Dict{String, String}()

    for name in readdir(root)
        p = joinpath(root, name)
        if isfile(p)
            #println(p)
            
            f = open(p, "r")
            s = read(f, String)
            close(f)
            f_map[p] = s
        end
    end

    sub_unit_dict = Dict{Symbol, SubUnit}()

    for (p, s) in f_map
        #parsed = s |> split_word |> build_tree |> extract
        parsed = s |> Meta.parse
        for (key, unit) in zip(keys(parsed[:sub_units]), parsed[:sub_units])
            #println(key)
            sub_unit = SubUnit(;unit...)
            sub_unit_dict[key] = sub_unit
        end
    end

    return sub_unit_dict
end

