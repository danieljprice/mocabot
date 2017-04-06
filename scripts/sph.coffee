# Description:
#   This is an SPH code!

root = exports ? this

root.dfkern = (q) ->
    if 0.0 <= q <= 1.0
        twoq = 2.0 - q
        oneq = 1.0 - q
        val = - 0.75 * twoq * twoq + 3.0 * oneq * oneq
    else if 1.0 < q <= 2.0
        twoq = 2.0 - q
        val = -0.75 * twoq * twoq
    else
        val = 0.0
    val

root.fkern = (q) ->
    if 0.0 <= q <= 1.0
        twoq = 2.0 - q
        oneq = 1.0 - q
        val = 0.25 * twoq * twoq * twoq - oneq * oneq * oneq
    else if 1.0 < q <= 2.0
        twoq = 2.0 - q
        val = 0.25 * twoq * twoq * twoq
    else
        val = 0.0
    val

root.dwkern = (xa, xb, h) ->
    xab = xb - xa
    q = Math.abs(xab) / h
    sigma = 0.6666666666
    - Math.sign(xab) * (sigma / (h * h)) * root.dfkern(q)

root.wkern = (xa, xb, h) ->
    xab = xb - xa
    q = Math.abs(xab) / h
    sigma = 0.6666666666
    (sigma / h) * root.fkern(q)

root.getdens = (x, h, m) ->
    rho = []
    a = 0
    while a < x.length
        rhoa = 0.0
        b = 0
        while b < x.length
            rhoa += root.wkern(x[a], x[b], h[a])
            b++
        a++
        rho.push m * rhoa
    rho

root.solveh = (x, h, m) ->
    hfac = 1.2
    its = 0
    while its < 5
        rho = root.getdens(x, h, m)
        h = (hfac * m / rhoa for rhoa in rho)
        its++
    [h, rho]

root.accel = (x, h, v, p, rho, cs, m) ->
    alpha = 1
    beta = 2
    acc = []
    du = []
    for a in [0...x.length]
        acca = 0.0
        dua = 0.0
        for b in [0...x.length]
            rhoa2 = rho[a] * rho[a]
            rhob2 = rho[b] * rho[b]
            xab = x[b] - x[a]
            vab = v[b] - v[a]
            vabxab = vab * Math.sign(xab)
            if vabxab < 0.0
                vsiga = alpha * cs[a] - beta * vabxab
                vsigb = alpha * cs[b] - beta * vabxab
                qa = - 0.5 * rho[a] * vsiga * vabxab
                qb = - 0.5 * rho[b] * vsigb * vabxab
            else
                qa = 0.0
                qb = 0.0
            acca += - (p[a] + qa) * root.dwkern(x[a], x[b], h[a]) / rhoa2
            acca += - (p[b] + qb) * root.dwkern(x[a], x[b], h[b]) / rhob2
            dua  += (p[a] + qa) * (v[a] - v[b]) * root.dwkern(x[a], x[b], h[a]) / rhoa2
        acc.push m * acca
        du.push m * dua
    [acc, du]

root.derivs = (x, h, v, rho, u, p, cs, m) ->
    [h, rho] = root.solveh(x, h, m)
    p = []
    for a in [0...x.length]
        p.push (1.4 - 1.0) * rho[a] * u[a]
    [acc, du] = root.accel(x, h, v, p, rho, cs, m)
    [h, acc, du, rho, p]

