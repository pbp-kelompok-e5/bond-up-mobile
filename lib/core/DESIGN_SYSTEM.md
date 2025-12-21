# BondUp Design System

This design system is a Flutter implementation of the `.global.css` design system from the Django web application. It ensures visual consistency between the web and mobile applications.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Core Module Structure](#core-module-structure)
- [Color Palette](#color-palette)
- [Components](#components)
- [Constants](#constants)
- [Theme Configuration](#theme-configuration)
- [Design System Mapping](#design-system-mapping)
- [Best Practices](#best-practices)

## Overview

The BondUp core module provides a comprehensive design system that includes:
- **Theme**: Centralized color palette and styling configurations
- **Widgets**: Reusable UI components (buttons, cards, chips, inputs, badges, navigation)
- **Utils**: Helper utilities for toasts and notifications
- **Constants**: Application-wide constants (API config, cities, sports, skill levels)

All components are designed to match the web application's visual language while following Flutter best practices and Material Design 3 guidelines.

## Installation

Import the entire design system (recommended):

```dart
import 'package:bond_up_mobile/core/design_system.dart';
```

Or import specific modules as needed:

```dart
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/core/widgets/buttons/app_button.dart';
import 'package:bond_up_mobile/core/constants/app_constants.dart';
```

## Core Module Structure

```
lib/core/
├── design_system.dart          # Main export file for all components
├── DESIGN_SYSTEM.md           # This documentation
├── constants/
│   ├── api_constants.dart     # API base URL configuration
│   └── app_constants.dart     # Cities, sports, skill levels
├── theme/
│   └── app_colors.dart        # Complete color palette
├── utils/
│   └── toast_utils.dart       # Toast notification utilities
└── widgets/
    ├── badges/
    │   └── status_badge.dart  # Status indicators (active, cancelled, completed)
    ├── buttons/
    │   └── app_button.dart    # Customizable button component
    ├── cards/
    │   └── deep_sea_card.dart # Deep sea themed card component
    ├── chips/
    │   └── app_chip.dart      # Selectable chip component
    ├── inputs/
    │   └── app_text_field.dart # Styled text input field
    └── navigation/
        └── app_drawer.dart    # App-wide navigation drawer
```

## Color Palette

### Brand Colors
The primary brand colors define BondUp's visual identity:

- **Orange Sport** (`#F26419`) - Primary brand color with hover and active states
- **Deep Sea** (`#00063D`) - Secondary brand color with light and lighter variants

### Semantic Colors
Colors organized by purpose for consistent UI feedback:

- **Button Colors**: Secondary (`#6B7280`), Danger (`#DC2626`), Success (`#16A34A`)
- **Status Colors**: Active/Green (`#22C55E`), Cancelled/Red (`#EF4444`), Completed/Blue (`#3B82F6`)
- **Utility Colors**: Gray scale (50-900), white, black, dark gray background

All colors are defined in `lib/core/theme/app_colors.dart` with proper naming conventions and opacity variants.

## Components

### Buttons (`AppButton`)
Customizable button component with multiple variants and sizes.

**Variants**: `primary`, `secondary`, `outline`, `danger`, `success`  
**Sizes**: `small`, `medium`, `large`  
**Features**: Full width option, icon support, loading state, disabled state

See `lib/core/widgets/buttons/app_button.dart` for implementation details.

### Chips (`AppChip`)
Selectable chip component for filters and tags.

**Variants**: `primary`, `secondary`, `filled`  
**States**: Active, disabled  
**Features**: Delete callback, custom styling

See `lib/core/widgets/chips/app_chip.dart` for implementation details.

### Cards (`DeepSeaCard`)
Dark-themed card component with consistent styling.

**Features**: Optional header and footer, tap callback, hover effects, gradient background  
**Styling**: Deep sea gradient, rounded corners, shadow effects

See `lib/core/widgets/cards/deep_sea_card.dart` for implementation details.

### Text Fields (`AppTextField`)
Styled text input component with validation support.

**Features**: Label and hint text, error state, password obscuring, multiline support, custom validation  
**Styling**: Orange sport accent color, consistent border radius

See `lib/core/widgets/inputs/app_text_field.dart` for implementation details.

### Status Badges (`StatusBadge`)
Visual indicators for status display.

**Types**: `active`, `cancelled`, `completed`  
**Features**: Custom label support, color-coded backgrounds

See `lib/core/widgets/badges/status_badge.dart` for implementation details.

### Navigation (`AppDrawer`)
App-wide navigation drawer with user profile integration.

**Features**: User profile display, navigation menu items, logout functionality, gradient background  
**Integration**: Works with authentication service and profile service

See `lib/core/widgets/navigation/app_drawer.dart` for implementation details.

### Toasts (`ToastUtils`)
Toast notification system for user feedback.

**Types**: `success`, `error`, `warning`, `info`  
**Features**: Customizable duration, color-coded by type, auto-dismiss

See `lib/core/utils/toast_utils.dart` for implementation details.

## Constants

### API Constants (`ApiConstants`)
Centralized API configuration for environment management.

**Configuration**: Base URL switching between development and production  
**Environments**: Localhost, Android emulator, iOS simulator, production server

See `lib/core/constants/api_constants.dart` for configuration options.

### App Constants (`AppConstants`)
Application-wide constants synchronized with Django backend.

**City Choices**: 107 Indonesian cities matching Django `CITY_CHOICES`  
**Sport Choices**: 8 sports (Football, Basketball, Badminton, Tennis, Running, Cycling, Swimming, Volleyball)  
**Skill Levels**: Beginner, Intermediate, Advanced

**Helper Methods**: Display name getters, sorted lists for dropdowns

See `lib/core/constants/app_constants.dart` for complete lists and utilities.

## Theme Configuration

The app theme is configured in `lib/app/app_theme.dart` and applied globally in `main.dart`.

**Theme Features**:
- Material Design 3 support
- Custom color scheme based on AppColors
- Consistent typography scale
- Styled input decoration theme
- Card theme with deep sea styling
- AppBar theme with deep sea background

**Usage**: The theme is automatically applied to all widgets. Access theme colors via `Theme.of(context)` or use `AppColors` directly for design system colors.

## Design System Mapping

This Flutter design system maps to the CSS classes from the web application as follows:

| CSS Class | Flutter Component | Description |
|-----------|------------------|-------------|
| `.btn` | `AppButton` | Base button styles |
| `.btn-primary` | `ButtonVariant.primary` | Primary orange button |
| `.btn-secondary` | `ButtonVariant.secondary` | Secondary gray button |
| `.btn-outline` | `ButtonVariant.outline` | Outlined button |
| `.btn-danger` | `ButtonVariant.danger` | Danger/delete button |
| `.btn-success` | `ButtonVariant.success` | Success/confirm button |
| `.btn-sm` | `ButtonSize.small` | Small button size |
| `.btn-md` | `ButtonSize.medium` | Medium button size (default) |
| `.btn-lg` | `ButtonSize.large` | Large button size |
| `.chip` | `AppChip` | Base chip component |
| `.chip-primary` | `ChipVariant.primary` | Primary chip style |
| `.chip-secondary` | `ChipVariant.secondary` | Secondary chip style |
| `.chip-filled` | `ChipVariant.filled` | Filled chip style |
| `.card-deep-sea` | `DeepSeaCard` | Deep sea themed card |
| `.status-badge` | `StatusBadge` | Status indicator badge |
| `.input-group` | `AppTextField` | Text input field |
| `.toast-*` | `ToastUtils` | Toast notifications |

## Best Practices

### Component Usage
1. **Always use design system components** instead of creating custom styled widgets
2. **Import from design_system.dart** for consistency and easier maintenance
3. **Follow the established patterns** when creating new components

### Color Usage
1. **Use AppColors constants** for all color references
2. **Prefer semantic colors** (e.g., `buttonDanger` instead of raw hex values)
3. **Use opacity variants** when available (e.g., `orangeSportWithOpacity(0.5)`)

### Consistency
1. **Follow size variants** (small, medium, large) across all components
2. **Use appropriate button variants** based on action importance and context
3. **Maintain spacing consistency** using standard padding/margin values

### User Feedback
1. **Show toast notifications** for user actions (success, error, warning, info)
2. **Use loading states** for async operations
3. **Provide clear error messages** in form fields

### Accessibility
1. **Provide proper labels** for all input fields
2. **Use semantic colors** that convey meaning
3. **Ensure sufficient contrast** for text readability

### Constants
1. **Use AppConstants** for cities, sports, and skill levels
2. **Never hardcode** values that exist in constants
3. **Keep constants synchronized** with Django backend

### API Configuration
1. **Use ApiConstants.baseUrl** for all API calls
2. **Switch environments** by changing the baseUrl value
3. **Never hardcode** API URLs in feature code

---

**For detailed implementation examples and code, refer to the actual component files in the codebase.**
