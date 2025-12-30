/*
 * MIT License
 *
 * Copyright (c) 2025 dev@ptrace.dev
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "BuildCpp";
#import "Bindings_Generator";


PROJECT_NAME      :: "raygizmo";
PATH_SRC_RAYGIZMO :: "../src/raylib-gizmo/src";

LIB :: "lib/raygizmo";


#run {
    set_build_options_dc({ do_output = false, write_added_strings = false });

    w := compiler_create_workspace(PROJECT_NAME);

    if !w {
        log_error("workspace creation failed for: %", PROJECT_NAME);
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = PROJECT_NAME;
    options.backend = .X64;

    set_build_options(options, w);
    make_directory_if_it_does_not_exist("lib");

    if !file_exists(tprint("%.a", LIB)) {
        log("Building lib ...");
        if !build_lib() return;
    }

    log("Generating bindings ...");
    generate_raygizmo_module();

}


build_lib :: (static_lib := true) -> success: bool {
    if static_lib {
        return build_cpp_static_lib(
            LIB,
            files=tprint("%/raygizmo.c", PATH_SRC_RAYGIZMO),
            extra=.["-fPIC", tprint("-I%", PATH_SRC_RAYGIZMO)]
        );
    }

    assert(false, "Does not work currently. @NotImplemented");
    return build_cpp_dynamic_lib(
        LIB,
        files=tprint("%/raygizmo.c", PATH_SRC_RAYGIZMO),
        extra=.[tprint("-I%", PATH_SRC_RAYGIZMO)]
    );
}

generate_raygizmo_module :: () {
    using options: Generate_Bindings_Options;
    strip_flags = 0;

    array_add(*library_search_paths, "lib");
    array_add(*libraries, { filename = "raygizmo" });
    array_add(*include_paths, PATH_SRC_RAYGIZMO);
    array_add(*source_files, "raygizmo.h");

    footer = #string STR_END
#import "Math";
#import "raylib";
    STR_END;

    visitor = raygizmo_visitor;

    generate_bindings(options, "module.jai");
}

raygizmo_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if decl.kind == .TYPEDEF && decl.name == "Matrix" {
        decl.output_name = "Matrix4";
    }

    return .RECURSE;
}

