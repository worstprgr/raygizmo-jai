#import "Basic";
#import "Compiler";
#import "File";


#run {
    set_build_options_dc(.{ do_output = false });

    build("01_getting_started", "01_getting_started.jai");
    build("02_gizmo_types", "02_gizmo_types.jai");
    build("03_render_targets", "03_render_targets.jai");
}

build :: (exec_name: string, source_code_fp: string) {
    w := compiler_create_workspace();

    if !w {
        log_error("workspace creation failed for project: %", exec_name);
        return;
    }

    log("The workspace % is %", exec_name, w);

    target_options := get_build_options(w);
    target_options.output_executable_name = exec_name;
    target_options.text_output_flags = 0;

    /*
        I had to create a "modules" dir and symlinks to the
        libraries, which is kinda fugly ...
        But `raygizmo` lives at the root of the project, which
        the compiler does not like apparently.

        Using

            `array_add(*import_path, "./");`

                        or

            `array_add(*import_path, "raygizmo");`

        Does not work, since the compiler expects a directory
        with the name of the library.
    */

    // import_path: [..] string;
    // array_add(*import_path, ..target_options.import_path);
    // array_add(*import_path, " hmmm ... ");
    // array_add(*import_path, "third-party/raylib-jai/raylib");
    // target_options.import_path = import_path;

    set_build_options(target_options, w);
    add_build_file(source_code_fp, w);
}

main :: () {}

