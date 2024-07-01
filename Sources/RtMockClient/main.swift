import RtMock

@RtMock
protocol A {
    func f1()
    func f2(a: String)
    func f3(a: String?)
    func f4(a b: String)
    func f5(a: String, b: Int)
    func f6() -> String
}
