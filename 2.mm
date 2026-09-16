#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "imgui/imgui.h"
#include "imgui/imgui_impl_metal.h"
#include "Recto.hpp"
#include "Draw/Draw.h"
#import "Utilities/Macros.h"
#import "Utilities/Obfuscate.h"
#import "Utilities/XORstring.h"
#include <simd/vector_make.h>  
#import "UnityStructs/Quaternion.hpp"
#include "imgui/icons.hpp"
#import "UnityStructs/Vector3.h"
#import "UnityStructs/Vector2.h"
#import "UnityStructs/Vector4.h"
#import "UnityStructs/Matrix4x4.h"
#import "UnityStructs/Unity.h"
#import "fishhook/fishhook.h"
#import "CheatState/CheatState.hpp"
#import "Stream/HeeeNoScreenShotView.h"
#import "libs/include/SniperGate/SniperGate.h"
#import "R6X9_CODM.h"
extern "C" bool __isPlatformVersionAtLeast(unsigned int major, unsigned int minor, unsigned int patch, unsigned int build) {
    return true;
}
#include "ModController.h"
#include "font.h"
#include "iconcpp.h"
#import "icons.h"
#import "Stream/HeeeNoScreenShotView.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

#ifndef IM_PI
#define IM_PI 3.14159265358979323846f
#endif

#define ICON_FA_BULLET "" 

inline bool IsValidScreenPos(const ImVec2& pos) {
    return pos.x >= 0 && pos.x <= kWidth && pos.y >= 0 && pos.y <= kHeight;
}

@interface InheritGesture : UITapGestureRecognizer
@property (nonatomic) int number;
@property (nonatomic) NSString *text;
@property (nonatomic) void (*ptr)();
@end

@implementation InheritGesture
@end

@implementation ModController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
static int totalEnemies = 0;
static float tDis = 0, tDistance = 0, markDistance, markDis;
Vector3 TargetPos;
static bool needAdjustAim = false;
static Vector2 markScreenPos;

static void* (*var_00388444)() = (void*(*)())var_00338e3([SniperGate var_00022351].longLongValue);
static void* (*var_00388446)() = (void*(*)())var_00338e3(0x1022FF258);
static bool (*var_00388440)(void*) = (bool(*)(void*))var_00338e3(0x1017BCEA4);
static monoString* (*var_003884430)(void*) = (monoString*(*)(void*))var_00338e3(0x10266CC0C);
static bool (*var_003884431)(void*) = (bool(*)(void*))var_00338e3(0x102671ADC);
static bool (*var_003884432)(void*) = (bool(*)(void*))var_00338e3(0x102671CF8);
static void* (*var_0038844345)(void*) = (void*(*)(void*))var_00338e3(0x108BB6D9C);

static void (*var_0038844342)(void*, Vector3*) = (void(*)(void*, Vector3*))var_00338e3(0x108C3AFDC);
static void* (*var_0038844349)() = (void*(*)())var_00338e3(0x108BB0CDC);
static Matrix4x4 (*var_0038844338)(void*) = (Matrix4x4(*)(void*))var_00338e3(0x108BAF9AC);
static Matrix4x4 (*var_003884233)(void*) = (Matrix4x4(*)(void*))var_00338e3(0x108BAFAE4);

static float (*var_0038842e3)(void*) = (float(*)(void*))var_00338e3(0x1020CEE38);
static bool (*var_0038842b3)(void*) = (bool (*)(void*))var_00338e3(0x102281198);
static bool (*var_0038842333)(void*) = (bool (*)(void*))var_00338e3(0x101F1EE58);
static void (*var_0038842343)(void*, Quaternion) = (void (*)(void*, Quaternion))var_00338e3(0x1017B9338);
static Quaternion (*var_0033842333)(void*) = (Quaternion (*)(void*))var_00338e3(0x101A75834);

constexpr uint64_t  OFFSET_ENEMY_LIST = 0x178;
constexpr uint64_t OFFSET_ENEMY_INFO = 0x5C0;
constexpr uint64_t OFFSET_ATTACKABLE_INFO = 0x78;
constexpr uint64_t OFFSET_HEAD_BONE = 0x308;
constexpr uint64_t OFFSET_SPINE_BONE = 0x1C90;
constexpr uint64_t OFFSET_NECK_BONE = 0x1C98;
constexpr uint64_t OFFSET_HIPS_BONE = 0x1CA0;
constexpr uint64_t OFFSET_LEFT_ANKLE = 0x1CA8;
constexpr uint64_t OFFSET_RIGHT_ANKLE = 0x1CB0;

static inline bool IsValidPointer(void* ptr) {
    if (ptr == nullptr) return false;
    uint64_t addr = (uint64_t)ptr;
    if (addr < 0x100000000 || addr > 0x200000000000) return false;
    return true;
}

static inline Vector3 GetPlayerLocation(void* player) {
    if (!IsValidPointer(player)) return Vector3::Zero();
    Vector3 loc = Vector3::Zero();
    @try {
        void* transform = var_0038844345(player);
        if (IsValidPointer(transform)) var_0038844342(transform, &loc);
    } @catch (...) {}
    return loc;
}

