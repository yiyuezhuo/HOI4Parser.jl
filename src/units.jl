
import Base.@kwdef

@kwdef struct TerrianModifier{T}
    attack::T = T(0)
    defence::T = T(0)
    movement::T = T(0)
end

Base.convert(::Type{TerrianModifier{T}}, kwargs::Dict{Symbol, <:Any}) where T = TerrianModifier{T}(;kwargs...)

@kwdef struct SubUnit{T}
    sprite::String = "missing sprite"
    map_icon_category::String = "missing map_icon_category"
    priority::T = T(0)
    ai_priority::T = T(0)
    active::Bool = true
    affects_speed::Bool = true

    special_forces::Bool = false

    cavalry::Bool = false
    marines::Bool = false
    mountaineers::Bool = false

    type::Vector{String} = String[]

    group::String = "missing group"

    categories::Vector{String} = String[]

    combat_width::T = T(0)

    # Size Definitions
    max_organisation::T = T(0)
    max_strength::T = T(0)
    default_morale::T = T(0)
    manpower::T = T(0)

    # Misc Ailities
    maximum_speed::T = T(0)
    training_time::T = T(0)
    weight::T = T(0)

    supply_consumption::T = T(0)
    recon::T = T(0)
    
    # Those attributes is just "bonus", base value is determined by equipment
    # Support nerfs to combat abilities
    entrenchment::T = T(0)
    defense::T = T(0)
    breakthrough::T = T(0)
    soft_attack::T = T(0)
    hard_attack::T = T(0)
    ap_attack::T = T(0)
    air_attack::T = T(0)

    # Important Ability
    reliability_factor::T = T(0)
    equipment_capture_factor::T = T(0)
    suppression_factor::T = T(0)
    casualty_trickleback::T = T(0)
    experience_loss_factor::T = T(0)
    own_equipment_fuel_consumption_mult::T = T(0)
    supply_consumption_factor::T = T(0)
    fuel_consumption_factor::T = T(0)
    initiative::T = T(0)

    essential::Vector{String} = String[]

    # Offensive Abilities
    suppression::T = T(0)

    # this is what moves us and sets speed
    transport::String = "missing transport"

    need::Dict{Symbol, T} = Dict{Symbol, T}()

    can_be_parachuted::Bool = false

    # TerrianModifier list
    forest::TerrianModifier{T} = TerrianModifier{T}()
    hills::TerrianModifier{T} = TerrianModifier{T}()
    mountain::TerrianModifier{T} = TerrianModifier{T}()
    jungle::TerrianModifier{T} = TerrianModifier{T}()
    marsh::TerrianModifier{T} = TerrianModifier{T}()
    plains::TerrianModifier{T} = TerrianModifier{T}()
    urban::TerrianModifier{T} = TerrianModifier{T}()
    desert::TerrianModifier{T} = TerrianModifier{T}()
    fort::TerrianModifier{T} = TerrianModifier{T}()
    river::TerrianModifier{T} = TerrianModifier{T}()
    amphibious::TerrianModifier{T} = TerrianModifier{T}()

    same_support_type::String = "missing same_support_type"

    # ship specific
    need_equipment::Dict{Symbol, Any} = Dict{Symbol, Any}()
    need_equipment_modules::Dict{Symbol, Any} = Dict{Symbol, Any}()
    critical_parts::Vector{String} = String[]
    critical_part_damage_chance_mult::T = T(0)
    hit_profile_mult::T = T(0)
end

# SubUnit(;kwargs...) = SubUnit{Float64}(;kwargs...)

