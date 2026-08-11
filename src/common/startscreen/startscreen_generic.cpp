/*
** startscreen_generic.cpp
**
** SOL! procedural startup screen
**
**---------------------------------------------------------------------------
**
** Copyright 2022 Christoph Oelckers
** Copyright 2022-2025 GZDoom Maintainers and Contributors
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

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <thread>

#include "startscreen.h"

namespace
{
constexpr int ScreenWidth = 640 * 2;
constexpr int ScreenHeight = 480 * 2;
constexpr int ParticleCount = 768;
constexpr int AnimationFrames = 30;
constexpr int FrameDelayMilliseconds = 12;
constexpr int InitialFrameMilliseconds = 24;
constexpr double Pi = 3.14159265358979323846;

uint32_t Mix(uint32_t value)
{
	value ^= value >> 16;
	value *= 0x7feb352du;
	value ^= value >> 15;
	value *= 0x846ca68bu;
	value ^= value >> 16;
	return value;
}

double Unit(uint32_t value)
{
	return double(Mix(value) & 0x00ffffffu) / double(0x01000000u);
}

void MaxPixel(FBitmap& bitmap, int x, int y, uint8_t red, uint8_t green, uint8_t blue)
{
	if (x < 0 || y < 0 || x >= bitmap.GetWidth() || y >= bitmap.GetHeight())
	{
		return;
	}

	auto pixels = reinterpret_cast<RgbQuad*>(bitmap.GetPixels());
	auto& pixel = pixels[y * bitmap.GetWidth() + x];
	pixel.rgbRed = std::max(pixel.rgbRed, red);
	pixel.rgbGreen = std::max(pixel.rgbGreen, green);
	pixel.rgbBlue = std::max(pixel.rgbBlue, blue);
	pixel.rgbReserved = 255;
}

void DrawGlowParticle(FBitmap& bitmap, int x, int y, double brightness)
{
	brightness = std::clamp(brightness, 0.0, 1.0);
	const auto core = static_cast<uint8_t>(150.0 + 105.0 * brightness);
	const auto blue = static_cast<uint8_t>(210.0 + 45.0 * brightness);
	const auto halo = static_cast<uint8_t>(25.0 + 75.0 * brightness);

	MaxPixel(bitmap, x - 2, y, halo / 2, halo, blue / 3);
	MaxPixel(bitmap, x + 2, y, halo / 2, halo, blue / 3);
	MaxPixel(bitmap, x, y - 2, halo / 2, halo, blue / 3);
	MaxPixel(bitmap, x, y + 2, halo / 2, halo, blue / 3);
	MaxPixel(bitmap, x - 1, y, halo, std::min<int>(255, halo + 35), blue / 2);
	MaxPixel(bitmap, x + 1, y, halo, std::min<int>(255, halo + 35), blue / 2);
	MaxPixel(bitmap, x, y - 1, halo, std::min<int>(255, halo + 35), blue / 2);
	MaxPixel(bitmap, x, y + 1, halo, std::min<int>(255, halo + 35), blue / 2);
	MaxPixel(bitmap, x, y, core, core, 255);
}
}

class FGenericStartScreen : public FStartScreen
{
public:
	FGenericStartScreen(int max_progress);

	bool DoProgress(int advance) override;

private:
	void DrawParticles(double progress);
	void PresentParticles(double progress);

	int DisplayedFrame = 0;
	bool InitialFramePresented = false;
};

FGenericStartScreen::FGenericStartScreen(int max_progress)
	: FStartScreen(max_progress)
{
	StartupBitmap.Create(ScreenWidth, ScreenHeight);
	DrawParticles(0.0);
}

void FGenericStartScreen::DrawParticles(double requestedProgress)
{
	ClearBlock(StartupBitmap, { 0, 0, 0, 255 }, 0, 0, ScreenWidth, ScreenHeight);

	const double progress = std::clamp(requestedProgress, 0.0, 1.0);
	const double gather = 1.0 - std::pow(1.0 - progress, 3.0);
	const double swirlEnvelope = progress > 0.0 && progress < 1.0
		? std::sin(progress * Pi)
		: 0.0;
	const double orbit = 72.0 * swirlEnvelope * (1.0 - gather * 0.45);
	const double centerX = ScreenWidth * 0.5;
	const double centerY = ScreenHeight * 0.46;

	for (int index = 0; index < ParticleCount; ++index)
	{
		const uint32_t seed = static_cast<uint32_t>(index + 1) * 0x9e3779b9u;
		const double startX = Unit(seed + 1u) * ScreenWidth;
		const double startY = Unit(seed + 2u) * ScreenHeight;
		const int ray = index & 7;
		const double angle = -Pi * 0.5 + ray * Pi * 0.25;
		const bool cardinal = (ray & 1) == 0;
		const double rayLength = cardinal
			? (ray == 0 ? 270.0 : ray == 2 || ray == 6 ? 210.0 : 235.0)
			: 115.0;
		const double along = std::pow(Unit(seed + 3u), 1.65);
		const double taper = (1.0 - along) * (cardinal ? 12.0 : 8.0);
		const double across = (Unit(seed + 4u) * 2.0 - 1.0) * taper;
		const double targetX = centerX + std::cos(angle) * rayLength * along
			- std::sin(angle) * across;
		const double targetY = centerY + std::sin(angle) * rayLength * along
			+ std::cos(angle) * across;
		const double phase = Unit(seed + 5u) * Pi * 2.0 + progress * Pi * 2.0;
		const double orbitScale = 0.25 + Unit(seed + 6u) * 0.75;
		const double swirlX = std::cos(phase) * orbit * orbitScale;
		const double swirlY = std::sin(phase) * orbit * orbitScale;
		const double x = startX + (targetX - startX) * gather + swirlX;
		const double y = startY + (targetY - startY) * gather + swirlY;
		const double brightness = 0.28 + 0.72 * gather
			* (0.55 + 0.45 * (1.0 - along));

		DrawGlowParticle(
			StartupBitmap,
			static_cast<int>(std::lround(x)),
			static_cast<int>(std::lround(y)),
			brightness);
	}

	if (gather > 0.0)
	{
		const int flareRadius = static_cast<int>(2.0 + gather * 20.0);

		for (int offset = -flareRadius; offset <= flareRadius; ++offset)
		{
			const double strength = 1.0 - std::abs(offset) / double(flareRadius + 1);
			DrawGlowParticle(
				StartupBitmap,
				static_cast<int>(centerX) + offset,
				static_cast<int>(centerY),
				strength * gather);
			DrawGlowParticle(
				StartupBitmap,
				static_cast<int>(centerX),
				static_cast<int>(centerY) + offset,
				strength * gather);
		}
	}
}

void FGenericStartScreen::PresentParticles(double progress)
{
	DrawParticles(progress);
	delete StartupTexture;
	StartupTexture = nullptr;
	Render(true);
}

bool FGenericStartScreen::DoProgress(int advance)
{
	if (!InitialFramePresented)
	{
		PresentParticles(0.0);
		std::this_thread::sleep_for(std::chrono::milliseconds(InitialFrameMilliseconds));
		InitialFramePresented = true;
	}

	FStartScreen::DoProgress(advance);

	const double rawProgress = MaxPos > 0 ? double(CurPos) / double(MaxPos) : 1.0;
	const double progress = std::clamp(rawProgress, 0.0, 1.0);
	const int targetFrame = std::clamp(
		static_cast<int>(std::lround(progress * AnimationFrames)),
		0,
		AnimationFrames);

	if (targetFrame < DisplayedFrame)
	{
		DisplayedFrame = targetFrame;
		PresentParticles(double(DisplayedFrame) / double(AnimationFrames));
		return true;
	}

	for (int frame = DisplayedFrame + 1;
		frame <= targetFrame && frame <= AnimationFrames;
		++frame)
	{
		PresentParticles(double(frame) / double(AnimationFrames));

		if (frame < AnimationFrames)
		{
			std::this_thread::sleep_for(std::chrono::milliseconds(FrameDelayMilliseconds));
		}
	}

	DisplayedFrame = targetFrame;
	return true;
}

FStartScreen* CreateGenericStartScreen(int max_progress)
{
	return new FGenericStartScreen(max_progress);
}
