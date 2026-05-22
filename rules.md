# Flutter Code Generation Rules

## General Rules
- Write production-grade Flutter code.
- Follow clean architecture with feature-first structure.
- Keep code simple, scalable, and maintainable.
- Prioritize readability over unnecessary abstraction.
- Avoid overengineering.
- Do not generate placeholder logic unless requested.
- Do not generate fake APIs or mock services unless explicitly requested.

## File Structure Rules
- Organize code using feature-first architecture.
- Keep related files close to their feature.
- Avoid deeply nested folders.
- Prefer concise and cohesive files.
- Split files only when readability decreases.
- Avoid giant widgets and giant cubits.

## Naming Conventions
- Use snake_case for files and folders.
- Use PascalCase for classes, enums, and typedefs.
- Use camelCase for variables and methods.
- Use meaningful and explicit names.
- Avoid generic names like utils, helper, manager, common.

## UI Rules
- Build pixel-perfect Flutter UI.
- Follow responsive design principles.
- Support RTL layout.
- Use consistent spacing and sizing.
- Avoid magic numbers.
- Use centralized dimensions and theme values.
- Keep widget trees clean and shallow.
- Extract reusable widgets only when meaningful.
- Prefer composition over inheritance.

## State Management Rules
- Never use setState.
- Use Cubit for business logic and screen states.
- Use ValueNotifier only for lightweight local UI state.
- Keep business logic outside UI files.
- Keep states immutable.
- Minimize unnecessary rebuilds.
- Use BlocBuilder, BlocSelector, and ValueListenableBuilder correctly.

## Performance Rules
- Use const constructors whenever possible.
- Avoid unnecessary widget rebuilds.
- Avoid expensive operations inside build methods.
- Keep build methods lightweight.
- Lazy load widgets and lists when appropriate.

## Theme & Styling Rules
- Do not hardcode colors, text styles, spacing, or radius values.
- Use centralized theme management.
- Use ThemeExtensions when needed.
- Keep styling consistent across the project.
- Avoid inline styling unless necessary.

## Widget Rules
- Create reusable widgets for repeated patterns only.
- Avoid unnecessary wrapper widgets.
- Keep widgets focused on a single responsibility.
- Prefer stateless widgets whenever possible.
- Extract sections into smaller widgets when readability decreases.

## Cubit Rules
- One cubit per feature or screen responsibility.
- Keep cubits focused and lightweight.
- Avoid massive state classes.
- Avoid unnecessary state emissions.
- Separate loading, success, empty, and error states clearly.

## Code Quality Rules
- Write clean and self-explanatory code.
- Avoid comments unless necessary.
- Prefer expressive naming instead of comments.
- Remove unused imports and dead code.
- Keep methods small and focused.
- Avoid duplicated logic.

## Architecture Restrictions
- Do not create unnecessary abstraction layers.
- Do not generate unnecessary base classes.
- Do not generate unnecessary interfaces.
- Avoid premature optimization.
- Avoid deeply coupled components.

## Layout Rules
- Use adaptive layouts when needed.
- Handle keyboard overflow properly.
- Respect safe areas.
- Avoid fixed heights unless necessary.
- Prefer flexible and scalable layouts.

## Animation Rules
- Keep animations smooth and minimal.
- Avoid excessive animations.
- Use subtle transitions and interactions.
- Keep animations performant.

## Platform Compatibility Rules (IMPORTANT)
- Ensure the project targets modern Flutter requirements with 16KB memory page size compatibility (Android 16KB page alignment support).
- Avoid assumptions that break 16KB memory page constraints on Android builds.
- Keep native dependencies and configurations compatible with Android 16KB page size requirements.
- Do not introduce low-level optimizations or plugins that are incompatible with modern Android memory page alignment standards.
- Ensure build outputs are aligned with current Flutter stable requirements for Android devices supporting 16KB page size.

## Output Rules
- Generate complete and runnable Flutter code.
- Ensure imports are correct.
- Ensure generated code compiles without modification.
- Follow existing project architecture and naming conventions strictly.