root.leapfrog = (x, h, v, rho, u, p, m, tfin, npart) ->
    xnew = x
    vnew = v
    unew = u
    cs = []
    for a in [0...x.length]
        cs.push Math.sqrt(1.4 * p[a] / rho[a])
    [h, accnew, dunew, rho, p] = root.derivs(x, h, v, rho, u, p, cs, m)

    t = 0.0
    while t < tfin
        # console.log 't =', t
        xold = xnew
        vold = vnew
        accold = accnew
        uold = unew
        duold = dunew

        cs = []
        for a in [0...x.length]
            cs.push Math.sqrt(1.4 * p[a] / rho[a])
        dt = 0.3 * Math.min(h[0..npart]...) / Math.max(cs[0..npart]...)

        xnew = []
        for a in [0...x.length]
            if a < npart
                xnew.push xold[a] + (dt * vold[a]) + (0.5 * dt * dt * accold[a])
            else
                xnew.push xold[a]
        vpredict = []
        for a in [0...x.length]
            if a < npart
                vpredict.push vold[a] + dt * accold[a]
            else
                vpredict.push 0.0
        upredict = []
        for a in [0...x.length]
            if a < npart
                upredict.push uold[a] + dt * duold[a]
            else
                upredict.push uold[a]
        [h, accnew, dunew, rho, p] = root.derivs(xnew, h, vpredict, rho, unew, p, cs, m)
        vnew = []
        for a in [0...x.length]
            if a < npart
                vnew.push vpredict[a] + (0.5 * dt * (accnew[a] - accold[a]))
            else
                vnew.push 0.0
        unew = []
        for a in [0...x.length]
            if a < npart
                unew.push upredict[a] + (0.5 * dt * (dunew[a] - duold[a]))
            else
                unew.push upredict[a]

        t += dt
    [xnew, rho]


module.exports = (robot) ->
    robot.respond /sph\s?(.*)?/i, (res) ->
        input = Number(res.match[1])
        if isNaN(input)
            res.send "I can solve the shock tube problem using SPH!\nWhat time do you want to integrate to?\nE.g. @mocabot sph 0.2"
            return
        else if input < 0.0
            res.send "Choose a _positive_ simulation end time! :joy:"
            return
        else if input > 0.2
            res.send "Choose an end time no greater than 0.2\nI'm kinda slow at this SPH thing :flushed:"
            return

        npart = 200
        nghost = 10
        rholeft = 1.0
        rhoright = 0.125
        pleft = 1.0
        pright = 0.1
        tfin = input

        nleft = Math.round(npart * rholeft / (rholeft + rhoright))
        nright = npart - nleft

        x = []
        rho = []
        h = []
        v = []
        p = []

        for i in [0...npart]
            if i < nleft
                x.push 0.5 * i / nleft
                rho.push rholeft
                p.push pleft
                h.push 1.0 / nleft
                v.push 0.0
            else
                x.push 0.5 + 0.5 * ((i - nleft) / nright)
                rho.push rhoright
                p.push pright
                h.push 1.0 / nright
                v.push 0.0
        for i in [0...nghost]
            x.push 0.0 - 0.5 * (i + 1) / nleft
            rho.push rholeft
            p.push pleft
            h.push 1.0 / nleft
            v.push 0.0
        for i in [0...nghost]
            x.push 1.0 + 0.5 * ((i + 1) / nright)
            rho.push rhoright
            p.push pright
            h.push 1.0 / nright
            v.push 0.0

        m = (x[1] - x[0]) * rholeft
        [h, rho] = root.solveh(x, h, m)
        u = []
        for a in [0...x.length]
            u.push p[a] / ((1.4 - 1.0) * rho[a])

        [x, rho] = root.leapfrog(x, h, v, rho, u, p, m, tfin, npart)

        nrow = 12
        ncol = 30
        rhogrid = []
        for i in [0...ncol]
            left = i / ncol
            right = (i + 1) / ncol
            nbin = 0
            rhobin = 0.0
            for j in [0...x.length]
                # console.log left < x[j] <= right
                if left < x[j] <= right
                    rhobin += rho[j]
                    nbin++
            rhogrid.push Math.round(nrow * rhobin / nbin)
        text = []
        text.push '*Slack Particle Hydrodynamics*'
        text.push 'Adiabatic shock tube'
        text.push npart + ' particles'
        text.push 't = ' + tfin
        text.push ''
        for j in [0...nrow]
            line = []
            for i in [0...ncol]
                if rhogrid[i] == nrow - j
                    line.push '█'
                else
                    line.push '░'
            text.push line.join('')
        res.send text.join('\n')
