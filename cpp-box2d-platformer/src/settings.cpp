// MIT License

// Copyright (c) 2019 Erin Catto

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

#include "sajson/sajson.h"

#include "include/settings.h"

Settings g_settings;

static const char* fileName = "settings.ini";

// Load a file. You must free the character array.
static bool sReadFile(char*& data, int& size, const char* filename) {
	FILE* file = fopen(filename, "rb");
	if (file == nullptr) {
		return false;
	}

	fseek(file, 0, SEEK_END);
	size = ftell(file);
	fseek(file, 0, SEEK_SET);

	if (size == 0) {
		return false;
	}

	data = (char*)malloc(size + 1);
	fread(data, size, 1, file);
	fclose(file);
	data[size] = 0;

	return true;
}

static void sParseInteger(sajson::string fieldName, sajson::value fieldValue, 
        const char* matchName, int& output) {

    if (strncmp(fieldName.data(), matchName, fieldName.length()) == 0) {

        if (fieldValue.get_type() == sajson::TYPE_INTEGER) {
            output = fieldValue.get_integer_value();
        }
    }
}

static void sParseBoolean(sajson::string fieldName, sajson::value fieldValue, 
        const char* matchName, bool& output) {

    if (strncmp(fieldName.data(), matchName, fieldName.length()) == 0) {

        if (fieldValue.get_type() == sajson::TYPE_FALSE) {
            output = false;
        } else if (fieldValue.get_type() == sajson::TYPE_FALSE) {
            output = true;
        }
    }
}

Settings::Settings() {
    reset();
}

void Settings::reset() {
    windowWidth = 1600;
    windowHeight = 900;
    windowVSync = false;
    windowFullscreen = false;
}

void Settings::load() {
	char* data = nullptr;
	int size = 0;
	bool found = sReadFile(data, size, fileName);
	if (found ==  false) {
		return;
	}

	const sajson::document& document = sajson::parse(
                                            sajson::dynamic_allocation(),
                                            sajson::mutable_string_view(size, data));

	if (document.is_valid() == false) {
		return;
	}

	sajson::value root = document.get_root();
	int fieldCount = int(root.get_length());

	for (int i = 0; i < fieldCount; ++i) {
		sajson::string fieldName = root.get_object_key(i);
		sajson::value fieldValue = root.get_object_value(i);

        sParseInteger(fieldName, fieldValue, "windowWidth", windowWidth);
        sParseInteger(fieldName, fieldValue, "windowHeight", windowHeight);
        sParseInteger(fieldName, fieldValue, "windowScale", windowScale);
        sParseBoolean(fieldName, fieldValue, "windowVSync", windowVSync);
        sParseBoolean(fieldName, fieldValue, "windowFullscreen", windowFullscreen);

        sParseInteger(fieldName, fieldValue, "audioMusicVolume", audioMusicVolume);
        sParseInteger(fieldName, fieldValue, "audioSoundVolume", audioSoundVolume);
	}

	free(data);
}

void Settings::save() {
	FILE* file = fopen(fileName, "w");

	fprintf(file, "{\n");
	fprintf(file, "  \"windowWidth\": %d,\n", windowWidth);
	fprintf(file, "  \"windowHeight\": %d,\n", windowHeight);
	fprintf(file, "  \"windowVSync\": %d,\n", windowVSync);
	fprintf(file, "  \"windowFullscreen\": %d,\n", windowFullscreen);

	fprintf(file, "  \"audioMusicVolume\": %d,\n", audioMusicVolume);
	fprintf(file, "  \"audioSoundVolume\": %d,\n", audioSoundVolume);
	fprintf(file, "}\n");
	
    fclose(file);
}
