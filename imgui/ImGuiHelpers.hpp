#import <Foundation/Foundation.h>

#pragma once
#include "imgui.h"
#include "imgui_internal.h"
#include <initializer_list>

#define IM_COL32F(r, g, b, a) ImColor((float)(r), (float)(g), (float)(b), (float)(a))

inline void LoadEmojiFont(ImGuiIO& io)
{
    io.Fonts->AddFontDefault();

    static const ImWchar emoji_ranges[] = {
        (ImWchar)0x1F300, (ImWchar)0x1F5FF,
        (ImWchar)0x1F600, (ImWchar)0x1F64F,
        (ImWchar)0x1F680, (ImWchar)0x1F6FF,
        (ImWchar)0x2600,  (ImWchar)0x26FF,
        (ImWchar)0x2700,  (ImWchar)0x27BF,
        (ImWchar)0xFE00,  (ImWchar)0xFE0F,
        (ImWchar)0x1F900, (ImWchar)0x1F9FF,
        (ImWchar)0x2000,  (ImWchar)0x206F,
        (ImWchar)0x2B50,  (ImWchar)0x2B55,
        0
    };

    ImFontConfig cfg;
    cfg.MergeMode = true;
    cfg.PixelSnapH = true;

    const char* emojiFontPath = "/var/jb/var/mobile/Containers/Data/Application/Pro/imgui/NotoColorEmoji.ttf";

    if (!io.Fonts->AddFontFromFileTTF(emojiFontPath, 20.0f, &cfg, emoji_ranges)) {
        NSLog(@"❌ فشل تحميل خط الإيموجي من: %s", emojiFontPath);
    } else {
        NSLog(@"✅ تم تحميل خط الإيموجي بنجاح من: %s", emojiFontPath);
    }
}

inline bool StyledButton(const char* label) {
    ImVec2 size = ImVec2(ImGui::CalcTextSize(label).x + 20.0f, 28.0f);
    ImGui::PushStyleColor(ImGuiCol_Button,        ImVec4(0.12f, 0.18f, 0.22f, 0.8f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.2f, 0.44f, 0.92f, 0.9f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive,  ImVec4(0.1f, 0.3f, 0.7f, 1.0f));
    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 7.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(5, 4));
    bool pressed = ImGui::Button(label, size);
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(3);
    return pressed;
}

inline bool StyledToggleButton(const char* label, bool* state, float width = 120.f, float height = 36.f) {
    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImVec2 size(width, height);
    auto dl = ImGui::GetWindowDrawList();
    bool active = *state;
    ImU32 bg = ImGui::GetColorU32(active
        ? ImVec4(0.22f, 0.52f, 1.f, 0.85f)
        : ImVec4(0.12f, 0.18f, 0.22f, 0.5f));
    ImU32 border = ImGui::GetColorU32(active
        ? ImVec4(0.4f, 0.75f, 1.f, 0.6f)
        : ImVec4(0.25f, 0.32f, 0.38f, 0.3f));
    ImVec4 textColor = active
        ? ImVec4(0.4f, 0.75f, 1.f, 1.f)
        : ImVec4(1.0f, 1.0f, 1.0f, 0.85f);
    dl->AddRectFilled(pos, ImVec2(pos.x + size.x, pos.y + size.y), bg, 10);
    dl->AddRect(pos, ImVec2(pos.x + size.x, pos.y + size.y), border, 10, 0, active ? 2.5f : 1.0f);
    ImVec2 txt = ImGui::CalcTextSize(label);
    dl->AddText(NULL, 17.5f,
        ImVec2(pos.x + size.x / 2 - txt.x / 2, pos.y + size.y / 2 - txt.y / 2),
        ImColor(textColor), label);
    ImGui::SetCursorScreenPos(pos);
    if (ImGui::InvisibleButton(label, size)) {
        *state = !*state;
        return true;
    }
    ImGui::Dummy(ImVec2(0, 10));
    return false;
}

inline bool StyledCheckboxNoIcon(const char* label, bool* v) {
    return ImGui::Checkbox(label, v);
}

inline bool StyledSliderThin(const char* label, float* v, float min, float max, const char* fmt) {
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(4, 2));
    bool changed = ImGui::SliderFloat(label, v, min, max, fmt);
    ImGui::PopStyleVar();
    return changed;
}

inline bool StyledSliderIntThin(const char* label, int* v, int min, int max) {
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(4, 2));
    bool changed = ImGui::SliderInt(label, v, min, max);
    ImGui::PopStyleVar();
    return changed;
}

