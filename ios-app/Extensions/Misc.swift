import Foundation

enum Debounce<T: Equatable> {
    static func input(_ input: T, delay: TimeInterval = 0.3, current: @escaping @autoclosure () -> T, perform: @escaping (T) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard input == current() else { return }
            perform(input)
        }
    }
}
