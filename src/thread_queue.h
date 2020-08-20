#ifndef THREAD_QUEUE_H
#define THREAD_QUEUE_H

#include <Godot.hpp>
#include <Node.hpp>
#include <String.h>
#include <Thread.hpp>

namespace godot {

class ThreadQueue : public Node {
    GODOT_CLASS(ThreadQueue, Node);

private:
    Ref<Thread> thread;
    Array queue;

public:
    void _init();
    void _ready();
    void _process(float p_delta);

    static void _register_methods();

    void initialize(Object *p_object, const String &p_callback, Array p_parameters, Variant p_custom_data);

    ThreadQueue();
    ~ThreadQueue();
};

template <class T> struct CallRef {
    Object *object;
    String callback;
    Array parameters;
    T custom_data;

    template <typename... Args> CallRef(T t, Args... p_parameters) {
        parameters = Array::make<Args...>(p_parameters...);
    }

    CallRef() {}
};

} // namespace godot

#endif