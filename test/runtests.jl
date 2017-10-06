using DataFrames
using Base.Test

include("$(Pkg.dir())/MultiDimEquations/src/MultiDimEquations.jl")

# TEST 1: Testing both defVars()and the @meq macro
df = wsv"""
reg	prod	var	value
us	banana	production	10
us	banana	transfCoef	0.6
us	banana	trValues	2
us	apples	production	7
us	apples	transfCoef	0.7
us	apples	trValues	5
us	juice	production	NA
us	juice	transfCoef	NA
us	juice	trValues	NA
eu	banana	production	5
eu	banana	transfCoef	0.7
eu	banana	trValues	1
eu	apples	production	8
eu	apples	transfCoef	0.8
eu	apples	trValues	4
eu	juice	production	NA
eu	juice	transfCoef	NA
eu	juice	trValues    NA
"""
variables =  vcat(unique(dropna(df[:var])),["consumption"])
defVars(variables,df;dfName="df",varNameCol="var", valueCol="value")
products = ["banana","apples","juice"]
primPr   = products[1:2]
secPr    = [products[3]]
reg      = ["us","eu"]
# equivalent to [production!(sum(trValues_(r,pp) * transfCoef_(r,pp)  for pp in primPr), r, sp) for r in reg, sp in secPr]
@meq production!(r in reg, sp in secPr)   = sum(trValues_(r,pp) * transfCoef_(r,pp)  for pp in primPr)
@meq consumption!(r in reg, pp in primPr) = production_(r,pp) - trValues_(r,pp)
@meq consumption!(r in reg, sp in secPr)  = production_(r, sp)
totalConsumption = sum(consumption_(r,p) for r in reg, p in products)

totalConsumption == 26.6

@test totalConsumption == 26.6


# Test 2: Fake test, this should not pass
# @test 1 == 2
