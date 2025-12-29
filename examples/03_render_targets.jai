/*
    Rewritten in Jai by dev@ptrace.dev 
    original source code by Claudio Z. (@cloudofoz)
*/


/*
 * Example 03 - Gizmo With Render Targets
 * Demonstrates four independent 3D viewports, each rendered to its own texture.
 * The main gizmo (translate mode) is active in the viewport currently under the cursor.
 */

#import "Math";

#import "raylib";
#import "raygizmo";

//--------------------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------------------
SCREEN_WIDTH   :: 960;
SCREEN_HEIGHT  :: 540;
VIEWPORT_COUNT :: 4;

EXAMPLE_TITLE :: "Example 03 - Gizmo With Render Targets";

//--------------------------------------------------------------------------------------------------
// Types
//--------------------------------------------------------------------------------------------------
Viewport :: struct
{
     area: Rectangle;    // Screen rectangle
     rt: RenderTexture;  // Render target
     camera: Camera;     // Per-viewport camera
     clearColor: Color;  // Background color
}

//--------------------------------------------------------------------------------------------------
// Local Helpers
//--------------------------------------------------------------------------------------------------
CreateCamera :: (position: Vector3, target: Vector3) -> Camera
{
    cam: Camera;
    cam.position = position;
    cam.target = target;
    cam.up = Vector3.{ 0.0, 1.0, 0.0 };
    cam.fovy = 45.0;
    cam.projection = .CAMERA_PERSPECTIVE;
    return cam;
}

//--------------------------------------------------------------------------------------------------
// Program Entry
//--------------------------------------------------------------------------------------------------
main :: ()
{
    //----------------------------------------------------------------------------------------------
    // Initialization
    //----------------------------------------------------------------------------------------------
    SetConfigFlags(.FLAG_MSAA_4X_HINT);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, TextFormat("raylib-gizmo | %s", EXAMPLE_TITLE));
    defer CloseWindow();

    SetTargetFPS(60);

    // Load assets
    crateTexture: Texture = LoadTexture("resources/textures/crate_texture.jpg");
    defer UnloadTexture(crateTexture);

    GenTextureMipmaps(*crateTexture);
    SetTextureFilter(crateTexture, .TEXTURE_FILTER_TRILINEAR);

    crateModel: Model = LoadModel("resources/models/crate_model.obj");
    defer UnloadModel(crateModel);

    crateModel.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture = crateTexture;

    // Initial transform for the crate (will be modified by the gizmo)
    crateTransform: Transform = GizmoIdentity();

    // Viewport configuration
    BACK_COLORS := Color.[ BLACK, PURPLE, ORANGE, RED ];
    CAM_POSITIONS := Vector3.[
        { -5.5, 5.5, 2.0 },
        {  5.5, 5.5, 2.0 },
        { -2.5, 2.5, 2.0 },
        {  2.5, 2.5, 2.0 }
    ];

    HALF_W := cast(float)SCREEN_WIDTH * 0.5;
    HALF_H := cast(float)SCREEN_HEIGHT * 0.5;

    view: [VIEWPORT_COUNT]Viewport;
    defer for i: 0..VIEWPORT_COUNT-1  UnloadRenderTexture(view[i].rt);

    for i: 0..VIEWPORT_COUNT-1
    {
        col := cast(float)(i % 2);
        row := cast(float)(i / 2);

        view[i].area = Rectangle.{col * HALF_W, row * HALF_H, HALF_W, HALF_H};
        view[i].clearColor = BACK_COLORS[i];
        view[i].camera = CreateCamera(CAM_POSITIONS[i], Vector3.{ 0.0, 0.0, 0.0 });
        view[i].rt = LoadRenderTexture(cast(s32)HALF_W, cast(s32)HALF_H);
    }

    // Increase the gizmo size for better visibility
    SetGizmoSize(4.0);

    //----------------------------------------------------------------------------------------------
    // Main Loop
    //----------------------------------------------------------------------------------------------
    while !WindowShouldClose()
    {
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(Color.{ 0, 0, 25, 255 });

        for i: 0..VIEWPORT_COUNT-1
        {
            // Render the scene to the viewport's render target
            BeginTextureMode(view[i].rt);
            ClearBackground(view[i].clearColor);

            BeginMode3D(view[i].camera);
            defer EndMode3D();

            crateModel.transform = GizmoToMatrix(crateTransform);
            DrawModel(crateModel, Vector3Zero(), 1.0, WHITE);

            // Activate gizmo if mouse is inside this viewport
            if CheckCollisionPointRec(GetMousePosition(), view[i].area)
            {
                SetMouseOffset(-cast(s32)view[i].area.x, -cast(s32)view[i].area.y);
                SetMouseScale(cast(float)view[i].rt.texture.width / view[i].area.width,
                              cast(float)view[i].rt.texture.height / view[i].area.height);

                DrawGizmo3D(cast(s32)GizmoFlags.GIZMO_TRANSLATE, *crateTransform);

                SetMouseOffset(0, 0);
                SetMouseScale(1.0, 1.0);
            }

            EndMode3D();
            EndTextureMode();

            // Draw the render target to the window
            DrawTextureRec(view[i].rt.texture,
                           Rectangle.{
                               0, 0,
                               cast(float)view[i].rt.texture.width,
                               -cast(float)view[i].rt.texture.height
                           },
                           Vector2.{
                               view[i].area.x, view[i].area.y
                           },
                           WHITE);
        }

    }
}

