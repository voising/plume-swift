# Today View Layout Update

## Overview
Updated the TodayHeroView to match the exact layout from the React Native journaling app reference.

## Changes Made

### 1. Created New FieldCard Component
**File**: `plume/Views/Shared/FieldCard.swift`

A collapsible card component for entry fields with:
- Expandable/collapsible behavior
- Header with icon, label, and completion indicator
- Automatic expansion when field has content or is focused
- Collapses when empty and loses focus
- Smooth animations using Spring physics
- Visual feedback with scale animation when completed

### 2. Completely Redesigned TodayHeroView
**File**: `plume/Views/Entry/TodayHeroView.swift`

**New Layout Structure:**
1. **Header Section** (centered)
   - Full date display (e.g., "Wednesday, November 27, 2024")
   - Motivational quote below the date
   - Clean, centered alignment

2. **Journal Card** (full-width, prominent)
   - Large, prominent card at the top
   - Icon and "Journal" label
   - Preview/Edit toggle button (appears when journal has content)
   - Minimum height of 200pt on iPad, 120pt on iPhone
   - Tap to enter Zen Mode functionality
   - Markdown preview support

3. **Three Field Cards Row**
   - **Gratitude** (heart icon)
   - **Memory** (sparkles icon)
   - **Accomplishments** (trophy icon)

   **Responsive Layout:**
   - iPad: Horizontal row (3 cards side-by-side)
   - iPhone: Vertical stack (3 cards stacked)
   - Cards initially expanded on iPad, collapsed on iPhone
   - Each card collapses/expands independently

**Responsive Design:**
- Max content width: 900pt on iPad, 800pt on iPhone
- Responsive padding: 24pt on iPad, 20pt on iPhone
- Font sizes adjusted per device
- Proper spacing and alignment for both orientations

### 3. Updated QuoteService
**File**: `plume/Services/QuoteService.swift`

Added:
- `motivationalQuotes` array with short inspirational quotes
- `randomMotivationalQuote()` method that returns a random motivational quote string

The motivational quotes are shorter and more focused than the full quotes, matching the React Native app's design.

## Key Features

### Layout Matching React Native Reference
✅ Header with date and motivational quote
✅ Large journal card with preview toggle
✅ Three collapsible field cards
✅ Horizontal layout on iPad, vertical on iPhone
✅ Responsive spacing and sizing
✅ Same field order (Journal → Gratitude, Memory, Accomplishments)

### Improvements
- Smooth collapse/expand animations
- Visual completion indicators (checkmark badges)
- Clean, minimalist card design
- Proper iPad/iPhone responsive behavior
- Zen mode integration maintained
- Data bindings work seamlessly with Entry model

## Design System Consistency

All components follow the existing design system:
- Uses `AppColors` for consistent theming
- Follows spacing and border radius conventions
- Maintains the warm off-black aesthetic
- Proper shadows and overlays
- Typography hierarchy maintained

## Build Status

✅ Project builds successfully
✅ No compilation errors
✅ All Swift syntax valid
✅ Compatible with existing codebase

## Testing Recommendations

1. **iPad Testing**
   - Verify three cards display in horizontal row
   - Check that cards are initially expanded
   - Test journal card takes appropriate space
   - Verify tap-to-zen functionality

2. **iPhone Testing**
   - Verify three cards stack vertically
   - Check that cards are initially collapsed
   - Test expand/collapse animation
   - Verify scrolling behavior

3. **Functional Testing**
   - Test data persistence across all fields
   - Verify markdown preview in journal
   - Test zen mode entry/exit
   - Verify completion indicators appear correctly

## Files Modified
- `plume/Views/Entry/TodayHeroView.swift` (completely rewritten)
- `plume/Services/QuoteService.swift` (added motivational quotes)

## Files Created
- `plume/Views/Shared/FieldCard.swift` (new component)
