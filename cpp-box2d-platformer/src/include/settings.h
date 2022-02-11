//================SETTINGS.H================
// Allows basic game settings to be saved
// and loaded as a JSON file.
//==========================================

#pragma once

class Settings {
public:
	int windowWidth;
	int windowHeight;
    int windowScale;
    bool windowVSync;
    bool windowFullscreen;

    int audioMusicVolume;
    int audioSoundVolume;

	Settings();

	void reset();
	void save();
	void load();

};

extern Settings g_settings;
