#ifndef CAMERA_H
#define CAMERA_H

#define GLFW_INCLUDE_NONE
#include "glad/gl.h"
#include "GLFW/glfw3.h"

#include "box2d/box2d.h"
#include "game.h"

//
class Camera {
    public:
	Camera() {
        centerSmooth.Set(0.0f, 0.0f);
		center.Set(0.0f, 0.0f);
		zoom = 1.0f;
		width = 1280;
		height = 800;
	}

	b2Vec2 convertScreenToWorld(const b2Vec2& screenPoint);
	b2Vec2 convertWorldToScreen(const b2Vec2& worldPoint);
	void buildProjectionMatrix(float* m, float zBias);

    void step();

    b2Vec2 centerSmooth;
	b2Vec2 center;
	float zoom;
	int32 width;
	int32 height;
};

extern Camera g_camera;

#endif
