# BondUp Design System

This design system is a Flutter implementation of the `.global.css` design system from the Django web application. It ensures visual consistency between the web and mobile applications.

## Table of Contents

- [Installation](#installation)
- [Color Palette](#color-palette)
- [Components](#components)
  - [Buttons](#buttons)
  - [Chips](#chips)
  - [Cards](#cards)
  - [Text Fields](#text-fields)
  - [Status Badges](#status-badges)
  - [Toasts](#toasts)
- [Theme](#theme)
- [Examples](#examples)

## Installation

Import the design system in your Dart files:

```dart
import 'package:bond_up_mobile/core/design_system.dart';
```

Or import specific components:

```dart
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/core/widgets/buttons/app_button.dart';
```

## Color Palette

### Brand Colors

```dart
AppColors.orangeSport        // #F26419 - Primary brand color
AppColors.orangeSportHover   // #D94F0F - Hover state
AppColors.orangeSportActive  // #C0430D - Active/pressed state

AppColors.deepSea           // #00063D - Secondary brand color
AppColors.deepSeaLight      // #1A1F5C - Light variant
AppColors.deepSeaLighter    // #2A2F6C - Lighter variant
```

### Button Colors

```dart
AppColors.buttonSecondary       // #6B7280
AppColors.buttonDanger          // #DC2626
AppColors.buttonSuccess         // #16A34A
```

### Status Colors

```dart
AppColors.statusActive          // #22C55E - Green
AppColors.statusCancelled       // #EF4444 - Red
AppColors.statusCompleted       // #3B82F6 - Blue
```

## Components

### Buttons

The `AppButton` widget provides a consistent button design with multiple variants and sizes.

#### Basic Usage

```dart
AppButton(
  text: 'Click Me',
  onPressed: () {
    // Handle button press
  },
)
```

#### Variants

```dart
// Primary (default)
AppButton(
  text: 'Primary',
  variant: ButtonVariant.primary,
  onPressed: () {},
)

// Secondary
AppButton(
  text: 'Secondary',
  variant: ButtonVariant.secondary,
  onPressed: () {},
)

// Outline
AppButton(
  text: 'Outline',
  variant: ButtonVariant.outline,
  onPressed: () {},
)

// Danger
AppButton(
  text: 'Delete',
  variant: ButtonVariant.danger,
  onPressed: () {},
)

// Success
AppButton(
  text: 'Confirm',
  variant: ButtonVariant.success,
  onPressed: () {},
)
```

#### Sizes

```dart
// Small
AppButton(
  text: 'Small',
  size: ButtonSize.small,
  onPressed: () {},
)

// Medium (default)
AppButton(
  text: 'Medium',
  size: ButtonSize.medium,
  onPressed: () {},
)

// Large
AppButton(
  text: 'Large',
  size: ButtonSize.large,
  onPressed: () {},
)
```

#### Full Width

```dart
AppButton(
  text: 'Full Width Button',
  isFullWidth: true,
  onPressed: () {},
)
```

#### With Icon

```dart
AppButton(
  text: 'Add Item',
  icon: const Icon(Icons.add, color: Colors.white),
  onPressed: () {},
)
```

#### Loading State

```dart
AppButton(
  text: 'Submit',
  isLoading: true,
  onPressed: () {},
)
```

### Chips

The `AppChip` widget provides selectable/filterable chip components.

#### Basic Usage

```dart
AppChip(
  label: 'Basketball',
  onTap: () {
    // Handle chip tap
  },
)
```

#### Variants

```dart
// Primary (bold bordered)
AppChip(
  label: 'Primary',
  variant: ChipVariant.primary,
  onTap: () {},
)

// Secondary (subtle)
AppChip(
  label: 'Secondary',
  variant: ChipVariant.secondary,
  onTap: () {},
)

// Filled
AppChip(
  label: 'Filled',
  variant: ChipVariant.filled,
  onTap: () {},
)
```

#### States

```dart
// Active state
AppChip(
  label: 'Selected',
  isActive: true,
  onTap: () {},
)

// Disabled state
AppChip(
  label: 'Disabled',
  isDisabled: true,
  onTap: () {},
)
```

#### With Delete

```dart
AppChip(
  label: 'Removable',
  onTap: () {},
  onDelete: () {
    // Handle delete
  },
)
```

### Cards

The `DeepSeaCard` widget provides a dark-themed card with hover effects.

#### Basic Usage

```dart
DeepSeaCard(
  body: const Text('Card content goes here'),
)
```

#### With Header and Footer

```dart
DeepSeaCard(
  header: const Text('Event Details'),
  body: const Text('Join us for an exciting basketball match!'),
  footer: Row(
    children: [
      AppButton(
        text: 'Join',
        size: ButtonSize.small,
        onPressed: () {},
      ),
    ],
  ),
)
```

#### Clickable Card

```dart
DeepSeaCard(
  body: const Text('Tap me'),
  onTap: () {
    // Handle card tap
  },
)
```

### Text Fields

The `AppTextField` widget provides styled text input fields.

#### Basic Usage

```dart
AppTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
)
```

#### Password Field

```dart
AppTextField(
  label: 'Password',
  hint: 'Enter your password',
  obscureText: true,
  controller: passwordController,
)
```

#### With Error

```dart
AppTextField(
  label: 'Username',
  hint: 'Enter username',
  errorText: 'Username is required',
  controller: usernameController,
)
```

#### Multiline

```dart
AppTextField(
  label: 'Description',
  hint: 'Enter description',
  maxLines: 5,
  controller: descriptionController,
)
```

### Status Badges

The `StatusBadge` widget displays event or item status.

#### Usage

```dart
// Active status
StatusBadge(status: StatusType.active)

// Cancelled status
StatusBadge(status: StatusType.cancelled)

// Completed status
StatusBadge(status: StatusType.completed)

// Custom label
StatusBadge(
  status: StatusType.active,
  customLabel: 'ONGOING',
)
```

### Toasts

The `ToastUtils` class provides toast notifications.

#### Usage

```dart
// Success toast
ToastUtils.showSuccess(context, 'Operation successful!');

// Error toast
ToastUtils.showError(context, 'Something went wrong!');

// Warning toast
ToastUtils.showWarning(context, 'Please check your input.');

// Info toast
ToastUtils.showInfo(context, 'This is an informational message.');

// Custom toast
ToastUtils.showToast(
  context,
  message: 'Custom message',
  type: ToastType.success,
  duration: const Duration(seconds: 5),
);
```

## Theme

The app theme is configured in `lib/app/app_theme.dart` and applied in `main.dart`.

### Using Theme in main.dart

```dart
import 'package:bond_up_mobile/app/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

### Accessing Theme Colors

```dart
// Using AppColors directly
Container(
  color: AppColors.orangeSport,
)

// Using theme
Container(
  color: Theme.of(context).colorScheme.primary,
)
```

## Examples

See `lib/core/widgets/examples/design_system_demo.dart` for a complete demo of all components.

To view the demo, navigate to the DesignSystemDemo widget:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DesignSystemDemo(),
  ),
);
```

## Design System Mapping

This Flutter design system maps to the CSS classes as follows:

| CSS Class | Flutter Widget | Notes |
|-----------|---------------|-------|
| `.btn` | `AppButton` | Base button styles |
| `.btn-primary` | `ButtonVariant.primary` | Primary button |
| `.btn-secondary` | `ButtonVariant.secondary` | Secondary button |
| `.btn-outline` | `ButtonVariant.outline` | Outline button |
| `.btn-danger` | `ButtonVariant.danger` | Danger button |
| `.btn-success` | `ButtonVariant.success` | Success button |
| `.btn-sm` | `ButtonSize.small` | Small button |
| `.btn-md` | `ButtonSize.medium` | Medium button |
| `.btn-lg` | `ButtonSize.large` | Large button |
| `.chip` | `AppChip` | Base chip styles |
| `.chip-primary` | `ChipVariant.primary` | Primary chip |
| `.chip-secondary` | `ChipVariant.secondary` | Secondary chip |
| `.chip-filled` | `ChipVariant.filled` | Filled chip |
| `.card-deep-sea` | `DeepSeaCard` | Deep sea themed card |
| `.status-badge` | `StatusBadge` | Status badge |
| `.input-group` | `AppTextField` | Text input field |
| `.toast-*` | `ToastUtils` | Toast notifications |

## Best Practices

1. **Always use design system components** instead of creating custom styled widgets
2. **Use AppColors** for consistent color usage across the app
3. **Follow the size variants** (small, medium, large) for consistency
4. **Use appropriate button variants** based on action importance
5. **Show feedback** using toasts for user actions
6. **Maintain accessibility** by providing proper labels and hints

## Contributing

When adding new components to the design system:

1. Follow the existing naming conventions
2. Add comprehensive documentation
3. Update this README with usage examples
4. Add the component to `design_system_demo.dart`
5. Ensure consistency with the CSS design system