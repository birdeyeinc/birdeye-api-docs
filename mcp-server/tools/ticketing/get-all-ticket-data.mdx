---
title: "Get All Ticket Data"
description: "Retrieve tickets for the business with comprehensive filtering and pagination."
---

```
get_all_ticket_data
```

## Description

Returns tickets from Birdeye's ticketing system with support for filtering by assignee, location, source type, status, tags, and ticket type. Assignee email addresses are automatically redacted from responses.

## Parameters

### Required

| Parameter | Type | Format | Description |
|---|---|---|---|
| `fromDate` | integer | Epoch milliseconds | Start of the date range |
| `toDate` | integer | Epoch milliseconds | End of the date range |

### Pagination & Sorting

| Parameter | Type | Default | Description |
|---|---|---|---|
| `sIndex` | integer | `0` | Start index for pagination |
| `count` | integer | `25` | Number of tickets to return |
| `sortBy` | integer | `2` | Sort field: `2` = creation date, `3` = business alias |
| `sortOrder` | integer | `1` | Sort direction: `0` = ascending, `1` = descending |
| `totalCount` | boolean | `false` | Include total count in response |
| `op` | integer | `3` | Operation: `1` = count only, `3` = full data |

### Filters

| Parameter | Type | Description |
|---|---|---|
| `assignees` | list[string] | Filter by assignee name or ID |
| `businessNumbers` | list[integer] | Scope to specific location IDs |
| `sourceAliases` | list[string] | Filter by source alias |
| `sourceTypes` | list[string] | Filter by source type: `"phone"`, `"socialmedia"`, `"chat"`, `"internal"` |
| `tagNames` | list[string] | Filter by ticket tags |
| `ticketStatuses` | list[string] | Filter by ticket status |
| `ticketTypes` | list[string] | Filter by ticket type: `"review"`, `"survey"`, `"untagged"` |

## Example Usage

```
Show me all open tickets from the last 7 days.
```

```
How many review tickets were created in June 2026?
```

```
List all unresolved chat tickets assigned to the support team.
```

## Response Fields

Each ticket includes:

| Field | Description |
|---|---|
| `id` | Unique ticket ID |
| `status` | Ticket status |
| `rating` | Associated rating (for review-type tickets) |
| `description` | Ticket content or summary |
| `activityCount` | Number of activities/comments on the ticket |
| `assignedTo` | `{ firstName, lastName, name }` — email is redacted |
| `source` | `{ name }` — source channel name |
| `ticketType` | `"review"`, `"survey"`, or `"untagged"` |
| `tags` | List of tag names |
| `reporter` | `{ firstName, lastName }` — email is redacted |

## Notes

- Dates must be provided as **epoch milliseconds**. Example: `1750896000000` = June 26, 2026 00:00:00 UTC.
- Use `op: 1` to get just the count before fetching full data — useful for large date ranges.
- Assignee and reporter `emailId` fields are automatically stripped for privacy.
