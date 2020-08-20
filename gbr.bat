@echo off
cmd /c "cd godot-cpp && scons platform=windows target=release bits=64 generate_bindings=yes -j4 use_custom_api_file=yes custom_api_file=../api.json"

PAUSE