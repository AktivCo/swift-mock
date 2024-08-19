import RtMock

@RtMock
protocol MockFactory {
    func f1()
    func f2(a: String)
    func f3(a: String?)
    func f4(a b: String)
    func f5(a: String, b: Int)
    func f6() -> String
    func f7() throws
    func f8(a: [String])
    func f8(a: Set<Int>)
    func f9() -> Int?
    func f10() -> AsyncThrowingStream<UInt, Never>

    func f_overloaded()
    func f_overloaded() async
    func f_overloaded() -> Int
    func f_overloaded() -> String
    func f_overloaded() -> String?
    func f_overloaded(a: String)
    func f_overloaded(_ a: String)
    func f_overloaded(a: Int)
    func f_overloaded(a: Int?)
    func f_overloaded(a: Int, b: String)
    func f_overloaded(with a: String)
    func f_overloaded(x y: String)
    func f_overloaded(x: String, y: Int)

    var v1: Int { get }
}
