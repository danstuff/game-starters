#ifndef UI_H
#define UI_H

#include "box2d/box2d.h"
#include "settings.h"
#include "camera.h"
#include "game.h"

class UI {
    private:
        Part* selectedPart;

    public:
        UI();

        void create(GLFWwindow* window, const char* glslVersion = NULL);

        bool onKey(GLFWwindow* window, int key, int scancode, int action, int mods);
        void onChar(GLFWwindow* window, unsigned int c);
        bool onMouseButton(GLFWwindow* window, int32 button, int32 action, int32 mods);
        bool onMouseScroll(GLFWwindow* window, double dx, double dy);

        void newFrame();

        void buildSettings();

        void buildPartTree(Part* root);
        void buildPartList();

        void buildAvailableParts(Part* root);
        void buildSelectedPart();

        void render();

        void destroy();
};

extern UI g_ui;

#endif
