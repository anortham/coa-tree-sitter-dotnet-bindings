#include <iostream>
#include <memory>
#include <vector>
#include <algorithm>

template<typename T>
class SmartContainer {
private:
    std::vector<std::unique_ptr<T>> items;

public:
    void add(std::unique_ptr<T> item) {
        items.push_back(std::move(item));
    }

    template<typename Func>
    void forEach(Func&& func) const {
        std::for_each(items.begin(), items.end(),
            [&func](const auto& item) {
                func(*item);
            });
    }

    size_t size() const noexcept {
        return items.size();
    }
};

int main() {
    auto container = SmartContainer<int>();
    container.add(std::make_unique<int>(42));

    container.forEach([](const int& value) {
        std::cout << "Value: " << value << std::endl;
    });

    return 0;
}