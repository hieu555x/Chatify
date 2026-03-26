Flutter & Dart Development Guidelines for Gemini
This document outlines the standard operating procedures, architectural patterns, and coding styles for developing high-quality Flutter applications. Use these guidelines to ensure code is performant, maintainable, and idiomatic.

💡 Interaction & Persona
User Persona: Assume the user understands general programming but may be new to Dart-specific nuances.

Explanations: Always explain Dart-specific features like null safety, Futures, and Streams when they appear in code.

Ambiguity: If a request is unclear, ask for clarification regarding the intended functionality and target platform (Mobile, Web, Desktop, etc.).

Tooling: * Use dart_format for consistent styling.

Use dart_fix to resolve common errors and align with analysis options.

Use the Dart linter (analyze_files) to catch issues early.

🏗️ Architecture & Project Structure
Standard Layout: Follow the standard Flutter structure with lib/main.dart as the entry point.

Logical Layers: Organize the project into four distinct layers:

Presentation: Widgets and screens.

Domain: Business logic classes.

Data: Model classes and API clients.

Core: Shared utilities and extension types.

Feature-based Organization: For large projects, group code by feature (each with its own presentation/domain/data subfolders) to improve scalability.

SOLID Principles: Strictly apply SOLID principles and favor composition over inheritance.

💻 Coding Standards & Best Practices
Dart Essentials
Effective Dart: Adhere to the official Effective Dart guidelines.

Immutability: Prefer immutable data structures. Widgets (especially StatelessWidget) must be immutable.

Naming: Use PascalCase for classes, camelCase for members/variables, and snake_case for files. Avoid abbreviations.

Functions: Keep functions short (strive for < 20 lines) with a single purpose. Use arrow syntax for simple one-liners.

Async/Await: Use async/await for single asynchronous operations and Streams for sequences of events.

Flutter UI Logic
Widget Composition: Compose complex UIs from smaller, reusable, private Widget classes rather than helper methods.

Performance:

Use const constructors whenever possible to reduce rebuilds.

Use ListView.builder or SliverList for long lists to enable lazy loading.

Use compute() for expensive tasks (like heavy JSON parsing) to avoid blocking the UI thread.

Build Methods: Keep build() methods clean. Never perform network calls or complex computations inside them.

🎛️ State Management & Data Flow
Built-in Solutions: Default to Flutter's built-in tools unless a third-party package is explicitly requested:

ValueNotifier: For simple, single-value local state.

ChangeNotifier: For complex or shared state, paired with ListenableBuilder.

Streams/Futures: Use StreamBuilder and FutureBuilder for async data.

Dependency Injection: Use manual constructor injection to keep dependencies explicit.

Data Abstraction: Use Repositories/Services to abstract data sources (APIs, databases) and improve testability.

🛣️ Navigation & Routing
Primary Router: Use the go_router package for declarative navigation and deep linking.

Authentication: Handle redirects (e.g., login walls) using the redirect property of GoRouter.

Navigator: Use the built-in Navigator only for short-lived views like dialogs.

🎨 Visual Design & Theming
Material 3: Embrace Material 3 by using ColorScheme.fromSeed() to generate harmonious palettes.

Themes: Always provide both theme (light) and darkTheme to MaterialApp.

Typography: Use GoogleFonts and define a clear TextTheme scale (e.g., displayLarge, bodyMedium).

Responsiveness: Use LayoutBuilder, MediaQuery, Expanded, or Wrap to ensure the UI works on mobile and web.

Advanced Styling: * Use ThemeExtension for custom design tokens.

Use WidgetStateProperty.resolveWith for interactive elements (e.g., changing button colors on press).

Apply subtle noise textures and multi-layered shadows for a "premium" feel.

🧪 Testing & Quality Assurance
Frameworks: Use package:test for unit tests, package:flutter_test for widgets, and package:integration_test for end-to-end flows.

Pattern: Follow the Arrange-Act-Assert (Given-When-Then) convention.

Mocks: Prefer fakes or stubs. Only use mockito or mocktail if absolutely necessary.

Logging: Use the logging package or dart:developer's log() function instead of print().

📖 Documentation & Accessibility
Documentation: Use /// for doc comments. Every public API must have a concise, single-sentence summary.

Accessibility (A11Y):

Maintain a minimum contrast ratio of 4.5:1 for text.

Use the Semantics widget to provide labels for screen readers.

Ensure the UI remains functional under system-wide font scaling.

Would you like me to generate a starter analysis_options.yaml file based on these linting rules?