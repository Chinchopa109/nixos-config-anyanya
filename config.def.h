#pragma once
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 2;        /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = {
	"JetBrainsMono Nerd Font:size=10:antialias=true:autohint=true",
	"Noto Color Emoji:size=10"
};
static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=10";
#define COORDINATES_STYLE "[x%d y%d]"

/* Default Suckless Palette (Overridden dynamically by Wallust via XRDB) */
static MAYBE_CONST char normbgcolor[]           = "#222222";
static MAYBE_CONST char normbordercolor[]       = "#444444";
static MAYBE_CONST char normfgcolor[]           = "#bbbbbb";
static MAYBE_CONST char selfgcolor[]            = "#eeeeee";
static MAYBE_CONST char selbordercolor[]        = "#005577";
static MAYBE_CONST char selbgcolor[]            = "#005577";
static MAYBE_CONST char *colors[][3] = {
	/*               fg           bg           border   */
	[SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
	[SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

#if GAPS
static const unsigned int gappx = 4;
#endif

#if BAR_HEIGHT
static const int user_bh = 18;
#endif

#if BAR_PADDING
static const int top_vertpad    = 0;
static const int bottom_vertpad = 0;
static const int left_sidepad   = 300;
static const int right_sidepad  = 300;
#endif

#define BAR_ALWAYS_ON_TOP 1

#if EXTERNAL_BARS
#define EXTERNAL_BARS_ALWAYS_ON_TOP 1
#endif

#if INFINITE_TAGS
#define PINNED_WINDOWS_ALWAYS_ON_TOP 1
#endif

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

#if OCCUPIED_TAGS_DECORATION
static const char *occupiedtags[] = { "1+", "2+", "3+", "4+", "5+", "6+", "7+", "8+", "9+" };
#endif

#if INFINITE_TAGS
#define MOVE_CANVAS_STEP 120
#endif

#if INFINITE_TAGS && IT_SHOW_COORDINATES_IN_BAR
#define COORDINATES_DIVISOR 10
#endif

#if MOVE_RESIZE_WITH_KEYBOARD
#define MOVE_RESIZE_WITH_KEYBOARD_STEP 100
#define MOVE_WITH_KEYBOARD_STEP 100
#define RESIZE_WITH_KEYBOARD_STEP 100
#endif

static const Rule rules[] = {
	{ NULL,              NULL,       NULL,                   0,            0,           -1 },
	/* class             instance    title                   tags mask     isfloating   monitor */
};

/* layout(s) */
static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 0;
static const int lockfullscreen = 1;
#if LOCK_MOVE_RESIZE_REFRESH_RATE
static const int refreshrate = 120;
#endif

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "><>",      NULL },    /* first entry is default (floating / infinite canvas) */
	{ "[]=",      tile },    /* tiled */
	{ "[M]",      monocle }, /* monocle */
};

/* key definitions */
#define MODKEY Mod4Mask
#define ALTERNATE_MODKEY Mod1Mask

#define SCROLL_UP Button4
#define SCROLL_DOWN Button5

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ Mod1Mask,                     KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell pipelines */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0";
static const char *dmenucmd[]   = { "dmenu_wallust", "-m", dmenumon, "-fn", dmenufont, NULL };
static const char *browsercmd[] = { "librewolf", NULL };
static const char *termcmd[]    = { "kitty", "--single-instance", NULL };
static const char *yazicmd[]    = { "kitty", "--single-instance", "-e", "yazi", NULL };
static const char *btopcmd[]    = { "kitty", "--single-instance", "-e", "btop", NULL };

static const Key keys[] = {
	/* modifier                     key                      function        argument */
	{ MODKEY,                       XK_d,                    spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_t,                    spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_e,                    spawn,          {.v = yazicmd } },
	{ MODKEY,                       XK_b,                    spawn,          {.v = browsercmd } },
	{ MODKEY|ShiftMask,             XK_b,                    spawn,          {.v = btopcmd } },
	{ MODKEY|ControlMask,           XK_b,                    togglebar,      {0} },
  /* Media player controls (Works out-of-the-box with DeaDBeeF, MPV, LibreWolf) */
	{ 0,                            XF86XK_AudioPlay,        spawn,          SHCMD("playerctl play-pause") },
	{ 0,                            XF86XK_AudioNext,        spawn,          SHCMD("playerctl next") },
	{ 0,                            XF86XK_AudioPrev,        spawn,          SHCMD("playerctl previous") },
  { 0,                            XF86XK_AudioStop,        spawn,          SHCMD("playerctl stop") },
	/* Screenshots to clipboard (Super+s or Print = Area, Super+Shift+s = Fullscreen) */
	{ MODKEY,                       XK_s,                    spawn,          SHCMD("maim -s -u -o | xclip -selection clipboard -t image/png && notify-send -u low 'Screenshot' 'Area copied to clipboard'") },
	{ 0,                            XK_Print,                spawn,          SHCMD("maim -s -u -o | xclip -selection clipboard -t image/png && notify-send -u low 'Screenshot' 'Area copied to clipboard'") },
	{ MODKEY|ShiftMask,             XK_s,                    spawn,          SHCMD("maim -u -o | xclip -selection clipboard -t image/png && notify-send -u low 'Screenshot' 'Fullscreen copied to clipboard'") },

	{ MODKEY,                       XK_j,                    focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,                    focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,                    incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_p,                    incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,                    setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,                    setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return,               swapmaster,     {0} },
	{ MODKEY,                       XK_0,                    view,           {0} },
	{ MODKEY,                       XK_q,                    killclient,     {0} },
	{ MODKEY,                       XK_y,                    setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,                    setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,                    setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,                setlayout,      {0} },
	{ MODKEY,                       XK_Tab,                  view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,                    tag,            {.ui = ~0 } },
	TAGKEYS(                        XK_1,                                    0)
	TAGKEYS(                        XK_2,                                    1)
	TAGKEYS(                        XK_3,                                    2)
	TAGKEYS(                        XK_4,                                    3)
	TAGKEYS(                        XK_5,                                    4)
	TAGKEYS(                        XK_6,                                    5)
	TAGKEYS(                        XK_7,                                    6)
	TAGKEYS(                        XK_8,                                    7)
	TAGKEYS(                        XK_9,                                    8)
	{ MODKEY|ShiftMask,             XK_c,                    quit,           {0} },
#if XRDB
	{ MODKEY,                       XK_F5,                   xrdb,           {.v = NULL } },
#endif
#if FULLSCREEN
	{ MODKEY|ShiftMask,             XK_f,                    togglefullscr,  {0} },
#endif
#if ENHANCED_TOGGLE_FLOATING
	{ MODKEY|ShiftMask,             XK_q,                    enhancedtogglefloating, {0} },
#endif
#if GAPS
	{ MODKEY,                       XK_minus,                setgaps,        {.i = -1 } },
	{ MODKEY,                       XK_equal,                setgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_equal,                setgaps,        {.i = 0  } },
#endif
#if MOVE_RESIZE_WITH_KEYBOARD
	{ MODKEY,                       XK_Down,                 moveresize,     {.v = (int []){ 0, 0, 0, RESIZE_WITH_KEYBOARD_STEP }}},
	{ MODKEY,                       XK_Up,                   moveresize,     {.v = (int []){ 0, 0, 0, -RESIZE_WITH_KEYBOARD_STEP }}},
	{ MODKEY,                       XK_Right,                moveresize,     {.v = (int []){ 0, 0, RESIZE_WITH_KEYBOARD_STEP, 0 }}},
	{ MODKEY,                       XK_Left,                 moveresize,     {.v = (int []){ 0, 0, -RESIZE_WITH_KEYBOARD_STEP, 0 }}},
#endif
#if INFINITE_TAGS
	{ MODKEY,                       XK_r,                    homecanvas,     {0} },
	{ MODKEY|ShiftMask,             XK_Left,                 movecanvas,     {.i = 0} },
	{ MODKEY|ShiftMask,             XK_Right,                movecanvas,     {.i = 1} },
	{ MODKEY|ShiftMask,             XK_Up,                   movecanvas,     {.i = 2} },
	{ MODKEY|ShiftMask,             XK_Down,                 movecanvas,     {.i = 3} },
	{ MODKEY|ShiftMask,             XK_d,                    centerwindow,   {0} },
	{ MODKEY|ControlMask,           XK_z,                    pinwindow,      {0} },
#endif
#if DIRECTIONAL_FOCUS
	{ ALTERNATE_MODKEY,             XK_Left,                 focusdir,       {.i = 0 } },
	{ ALTERNATE_MODKEY,             XK_Right,                focusdir,       {.i = 1 } },
	{ ALTERNATE_MODKEY,             XK_Up,                   focusdir,       {.i = 2 } },
	{ ALTERNATE_MODKEY,             XK_Down,                 focusdir,       {.i = 3 } },
#endif
};

/* button definitions */
static const Button buttons[] = {
	/* click                event mask        button          function        argument */
#if INFINITE_TAGS
	{ ClkRootWin,           MODKEY|ShiftMask, Button1,        movecanvasmouse, {.f = 1.5 } },
	{ ClkClientWin,         MODKEY|ShiftMask, Button1,        movecanvasmouse, {.f = 1.5 } },
	{ ClkRootWin,           0,                Button1,        movecanvasmouse, {.f = 1.5 } },
#endif
	{ ClkLtSymbol,          0,                Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,                Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,                Button2,        swapmaster,     {0} },
	{ ClkStatusText,        0,                Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,           Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,           Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,           Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,                Button1,        view,           {0} },
	{ ClkTagBar,            0,                Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,           Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,           Button3,        toggletag,      {0} },
};
