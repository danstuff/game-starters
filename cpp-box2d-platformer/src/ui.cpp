#include "include/ui.h"

UI g_ui;

UI::UI() {
    selectedPart = nullptr;
}

void UI::create(GLFWwindow* window, const char* glslVersion) {
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();

    // Initialize imgui context
	bool success;
	success = ImGui_ImplGlfw_InitForOpenGL(window, false);
	if (success == false) {
		printf("ImGui_ImplGlfw_InitForOpenGL failed\n");
		assert(false);
	}

	success = ImGui_ImplOpenGL3_Init(glslVersion);
	if (success == false) {
		printf("ImGui_ImplOpenGL3_Init failed\n");
		assert(false);
	}

	// Search for font file
	const char* fontPath1 = "data/droid_sans.ttf";
	const char* fontPath2 = "../data/droid_sans.ttf";
	const char* fontPath = nullptr;

	FILE* file1 = fopen(fontPath1, "rb");
	FILE* file2 = fopen(fontPath2, "rb");

	if (file1) {
		fontPath = fontPath1;
		fclose(file1);
	}
	
	if (file2) {
		fontPath = fontPath2;
		fclose(file2);
	}

	if (fontPath) {
		ImGui::GetIO().Fonts->AddFontFromFileTTF(fontPath, 13.0f);
	}
}


bool UI::onKey(GLFWwindow* window, int key, int scancode, int action, int mods) {
	ImGui_ImplGlfw_KeyCallback(window, key, scancode, action, mods);
	return ImGui::GetIO().WantCaptureKeyboard;
}

void UI::onChar(GLFWwindow* window, unsigned int c) {
	ImGui_ImplGlfw_CharCallback(window, c);
}

bool UI::onMouseButton(GLFWwindow* window, int32 button, int32 action, int32 mods) {
	ImGui_ImplGlfw_MouseButtonCallback(window, button, action, mods);
    return ImGui::GetIO().WantCaptureMouse;
}

bool UI::onMouseScroll(GLFWwindow* window, double dx, double dy) {
	ImGui_ImplGlfw_ScrollCallback(window, dx, dy);
    return ImGui::GetIO().WantCaptureMouse;
}

void UI::newFrame() {
	ImGui_ImplOpenGL3_NewFrame();
	ImGui_ImplGlfw_NewFrame();
    
    ImGui::NewFrame();
}

void UI::buildSettings() {
}

void UI::buildPartTree(Part* root) {
    if(ImGui::TreeNode(root->temp->name)) {
        root->resetWalk();
        Part* p = root->walk(); 

        while(p != nullptr) {
            buildPartTree(p);
            p = root->walk(); 
        }
            
        ImGui::TreePop();
    }
}

void UI::buildPartList() {
    if(g_game.getPartList() == nullptr) return;

    //Part selection menu
    if(ImGui::Begin("Parts Menu")) {
        Part* player = g_game.getPlayer();
        
        if(ImGui::BeginTabBar("Parts", ImGuiTabBarFlags_None)) {
            if(ImGui::BeginTabItem("Equipped")) {
                player->resetWalk();
                Part* p = player->walk(); 

                while(p != nullptr) {
                    buildPartTree(p);
                    p = player->walk(); 
                }

                ImGui::EndTabItem();
            }

            if(ImGui::BeginTabItem("Nearby")) {
                unsigned int i = 0;
                PartList* pl = g_game.getPartList();
                Part* p = pl->getNextRoot(i);

                while(p != nullptr) {
                    if(p->temp != nullptr && p != player) {
                        buildPartTree(p);
                    }

                    p = pl->getNextRoot(i);
                }
                
                ImGui::EndTabItem();
            }

            ImGui::EndTabBar();
        }

        ImGui::End();
    }
}

void UI::buildAvailableParts(Part* root) {
    if(root->addChild(nullptr)) {
        ImGui::BulletText(root->temp->name);
    }

    ImGui::Indent();

    root->resetWalk();
    Part* p = root->walk(); 

    while(p != nullptr) {
        buildAvailableParts(p);
        p = root->walk(); 
    }
        
    ImGui::Unindent();
}

void UI::buildSelectedPart() {
    if(g_game.getPartList() == nullptr) return;

    //Selected part menu
    if(ImGui::Begin("Selected Part")) {

        if(selectedPart != nullptr) {
            ImGui::Text(selectedPart->temp->name);

            ImGui::Separator();

            if(selectedPart->parent == nullptr) {
                ImGui::Text("Click to Equip to an open slot:");
                buildAvailableParts(g_game.getPlayer());
            } else {
                if(ImGui::Button("Unequip")) {
                    selectedPart->parent->removeChild(selectedPart);
                }
            }
        } else {
            ImGui::Text("Select a part in the parts menu to see its status."); 
        }

        ImGui::End();
    }
}

void UI::render() {
    // Render imgui frames
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

void UI::destroy() {
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
}
