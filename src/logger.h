#ifndef LOGGER_H
#define LOGGER_H

#include <File.hpp>
#include <Godot.hpp>
#include <Node.hpp>

namespace godot {

class Logger : public Node {
    GODOT_CLASS(Logger, Node);

private:
    static Logger *singleton;

public:
    enum Level {
        DEBUG,
        INFO,
        WARNING,
        ERROR,
        NONE,
    };

    PoolStringArray tags;
    String path;
    String file_name;

    int log_level;

    Ref<File> file;

private:
    void load_file();
    void store(const String &p_line);
    void store_print(const String &p_line);

    String get_datetime();
    String get_time();

    void out(int p_level, const String &p_message = "",
             const Array &p_args = Array());

public:
    void _ready();
    static void _register_methods();
    static Logger *get_singleton();
    void debug(const String &p_message = "", const Array &p_args = Array());
    void info(const String &p_message = "", const Array &p_args = Array());
    void warn(const String &p_message = "", const Array &p_args = Array());
    void error(const String &p_message = "", const Array &p_args = Array());

    Logger();
    ~Logger();
};

} // namespace godot

#endif // LOGGER_H