static inline Vector3 GetBoneLocation(void* transform) {
    if (!IsValidPointer(transform)) return Vector3::Zero();
    Vector3 loc = Vector3::Zero();
    @try {
        var_0038844342(transform, &loc);
    } @catch (...) {}
    return loc;
}

static inline Matrix4x4 GetViewMatrix() {
    void* cam = nullptr;
    @try {
        cam = var_0038844349();
    } @catch (...) {}
    return IsValidPointer(cam) ? var_0038844338(cam) : Matrix4x4();
}

static inline Matrix4x4 GetProjMatrix() {
    void* cam = nullptr;
    @try {
        cam = var_0038844349();
    } @catch (...) {}
    return IsValidPointer(cam) ? var_003884233(cam) : Matrix4x4();
}

static inline Vector4 MultiplyPoint(Vector3 p, Matrix4x4 mv) {
    return Vector4(
        p.x * mv[0][0] + p.y * mv[1][0] + p.z * mv[2][0] + mv[3][0],
        p.x * mv[0][1] + p.y * mv[1][1] + p.z * mv[2][1] + mv[3][1],
        p.x * mv[0][2] + p.y * mv[1][2] + p.z * mv[2][2] + mv[3][2],
        p.x * mv[0][3] + p.y * mv[1][3] + p.z * mv[2][3] + mv[3][3]
    );
}

static inline Vector4 MultiplyProject(Vector4 v, Matrix4x4 proj) {
    return Vector4(
        v.X * proj[0][0] + v.Y * proj[1][0] + v.Z * proj[2][0] + v.W * proj[3][0],
        v.X * proj[0][1] + v.Y * proj[1][1] + v.Z * proj[2][1] + v.W * proj[3][1],
        v.X * proj[0][2] + v.Y * proj[1][2] + v.Z * proj[2][2] + v.W * proj[3][2],
        v.X * proj[0][3] + v.Y * proj[1][3] + v.Z * proj[2][3] + v.W * proj[3][3]
    );
}

static inline Vector3 NormalizeVector(Vector4 v) {
    if (v.W == 0.0f) return Vector3::Zero();
    return Vector3(v.X / v.W, v.Y / v.W, v.Z / v.W);
}

static inline Vector2 WorldToScreen(Vector3 n) {
    return Vector2(
        (kWidth / 2.0f * n.x) + (n.x + kWidth / 2.0f),
        -(kHeight / 2.0f * n.y) + (n.y + kHeight / 2.0f)
    );
}

static inline NSString* GetNSString(monoString* str) {
    if (!IsValidPointer(str) || str->length <= 0 || str->chars[0] == 0) return @"";
    @try {
        return [[NSString alloc] initWithCharacters:(const unichar*)str->chars length:str->length];
    } @catch (...) {
        return @"";
    }
}

static inline bool GetEnemyLabel(float Distance, void* enemyInfo, NSString** labelLine) {
    if (!IsValidPointer(enemyInfo) || !labelLine) return false;
    
    int distM = (int)Distance;
    void* playerInfo = *(void **)((uint64_t)enemyInfo + 0x5C0);
    
    if (!playerInfo) {
        *labelLine = [NSString stringWithFormat:@"Unknown [%dm]", distM];
        return true;
    }

    monoString *m_NickName = *(monoString **)((uint64_t)playerInfo + 0x158);
    NSString *nameEnemy = IsValidPointer(m_NickName) ? GetNSString(m_NickName) : @"";
    
    bool isBot = false;
    @try {
        isBot = (var_003884431 && var_003884431(enemyInfo)) || (var_003884432 && var_003884432(enemyInfo));
    } @catch (...) {}
    
    if (nameEnemy.length == 0) {
        nameEnemy = isBot ? @"BOT" : @"Unknown";
    }
    
    *labelLine = [NSString stringWithFormat:@"%@ [%dm]", nameEnemy, distM];
    
    return true;
}

static bool MenDeal = true;
ImFont *_espFont;
HeeeNoScreenShotView *noScreenShotView;
UILabel *menuTitle;
UIButton *var_00036763;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

