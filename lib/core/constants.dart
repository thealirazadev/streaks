/// App-wide constants shared across features.
library;

/// Minimum accepted length for a trimmed habit name.
const int habitNameMinLength = 1;

/// Maximum accepted length for a trimmed habit name.
const int habitNameMaxLength = 80;

/// Schedule bitmask value meaning every weekday is scheduled.
const int everyDayScheduleMask = 0x7F;

/// Number of weekdays in a schedule bitmask.
const int daysPerWeek = 7;
