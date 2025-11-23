# Company Management and Role-Based Access Control Implementation Summary

## Overview
This document describes the implementation of Company Management for Owner role and role-based access control for Owner, Manager, and Sales Representative roles in the mobile app.

## Backend Endpoints Connected

### Company Management Endpoints (Owner Only)

1. **GET `/api/accounts/company/employees/`** - Get current company employees
   - **Used in**: `StaffService.getStaff()`
   - **Returns**: Array of employee objects with `id`, `full_name`, `email`, `role`, `company`
   - **Access**: Owner only

2. **GET `/api/accounts/company/unassigned/`** - Get unassigned users available to assign
   - **Used in**: `StaffService.getUnassignedUsers()`
   - **Returns**: Array of user objects (Managers and Sales Representatives not assigned to any company)
   - **Access**: Owner only

3. **POST `/api/accounts/company/assign/`** - Assign user to company
   - **Used in**: `StaffService.addStaff()`
   - **Request Body**: `{ "user_id": integer }`
   - **Note**: Backend uses the user's existing role (manager or sales), not from request body
   - **Access**: Owner only
   - **Returns**: `{ "detail": "Employee assigned successfully" }`

4. **POST `/api/accounts/company/remove/`** - Remove employee from company
   - **Used in**: `StaffService.removeStaff()`
   - **Request Body**: `{ "user_id": integer }`
   - **Access**: Owner only
   - **Returns**: `{ "detail": "Employee removed successfully" }`

## Role-Based Access Control

### Owner
**Full Access + Company Management**
- ✅ My Catalog
- ✅ Products (Catalog Management)
- ✅ Order Management
- ✅ **Company Management** (exclusive to Owner)
- ✅ Chats
- ✅ Complaints Management
- Can assign Managers and Sales Representatives to company
- Can remove any staff member
- Can resolve/reject escalated complaints

### Manager
**All Abilities Except Company Management**
- ✅ My Catalog
- ✅ Products (Catalog Management)
- ✅ Order Management
- ❌ Company Management (not visible)
- ✅ Chats
- ✅ Complaints Management
- **Important**: Actions are invisible to consumers until assigned to company by Owner
- Can resolve/reject escalated complaints

### Sales Representative
**Limited Access: Orders, Chat, Complaints Only**
- ❌ My Catalog (not visible)
- ❌ Products (not visible)
- ✅ Order Management
- ❌ Company Management (not visible)
- ✅ Chats
- ✅ Complaints Management
- **Important**: Cannot see orders/chat/complaints from consumers until assigned to company by Owner
- Can resolve/reject/escalate pending complaints
- When complaint is escalated, it moves from Sales Rep to Manager/Owner

## Complaint Escalation Flow

1. **Consumer creates complaint** → Goes to Sales Representative of the company
2. **Sales Rep sees complaint** in Complaints Management (pending status)
3. **Sales Rep can**:
   - Resolve complaint
   - Reject complaint
   - **Escalate complaint** to Manager/Owner
4. **When escalated**:
   - Complaint status changes to "escalated"
   - Complaint disappears from Sales Rep's view
   - Complaint appears in Manager and Owner's Complaints Management
5. **Manager/Owner can**:
   - Resolve escalated complaint
   - Reject escalated complaint

## Mobile App Implementation

### Company Management Screen

**File**: `mobile/lib/screens/company_management_screen.dart`

**Features**:
- Two-column layout matching website design
- **Current Employees** panel (left):
  - Shows all employees assigned to company
  - Displays: Name, Email, Role badge
  - "Remove" button for each employee
- **Available to Assign** panel (right):
  - Shows Managers and Sales Representatives not assigned to any company
  - Displays: Name, Email, Role badge
  - "Assign to Company" button for each user
- Refresh button to reload data
- Owner-only access (redirects if not Owner)

**UI Elements**:
- Header with "Company Management" title and "Refresh" button
- Two side-by-side white cards
- Employee cards with name, email, role badge, and action button
- Color-coded role badges (Owner: Purple, Manager: Blue, Sales: Green)
- Action buttons: Green "Assign to Company", Red "Remove"

**Colors** (matching website):
- Background: Light grey (`#F5F5F5`)
- Cards: White
- Primary actions: Dark blue (`#1E3A8A`)
- Assign button: Green
- Remove button: Red
- Role badges: Purple (Owner), Blue (Manager), Green (Sales)

### Supplier Dashboard Updates

**File**: `mobile/lib/screens/supplier_dashboard.dart`

**Role-Based Quick Actions**:
- **Owner/Manager**: My Catalog, Products, Order Management, Company Management (Owner only), Chats, Complaints
- **Sales Rep**: Order Management, Chats, Complaints only

### Complaints Management Updates

**File**: `mobile/lib/screens/complaints_management_screen.dart`

**Escalation Feature**:
- Added "Escalate" button for Sales Rep on pending complaints
- Button appears alongside "Resolve" and "Reject" buttons
- When escalated, complaint moves to Manager/Owner view
- Manager/Owner can resolve/reject escalated complaints

**Button Layout**:
- "Open Chat" button (full width, top)
- Action buttons row below (Resolve, Reject, Escalate for Sales Rep)

## Data Models

### StaffMember Model
**File**: `mobile/lib/models/staff_member.dart`

**Fields**:
- `id`: String
- `supplierId`: String (company ID)
- `email`: String
- `name`: String (from backend `full_name`)
- `role`: String ('owner', 'manager', 'sales')
- `phone`: String?
- `isActive`: bool
- `createdAt`: DateTime
- `updatedAt`: DateTime?

**Note**: Backend UserSerializer returns `full_name` instead of `name`, so the model handles both.

## Navigation Flow

### Owner Flow
1. Dashboard → "Company Management" → `CompanyManagementScreen`
2. View Current Employees and Available to Assign
3. Click "Assign to Company" → User assigned, lists refresh
4. Click "Remove" → Employee removed, lists refresh

### Manager Flow
1. Dashboard → No "Company Management" button (not visible)
2. Can access: My Catalog, Products, Order Management, Chats, Complaints
3. Actions are invisible to consumers until Owner assigns Manager to company

### Sales Rep Flow
1. Dashboard → Limited quick actions (Order Management, Chats, Complaints)
2. Cannot access: My Catalog, Products, Company Management
3. Cannot see orders/chat/complaints until Owner assigns Sales Rep to company
4. In Complaints Management:
   - Can resolve/reject/escalate pending complaints
   - When escalated, complaint moves to Manager/Owner

## Company Assignment Impact

### Before Assignment (Manager/Sales Rep)
- **Manager**: Can add products, but consumers won't see them (no company association)
- **Sales Rep**: Cannot see orders, chat, or complaints from consumers
- Both roles are essentially "inactive" until assigned

### After Assignment (Manager/Sales Rep)
- **Manager**: Products become visible to consumers (associated with company)
- **Sales Rep**: Can see and handle orders, chat, and complaints from consumers
- Both roles become fully functional

## Backend Behavior

The backend handles most of the role-based filtering:
- If Manager/Sales Rep is not assigned to a company (`user.company == None`), backend won't return data for them
- Products created by unassigned Manager won't be associated with a company
- Orders/complaints won't be visible to unassigned Sales Rep
- Company assignment is handled server-side, ensuring data integrity

## Error Handling

- Loading states during API calls
- Error messages displayed if operations fail
- Confirmation dialogs for destructive actions (Remove)
- Success messages after successful operations
- Owner-only access enforced (redirects if not Owner)

## Future Enhancements (Not Implemented)

- Bulk assign/remove operations
- Role change functionality
- Employee activity tracking
- Company settings management



