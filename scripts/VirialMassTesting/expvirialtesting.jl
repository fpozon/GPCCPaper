@everywhere using GPCC
using JLD2
using ProgressMeter, Suppressor, Printf
using GPCCData

function formdelays(source)

    tobs, = readdataset(source = source);

    τmax = maximum(maximum.(tobs)) - minimum(minimum.(tobs))

    τ = 0.0:0.1:τmax

    L = length(tobs)

    delays = Iterators.product([τ for l in 1:L-1]...)

    return delays

end

function runme(source; maxiter=1, initialrandom = 1, numberofrestarts=1, rhomax = rhomax, kernel = kernel, delays = delays)

    tobs, yobs, σobs, = readdataset(source = source);

    @printf("Trying out %d delay combinations in parallel\n", length(delays))

    @showprogress pmap(d->(@suppress performcv(tobs, yobs, σobs; initialrandom = initialrandom, rhomax=rhomax, iterations = maxiter, numberofrestarts = numberofrestarts, delays = [0;collect(d)], kernel = kernel)), delays)

end


# warmup
runme("3C120"; maxiter=1, numberofrestarts=1, rhomax = 10, kernel = OU(), delays = LinRange(0.0, 10, 2*nworkers()))
runme("3C120"; maxiter=1, numberofrestarts=1, rhomax = 10, kernel = OU(), delays = LinRange(0.0, 10, 2*nworkers()))


function properrun(kernel)

    source = "3C120"

    delays = formdelays(source)

    let

        rhomax = 500.0

        numberofrestarts = 1

        initialrandom = 1

        RESULTS = runme(source, maxiter = 3000, initialrandom = initialrandom, numberofrestarts = numberofrestarts, rhomax = rhomax, kernel = kernel, delays = delays)

        JLD2.save("results_1.jld2", "cvresults", RESULTS, "delays", collect(delays))

    end

    let

        rhomax = 500.0

        numberofrestarts = 10

        initialrandom = 1

        RESULTS = runme(source, maxiter = 3000, initialrandom = initialrandom, numberofrestarts = numberofrestarts, rhomax = rhomax, kernel = kernel, delays = delays)

        JLD2.save("results_2.jld2", "cvresults", RESULTS, "delays", collect(delays))

    end

    let

        rhomax = 500.0

        numberofrestarts = 10

        initialrandom = 100

        RESULTS = runme(source, maxiter = 3000, initialrandom = initialrandom, numberofrestarts = numberofrestarts, rhomax = rhomax, kernel = kernel, delays = delays)

        JLD2.save("results_3.jld2", "cvresults", RESULTS, "delays", collect(delays))

    end

    let

        rhomax = 500.0

        numberofrestarts = 33

        initialrandom = 1

        RESULTS = runme(source, maxiter = 3000, initialrandom = initialrandom, numberofrestarts = numberofrestarts, rhomax = rhomax, kernel = kernel, delays = delays)

        JLD2.save("results_4.jld2", "cvresults", RESULTS, "delays", collect(delays))

    end
end