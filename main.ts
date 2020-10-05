type ParseContainer<A> = (s: String) => [[A, String]] | []


class Parser<A> {
  a: ParseContainer<A>
  constructor(a: ParseContainer<A>) {
    this.a = a
  }
}

const parse = <A>(a: Parser<A>): ParseContainer<A> => a.a


const unit = <A>(a: A) => new Parser<A>(s => [[a, s]] )

const item = new Parser<String>(s =>
  s.length === 0
    ? []
    : [[s[0], s.slice(1)]]
  )


const fmap = <A, B>(f: (a: Parser<A>) => Parser<B>, p: Parser<A>) => new Parser(s => (
  p.a(s).map(([a, b]) => [f(a), b] )
))


const apfmap = null

const bind = <A>(p: Parser<A>, f: (p: Parser<A>) => Parser<A>) => new Parser(s => {
  parse(p)
}) 

const mzero = null

const mplus = null

const altEmpty =  mzero

const altOneof = null