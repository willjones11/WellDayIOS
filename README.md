# 🍎 Wellday — iOS Health App (Phase 1 MVP)

**Redefining what it means to be healthy.**

Wellday is an iOS app that rewards healthy decisions through a simple, points-based system.  
Instead of counting calories or macros, users earn points by making better meal choices and seeing their progress grow day by day.

---

## 🎯 Goal
Create a lightweight, habit-forming iOS app that:
1. Lets users log meals via **text**, **photo**, **voice**, or **recipe**.  
2. Scores each meal automatically using a **tiered health system**.  
3. Displays a friendly **advisor message**, streak tracker, and daily summary.  
4. Encourages users to **cook their own meals** with recipes that show health and cost insights.  
5. Keeps friction low — no calorie tracking, minimal data entry.

---

## 🧩 Core Features

### 1. **Home Screen**
- Daily **advisor message** (“Great job yesterday! You’re on track for a strong day.”)  
- **Streak counter**, **daily points**, and quick **budget overview**.  
- Simple **analytics tiles**: 7-day trend, macro balance, cost vs. plan.  
- Scrollable list of meals added today — tap for detail.  
- Floating **“Add Meal”** button.

---

### 2. **Add Meal**
- Choose input type: **📸 Photo**, **📝 Text**, **🎙️ Voice**, or **🍽 From Recipe**.  
- Automatic nutrition inference (mocked in MVP).  
- Displays **tier**, **points**, and **tags** such as:  
  `protein_packed`, `fiber_rich`, `high_sodium`, `carb_dense`.  
- Buttons:  
  - “Save to Day” → adds meal and updates daily score.  
  - “Save as Recipe” → optional recipe creation.

---

### 3. **Recipe Hub**
- Tabs:  
  - **Discover** – curated and community recipes.  
  - **My Recipes** – personal uploads.  
  - **+ Add Recipe** – create your own.  
- Recipe cards show: photo (optional), tier, prep time, cost (optional), tags.  
- Add Recipe flow:
  - Minimal input: title + ingredients required.
  - Optional: cost, photo, prep time, diet tags.
  - Automatic analysis → displays tier and health tags.
  - “Save” adds it to user’s collection.

---

### 4. **Profile**
- Simple settings:
  - Health goal (Lose / Maintain / Gain)  
  - Daily food budget (optional)  
  - Dietary preferences  
  - Units (US / metric)

---

### 5. **Advisor System**
- Rule-based text engine that reacts to meal patterns:  
  - “Add a protein source for lunch to stay balanced.”  
  - “Great job staying under budget this week.”  
  - “Sodium trended high recently — consider a lighter dinner.”  
- Always supportive and concise, never punitive.

---

## 🧠 Scoring Framework

| Tier | Health Index Range | Points | Meaning |
|------|--------------------|---------|----------|
| 🥇 Excellent | ≥ 80 | +10 | Clean, balanced meal |
| 🥈 Good | 65–79 | +6 | Generally healthy |
| ⚪ Neutral | 50–64 | +3 | Mixed quality |
| 🟠 Needs Improvement | 35–49 | +0 | Processed or high sodium |
| 🔴 Poor | < 35 | −3 | Unhealthy meal |

Users earn a **2-point bonus** if they log at least 3 meals in a day.

---

## 🧰 Technology

| Layer | Toolset |
|--------|----------|
| **App Framework** | React Native (Expo SDK 51) |
| **Language** | TypeScript |
| **Platform Target** | iOS 16 + |
| **API** | Node.js + Express (TypeScript) |
| **Database** | PostgreSQL (via Prisma ORM) |
| **Auth** | JWT (email + password) |
| **AI/Nutrition Analysis** | Mocked functions, ready for API plug-in |
| **State Management** | Zustand |

---

## 🗺️ App Flow

Wellday/
  WelldayApp.swift
  Models/
    Meal.swift
    Recipe.swift
    UserProfile.swift
  Services/
    Store.swift
    AnalyzeService.swift
    AdvisorService.swift
    MockData.swift
  ViewModels/
    HomeVM.swift
    AddMealVM.swift
    RecipesVM.swift
    ProfileVM.swift
  Views/
    HomeView.swift
    AddMealView.swift
    RecipeHubView.swift
    RecipeDetailView.swift
    AddRecipeView.swift
    ProfileView.swift
  Components/
    TierBadge.swift
    Chip.swift
    Tile.swift
    MealRow.swift