-(instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!self.device) {
        abort();
    }
    menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    menuTitle.text = [NSString stringWithUTF8String:make_string("STORE  R6X9").c_str()];
    menuTitle.textColor = UIColorFromHex(0x3399FF);
    menuTitle.font = [UIFont fontWithName:[NSString stringWithUTF8String:make_string("AppleSDGothicNeo-Light").c_str()] size :27.0f ];
    menuTitle.textAlignment = NSTextAlignmentCenter;
    [menuTitle sizeToFit];
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    menuTitle.center = CGPointMake(CGRectGetMidX(mainWindow.bounds), 20);
    menuTitle.adjustsFontSizeToFitWidth = true;
    [mainWindow addSubview:menuTitle];

    var_00036763 = [UIButton buttonWithType:UIButtonTypeCustom];
    var_00036763.frame = CGRectMake((kWidth - 46) / 2, (kHeight - 46) / 2, 46, 46);
    var_00036763.layer.cornerRadius = 23;
    var_00036763.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.007];
    [var_00036763 addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [mainWindow addSubview:var_00036763];

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsDark();
    NSString *FontPath = @"/System/Library/Fonts/AppFonts/AppleGothic.otf";
    static const ImWchar icons_ranges[] = { 0xf000, 0xf3ff, 0 };
    ImFontConfig icons_config;
    ImFontConfig CustomFont;
    CustomFont.FontDataOwnedByAtlas = false;

    icons_config.MergeMode = true;
    icons_config.PixelSnapH = true;

    io.Fonts->AddFontFromMemoryTTF(const_cast<std::uint8_t*>(Custom), sizeof(Custom), 21.f, &CustomFont);
    _espFont = io.Fonts->AddFontFromMemoryCompressedTTF(font_awesome_data, font_awesome_size, 19.0f, &icons_config, icons_ranges);
    io.Fonts->AddFontDefault();
    ImGui_ImplMetal_Init(_device);
    return self;
}

- (void)startPulsatingAnimation {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         var_00036763.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:nil];
}

- (void)toggleMenu {
    MenDeal = !MenDeal;
}

-(MTKView *)mtkView {
    return (MTKView *)self.view;
}

-(void)loadView {
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    noScreenShotView = [[HeeeNoScreenShotView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    noScreenShotView.backgroundColor = [UIColor clearColor];
    noScreenShotView.userInteractionEnabled = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:noScreenShotView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = self;
    self.window.hidden = NO;
    self.view.hidden = NO;
    [noScreenShotView addSubview:self.window];
}

#pragma mark - MTKViewDelegate
int ret_000054438 =4442;
-(void)drawInMTKView:(MTKView*)view {
    NSString *deviceModel = [[UIDevice currentDevice] model];
    UIDevice *device = [UIDevice currentDevice];
    NSString *systemVersion = [device systemVersion];
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    id<MTLCommandBuffer > commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil ) {
        [commandBuffer commit];
        return;
    }
        if (MenDeal == true) {
        [self.view setUserInteractionEnabled:YES];
        [self.window setUserInteractionEnabled:YES];
    } else {
        [self.view setUserInteractionEnabled:NO];
        [self.window setUserInteractionEnabled:NO];
    }ImGui_ImplMetal_NewFrame(renderPassDescriptor);
    ImGui::NewFrame();
    ImFont* font = ImGui::GetFont();
    font->Scale = 16.f / font->FontSize;

    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
CGFloat menuWidth    = 380;
CGFloat menuHeight   = 260;
CGFloat x            = (screenWidth  - menuWidth)  / 2;
CGFloat y            = screenHeight * 0.1;

if (MenDeal == true) {
    ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowBgAlpha(0.98f);

    ImGui::Begin("##HiddenTitle", &MenDeal, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse);

    static auto StyledCheckboxNoIcon = [](const char* l, bool* v) {
        ImGui::PushStyleColor(ImGuiCol_Header, ImVec4(0, 0, 0, 0));
        ImGui::PushStyleColor(ImGuiCol_HeaderHovered, ImVec4(0, 0, 0, 0));
        ImGui::PushStyleColor(ImGuiCol_HeaderActive, ImVec4(0, 0, 0, 0));
        ImGui::PushStyleColor(ImGuiCol_Text, *v ? ImVec4(0.4f, 0.75f, 1, 1) : ImVec4(1, 1, 1, 1));
        if (ImGui::Selectable(l, *v)) *v = !*v;
        ImGui::PopStyleColor(4);
    };

    static auto StyledTextButton = [](const char* l, bool s) {
        ImGui::PushStyleColor(ImGuiCol_Text, s ? ImVec4(0.4f, 0.75f, 1, 1) : ImVec4(1, 1, 1, 1));
        bool p = ImGui::Selectable(l, s);
        ImGui::PopStyleColor();
        return p;
    };

    static auto StyledSliderThin = [](const char* l, float* v, float mn, float mx, const char* fmt) {
        ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0, 0, 0, 0));
        ImGui::PushStyleColor(ImGuiCol_SliderGrab, ImVec4(0.4f, 0.75f, 1, 0.6f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.4f, 0.75f, 1, 0.4f));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 2);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1);
        bool c = ImGui::SliderFloat(l, v, mn, mx, fmt);
        ImGui::PopStyleVar(2);
        ImGui::PopStyleColor(3);
        return c;
    };

    static auto StyledSliderIntThin = [](const char* l, int* v, int mn, int mx) {
        ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0, 0, 0, 0));
        ImGui::PushStyleColor(ImGuiCol_SliderGrab, ImVec4(0.4f, 0.75f, 1, 0.6f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.4f, 0.75f, 1, 0.4f));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 2);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1);
        bool c = ImGui::SliderInt(l, v, mn, mx);
        ImGui::PopStyleVar(2);
        ImGui::PopStyleColor(3);
        return c;
    };

    float tabW = ImGui::GetWindowWidth() * 0.28f;
    float tabH = 38;
    ImVec2 ts = ImGui::GetCursorScreenPos();

    for (int t = 1; t <= 3; t++) {
        bool s = (CheatState::currentPage == t);
        ImVec2 p = ImVec2(ts.x + (t - 1) * (tabW + 18), ts.y);
        ImU32 bg = ImGui::GetColorU32(s ? ImVec4(0.2f, 0.44f, 0.92f, 0.7f) : ImVec4(0.09f, 0.14f, 0.18f, 0.52f));
        ImU32 gl = ImGui::GetColorU32(s ? ImVec4(0.33f, 0.6f, 1, 0.32f) : ImVec4(0.12f, 0.16f, 0.22f, 0.22f));
        ImU32 tx;

        const char* n = (t == 1 ? "DRAW" : (t == 2 ? "AIM" : "CLOSE"));
        ImVec2 ss = ImGui::CalcTextSize(n);

        auto d = ImGui::GetWindowDrawList();

        d->AddRectFilled(p, ImVec2(p.x + tabW, p.y + tabH), bg, 10);
        d->AddRect(p, ImVec2(p.x + tabW, p.y + tabH), gl, 10, 0, s ? 3.2f : 1.1f);
        d->AddRect(ImVec2(p.x - 4, p.y - 4), ImVec2(p.x + tabW + 4, p.y + tabH + 4), gl, 16, 0, s ? 5.5f : 2);

        if (t == 3) {
            tx = ImGui::GetColorU32(ImVec4(0.25f, 0.55f, 1.0f, 1.0f));
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    if (i == 0 && j == 0) continue;
                    d->AddText(NULL, 18.5f, ImVec2(p.x + tabW / 2 - ss.x / 2 + i * 0.8f, p.y + tabH / 2 - ss.y / 2 + j * 0.8f), ImGui::GetColorU32(ImVec4(0.25f, 0.55f, 1.0f, 0.3f)), n);
                }
            }
        } else {
            tx = ImGui::GetColorU32(s ? ImVec4(1, 1, 1, 1) : ImVec4(0.55f, 0.68f, 0.9f, 0.88f));
        }

        d->AddText(NULL, 18.5f, ImVec2(p.x + tabW / 2 - ss.x / 2, p.y + tabH / 2 - ss.y / 2), tx, n);

        ImGui::SetCursorScreenPos(p);
        ImGui::InvisibleButton(n, ImVec2(tabW, tabH));

        if (ImGui::IsItemClicked()) {
            if (t == 3) {
                MenDeal = false;
            } else {
                CheatState::currentPage = t;
            }
        }

        ImGui::SameLine(0, 18);
    }

    ImGui::NewLine();
