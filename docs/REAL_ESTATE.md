# Customer App — Real Estate Integration

This document describes the Real Estate layer in `Customer_app/`, how to
wire the entry point, and the decisions still pending from the master
plan §14.1.

## Files added (8 + 1 widget)

```
lib/app/core/
├── models/real_estate_property_model.dart
│     • PropertyModel (with displayPrice / displayTitle helpers, geo extraction)
│     • LeadModel
│     • LeadActivityEntry
│     • PropertyCategory
│     • formatIndianPrice (lakh / crore)
└── repositories/real_estate_repository.dart
      • 11 methods: listCategories, listFeatured, listRecent, search,
        propertyById, similarProperties, createEnquiry, myLeads,
        leadById, leadActivity, withdrawLead

lib/app/presentation/pages/real_estate/
├── property_search.dart      — Buy/Rent chips, category chips, grid results
├── property_detail.dart      — gallery, specs, verified badge, similar, CTA
├── enquiry_form.dart         — message + optional referral code, creates Lead
├── my_leads.dart             — customer's own enquiries, status badges
├── lead_detail.dart          — status, activity history, withdraw control
└── widgets/
    ├── property_card.dart                — shared full result card (search grid)
    ├── featured_property_card.dart      — compact carousel card (home featured rail)
    ├── real_estate_entry_card.dart      — home-screen entry card (compact banner)
    ├── real_estate_home_section.dart    — featured carousel + categories grid (orchestrator)
    ├── categories_section.dart          — "Browse by category" with subcategory chips + skeleton
    ├── subcategory_picker_sheet.dart    — bottom sheet for subcategory selection
    ├── property_rail_section.dart       — reusable rail (title + horizontal scroller) for all discovery rails
    ├── real_estate_discovery_section.dart — popular / recent / most-enquired / premium / affordable rails
    └── withdraw_dialog.dart             — withdraw reason dialog

### Home page section flow (top to bottom)
1. RealEstateEntryCard — compact banner with live count
2. RealEstateHomeSection
   - Featured properties carousel
   - Browse by category (grouped subcategory grid)
3. RealEstateDiscoverySection (5 rails, each independently loaded)
   - Popular properties        (sortBy=views:desc)
   - Recently added            (sortBy=publishedAt:desc)
   - Most enquired             (sortBy=enquiries:desc)
   - Premium listings          (sortBy=price:desc)
   - Affordable homes          (sortBy=price:asc)

test/real_estate_model_test.dart
      • Pure unit tests for all four model parsers
      • 12 assertions covering full / partial / edge-case JSON shapes
```

## Modified files (3)

```
lib/app/core/config/api_endpoints.dart
      • +12 endpoint getters under V1Request

lib/app/router/app_route_config.dart
      • +5 route constants: reSearchRoute, rePropertyDetailRoute,
        reEnquiryRoute, reLeadsRoute, reLeadDetailRoute
      • +5 switch cases wired to the new screens

lib/app/l10n/app_{en,hi,ar,es}.arb
      • +31 keys × 4 locales = 124 strings
      • Pattern: re_*  (re_search_title, re_withdraw, re_my_enquiries, …)
```

## Entry point — two options, still a business-owner decision (plan §14.1)

### Option A — add as a 6th bottom-nav tab

Edit `lib/app/presentation/pages/tabs/tabs_view.dart`:
- `TabController(length: 6)` → `length: 7`
- `TabBarView.children` add a 7th widget
- Wire the entry to navigate to `reSearchRoute`

The plan marks six tabs as the ceiling (we're already at 6), so this
option pushes past it. Mitigation: hide the food-cart bar on real
estate screens (it only fires for `state.summary.isNotEmpty`).

### Option B — vertical picker / home entry (recommended, no-tab impact)

**Status: wired, expanded.** The real estate section on the home page
is now two siblings:
1. `RealEstateEntryCard` — a compact tappable banner that opens the
   search screen. Embedded inside the categories `Column`, so it shows
   only when the user has a city set (matches the food rhythm).
2. `RealEstateHomeSection` — featured-properties carousel + a
   "Browse by category" grid with subcategory chips. Always rendered
   as a direct child of the home `Column` (not gated on food categories),
   so the real estate surface is discoverable even before the user
   picks a location.

Tapping a subcategory chip opens the search screen pre-filtered to
that key. Tapping the group header opens a bottom sheet with the full
list. Tapping a featured card opens the detail screen.

## Backend surface used

| Method | Endpoint |
|---|---|
| GET | `/v1/realestate/public/categories` |
| GET | `/v1/realestate/public/properties` |
| GET | `/v1/realestate/public/properties/featured` |
| GET | `/v1/realestate/public/properties/recent` |
| GET | `/v1/realestate/public/properties/:id` |
| GET | `/v1/realestate/public/properties/:id/similar` |
| POST | `/v1/realestate/customer/properties/:id/enquiry` |
| GET | `/v1/realestate/customer/leads` |
| GET | `/v1/realestate/customer/leads/:id` |
| GET | `/v1/realestate/customer/leads/:id/activity` |
| PATCH | `/v1/realestate/customer/leads/:id/withdraw` |

The dio interceptor (`api_request_service.dart`) attaches the customer
token to authenticated calls automatically — no per-call auth wiring.

## Local development

```bash
cd Customer_app
flutter pub get
flutter analyze                  # all green
flutter test test/real_estate_model_test.dart
```

For end-to-end smoke testing against a running backend:

```dart
// scratch_real_estate.dart in a Flutter test
final repo = RealEstateRepository();
print(await (await repo.listFeatured()).length);
```
