/*
** version.h
**
** ZDoom version constants
**
**---------------------------------------------------------------------------
**
** Copyright 1999-2016 Marisa Heit
** Copyright 2006-2016 Christoph Oelckers
** Copyright 2017-2025 GZDoom Maintainers and Contributors
** Copyright 2025-2026 UZDoom Maintainers and Contributors
**
** SPDX-License-Identifier: GPL-3.0-or-later
**
**---------------------------------------------------------------------------
**
** Code written prior to 2026 is also licensed under:
**
** SPDX-License-Identifier: BSD-3-Clause
**
**---------------------------------------------------------------------------
**
*/

#pragma once

/** Lots of different version numbers **/

#define VERSIONSTR "0.4.0"

// The version as seen in the Windows resource
#define RC_FILEVERSION 0,4,0,0
#define RC_PRODUCTVERSION 0,4,0,0
#define RC_PRODUCTVERSION2 VERSIONSTR
// These are for content versioning.
#define VER_MAJOR 0
#define VER_MINOR 4
#define VER_REVISION 0

// This should always refer to the upstream compatibility version a derived port is based on and not reflect the derived port's version number!
#define ENG_MAJOR 5
#define ENG_MINOR 0
#define ENG_REVISION 0

// Version stored in the ini's [LastRun] section.
// Bump it if you made some configuration change that you want to
// be able to migrate in FGameConfigFile::DoGlobalSetup().
#define ENGINELASTRUNVERSION "233"
#define GAMELASTRUNVERSION "1"

// Protocol version used in demos.
// Bump it if you change existing DEM_ commands or add new ones.
// Otherwise, it should be safe to leave it alone.
#define DEMOGAMEVERSION 0x221

// Minimum demo version we can play.
// Bump it whenever you change or remove existing DEM_ commands.
#define MINDEMOVERSION 0x221

// SAVEVER is the version of the information stored in level snapshots.
// Note that SAVEVER is not directly comparable to VERSION.
// SAVESIG should match SAVEVER.

// extension for savegames
#define SAVEGAME_EXT "zds"

// MINSAVEVER is the minimum level snapshot version that can be loaded.
#define MINSAVEVER 4556

// Use 4500 as the base git save version, since it's higher than the
// SVN revision ever got.
#define SAVEVER 4560

// This is so that derivates can use the same savegame versions without worrying about engine compatibility
#define GAMESIG "SOLENGINE"

// list of compatible ports, ex.:
// #define ALLOWLOADIN "PORT1", "PORT2", "PORT3"
#define ALLOWLOADIN

#ifndef LOAD_GZDOOM_4142_SAVES
	#define LOAD_GZDOOM_4142_SAVES 0
#endif

#define BASEWAD "sol-engine.pk3"
#define SOLBUNDLE "sol.pk3"
#define SOLPACK_SCHEMA 2
#define SOLBUNDLE_CONTRACT 2
#define SOL_WADPACK_CONTRACT 3
#define SOL_WADPACK_ENTRIES 18
#define SOL_WADPACK_SLOTS 20
#define SOLBUNDLE_COMPONENTS 20
#define SOL_RUNTIME_SLOT 21
#define SOL_CONTENT_SLOT 22
#define SOLDEFAULTS_CONTRACT 1
#define SOL_GEOMETRY_CONTRACT 1
// Set OPTIONALWAD to "" (null) to disable searching for it
#define OPTIONALWAD "game_support.pk3"
#define GZDOOM 1
#define VR3D_ENABLED

// More stuff that needs to be different for derivatives.
#define GAMENAME "SOL! Engine"
#define WGAMENAME L"SOL! Engine"
#define GAMENAMELOWERCASE "sol-engine"
#define APPID "io.github.claire_moon.solengine"
#define QUERYIWADDEFAULT false
#define BUGS_URL "https://github.com/claire-moon/sol-engine/issues"

#define UPDATER_URL "https://github.com/claire-moon/sol-engine/releases/{}/{}/{}"
#define UPDATER_URL_BACKUP UPDATER_URL

// For QUERYIWADDEFAULT: Set to 'true' to always show dialog box on startup by default, 'false' to disable.
// Should set to 'false' for standalone games, and set to 'true' for regular source port forks that are meant to run any game.

#if defined(__APPLE__) || defined(_WIN32)
#define GAME_DIR GAMENAME
#elif defined(__HAIKU__)
#define GAME_DIR "config/settings/" GAMENAME
#endif

#define DEFAULT_DISCORD_APP_ID "1428620310302691349"

const int SAVEPICWIDTH = 216;
const int SAVEPICHEIGHT = 162;
const int VID_MIN_WIDTH = 320;
const int VID_MIN_HEIGHT = 200;

const char *GetVersionString();
const char *GetGitHash();
const char *GetGitTime();
const char *GetGitTag();
int GetGitDistance();