ImGui::Dummy(ImVec2(0, 7));

if (CheatState::currentPage == 1) {
    StyledCheckboxNoIcon("Stream Mode", &CheatState::stream_mode);
    StyledCheckboxNoIcon("Hide Top Label", &CheatState::hide_top_label);
    StyledCheckboxNoIcon("Enable Draw", &CheatState::show_visual);
    StyledCheckboxNoIcon("Draw - Skeleton", &CheatState::show_skeleton);
    StyledCheckboxNoIcon("Draw - Boxes", &CheatState::show_boxes);
    StyledCheckboxNoIcon("Draw - Health", &CheatState::show_health);
    StyledCheckboxNoIcon("Draw - Name", &CheatState::enable_r6x9);
    StyledCheckboxNoIcon("Draw - Lines", &CheatState::show_lines);
    StyledSliderThin("Lock Aim", &CheatState::max_distance, 10.0f, 200.0f, "%.0f m");

    float w = 65, h = 27, s = 7;
    ImVec2 b = ImGui::GetCursorScreenPos();
    const char* ln[3] = { "down", "middle", "top" };

    for (int i = 0; i < 3; i++) {
        bool s2 = (CheatState::line_mode == 2 - i);
        ImU32 bg2 = ImGui::GetColorU32(s2 ? ImVec4(0.19f, 0.44f, 0.95f, 0.73f) : ImVec4(0.12f, 0.18f, 0.22f, 0.44f));
        ImU32 gl2 = ImGui::GetColorU32(s2 ? ImVec4(0.37f, 0.6f, 1, 0.22f) : ImVec4(0.11f, 0.17f, 0.24f, 0.13f));
        ImU32 tx2 = ImGui::GetColorU32(s2 ? ImVec4(1, 1, 1, 1) : ImVec4(0.7f, 0.88f, 1, 0.77f));
        auto d2 = ImGui::GetWindowDrawList();
        ImVec2 p2(b.x + i * (w + s), b.y);
        d2->AddRectFilled(p2, ImVec2(p2.x + w, p2.y + h), bg2, 8.5f);
        d2->AddRect(p2, ImVec2(p2.x + w, p2.y + h), gl2, 8.5f, 0, s2 ? 2.6f : 1.1f);
        ImVec2 sz2 = ImGui::CalcTextSize(ln[2 - i]);
        d2->AddText(NULL, 18.5f, ImVec2(p2.x + (w - sz2.x) * 0.5f, p2.y + (h - sz2.y) * 0.5f + 0.5f), tx2, ln[2 - i]);
        ImGui::SetCursorScreenPos(p2);
        if (ImGui::InvisibleButton(ln[2 - i], ImVec2(w, h))) CheatState::line_mode = 2 - i;
    }
    ImGui::SetCursorScreenPos(ImVec2(b.x + 3 * (w + s), b.y));
}

