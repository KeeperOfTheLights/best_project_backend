# Complaints Feature Implementation Summary

## Overview
This document describes the implementation of the complaints feature for both consumers and suppliers in the mobile app, matching the website design and functionality.

## Backend Endpoints Connected

### Consumer Endpoints

1. **GET `/api/accounts/complaints/my/`** - Get consumer's complaints
   - **Used in**: `ComplaintService.getComplaints()` when `userRole == UserRole.consumer`
   - **Returns**: Array of complaint objects
   - **Fields**: `id`, `order`, `consumer`, `consumer_name`, `supplier`, `supplier_name`, `title`, `description`, `status`, `created_at`, `resolved_at`

2. **POST `/api/accounts/complaints/{order_id}/create/`** - Create a new complaint
   - **Used in**: `ComplaintService.createComplaint()`
   - **Request Body**: `{ "title": string, "description": string }`
   - **Note**: `order_id` is passed in the URL path, not in the body

### Supplier Endpoints

1. **GET `/api/accounts/complaints/supplier/`** - Get supplier's complaints
   - **Used in**: `ComplaintService.getComplaints()` when `userRole != UserRole.consumer`
   - **Returns**: Array of complaint objects
   - **Fields**: Same as consumer endpoint

2. **POST `/api/accounts/complaints/{id}/resolve/`** - Resolve a complaint
   - **Used in**: `ComplaintService.resolveComplaint()`
   - **Request Body**: None (empty POST request)
   - **Returns**: `{ "detail": "Complaint resolved" }`

3. **POST `/api/accounts/complaints/{id}/reject/`** - Reject a complaint
   - **Used in**: `ComplaintService.rejectComplaint()`
   - **Request Body**: None (empty POST request)
   - **Returns**: `{ "detail": "Complaint rejected" }`

4. **POST `/api/accounts/complaints/{id}/escalate/`** - Escalate a complaint (NOT IMPLEMENTED IN UI)
   - **Used in**: `ComplaintService.escalateComplaint()` (backend support exists, but UI button not added per user request)
   - **Request Body**: None (empty POST request)
   - **Returns**: `{ "detail": "Complaint escalated" }`

## Mobile App Implementation

### Consumer Side - "My Complaints" Screen

**File**: `mobile/lib/screens/view_complaints_screen.dart`

**Features**:
- View all complaints with filter tabs (All, Pending, Resolved, Rejected, Escalated)
- Create new complaint with order selector
- Open chat with supplier from complaint card
- Color-coded status badges
- Order details preview when selecting order for complaint

**UI Elements**:
- Header with "My Complaints" title and "New Complaint" button
- Collapsible complaint form with:
  - Order dropdown selector
  - Order details preview (Supplier name, Total)
  - Complaint title input
  - Description textarea
  - Submit/Cancel buttons
- Filter tabs showing counts
- Complaint cards with:
  - Title and status badge
  - Supplier name
  - Order ID
  - Description
  - Created date
  - "Open Chat" button

**Colors** (matching website):
- Primary: `#61DAFB` (light blue)
- Background: `#F5F5F5` (light grey)
- Status colors:
  - Pending: Orange
  - Resolved: Green
  - Rejected: Red
  - Escalated: Purple

### Supplier Side - "Complaints Management" Screen

**File**: `mobile/lib/screens/complaints_management_screen.dart`

**Features**:
- View all complaints with filter tabs
- Summary cards showing counts (Pending, Resolved, Rejected for sales; Escalated for managers)
- Resolve/Reject complaints (for pending complaints)
- Open chat with consumer from complaint card
- Refresh button to reload complaints
- **Note**: Escalate button is NOT implemented per user request

**UI Elements**:
- Header with "Complaints Management" title, subtitle, and "Refresh" button
- Summary cards (for sales role):
  - Pending count with hourglass icon
  - Resolved count with checkmark icon
  - Rejected count with X icon
- Summary card (for manager role):
  - Escalated count with trending icon
- Filter tabs (All, Pending, Resolved, Rejected for sales; All, Escalated for managers)
- Complaint cards with:
  - Title and status badge
  - Consumer name
  - Order ID
  - Description
  - Created date
  - Action buttons:
    - "Open Chat" (always visible)
    - "Resolve" (only for pending complaints)
    - "Reject" (only for pending complaints)

**Colors** (matching website):
- Same as consumer side
- Action button colors:
  - Open Chat: Light blue (`#61DAFB`)
  - Resolve: Green
  - Reject: Red

## Data Models

### Complaint Model
**File**: `mobile/lib/models/complaint.dart`

**Fields**:
- `id`: String
- `orderId`: String (from backend `order` field)
- `consumerId`: String (from backend `consumer` field)
- `supplierId`: String (from backend `supplier` field)
- `title`: String
- `description`: String
- `status`: String ('pending', 'resolved', 'rejected', 'escalated')
- `createdAt`: DateTime (from backend `created_at`)
- `resolvedAt`: DateTime? (from backend `resolved_at`)
- `consumerName`: String? (from backend `consumer_name`)
- `supplierName`: String? (from backend `supplier_name`)

**Note**: The backend serializer returns `consumer_name` and `supplier_name` as read-only fields, which are used for display in the UI.

## Navigation Flow

### Consumer Flow
1. Dashboard → "Complaints" → `ViewComplaintsScreen`
2. Click "New Complaint" → Form appears
3. Select order → Order details preview
4. Fill title and description → Submit
5. Click "Open Chat" on complaint card → Navigate to `ChatRoomScreen` with supplier

### Supplier Flow
1. Dashboard → "Complaints" → `ComplaintsManagementScreen`
2. View summary cards and filter tabs
3. Click "Open Chat" on complaint card → Navigate to `ChatRoomScreen` with consumer
4. Click "Resolve" or "Reject" → Status updates, complaints list refreshes

## Integration with Chat Feature

Both screens integrate with the chat feature:
- **Consumer**: Opens chat with supplier using `supplierId` from complaint
- **Supplier**: Opens chat with consumer using `consumerId` from complaint

The chat screen is navigated to with:
- `chatRoomId`: Partner's ID (supplier ID for consumer, consumer ID for supplier)
- `otherPartyName`: Partner's name (supplier name or consumer name)
- `otherPartyType`: 'Supplier' or 'Consumer'

## Status Management

### Complaint Statuses
- **pending**: Initial status when complaint is created
- **resolved**: When supplier resolves the complaint
- **rejected**: When supplier rejects the complaint
- **escalated**: When sales escalates to manager (not implemented in UI)

### Status Updates
After resolving or rejecting a complaint, the app:
1. Calls the backend endpoint
2. Reloads the complaints list to get updated data
3. Shows success/error message to user

## Error Handling

- Loading states shown during API calls
- Error messages displayed if API calls fail
- Retry buttons available on error screens
- Form validation for complaint creation

## Future Enhancements (Not Implemented)

- Escalate button for sales role (backend support exists, but UI not added per user request)
- Image/file attachments for complaints
- Complaint resolution notes/feedback
- Push notifications for new complaints



