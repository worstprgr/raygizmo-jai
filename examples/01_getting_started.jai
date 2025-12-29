/*
    Rewritten in Jai by dev@ptrace.dev
    Original source code by Claudio Z. (@cloudofoz)
*/


//--------------------------------------------------------------------------------------------------
// Example 01 - Getting Started
// Demonstrates how to use a simple, globally oriented, 3D translation gizmo in a raylib scene.
//--------------------------------------------------------------------------------------------------

#import "Math";

#import "raylib";
#import "raygizmo";

//--------------------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------------------

EXAMPLE_TITLE :: "Example 01 - Getting Started";
SCREEN_WIDTH: s32 = 960;
SCREEN_HEIGHT: s32 = 540;

//--------------------------------------------------------------------------------------------------
// Main Entry Point
//--------------------------------------------------------------------------------------------------

main :: ()
{
    // This Transform stores the translation, rotation, and scaling of our crate.
    // It will be updated dynamically by the gizmo during the program.
    crateTransform: Transform = GizmoIdentity();

    // Setup: Initialize the window and basic configurations.
    SetConfigFlags(.FLAG_MSAA_4X_HINT | .FLAG_WINDOW_RESIZABLE);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TextFormat("raylib-gizmo | %s", EXAMPLE_TITLE));
    defer CloseWindow();

    SetTargetFPS(60);

    // Load the crate texture.
    crateTexture: Texture = LoadTexture("resources/textures/crate_texture.jpg");
    defer UnloadTexture(crateTexture);

    GenTextureMipmaps(*crateTexture);
    SetTextureFilter(crateTexture, .TEXTURE_FILTER_TRILINEAR);

    // Load the crate model and apply the texture.
    crateModel: Model = LoadModel("resources/models/crate_model.obj");
    defer UnloadModel(crateModel);

    crateModel.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture = crateTexture;

    // Setup the 3D camera.
    cam: Camera;
    cam.fovy = 45.0;
    cam.position = Vector3.{ 7.5, 5.5, 5.0 };
    cam.target = Vector3.{ 0, 1.5, 0 };
    cam.up = Vector3.{ 0, 1, 0 };
    cam.projection = .CAMERA_PERSPECTIVE;

    // Main game loop.
    while !WindowShouldClose()
    {
        BeginDrawing();
        defer EndDrawing();

        // Clear the background with a dark blue color.
        ClearBackground(Color.{ 0, 0, 25, 255 });

        BeginMode3D(cam);
        defer EndMode3D();

        // Update the crate's transform matrix from the gizmo.
        crateModel.transform = GizmoToMatrix(crateTransform);

        // Draw the crate model using the updated transform.
        DrawModel(crateModel, Vector3Zero(), 1.0, WHITE);

        // Draw the translation gizmo and handle its input.
        // This will directly update the crateTransform variable.
        DrawGizmo3D(cast(s32)GizmoFlags.GIZMO_TRANSLATE, *crateTransform);

    }
}