if (CheatState::currentPage == 2) {
        StyledCheckboxNoIcon("On FOV", &CheatState::enable_fov_circle);
StyledCheckboxNoIcon("On AIMBOT", &CheatState::enable_assist);

        auto StyledComboButtons = [](const char* l, int* v, const char* const* it, int c) {
            ImGui::TextColored(ImVec4(0.38f, 0.78f, 1, 0.92f), "%s", l);
            ImGui::SameLine();
            for (int i = 0; i < c; i++) {
                bool sl = (*v == i);
                ImU32 bg = ImGui::GetColorU32(sl ? ImVec4(0.19f, 0.44f, 0.95f, 0.89f) : ImVec4(0.12f, 0.18f, 0.22f, 0.54f));
                ImU32 tx = ImGui::GetColorU32(sl ? ImVec4(1, 1, 1, 1) : ImVec4(0.78f, 0.88f, 1, 0.82f));
                auto d3 = ImGui::GetWindowDrawList();
                float w = ImGui::CalcTextSize(it[i]).x + 25, h = 22;
                ImVec2 p3 = ImGui::GetCursorScreenPos();
                d3->AddRectFilled(p3, ImVec2(p3.x + w, p3.y + h), bg, 7);
                d3->AddText(NULL, 16, ImVec2(p3.x + w / 2 - ImGui::CalcTextSize(it[i]).x / 2, p3.y + h / 2 - 7.5f), tx, it[i]);
                ImGui::SetCursorScreenPos(p3);
                if (ImGui::InvisibleButton(it[i], ImVec2(w, h))) *v = i;
                ImGui::SameLine(0, 4);
            }
            ImGui::NewLine();
        };

        const char* aimT[] = { "off", "Aim FOV" };
        const char* aimL[] = { "Head", "Chest", "Legs" };
        const char* aimTr[] = { "both", "AimFire", "AimScope" };

        StyledComboButtons("Aim Target", &CheatState::aim_target, aimT, 2);
        StyledComboButtons("Aim Location", &CheatState::aim_location, aimL, 3);
        StyledComboButtons("Aim Trigger", &CheatState::assist_trigger, aimTr, 3);
        ImGui::Text("Adjust Smooth Aim Settings:");
StyledSliderThin("Smooth", &CheatState::assist_smoothness, 0.01f, 1.0f, "%.2f");
StyledSliderThin("Size FOV", &CheatState::fov_radius, 0.0f, 500.0f, "%.1f");
    }

    ImGui::End();
}

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject load];
    });

    if (CheatState::stream_mode) {
        [noScreenShotView setSecure:YES];
    } else {
        [noScreenShotView setSecure:NO];
    }

    if (CheatState::hide_top_label) {
        menuTitle.hidden = YES;
    } else {
        menuTitle.hidden = NO;
    }

    totalEnemies = 0;
    tDistance = 0;
    needAdjustAim = false;
    markDistance = kWidth;
    markScreenPos = Vector2(kWidth / 2, kHeight / 2);
    markDis = kWidth;
    tDis = 0;
    float closestDistance = std::numeric_limits<float>::infinity();

