#include "thread_queue.h"

using namespace godot;

void ThreadQueue::_init() {}

void ThreadQueue::_ready() {}

void ThreadQueue::_process(float delta) {
    if (!(thread->is_active() || queue.empty())) {
        //CallRef<int> call = queue.pop_front();
        //initialize(call.object, call.callback, call.parameters, call.custom_data);
        //CallRef<int> call;
    }
}

void ThreadQueue::_register_methods() {
    register_method("_ready", &ThreadQueue::_ready);
    register_method("_process", &ThreadQueue::_process);

    // register_signal()
}

ThreadQueue::ThreadQueue() { thread = Ref<Thread>(); }

ThreadQueue::~ThreadQueue() {}