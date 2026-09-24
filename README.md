# MemoryCollage

The shipping product is now the Flutter app in [`memory_book/`](memory_book/README.md) (iOS + Android): a living photo book, collage studio, and memory-reel exporter.

Long-range docs (so we do not lose the plan): [system design](memory_book/docs/SYSTEM_DESIGN.md), [product roadmap](memory_book/docs/PRODUCT_ROADMAP.md), and [backend](docs/BACKEND.md).

This Swift/iOS tree is kept as layout-math and filter reference for the rebuild.

MemoryCollage is a powerful and intuitive iOS application that enables users to create photo collages, generate videos from images with background music and filters, and leverage AI to generate videos from text or images. The app provides a seamless user experience with customizable features for each media creation mode.

##  Features

### **Collage Generator**
- Drag and drop images to create a freeform collage.
- Choose from predefined templates (grid, circular, custom shapes, etc.).
- Add text overlays with customizable fonts and colors.
- Set background colors or gradients.
- Export collage in different resolutions and formats (JPEG, PNG, HEIC).
- Includes watermark removal for premium users.

### **Video Generator**
- Convert selected images into a video.
- Auto-generate background music.
- Apply built-in video filters (Sepia, Noir, Bloom, etc.).
- Add transitions (Crossfade, Slide, Zoom).
- Save and share videos directly from the app.

### **AI Video Generator (Upcoming)**
- Generate AI-powered videos from text prompts or images.
- Customizable themes and effects.
- Fine-tuned AI models for creative video generation.

## Tech Stack
- **Swift & SwiftUI** – Core app development.
- **AVFoundation** – Video processing and export.
- **Core Image (CIImage)** – Applying filters and effects.
- **Core Animation (CAAnimation)** – Implementing transitions.
- **SwiftVideoGenerator** – Video composition from images.
- **UIKit** – Document picker and system-level integrations.
- **FFmpegKit (Planned)** – Advanced video and audio merging.
- **GitHub Actions (Planned)** – Automated CI/CD pipeline.

## Installation & Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/mobigaurav/MemoryCollage.git
   ```
2. Open the project in Xcode:
   ```bash
   cd MemoryCollage
   open MemoryCollage.xcodeproj
   ```
3. Install dependencies using CocoaPods (if applicable):
   ```bash
   pod install
   ```
4. Run the app on a simulator or device:
   ```bash
   Xcode > Run
   ```

## Unit Testing
- Unit test coverage for image and video processing.
- XCTest framework integration.
- Automated validation of export functionalities.

## CI/CD Integration (Planned)
- GitHub Actions for automated builds and testing.
- Code quality checks and linting.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Future Enhancements
- AI-powered video generation and smart editing.
- More templates and layouts for collages.
- Advanced video editing tools with real-time previews.

## Contact
For feature requests, bugs, or collaboration, feel free to reach out:
- ✉️ Email: mobigaurav@gmail.com
- 🔗 GitHub Issues: [Create an Issue](https://github.com/mobigaurav/MemoryCollage/issues)

## Support the Project

If you find this project helpful and want to support its development, you can buy me a coffee! Your support helps keep this project alive.

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-yellow?style=flat&logo=buy-me-a-coffee)](https://buymeacoffee.com/mobigaurav)


---