bool isSafeToRun = false;
    if (var_00388446) {
        if (ret_000054438 != 3388)return;

        void *localPawnCheck = var_00388446();
        if (IsValidPointer(localPawnCheck)) {
            @try {
                if (var_00388440(localPawnCheck)) {
                    isSafeToRun = true;
                }
            } @catch (...) {
                isSafeToRun = false;
            }
        }
    }
 
    if (isSafeToRun) {
        if (CheatState::show_visual) {
            if (var_00388444) {
                auto gameplayInstance = var_00388444();
                if (IsValidPointer(gameplayInstance)) {
                    void *localPlayer = var_00388446();
                    if (IsValidPointer(localPlayer)) {
                        Matrix4x4 viewMatrix = GetViewMatrix();
                        Matrix4x4 projectionMatrix = GetProjMatrix();
                        monoList<void **> *enemyList = *(monoList<void **>**)((uint64_t)gameplayInstance + OFFSET_ENEMY_LIST);
                        if (ret_000054438 != 3388)return;

                        if (IsValidPointer(enemyList)) {
                            int enemyCount = enemyList->getSize();
                            if (enemyCount > 100) enemyCount = 100;

                            for (int i = 0; i < enemyCount; i++) {
                                void* enemyPtr = enemyList->getItems()[i];
                                if (!IsValidPointer(enemyPtr)) continue;
                                @try {
                                    void* enemyInfo = *(void **)((uint64_t)enemyPtr + OFFSET_ENEMY_INFO);
                                    if (!IsValidPointer(enemyInfo)) continue;
                                    
                                    bool isEnemyAlive = false;
                                    @try {
                                        if (var_00388440(enemyPtr)) isEnemyAlive = true;
                                    } @catch (...) { isEnemyAlive = false; }
                                    
                                    if (!isEnemyAlive) continue;
                                    
                                    Vector3 localPlayerLoc = GetPlayerLocation(localPlayer);
                                    Vector3 enemyLoc = GetPlayerLocation(enemyPtr);
                                    if (std::isnan(enemyLoc.x) || std::isnan(enemyLoc.y) || std::isnan(enemyLoc.z)) continue;

                                    Vector4 viewPoint = MultiplyPoint(enemyLoc, viewMatrix);
                                    Vector4 clipPoint = MultiplyProject(viewPoint, projectionMatrix);
                                    Vector3 normPoint = NormalizeVector(clipPoint);
                                    Vector2 screenPos = WorldToScreen(normPoint);
                                    if (std::isnan(screenPos.X) || std::isnan(screenPos.Y)) continue;

                                    void* headBone = nullptr, *spineBone = nullptr, *neckBone = nullptr, *hipsBone = nullptr, *leftAnkle = nullptr, *rightAnkle = nullptr;

                                    @try { headBone = *(void **)((uint64_t)enemyPtr + OFFSET_HEAD_BONE); } @catch (...) { continue; }
                                    @try { spineBone = *(void **)((uint64_t)enemyPtr + OFFSET_SPINE_BONE); } @catch (...) { continue; }
                                    @try { neckBone = *(void **)((uint64_t)enemyPtr + OFFSET_NECK_BONE); } @catch (...) { continue; }
                                    @try { hipsBone = *(void **)((uint64_t)enemyPtr + OFFSET_HIPS_BONE); } @catch (...) { continue; }
                                    @try { leftAnkle = *(void **)((uint64_t)enemyPtr + OFFSET_LEFT_ANKLE); } @catch (...) { continue; }
                                    @try { rightAnkle = *(void **)((uint64_t)enemyPtr + OFFSET_RIGHT_ANKLE); } @catch (...) { continue; }

                                    if (!IsValidPointer(headBone) || !IsValidPointer(spineBone) || !IsValidPointer(neckBone) ||
                                        !IsValidPointer(hipsBone) || !IsValidPointer(leftAnkle) || !IsValidPointer(rightAnkle)) continue;
                                        
                                    Vector3 headPosWorld, spinePosWorld, neckPosWorld, hipsPosWorld, leftAnklePosWorld, rightAnklePosWorld;
                                    @try { headPosWorld = GetBoneLocation(headBone); } @catch (...) { continue; }
                                    @try { spinePosWorld = GetBoneLocation(spineBone); } @catch (...) { continue; }
                                    @try { neckPosWorld = GetBoneLocation(neckBone); } @catch (...) { continue; }
                                    @try { hipsPosWorld = GetBoneLocation(hipsBone); } @catch (...) { continue; }
                                    @try { leftAnklePosWorld = GetBoneLocation(leftAnkle); } @catch (...) { continue; }
                                    @try { rightAnklePosWorld = GetBoneLocation(rightAnkle); } @catch (...) { continue; }

                                    Vector2 screenBones[6];
                                    @try {
                                        screenBones[0] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(headPosWorld, viewMatrix), projectionMatrix)));
                                        screenBones[1] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(neckPosWorld, viewMatrix), projectionMatrix)));
                                        screenBones[2] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(spinePosWorld, viewMatrix), projectionMatrix)));
                                        screenBones[3] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(hipsPosWorld, viewMatrix), projectionMatrix)));
                                        screenBones[4] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(leftAnklePosWorld, viewMatrix), projectionMatrix)));
                                        screenBones[5] = WorldToScreen(NormalizeVector(MultiplyProject(MultiplyPoint(rightAnklePosWorld, viewMatrix), projectionMatrix)));
                                    } @catch (...) { continue; }

                                    bool isFacing = (clipPoint.Z >= 0.01f);
                                    bool isVisible = (screenPos.X >= 0 && screenPos.X <= screenWidth && screenPos.Y >= 0 && screenPos.Y <= screenHeight);
                                    if (!isVisible || !isFacing) continue;

                                    float distance = Vector3::Distance(localPlayerLoc, enemyLoc);
                                    if (distance > (CheatState::distanceValue > 0.0f ? CheatState::distanceValue : 250.0f)) continue;

                                    float boxHeight = screenPos.Y - screenBones[0].Y;
                                    if (boxHeight <= 0.0f) continue;

                                    Recto rect(
                                        screenPos.X - (boxHeight * 0.45f * 0.5f),
                                        screenBones[0].Y,
                                        boxHeight * 0.45f,
                                        boxHeight
                                    );

                                    if (CheatState::enable_r6x9) {
                                        NSString *label = nil;
                                        if (GetEnemyLabel(distance, enemyPtr, &label)) {
                                            if (label && label.UTF8String && strlen(label.UTF8String) > 0) {
                                                ImDrawList *draw = ImGui::GetForegroundDrawList();
                                                float fontSize = 13.0f;
                                                ImVec2 labelSz = ImGui::CalcTextSize(label.UTF8String);
                                                ImVec2 labelPos = ImVec2(screenBones[0].X - labelSz.x * 0.5f, screenBones[0].Y - 25.0f);
                                                ImU32 black = IM_COL32(0, 0, 0, 255);
                                                draw->AddText(nullptr, fontSize, ImVec2(labelPos.x - 1, labelPos.y), black, label.UTF8String);
                                                draw->AddText(nullptr, fontSize, ImVec2(labelPos.x + 1, labelPos.y), black, label.UTF8String);
                                                draw->AddText(nullptr, fontSize, ImVec2(labelPos.x, labelPos.y - 1), black, label.UTF8String);
                                                draw->AddText(nullptr, fontSize, ImVec2(labelPos.x, labelPos.y + 1), black, label.UTF8String);
                                                draw->AddText(nullptr, fontSize, labelPos, IM_COL32(255, 255, 255, 255), label.UTF8String);
                                            }
                                        }
                                    }

                                    if (CheatState::show_lines) {
                                        ImDrawList *draw = ImGui::GetForegroundDrawList();
                                        ImVec2 startPos, endPos;
                                        if (CheatState::line_mode == 0) {
                                            startPos = ImVec2(screenWidth * 0.5f, 0.0f);
                                            endPos = ImVec2(screenBones[0].X, screenBones[0].Y);
                                        } else if (CheatState::line_mode == 1) {
                                            startPos = ImVec2(screenWidth * 0.5f, screenHeight * 0.5f);
                                            endPos = ImVec2(screenBones[2].X, screenBones[2].Y);
                                        } else {
                                            startPos = ImVec2(screenWidth * 0.5f, screenHeight - 7.0f);
                                            endPos = ImVec2(screenBones[5].X, screenBones[5].Y + 35.0f);
                                        }
                                        draw->AddLine(startPos, endPos, IM_COL32(0, 0, 0, 255), 4.0f);
                                        draw->AddLine(startPos, endPos, IM_COL32(0, 255, 0, 255), 2.0f);
                                    }

                                    if (CheatState::show_boxes) {
                                        ImDrawList *draw = ImGui::GetBackgroundDrawList();
                                        ImColor col(1.0f, 1.0f, 1.0f, 0.92f);
                                        DrawBox(rect.x, rect.y, rect.w, rect.h + 1.0f, col, 0.0f, 1.0f);
                                    }

                                    if (CheatState::show_health) {
                                        float health = 0.0f;
                                        float maxHealth = 100.0f;
                                        if (enemyPtr) {
                                            @try {
                                                void* attackInfo = *(void**)((uint64_t)enemyPtr + OFFSET_ATTACKABLE_INFO);
                                                if (IsValidPointer(attackInfo)) {
                                                    health = var_0038842e3(attackInfo);
                                                }
                                            } @catch (...) { health = 0.0f; }
                                        }
                                        float hpPercent = health / maxHealth;
                                        if (hpPercent < 0.0f) hpPercent = 0.0f;
                                        if (hpPercent > 1.0f) hpPercent = 1.0f;
                                        drawHealth(rect, (int)(maxHealth * hpPercent), (int)maxHealth);
                                    }
                                } @catch (...) {}
                            }
                        }
                    }
                }
            }
        }
    }

    if (CheatState::enable_assist) {
        Aimbot();
    }

    auto draw = ImGui::GetBackgroundDrawList();
    if (CheatState::enable_fov_circle) {
        ImVec2 center = ImVec2(kWidth / 2, kHeight / 2);
        float radius = CheatState::fov_radius;
        ImColor color = IM_COL32(255, 255, 255, 255);
        draw->AddCircle(center, radius, color, 0, 1.0f);
    }
    ImGui::Render();
    ImDrawData* drawData = ImGui::GetDrawData();
    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder pushDebugGroup:@"Dear ImGui rendering"];
    ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);
    [renderEncoder popDebugGroup];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

