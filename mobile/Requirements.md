Supplier–Consumer Platform (SCP) Mobile Application
1. Introduction

The SCP Mobile App connects Consumers (restaurants, hotels) with Suppliers (food product companies).
The app enables authentication, supplier–consumer linking, catalog browsing, chat communication, and order processing.

The app must support two user roles:

Consumer

Supplier

Owner

Manager

Sales Representative

Each role has specific permissions and features.

2. High-Level Features

Authentication

Role-based Dashboards

Supplier–Consumer Link Requests

Catalog Browsing & Item Management

Shopping Cart & Order Creation

Order Management

Real-time or Async Chat

Staff Management (Supplier only)

Complaints Management

Profile & Settings

General App Behavior (error handling, UI, storage, etc.)

3. Feature Details
3.1 Authentication
3.1.1 Sign Up

User selects role: Consumer or Supplier

Required fields:

Email, Password, Name

Consumer extra fields:

Business name, Address, Phone

Supplier extra fields:

Company name, Company type, Address, Phone

Sends data to backend → receives token → saves token → goes to dashboard

3.1.2 Login

Inputs: Email + Password

Validates against backend

Saves token + role

Redirects to correct dashboard

3.1.3 Logout

Clear token and cached data

Redirect to login

3.2 Dashboards (Role-Based)
3.2.1 Consumer Dashboard

Shows:

Linked suppliers (approved/pending)

Quick actions: Search Suppliers, View Catalogs, My Orders, Chats

If user has no approved suppliers → show message:
“Send a link request to view catalog.”

3.2.2 Supplier Dashboard

Shows:

Pending link requests (Owner/Manager)

New orders

Open complaints

Quick actions:

Catalog, Orders, Link Requests, Chats, Staff (role-based)

3.3 Supplier–Consumer Linking
3.3.1 Search Suppliers (Consumer)

Search by supplier name

View supplier info

Button: Send Link Request

3.3.2 Manage Links (Consumer)

Sections: Pending, Approved, Rejected

For Approved:

Open Catalog

Open Chat

Create Order

3.3.3 Manage Link Requests (Supplier)

View pending requests

Approve / Reject

Approved → consumer gains catalog access

Rejected → no access

3.4 Catalog & Item Management
3.4.1 Consumer Catalog Browsing

Only available if link is Approved

Features:

Search items

Filter by category

View item details

Add to cart with quantity selection

3.4.2 Supplier Catalog Management (Owner/Manager only)

Add new item

Edit item

Update price/stock

Delete item

Item Fields:

Name

Description

Category

Unit (kg/box/etc.)

Price

Stock quantity

Active/Inactive

3.5 Shopping Cart & Order Creation (Consumer)
3.5.1 Cart

Items grouped by supplier

Change quantity

Remove items

Price summary

3.5.2 Checkout

Select delivery/pickup

Add comment

View total

Submit order → backend creates order

3.6 Order Management
3.6.1 Consumer

View all orders

Order details (items, price, status)

Order statuses:

Pending

Accepted

Rejected

In Delivery

Completed

Button: Open Chat

Button: Create Complaint

3.6.2 Supplier (Owner/Manager/Sales)

See all incoming orders

Order details (customer, items, totals)

Actions:

Accept order

Reject order (with optional reason)

Update status (In Delivery, Completed)

3.7 Chat (Both Roles)
3.7.1 Chat List

Shows suppliers (for Consumer)

Shows consumers (for Supplier)

Last message preview

Unread message counter

3.7.2 Chat Room

Simple two-way chat

Text messages

Support for images/files (optional)

When accessed from Order:

Automatically link messages to order context

3.8 Staff Management (Supplier only)
Access Control

Owner:

Add Manager

Add Sales

Remove any staff

Manager:

Add Sales

Manage Sales

Sales:

No staff management

Features

Staff list (roles + status)

Buttons:

Add Staff

Edit Staff

Deactivate/Remove

3.9 Complaints Management
3.9.1 Consumer

Create complaint:

Select order

Select item (optional)

Type of issue

Description

Attach photos

View complaint status

3.9.2 Supplier

Sales sees complaints from assigned consumers

Manager sees escalated complaints

Actions:

Mark in progress

Resolve

Escalate (Sales → Manager)

3.10 Profile & Settings

View/edit profile

Role display

Company info (for suppliers)

Language selection (optional)

Logout

4. Technical Features
4.1 Local Storage

Save token securely

Save user role

Save minimal cached data

4.2 API Communication

All calls use REST API

Auth header:

Authorization: Bearer <token>

4.3 Error Handling

No internet → “Connection error” screen

Server errors → toast/dialog

Validation errors → under field + inline error

4.4 UI/UX Requirements

Modern, clean UI

Works on Android phones + small tablets

Bottom navigation for core sections

5. Feature Priority Order (Recommended)
Phase 1 – Core

Authentication (signup + login)

Consumer dashboard

Supplier dashboard

Supplier–Consumer link system

Phase 2 – Marketplace

Consumer catalog browsing

Shopping cart

Create order

Phase 3 – Supplier tools

Supplier item management

Supplier order management

Phase 4 – Communication

Chat (Consumer ↔ Supplier)

Phase 5 – Advanced

Staff management (owner/manager)

Complaints system

Profile & Settings

6. Completion Criteria

The app is considered “feature-complete” when:

All above features are implemented

Both Consumers and Suppliers can:

Authenticate

Link to each other

Browse/add items

Place and accept orders

Chat

Manage complaints

UI is functional and responsive

Errors are properly handled