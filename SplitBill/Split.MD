---

## 📝 Product Requirements Document (PRD)

**Product Name**: FairSplit
**Purpose**: Simple, fair expense splitting for any shared activity
**Owner**: Reza
**Last Updated**: July 14, 2025

---

### 1. **Purpose**

FairSplit is a tool that allows users to split any shared expenses—regardless of activity type (e.g., sports, food, travel, gifts, subscriptions)—among multiple participants. It ensures all costs are split fairly, with automatic rounding up of fractional shares.

---

### 2. **Problem Statement**

When people engage in shared activities (sports, group dinners, trips, etc.), managing and splitting the cost accurately and fairly is often a manual and error-prone process. People want a fast and flexible way to divide total expenses across participants — without dealing with decimals or math.

---

### 3. **Goals & Objectives**

* Allow users to create a shared session for any activity.
* Enable input of multiple expense items with descriptions and amounts.
* Dynamically set participant counts and optionally participant names.
* Automatically calculate equal shares with **round-up of decimal values**.
* Handle overages (due to rounding) transparently.
* Export or share final split amounts easily.

---

### 4. **User Stories**

#### 4.1 As a user,

* I want to create a session (e.g., “Badminton Night”, “Birthday Dinner”, “Netflix Share”).
* I want to add one or more expenses with labels (e.g., "Shuttlecock", "Cake", "1-month Subscription").
* I want to set the number of participants or list their names.
* I want the app to divide the total cost by participant count, rounding up if needed.
* I want to see the exact per-person cost and total overage (if any).
* I want to copy or export the result to share with others.

---

### 5. **Key Features**

#### 5.1 Session Creation

* Title (e.g., “Badminton @ July 14” or “Office Pizza”)
* Optional category/tag (e.g., Sports, Food, Subscription)

#### 5.2 Expense Input

* Add item:

  * Description (e.g., “Court fee”, “Pizza”)
  * Amount (e.g., 50,000)
* Add as many items as needed

#### 5.3 Participant Setup

* Number of participants (required)
* Optional: enter names (used for personalized sharing)

#### 5.4 Calculation Logic

* Total cost = sum of all items
* Raw share = `Total cost / participant count`
* Final share = **round up to nearest integer (or configurable rounding policy)**
* If total collected > actual cost, show:

  * Total overpaid
  * Optionally: suggest storing for next session or logging as tip/buffer

#### 5.5 Sharing & Export

* Copy/paste summary
* Export to text, WhatsApp format, or PDF
* Optionally: create a payment request or QR code (GoPay, Dana, etc.)

---

### 6. **Example**

**Session**: Badminton Night
**Participants**: 10
**Expenses**:

* Court: 60,000
* Shuttlecock: 40,000
  **Total**: 100,000
  **Raw share**: 10,000
  **Rounded per-person**: 10,000 (no change needed)

Another case:
**Total**: 101,000
**Raw share**: 10,100
**Rounded per-person**: **10,100** (no decimals, OK)
If raw share was 10,134.5 → round up to **10,135**

---

### 7. **Constraints**

* Rounding mode: must be clear (round **up**, not to nearest)
* No support for unequal splits (MVP)
* App/web must work offline-friendly (optional, stretch goal)

---

### 8. **Stretch Goals**

* Assign expenses to specific people
* Partial payments
* Debt tracking
* Group membership (repeated activities)
* Local currency support

---

Let me know if you'd like this PRD turned into a Figma wireframe, API design spec, or a working prototype.
