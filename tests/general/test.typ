#import "../../src/lib.typ": *

#import "@preview/cetz:0.5.3": canvas, draw

#canvas({
  import draw: *
  let c1 = new(circle, (0, 0), radius: 2, name: "c1")
  let c2 = c1
  c2.push((arg(0): "c1.east", anchor: "west", name: "c2"))

  let t1 = new(content, (0, 0), [Some \ Text Long])
  t1.push((arg(0): "c1.center"))
  t1.push((arg(1): update(align.with(center))))

  put(c1)
  put(c2)
  put(t1)
})

#pagebreak()


#import "@local/chemformula:0.1.4": ch

#canvas({
  import draw: *
  let base = new(line, (0, 0), (5, 0), name: "l0")
  let t0 = new(content, (), ch("Na(s) + 1/2 Cl2(g)"))
  t0.push((arg(0): "l0.start", anchor: "east", padding: (right: .5)))

  let step1 = base
  step1.push(it => {
    translate(y: 2)
    it
  })
  step1.push((name: "l1"))
  let t1 = t0
  t1.push((arg(1): ch("Na(g) + 1/2 Cl2(g)")))
  t1.push((arg(0): "l1.start"))

  let sub = new(line, mark: (end: "stealth", fill: eastern), stroke: eastern)
  sub.push((arg(<all>): ("l0.mid", "l1.mid"), name: "sub"))
  let ts1 = t1
  ts1.push((arg(0): "sub.mid", arg(1): $Delta H_"sublimation"$))
  ts1.push((arg(1): update(text.with(fill: eastern))))
  let step2 = step1
  let t2 = t1
  step2.push((name: "l2"))
  t2.push((arg(0): "l2.start", arg(1): ch("Na(g) + Cl(g)")))
  let dissoc = sub
  dissoc.push((arg(<all>): ("l1.mid", "l2.mid"), name: "dissoc"))
  let ts2 = ts1
  ts2.push((arg(1): [$1/2 #ch("Cl--Cl") "Bond Energy"$], arg(0): "dissoc.mid"))
  let step3 = step2
  step3.push((name: "l3"))
  step3.push((arg(1): (rel: (10, 0))))

  let ion1 = dissoc
  ion1.push((arg(<all>): ("l2.mid", ((), "|-", "l3")), name: "ion1"))
  let ts3 = ts2
  ts3.push((arg(0): "ion1.mid", arg(1): [$"IE"_1$ of Na]))
  let t3 = t2
  t3.push((arg(0): "l3.start", arg(1): ch("Na+(g) + Cl(g)")))

  put(base)
  put(t0)
  put(step1)
  put(t1)
  put(sub)
  put(ts1)
  put(step2)
  put(t2)
  put(dissoc)
  put(ts2)
  put(step3)
  put(ion1)
  put(ts3)
  put(t3)
})

