#include "CheatState.hpp"

namespace CheatState {

bool show_visual = false;
bool show_lines = false;
bool show_boxes = false;
bool show_skeleton = false;
bool show_health = false;

bool stream_mode = false;
bool hide_top_label = false;
bool enable_r6x9 = false;
bool enable_assist = false;
bool enable_fov_circle = false;

int currentPage = 0;
int line_mode = 0;

int aim_target = 0;
int assist_target_bone = 0;
int aim_location = 0;
int assist_trigger = 0;
int assist_fov_mode = 0;

float distanceValue = 250.0f;
float assist_smoothness = 0.47f;
float max_distance = 200.0f;
float fov_radius = 60.0f;

}