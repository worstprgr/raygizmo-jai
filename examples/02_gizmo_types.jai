/*
    Rewritten in Jai by dev@ptrace.dev
    Original source code by Claudio Z. (@cloudofoz)
*/


//--------------------------------------------------------------------------------------------------
// Example 02 - Gizmo Types
// Demonstrates multiple gizmo modes (translate, rotate, scale, and all combined) with fixed
// configurations.
//--------------------------------------------------------------------------------------------------

#import "Math";

#import "raylib";
#import "raygizmo";

//--------------------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------------------

EXAMPLE_TITLE :: "Example 02 - Gizmo Types";
SCREEN_WIDTH: s32 = 960;
SCREEN_HEIGHT: s32 = 540;

CRATE_COUNT :: 4;

//--------------------------------------------------------------------------------------------------
// Main Entry Point
//--------------------------------------------------------------------------------------------------

main :: ()
{
    // These Transforms store the translation, rotation, and scaling of the crates
    // They will be dynamically updated by the gizmos during the program
    crateTransforms: [CRATE_COUNT]Transform;

    // Initialize the transforms with default values
    for i: 0..CRATE_COUNT-1
    {
        crateTransforms[i] = GizmoIdentity();
        crateTransforms[i].translation.x = -12.0 + 6.0 * cast(float)i;  // Offset crates along the X-axis
    }

    // Assign each crate a different gizmo type
    gizmoTypes := GizmoFlags.[ .GIZMO_TRANSLATE, .GIZMO_SCALE, .GIZMO_ROTATE, .GIZMO_ALL ];

    // Setup: Initialize the window
    SetConfigFlags(.FLAG_MSAA_4X_HINT | .FLAG_WINDOW_RESIZABLE);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TextFormat("raylib-gizmo | %s", EXAMPLE_TITLE));
    defer CloseWindow();

    SetTargetFPS(60);

    // Load the crate texture
    crateTexture: Texture = LoadTexture("resources/textures/crate_texture.jpg");
    defer UnloadTexture(crateTexture);

    GenTextureMipmaps(*crateTexture);
    SetTextureFilter(crateTexture, .TEXTURE_FILTER_TRILINEAR);

    // Load the crate model and apply the texture
    crateModel: Model = LoadModel("resources/models/crate_model.obj");
    defer UnloadModel(crateModel);

    crateModel.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture = crateTexture;

    // Setup the 3D camera
    cam: Camera;
    cam.fovy = 45.0;
    cam.position = Vector3.{ -5.5, 10.5, 14.0 };
    cam.target = Vector3.{ -2.5, 0, 0 };
    cam.up = Vector3.{ 0, 1, 0 };
    cam.projection = .CAMERA_PERSPECTIVE;

    // Main loop
    while !WindowShouldClose()
    {
        BeginDrawing();
        defer EndDrawing();

        // Clear the background with a dark blue color
        ClearBackground(Color.{ 0, 0, 25, 255 });

        BeginMode3D(cam);
        defer EndMode3D();

        // Draw the crates with their updated transforms
        for i: 0..CRATE_COUNT-1
        {
            crateModel.transform = GizmoToMatrix(crateTransforms[i]);
            DrawModel(crateModel, Vector3Zero(), 1.0, WHITE);
        }

        // Draw the gizmos and handle user input
        for i: 0..CRATE_COUNT-1
        {
            DrawGizmo3D(cast(s32)gizmoTypes[i], *crateTransforms[i]);
        }
    }
}

