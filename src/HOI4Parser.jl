module HOI4Parser

import Base.@kwdef
using Statistics

include("common.jl")
include("units.jl")
include("equipment.jl")
include("land_units.jl")
include("io.jl")

greet() = print("Hello World!")

end # module
