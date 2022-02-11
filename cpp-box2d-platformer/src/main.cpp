#define _CRT_SECURE_NO_WARNINGS
#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS 1

#include "include/draw.h"
#include "include/camera.h"
#include "include/settings.h"
#include "include/input.h"
#include "include/ui.h"

#include "include/game.h"

#include <algorithm>
#include <stdio.h>
#include <thread>
#include <chrono>

#if defined(_WIN32)
#include <crtdbg.h>
#endif

GLFWwindow* g_mainWindow = nullptr;

//MAIN PROCESS STEPS
void Load() {
    g_settings.load();

    g_camera.width = g_settings.windowWidth;
    g_camera.height = g_settings.windowHeight;
}

void Create() {
#if __APPLE__
    const char* glslVersion = "#version 150";
#else
    const char* glslVersion = NULL;
#endif

    // Initialize drawing object and UI
    g_debugDraw.Create();
    g_ui.create(g_mainWindow, glslVersion);

    //create a game and link to input and camera
    g_game.create();
}

void Step() {
    g_ui.newFrame();

    g_ui.buildPartList();
    g_ui.buildSelectedPart();

    g_input.step();
    g_camera.step();

    g_game.step();

    g_ui.render();
}

void Destroy() {
    g_game.destroy();

    g_debugDraw.Destroy();

    g_ui.destroy();

    g_settings.save();

    glfwTerminate();
}

//CALLBACKS
void glfwErrorCallback(int error, const char* description) {
    fprintf(stderr, "GLFW error occured. Code: %d. Description: %s\n", error, description);
}

static void ResizeWindowCallback(GLFWwindow*, int width, int height) {
    g_camera.width = width;
    g_camera.height = height;
    g_settings.windowWidth = width;
    g_settings.windowHeight = height;
}

static void KeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if(!g_ui.onKey(window, key, scancode, action, mods)) {
        g_input.onKey(key, action);
    }
}

static void CharCallback(GLFWwindow* window, unsigned int c) {
    g_ui.onChar(window, c);
}

static void MouseButtonCallback(GLFWwindow* window, int32 button, int32 action, int32 mods) {
    if(!g_ui.onMouseButton(window, button, action, mods)) {
        g_input.onMouseButton(button, action);
    }
}

static void MouseMotionCallback(GLFWwindow*, double xd, double yd) {
    b2Vec2 mpos = g_camera.convertScreenToWorld(b2Vec2(xd, yd));
    g_input.onMouseMove(mpos);
}

static void ScrollCallback(GLFWwindow* window, double dx, double dy) {
    g_ui.onMouseScroll(window, dx, dy);
}

//MAIN ENTRY FUNCTION
int main(int, char**) {
#if defined(_WIN32)
    // Enable memory-leak reports
    _CrtSetDbgFlag(_CRTDBG_LEAK_CHECK_DF | _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG));
#endif

    char buffer[128];

    //LOAD STEP
    Load();

    glfwSetErrorCallback(glfwErrorCallback);

    if (glfwInit() == 0)
    {
        fprintf(stderr, "Failed to initialize GLFW\n");
        return -1;
    }

    // Configure GLFW version info and profile
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // Create a window with the desired settings configs
    sprintf(buffer, "TCG - hella alpha version");

    if (g_settings.windowFullscreen) {
        g_mainWindow = glfwCreateWindow(1920, 1080, buffer, glfwGetPrimaryMonitor(), NULL);
    }
    else {
        g_mainWindow = glfwCreateWindow(g_camera.width, g_camera.height, buffer, NULL, NULL);
    }

    // Terminate if window creation failed
    if (g_mainWindow == NULL) {
        fprintf(stderr, "Failed to open GLFW g_mainWindow.\n");
        glfwTerminate();
        return -1;
    }

    // Set the new window as the current context
    glfwMakeContextCurrent(g_mainWindow);

    // Load OpenGL functions using glad
    int version = gladLoadGL(glfwGetProcAddress);
    printf("GL %d.%d\n", GLAD_VERSION_MAJOR(version), GLAD_VERSION_MINOR(version));
    printf("OpenGL %s, GLSL %s\n", glGetString(GL_VERSION), glGetString(GL_SHADING_LANGUAGE_VERSION));

    // Configure all callbacks
    glfwSetScrollCallback(g_mainWindow, ScrollCallback);
    glfwSetWindowSizeCallback(g_mainWindow, ResizeWindowCallback);
    glfwSetKeyCallback(g_mainWindow, KeyCallback);
    glfwSetCharCallback(g_mainWindow, CharCallback);
    glfwSetMouseButtonCallback(g_mainWindow, MouseButtonCallback);
    glfwSetCursorPosCallback(g_mainWindow, MouseMotionCallback);
    glfwSetScrollCallback(g_mainWindow, ScrollCallback);

    // Control the frame rate if enabled in settings. One draw per monitor refresh.
    if(g_settings.windowVSync) {
        glfwSwapInterval(1);
    }

    // Set the background color
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);

    //CREATE STEP
    Create();

    // Keep track of time between frames to keep speeds steady
    std::chrono::duration<double> frameTime(0.0);
    std::chrono::duration<double> sleepAdjust(0.0);

    //
    // MAIN LOOP START
    while (!glfwWindowShouldClose(g_mainWindow)) {
        std::chrono::steady_clock::time_point t1 = std::chrono::steady_clock::now();

        // Update camera view size
        glfwGetWindowSize(g_mainWindow, &g_camera.width, &g_camera.height);

        // Configure the viewport
        int bufferWidth, bufferHeight;
        glfwGetFramebufferSize(g_mainWindow, &bufferWidth, &bufferHeight);
        glViewport(0, 0, bufferWidth, bufferHeight);

        // DRAW START: Clear screen to background color
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // STEP ALL GAME OBJECTS, UPDATE UI
        Step();

        //DRAW END: Swap buffers and poll events
        glfwSwapBuffers(g_mainWindow);
        glfwPollEvents();

        // Throttle to cap at 60Hz. This adaptive using a sleep adjustment. 
        // TODO This could be improved by using mm_pause or equivalent for the last millisecond.
        std::chrono::steady_clock::time_point t2 = std::chrono::steady_clock::now();
        std::chrono::duration<double> target(1.0 / 60.0);
        std::chrono::duration<double> timeUsed = t2 - t1;
        std::chrono::duration<double> sleepTime = target - timeUsed + sleepAdjust;

        if (sleepTime > std::chrono::duration<double>(0)) {
            std::this_thread::sleep_for(sleepTime);
        }

        std::chrono::steady_clock::time_point t3 = std::chrono::steady_clock::now();
        frameTime = t3 - t1;

        // Compute the sleep adjustment using a low pass filter
        sleepAdjust = 0.9 * sleepAdjust + 0.1 * (target - frameTime);
    }

    //DESTROY STEP
    Destroy();

    return 0;
}