-(void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size_ {
}

#pragma mark - Interaction
-(void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.AddMousePosEvent(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.AddMouseButtonEvent(0, hasActiveTouch);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

static bool GetInsideFov(float ScreenWidth, float ScreenHeight, Vector2 PlayerBone, float FovRadius) {
    Vector2 Cenpoint;
    Cenpoint.X = PlayerBone.X - (ScreenWidth / 2);
    Cenpoint.Y = PlayerBone.Y - (ScreenHeight / 2);
    return (Cenpoint.X * Cenpoint.X + Cenpoint.Y * Cenpoint.Y <= FovRadius * FovRadius);
}

void Aimbot() {
    if (!CheatState::enable_assist) return;

    Matrix4x4 viewMatrix = GetViewMatrix();
    Matrix4x4 projectionMatrix = GetProjMatrix();
    
    float closestDistance = std::numeric_limits<float>::infinity();
    Vector2 closestTargetScreenPos = Vector2(0, 0);
    Vector3 closestTargetWorldPos = Vector3(0, 0);

    void* localPawn = var_00388446 ? var_00388446() : nullptr;
    if (!localPawn) return;

    if (CheatState::assist_trigger == 1) {
        if (var_0038842b3 && !var_0038842b3(localPawn)) return;
    } else if (CheatState::assist_trigger == 2) {
        if (var_0038842333 && !var_0038842333(localPawn)) return;
    }

    void* gameInstance = var_00388444 ? var_00388444() : nullptr;
    if (!gameInstance) return;

    monoList<void **> *enemyList = *(monoList<void **>**)((uint64_t)gameInstance + OFFSET_ENEMY_LIST);
    if (!enemyList) return;

    int enemyCount = enemyList->getSize();
    for (int i = 0; i < enemyCount; i++) {
        if (i >= enemyList->getSize()) continue;
        
        void* enemyPawn = enemyList->getItems()[i];
        if (!enemyPawn) continue;

        bool isAlive = false;
        if (var_00388440 != nullptr) {
            @try {
                isAlive = var_00388440(enemyPawn);
            } @catch (...) { continue; }
        }
        if (!isAlive) continue;

        Vector3 enemyPositionWorld = GetPlayerLocation(enemyPawn);
        Vector3 localPosition = GetPlayerLocation(localPawn);
        float distance = Vector3::Distance(localPosition, enemyPositionWorld);

        if (distance > CheatState::max_distance) continue;

        void* headBone = nullptr;
        @try {
            headBone = *(void **)((uint64_t) enemyPawn + OFFSET_HEAD_BONE);
        } @catch (...) { continue; }

        if (!headBone) continue;

        Vector3 targetPosition = GetBoneLocation(headBone);
        if (CheatState::aim_location == 1) {
            targetPosition.y -= 0.3f;
        } else if (CheatState::aim_location == 2) {
            targetPosition.y -= 0.5f;
        }

        Vector4 targetPositionView = MultiplyPoint(targetPosition, viewMatrix);
        Vector4 targetPositionClip = MultiplyProject(targetPositionView, projectionMatrix);
        Vector3 targetPositionNormalized = NormalizeVector(targetPositionClip);
        Vector2 targetPositionScreen = WorldToScreen(targetPositionNormalized);

        if (targetPositionScreen.X < 0 || targetPositionScreen.X > kWidth ||
            targetPositionScreen.Y < 0 || targetPositionScreen.Y > kHeight) {
            continue;
        }

        if (targetPositionClip.Z < 0.01f) {
            continue;
        }

        if (CheatState::aim_target == 1) {
            if (!GetInsideFov(kWidth, kHeight, targetPositionScreen, CheatState::fov_radius)) {
                continue; 
            }
        }

        if (distance < closestDistance) {
            closestDistance = distance;
            closestTargetScreenPos = targetPositionScreen;
            closestTargetWorldPos = targetPosition;
        }
    }

    if (closestDistance != std::numeric_limits<float>::infinity()) {
        void* mainCamera = var_0038844349 ? var_0038844349() : nullptr;
        if (!mainCamera) return;

        void* mainView = var_0038844345 ? var_0038844345(mainCamera) : nullptr;
        if (!mainView) return;

        Vector3 mainViewPos = GetBoneLocation(mainView);

        if (var_0033842333 && var_0038842343) {
            Quaternion currentAimRotation = var_0033842333(localPawn);
            Quaternion targetAimRotation = Quaternion::LookRotation(closestTargetWorldPos - mainViewPos, Vector3::Up());

            Quaternion finalAimRotation;
            if (CheatState::assist_smoothness > 0) {
                finalAimRotation = Quaternion::Lerp(currentAimRotation, targetAimRotation, CheatState::assist_smoothness);
            } else {
                finalAimRotation = targetAimRotation;
            }

            var_0038842343(localPawn, finalAimRotation);
        }
    }
}

bool isJailbroken() {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return true;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]) {
        return true;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]) {
        return true;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]) {
        return true;
    }

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/Check.Packages"]]) {
        return true;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/usr/sbin/sshd"]) {
        return true;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb"]) {
        return true;
    }

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sileo://source/Check.Packages"]]) {
        return true;
    }
    return true;
}
@end

static ModController *sin_53 = nil;

extern "C" void sub_00238e7b(void) {
    ret_000054438 = 3388;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sin_53 == nil) {
            sin_53 = [[ModController alloc] initWithNibName:nil bundle:nil];
            [sin_53 loadView];
            [sin_53 viewDidLoad];

            var_00036763 = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat btnSize = 60;
            var_00036763.frame = CGRectMake(0, 0, btnSize, btnSize);
            var_00036763.backgroundColor = [UIColor clearColor];
            [var_00036763 setTitle:@"" forState:UIControlStateNormal];
            [var_00036763 addTarget:sin_53 action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

            UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
            [mainWindow addSubview:var_00036763];
            [mainWindow bringSubviewToFront:var_00036763];

            MenDeal = true;
            
            sin_53.window.hidden = NO;
            sin_53.view.hidden = NO;
            
            noScreenShotView.userInteractionEnabled = MenDeal;
            sin_53.view.userInteractionEnabled = MenDeal;
        }
    });
}