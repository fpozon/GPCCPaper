@everywhere using GPCC
using JLD2
using ProgressMeter, Suppressor, Printf
using GPCCData

function formdelays(source, Δt)

    tobs, = readdataset(source = source);

    τmax = maximum(maximum.(tobs)) - minimum(minimum.(tobs))

    τ = 0.0:Δt:τmax

    L = length(tobs)

    delays = Iterators.product([τ for l in 1:L-1]...)

    return delays

end

function runme(source; maxiter=1, numberofrestarts=1, rhomax = rhomax, kernel = kernel, delays = delays)

    tobs, yobs, σobs, = readdataset(source = source);

    @printf("Trying out %d delay combinations in parallel with kernel %s\n", length(delays), string(kernel))

    @showprogress pmap(d->(@suppress performcv(tobs, yobs, σobs; rhomax=rhomax, iterations = maxiter, numberofrestarts = numberofrestarts, delays = [0;collect(d)], kernel = kernel)), delays)

end


# warmup
runme("3C120"; maxiter=1, numberofrestarts=1, rhomax = 10, kernel = GPCC.OU, delays = LinRange(0.0, 10, 2*nworkers()))
runme("3C120"; maxiter=1, numberofrestarts=1, rhomax = 10, kernel = GPCC.OU, delays = LinRange(0.0, 10, 2*nworkers()))


function properrun(; kernel, rhomax = 1000.0, Δt = 0.1, numberofrestarts = 7, name = "")

    for source in ["3C120"] # listvirialdatasets()

        delays = formdelays(source, Δt)

        RESULTS = runme(source, maxiter = 3000, numberofrestarts = numberofrestarts, rhomax = rhomax, kernel = kernel, delays = delays)

        JLD2.save("results_" * name * source * @sprintf("_rho_%f_K_", rhomax) * string(kernel) * "_Dt_" * string(Δt) * ".jld2", "cvresults", RESULTS, "delays", collect(delays))

    end

end
