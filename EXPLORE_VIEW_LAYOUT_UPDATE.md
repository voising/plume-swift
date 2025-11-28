# Explore View Layout Update

## Overview
Completely rewrote the ExploreView to match the exact layout and functionality from the React Native journaling app reference.

## Changes Made

### 1. Created WordCloudView Component
**File**: `plume/Views/Explore/WordCloudView.swift`

A comprehensive word cloud visualization with:
- **Word frequency analysis** - Analyzes all entry text (journal, memory, gratitudes, accomplishments)
- **Smart word filtering** - Excludes common stop words (the, and, is, etc.)
- **Visual scaling** - Word size and opacity reflect frequency
- **Custom flexible layout** - Words wrap naturally using a custom SwiftUI Layout
- **Empty state** - Shows helpful message when no content available
- **Minimum word length** - Filters out words shorter than 3 characters
- **Randomized positioning** - Words shuffled for visual variety

**Word Cloud Algorithm:**
1. Extract text from all entry fields
2. Tokenize and clean words (remove punctuation)
3. Filter by minimum length (3 chars) and exclude common words
4. Count frequency of each word
5. Sort by frequency, take top 30
6. Calculate weight (normalized 0-1 scale)
7. Randomize order for display
8. Render with size/opacity based on weight

### 2. Completely Redesigned ExploreView
**File**: `plume/Views/Explore/ExploreView.swift`

**New Layout Structure:**

1. **Header Section**
   - Title: "Explore Your Journey"
   - Random motivational quote

2. **Statistics Dashboard**
   - 5 stat cards showing:
     - Total Entries
     - Gratitudes count
     - Memories count
     - Achievements count
     - Average words per journal
   - **Responsive:** Horizontal scroll on iPhone, grid on iPad
   - Each card shows emoji, large value, and label

3. **Word Cloud**
   - Visual representation of most frequent words
   - Only shown when entries exist
   - Updates based on filtered entries

4. **Time Period Filter**
   - 4 date range options:
     - All Time
     - Last Week
     - Last Month
     - Last 3 Months
   - **Responsive:** Horizontal row on iPad, vertical stack on iPhone
   - Active filter highlighted with primary color

5. **Content Filters**
   - Filter by content type:
     - All (default)
     - Gratitude
     - Memories
     - Achievements
     - Journal
   - **Responsive:** Horizontal row with spacer on iPad, horizontal scroll on iPhone
   - Active filter highlighted

6. **Sort Control**
   - Click to cycle through:
     - Newest (date descending)
     - Oldest (date ascending)
     - Content (by word count)
   - Icon changes based on sort type

7. **Results Count**
   - Shows number of filtered entries
   - Updates dynamically

8. **Entry Cards Grid**
   - **2-column grid on iPad**, 1-column on iPhone
   - Each card shows:
     - **Header:** Date, time ago, content badges
     - **Content sections:** Only shows filled fields
     - Gratitudes, Memory, Accomplishments, Journal
   - Cards have subtle shadows and borders
   - Content limited to 2-3 lines with ellipsis

9. **Floating Copy Button**
   - Bottom overlay button
   - Copies all filtered entries to clipboard
   - Format: Markdown-friendly text
   - Shows count of entries being copied
   - Cross-platform (NSPasteboard/UIPasteboard)

10. **Empty State**
    - Shows when no entries match filter
    - Magnifying glass icon
    - Helpful message

## Key Features Matching React Native Reference

### Filtering System
✅ Content type filtering (All, Gratitude, Memory, Accomplishments, Journal)
✅ Date range filtering (All Time, Last Week, Last Month, Last 3 Months)
✅ Combined filtering (date AND content)
✅ Dynamic results count

### Sorting Options
✅ Date descending (Newest first)
✅ Date ascending (Oldest first)
✅ Content length (Most words first)

### Statistics
✅ Total entries count
✅ Total gratitudes count
✅ Memories with content count
✅ Total accomplishments count
✅ Average words per journal

### Visual Components
✅ Word cloud with frequency visualization
✅ Stat cards with emojis
✅ Entry cards with content badges
✅ Responsive layouts (iPad vs iPhone)
✅ Smooth animations with spring physics

### Data Management
✅ Clipboard export functionality
✅ Time-ago formatting (e.g., "2 days ago")
✅ Proper date formatting
✅ Efficient filtering and sorting

## Technical Implementation

### Enums for Type Safety
```swift
enum FilterType: String, CaseIterable
enum SortType: String, CaseIterable
enum DateFilterType: String, CaseIterable
```

### Computed Properties
- `dateFilteredEntries` - Entries filtered by time period
- `filteredEntries` - Entries filtered by both date and content type, then sorted
- `statistics` - Dynamically calculated statistics based on filtered entries

### Responsive Design
- Uses GeometryReader to detect iPad vs iPhone
- Different layouts:
  - iPad: 2-column entry cards, horizontal stat cards, horizontal filters
  - iPhone: 1-column entry cards, horizontal scroll stats, scroll filters
- Max content width: 1200pt on iPad

### Animations
- Spring animations (response: 0.3, damping: 0.7)
- Smooth transitions for filter/sort changes
- Button press feedback

### Data Structures
- `StatCard` - Reusable statistics card
- `EntryCard` - Displays entry with dynamic sections
- `WordCloudItem` - Represents a word with frequency data
- `FlexibleWordCloudLayout` - Custom SwiftUI Layout for word wrapping

## Improvements Over Previous Version

**Before:**
- Simple search bar
- 3 static stat cards
- Heatmap chart
- Pie chart breakdown
- Basic search results

**After:**
- Comprehensive filtering (content + date)
- 5 dynamic stat cards
- Word cloud visualization
- Time period selection
- Sorting options
- 2-column grid on iPad
- Entry cards with previews
- Clipboard export
- Empty states
- Responsive layouts

## Build Status

✅ Project builds successfully
✅ No compilation errors
✅ All Swift syntax valid
✅ Compatible with existing codebase
✅ Cross-platform clipboard support (iOS/macOS)

## Testing Recommendations

1. **Filtering**
   - Test all content filters (All, Gratitude, Memory, Accomplishments, Journal)
   - Test date range filters
   - Verify combined filtering works
   - Check empty states when no matches

2. **Sorting**
   - Verify Newest/Oldest/Content sort
   - Check sort persists through filter changes
   - Test cycling through sort options

3. **Statistics**
   - Verify counts match actual data
   - Test average calculation
   - Check statistics update with filters

4. **Word Cloud**
   - Verify words appear from entries
   - Check frequency weighting (size/opacity)
   - Test with various entry counts
   - Verify empty state

5. **Responsive**
   - Test iPad horizontal layouts
   - Test iPhone vertical/scroll layouts
   - Verify 2-column grid on iPad
   - Check stat card scrolling on iPhone

6. **Clipboard**
   - Test copy button
   - Verify formatted output
   - Check special characters handling
   - Test on both iOS and macOS

## Files Modified
- `plume/Views/Explore/ExploreView.swift` (completely rewritten)

## Files Created
- `plume/Views/Explore/WordCloudView.swift` (new component)

## Design Consistency

All components follow the existing design system:
- Uses `AppColors` for theming
- Follows spacing and border radius conventions
- Proper shadows and overlays
- Typography hierarchy maintained
- Warm off-black aesthetic preserved
- Spring animations for interactions
