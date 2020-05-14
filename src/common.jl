
function extract(ex)
    return ex, nothing
end

function extract(ex::Expr)
    #@show ex
    if ex.head == :(=)
        left = ex.args[1]
        right = extract(ex.args[2])[1]
        if right isa Symbol
            right = String(right)
        end
        return left, right 
    elseif (ex.head == :bracescat) | (ex.head == :braces) # {x=1 ; y=2} or {x=1}
        res_dict = Dict()
        res_vec = Any[]
        
        for sub_ex in ex.args
            key, value = extract(sub_ex)
            if key == nothing
                continue
            elseif value == nothing
                push!(res_vec, key)
            else
                res_dict[key] = value
            end
        end
        
        if (length(res_dict) > 0) & (length(res_vec) == 0)
            return res_dict, nothing
        elseif (length(res_dict) == 0) & (length(res_vec) > 0)
            return res_vec, nothing
            #return convert(Vector{typeof(res_vec[1])}, res_vec), nothing
        elseif (length(res_dict) == 0) & (length(res_vec) == 0) # {}
            return res_vec, nothing
            #return nothing, nothing
        else
            println("ambiguous ex: $ex \n res_dict: $res_dict \n res_vec: $res_vec")
            return nothing, nothing
        end
    elseif ex.head == :row
        res_vec = Any[]
        for sub_ex in ex.args
            push!(res_vec, extract(sub_ex)[1])
        end
        return res_vec, nothing
    elseif ex.head == :call # suppress operation such as <, >, <=, >=
        return nothing, nothing
    else
        println("Unresolved expression: $ex")
        return nothing, nothing
    end
end

function type_adapt(::Type{Bool}, value::String)
    if value == "yes"
        return true
    elseif value == "no"
        return false
    else
        error("Try to convert unknown value $value to Bool")
    end
end

#type_adapt(::Type{String}, value::Symbol) = String(value)

function type_adapt(::Type{Vector{String}}, value::Vector)
    if length(value) == 0
        return String[]
    elseif typeof(value[1]) <: Vector
        return String.(value[1])
    else
        return string.(value)
    end
end

# type_adapt(::Type{Vector{String}}, value::Vector{Vector}) = String.(value[1])

# type_adapt(::Type{Union{String, Vector{String}}}, value::Symbol) = String(value)
type_adapt(::Type{Union{String, Vector{String}}}, value::Vector) = type_adapt(Vector{String}, value)
# type_adapt(::Type{Union{Dict, String}}, value::Symbol) = String(value)

type_adapt(::Any, value) = value

function adapt(type::Type, dict::Dict)
    dict = copy(dict)
    for (name, typ) in zip(fieldnames(type), fieldtypes(type))
        if name in keys(dict)
            dict[name] = type_adapt(typ, dict[name])
        end
    end
    return dict
end