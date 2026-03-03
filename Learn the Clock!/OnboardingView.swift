//
//  OnboardingView.swift
//  Learn The Clock!
//
//  Created by Sebastian Strus on 3/3/26.
//

import SwiftUI

// MARK: - Onboarding Slide Model
struct OnboardingSlide {
    let systemImage: String
    let imageColor: Color
    let title: String
    let subtitle: String
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            systemImage: "clock.fill",
            imageColor: .cyan,
            title: "Learn The Clock!",
            subtitle: "Master telling time with fun, interactive exercises designed for every level."
        ),
        OnboardingSlide(
            systemImage: "list.bullet.clipboard.fill",
            imageColor: .mint,
            title: "Three Ways to Learn",
            subtitle: "Multiple-choice, time pickers, or drag the clock hands — you choose how to practice!"
        ),
        OnboardingSlide(
            systemImage: "slider.horizontal.3",
            imageColor: .orange,
            title: "Your Pace, Your Rules",
            subtitle: "Pick Easy, Medium, or Hard. Switch between 12 or 24-hour clocks. You're in control."
        ),
        OnboardingSlide(
            systemImage: "star.fill",
            imageColor: .yellow,
            title: "Ready to Start?",
            subtitle: "Complete all exercises to earn your score. Challenge yourself and improve every day!"
        )
    ]

    var body: some View {
        ZStack {
            // Shifting background gradient
            LinearGradient(
                colors: [
                    slides[currentPage].imageColor.opacity(0.25),
                    Color.black.opacity(0.92),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            // Atmospheric blurred circles
            GeometryReader { geo in
                Circle()
                    .fill(slides[currentPage].imageColor.opacity(0.12))
                    .frame(width: geo.size.width * 1.1)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                    .blur(radius: 60)
                    .animation(.easeInOut(duration: 0.6), value: currentPage)

                Circle()
                    .fill(slides[currentPage].imageColor.opacity(0.08))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.6)
                    .blur(radius: 40)
                    .animation(.easeInOut(duration: 0.6), value: currentPage)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Swipeable slides
                TabView(selection: $currentPage) {
                    ForEach(slides.indices, id: \.self) { index in
                        SlideContentView(
                            slide: slides[index],
                            isActive: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height * 0.56)

                Spacer()

                // Dot indicators
                HStack(spacing: 10) {
                    ForEach(slides.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage
                                  ? slides[currentPage].imageColor
                                  : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 36)

                // Buttons
                VStack(spacing: 14) {
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            if currentPage < slides.count - 1 {
                                currentPage += 1
                            } else {
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        Text(currentPage == slides.count - 1 ? "Start Learning!" : "Next")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(slides[currentPage].imageColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: slides[currentPage].imageColor.opacity(0.45), radius: 12, y: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }

                    if currentPage < slides.count - 1 {
                        Button {
                            withAnimation { hasSeenOnboarding = true }
                        } label: {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Individual Slide
struct SlideContentView: View {
    let slide: OnboardingSlide
    let isActive: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(slide.imageColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .strokeBorder(slide.imageColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 140, height: 140)
                Image(systemName: slide.systemImage)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [slide.imageColor, slide.imageColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.1), value: appeared)
            }
            .scaleEffect(appeared ? 1.0 : 0.8)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 14) {
                Text(slide.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)

                Text(slide.subtitle)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.22), value: appeared)
            }
        }
        .padding(.horizontal, 24)
        .onAppear { triggerAnimation() }
        .onChange(of: isActive) { active in if active { triggerAnimation() } }
    }

    private func triggerAnimation() {
        appeared = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
    }
}
