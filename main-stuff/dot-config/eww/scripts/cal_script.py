#!/usr/bin/env python3
import calendar
from datetime import datetime

def get_calendar():
    cal = calendar.TextCalendar(calendar.SUNDAY)
    now = datetime.now()
    year, month, today = now.year, now.month, now.day

    # Standard "cal" header: Month Year
    header = f"{calendar.month_name[month]} {year}".center(20)
    # Standard "cal" week header
    days_header = "Su Mo Tu We Th Fr Sa"
    output = [header, days_header]

    for week in cal.monthdayscalendar(year, month):
        line_cells = []
        for day in week:
            if day == 0:
                # 2 spaces + 1 trailing space = 3 chars
                line_cells.append("  ")
            elif day == today:
                # Highlight today with brackets
                # If day is single digit: [4] (3 chars)
                # If day is double digit: [14] (4 chars)
                # To maintain alignment, we use 3 chars for everything else.
                # If today is double digit, it WILL push things.
                # Let's use a smarter padding.
                line_cells.append(f"[{day}]")
            else:
                # Regular day: " 4" or "14" (2 chars)
                line_cells.append(f"{day:2}")
        
        # We need each column to start at a fixed position: 0, 3, 6, 9, 12, 15, 18
        line = ""
        for i, cell in enumerate(line_cells):
            target_pos = i * 3
            # Add padding to reach the next target position
            current_len = len(line)
            if current_len < target_pos:
                line += " " * (target_pos - current_len)
            line += cell
            
        output.append(line.rstrip())

    return "\n".join(output)

if __name__ == "__main__":
    print(get_calendar())
