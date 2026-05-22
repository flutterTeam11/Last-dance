class OnboardingData {
  final String image;
  final String title;
  final String description;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

const List<OnboardingData> onboardingPages = [
  OnboardingData(
    image: 'assets/images/onboarding/onboarding1.svg',
    title: 'Saving lives through innovation',
    description:
        'Meet ResQer — your smart companion in disaster zones, designed to detect victims and guide rescue missions safely.',
  ),
  OnboardingData(
    image: 'assets/images/onboarding/onboarding2.svg',
    title: 'Intelligent thermal and visual scanning',
    description:
        'Our robot uses advanced thermal sensors and real-time cameras to locate victims under debris — even where humans can\'t reach',
  ),
  OnboardingData(
    image: 'assets/images/onboarding/onboarding3.svg',
    title: 'Stay connected anywhere',
    description:
        'Watch live drone feeds, analyze data instantly, and coordinate with rescue teams in seconds — all from one place',
  ),
  OnboardingData(
    image: 'assets/images/onboarding/onboarding4.svg',
    title: 'Every second counts',
    description:
        'ResQer helps save lives faster — because every heartbeat matters',
  ),
];