inline void StyledComboButtons(const char* label, int* val, const char* const* items, int count) {
    ImGui::TextColored(ImVec4(0.38f, 0.78f, 1.f, 0.92f), "%s", label);
    ImGui::SameLine();
    for (int i = 0; i < count; ++i) {
        bool selected = (*val == i);
        ImU32 bg = ImGui::GetColorU32(selected
                     ? ImVec4(0.19f, 0.44f, 0.95f, 0.89f)
                     : ImVec4(0.12f, 0.18f, 0.22f, 0.54f));
        ImU32 tx = ImGui::GetColorU32(selected
                     ? ImVec4(1.0f, 1.0f, 1.0f, 1.0f)
                     : ImVec4(0.78f, 0.88f, 1.0f, 0.82f));
        float ww = ImGui::CalcTextSize(items[i]).x + 25.f;
        float hh = 22.f;
        ImVec2 pos = ImGui::GetCursorScreenPos();
        auto draw = ImGui::GetWindowDrawList();
        draw->AddRectFilled(pos, ImVec2(pos.x + ww, pos.y + hh), bg, 7.f);
        draw->AddText(nullptr, 16.f,
                      ImVec2(pos.x + ww * 0.5f - ImGui::CalcTextSize(items[i]).x * 0.5f,
                             pos.y + hh * 0.5f - 7.5f),
                      tx, items[i]);
        ImGui::SetCursorScreenPos(pos);
        if (ImGui::InvisibleButton(items[i], ImVec2(ww, hh)))
            *val = i;
        ImGui::SameLine(0, 4.f);
    }
    ImGui::NewLine();
}

inline void StyledComboButtons(const char* label, int* val, std::initializer_list<const char*> items) {
    StyledComboButtons(label, val, items.begin(), (int)items.size());
}

static inline ImVec2 AddVec2(const ImVec2& a, const ImVec2& b) {
    return ImVec2(a.x + b.x, a.y + b.y);
}

static inline ImVec2 MulVec2(const ImVec2& v, float s) {
    return ImVec2(v.x * s, v.y * s);
}

inline bool IsValidScreenPos(const ImVec2& pos) {
    ImGuiIO& io = ImGui::GetIO();
    return pos.x >= 0 && pos.y >= 0 && pos.x <= io.DisplaySize.x && pos.y <= io.DisplaySize.y;
}

IMGUI_API void AddRectFilledMultiColor(
    const ImVec2& p_min,
    const ImVec2& p_max,
    ImU32 col_up_left,
    ImU32 col_up_right,
    ImU32 col_bot_right,
    ImU32 col_bot_left);

inline bool StyledBlueButton(const char* label, bool active, ImVec2 size = ImVec2(120, 0)) {
    ImVec4 normal  = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    ImVec4 enabled = ImVec4(0.0f, 0.55f, 1.0f, 1.0f);
    ImVec4 hovered = ImVec4(0.32f, 0.73f, 1.0f, 1.0f);
    ImGui::PushStyleColor(ImGuiCol_Button, active ? enabled : normal);
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, hovered);
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, enabled);
    ImGui::PushStyleColor(ImGuiCol_Text, active ? ImVec4(1,1,1,1) : ImVec4(0.07f,0.21f,0.4f,1.0f));
    bool pressed = ImGui::Button(label, size);
    ImGui::PopStyleColor(4);
    return pressed;
}

inline bool ToggleOption(const char* label, bool* state,
                         ImVec4 clrActive = ImVec4(0.20f, 0.85f, 0.95f, 1.0f),
                         ImVec4 clrNormal = ImVec4(0.85f, 0.85f, 0.85f, 0.8f))
{
    ImVec4 c = (*state) ? clrActive : clrNormal;
    ImGui::PushStyleColor(ImGuiCol_Text, c);
    ImGui::Text("» %s", label);
    ImGui::PopStyleColor();

    if (ImGui::IsItemClicked()) {
        *state = !*state;
        return true;
    }
    return false;
}
// Helpers for ImVec2 operators
static inline ImVec2 operator+(const ImVec2& lhs, const ImVec2& rhs) {
    return ImVec2(lhs.x + rhs.x, lhs.y + rhs.y);
}

static inline ImVec2 operator-(const ImVec2& lhs, const ImVec2& rhs) {
    return ImVec2(lhs.x - rhs.x, lhs.y - rhs.y);
}

static inline ImVec2 operator*(const ImVec2& lhs, float rhs) {
    return ImVec2(lhs.x * rhs, lhs.y * rhs);
}

static inline ImVec2 operator/(const ImVec2& lhs, float rhs) {
    return ImVec2(lhs.x / rhs, lhs.y / rhs);
}

void FloatOption(const char* label, float* value, float minValue, float maxValue)
{
    ImGui::Text("%s: %.2f", label, *value);
    ImGui::SliderFloat(label, value, minValue, maxValue);
}
