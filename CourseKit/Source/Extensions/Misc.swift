import Foundation

public enum Debounce<T: Equatable> {
    public static func input(_ input: T, delay: TimeInterval = 0.3, current: @escaping @autoclosure () -> T, perform: @escaping (T) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard input == current() else { return }
            perform(input)
        }
    }
}

extension RangeExpression where Bound == String.Index  {
    public func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}
