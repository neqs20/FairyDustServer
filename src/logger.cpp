#include "logger.h"

#include <Directory.hpp>
#include <OS.hpp>

using namespace godot;

Logger* Logger::singleton;

void Logger::load_file() {
    String full_path = path.plus_file(file_name);

    if (file->file_exists(full_path)) {
        Error error = file->open(full_path, File::READ_WRITE);
        if (error != Error::OK) {
            return;
        }

        file->seek_end();
    } else {
        Ref<Directory> dir;
        dir.instance();

        if (!dir->dir_exists(path)) {
            dir->make_dir_recursive(path);
        }

        Error error = file->open(full_path, File::WRITE_READ);
        if (error != Error::OK) {
            return;
        }

        store("############################################################");
        store("#                   " + get_datetime() + "                   #");
        store("############################################################");
    }
}

void Logger::store(const String &p_line) {
    if (p_line.empty()) {
        file->store_line(p_line);
    }
}

void Logger::store_print(const String &p_line) {
    Godot::print(p_line);
    store(p_line);
}

String Logger::get_datetime() {
    Dictionary datetime = OS::get_singleton()->get_datetime();

    String day = datetime["day"];
    String month = datetime["month"];
    String year = datetime["year"];

    String hour = datetime["hour"];
    String minute = datetime["minute"];
    String second = datetime["second"];

    return day.pad_zeros(2) + "." + month.pad_zeros(2) + "." + year + ", " +
           get_time();
}

String Logger::get_time() {
    Dictionary datetime = OS::get_singleton()->get_time();

    String hour = datetime["hour"];
    String minute = datetime["minute"];
    String second = datetime["second"];

    return hour.pad_zeros(2) + ":" + minute.pad_zeros(2) + ":" +
           second.pad_zeros(2);
}

void Logger::out(int p_level, const String &p_message, const Array &p_args) {
    if (log_level <= p_level && p_level >= Level::DEBUG &&
        p_level < Level::NONE) {
        store_print("[" + get_time() + "]" + "[CLIENT]" + tags[p_level] + ": " +
                    p_message.format(p_args, "{_}"));
    }
}

void Logger::_ready() {
    singleton = Object::cast_to<Logger>(get_node("/root/Logger"));
}

void Logger::_register_methods() {
    register_method("debug", &Logger::debug);
    register_method("info", &Logger::info);
    register_method("warn", &Logger::warn);
    register_method("error", &Logger::error);
}

Logger *Logger::get_singleton() {
    return singleton;
}

void Logger::debug(const String &p_message, const Array &p_args) {
    out(Level::DEBUG, p_message, p_args);
}
void Logger::info(const String &p_message, const Array &p_args) {
    out(Level::INFO, p_message, p_args);
}
void Logger::warn(const String &p_message, const Array &p_args) {
    out(Level::WARNING, p_message, p_args);
}
void Logger::error(const String &p_message, const Array &p_args) {
    out(Level::ERROR, p_message, p_args);
}

Logger::Logger() {
    tags.append("[DEBUG]");
    tags.append("[INFO]");
    tags.append("[WARNING]");
    tags.append("[ERROR]");

    path = "user://logs";
    file_name = "fdout.log";

    log_level = Level::DEBUG;

    file.instance();

    singleton = NULL;
    load_file();
}

Logger::~Logger() {
    if (file->is_open()) {
        file->close();
    }
    if (singleton) {
        delete singleton;
    }
}