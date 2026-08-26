# Checklist Design — home_manager index

Trimmed from Checklist Design v3.2.1 for **home_manager** (Flutter Web PWA +
iOS, mobile-first). Marketing websites, e-commerce, chat, maps, billing,
paywalls, and other out-of-scope surfaces were removed.

Find the checklist(s) matching the screen under review, then read the matching
file in `references/checklists/` for its full items. The file name is given in
backticks after each name.

Prefer **Mobile app** when reviewing iPhone / Home Screen PWA. Use **Web app**
when the same surface is open in Chrome desktop, or when only a Web app
checklist exists (Empty State, Single Item Detail).

## home_manager mapping

| Surface | Checklist |
|---------|-----------|
| Sign in (Google) | Login (Mobile) or Login (Web app) |
| First home / empty homes | Onboarding (Mobile) |
| Tổng quan | Dashboard (Mobile) |
| Kỳ điện/nước chi tiết | Single Item Detail (Web app) |
| Empty lists (no periods, expenses, …) | Empty State (Web app) |
| Bottom nav | Tab Bar Navigation (Mobile) |
| Quick-add, home picker, select/date sheets | Action Sheet (Mobile) |
| Thông báo | In-App Notifications (Mobile) |
| Cá nhân / tài khoản | Account (Mobile) |
| Cài đặt (nhà, lịch, giao diện, bảo mật) | Settings (Mobile) |
| Thành viên + join QR | Invite (Mobile) |
| Ảnh hoá đơn / biên lai | Camera (Mobile) + Uploading media |
| Forms (điện, nước, chi tiêu, thu nhập, nhà) | Submitting a form, Showing input error, Saving changes |
| Lọc lịch sử kỳ / thông báo | Filtering items |
| iOS launch | Splash Screen (Mobile) |
| Shared widgets | Design system (Card, Button, Input, Toast, …) |

## Design system

- **Typography** `design-system-typography.md` — The type layer of a design system that defines a scale, hierarchy, and set of text styles that is consistent, accessible, and expressive across the full range of product contexts
- **Accessibility** `design-system-accessibility.md` — The accessibility foundation of a design system including the standards, tooling, and shared conventions that ensure every component and pattern is built inclusively from the start.
- **Date Picker** `design-system-date-picker.md`
- **Spacing / Grid** `design-system-spacing-and-grid.md` — The spatial layer of a design system, defining a consistent scale for spacing, a grid for layout, and the rules that make both feel deliberate and coherent across all surfaces.
- **Alert** `design-system-alert.md`
- **Color System** `design-system-color-system.md` — The color layer of a design system — defining a palette that is purposeful, accessible, themeable, and expressed as tokens rather than raw values.
- **Tokens** `design-system-tokens.md` — The layer of a design system where defined variables are outlined across the platform to enable consistency, theming and alignment with code.
- **Skeleton** `design-system-skeleton.md` — A skeleton is a placeholder that mimics the structure of content while it loads. It provides visual feedback that content is coming and reduces perceived wait time.
- **Banner** `design-system-banner.md` — A banner is a prominent notification item that displays important messages to users. It communicates things like errors, success confirmations, warnings, or general information using distinct colors and placement to stand out from regular page content and grab attention.
- **Toast** `design-system-toast.md` — A toast is a brief, non-disruptive message that appears temporarily at the edge of the screen to provide feedback about an action or system status.
- **Tabs** `design-system-tabs.md` — Tabs are navigation elements that organize and separate content into different sections within the same view. They allow users to switch between related content, maintaining context while reducing clutter.
- **Radio** `design-system-radio.md` — A radio button is an interactive control that allows users to select exactly one option from a predefined set of mutually exclusive choices. Unlike checkboxes, when one radio button is selected, all others in the same group are automatically deselected.
- **Modal** `design-system-modal.md` — A modal is a dialog box or popup window that appears on top of the main content, requiring user attention or interaction before returning to the main interface. It creates a focused experience by temporarily disabling the underlying page and dimming the background.
- **Loading** `design-system-loading.md` — A loading indicator is a visual element that communicates to users that content or an action is being processed. It provides feedback through animations like spinning wheels, progress bars, or skeleton screens to maintain user engagement during wait times.
- **Toggle** `design-system-toggle.md` — A toggle is a switch-like control that allows users to quickly alternate between two opposing states (on/off) with a single click or tap.
- **Input Field** `design-system-input-field.md` — An input field is an interactive area where users can enter and edit text or data. It provides a clear visual container for user input, often accompanied by labels and validation feedback, making it essential for forms and data collection interfaces.
- **Icon** `design-system-icon.md` — An icon is a small, symbolic visual element that represents an action, feature, or concept. It's purpose is to communicate meaning quickly, save space, and enhance visual navigation across an interface.
- **Card** `design-system-card.md` — A card is a contained, modular component that groups related information and actions. It displays content like text, images, and interactive elements within a distinct container, often with shadows or borders to create visual hierarchy and organization in layouts.
- **Button** `design-system-button.md` — A button is an interactive element that triggers an action when clicked or tapped. It clearly communicates its clickability through visual styling and provides feedback on user interaction, making it a fundamental component for enabling user actions in interfaces.
- **Badge** `design-system-badge.md` — A badge is a small visual indicator that displays short, dynamic information like counts or status. It typically appears as a colored circle or pill shape, often overlaid on other elements.
- **Avatar** `design-system-avatar.md` — An avatar is a visual representation of a user. It helps identify individuals across a digital interface, commonly used in user profiles, comment sections, and chat applications.
- **Dropdown Menu** `design-system-dropdown-menu.md` — A dropdown triggered from a button or right-click target to reveal a menu of actions the user can proceed with

## Flows

- **Uploading media** `flows-uploading-media.md`
- **Filtering items** `flows-filtering-items.md` — Filtering helps users find what they need in large collections by specifying specific values of properties the items contain.
- **Saving changes** `flows-saving-changes.md` — Users are constantly updating their details. They might be changing an email address, fixing a typo in their name, or updating their payment details. That's why it's important to confirm that a change has been saved, in the clearest way. Here's a breakdown of how changes being saved should look and feel like.
- **Showing input error** `flows-showing-input-error.md` — Users mistype all the time - whether it's a finger slipping or rushing through letters, errors happen. So for an everyday occurrence, solving an error should be obvious and seamless. The key parts of making that happen are strong visuals, clear communication, and state changes — which are all featured below.
- **Submitting a form** `flows-submitting-a-form.md` — A form can help a user achieve anything from creating an account to subscribing to a newsletter. They are often the last step of a user's journey, so should be quick and easy to complete.

## Mobile app

- **Onboarding** `mobile-onboarding.md` — The first-run experience that orients a new user, collects necessary setup information, and delivers an early sense of the app value
- **Dashboard** `mobile-dashboard.md` — A glanceable summary of what matters most in an app experience, typically with leads that take the user to other specific areas of the app.
- **Settings** `mobile-settings.md` — The screen where users manage their account, preferences, notifications, and app behaviour.
- **Gesture navigation** `mobile-gesture-navigation.md` — The touch-based interaction patterns that let users navigate and act without tapping buttons.
- **Splash Screen** `mobile-splash-screen.md` — The first screen a user sees when launching the mobile app and it initialises before transitioning to the home screen.
- **Action Sheet** `mobile-action-sheet.md` — The sheet that slides up from the bottom of the screen to present options or confirmations — the mobile equivalent of a dropdown menu or modal dialog.
- **Tab Bar Navigation** `mobile-tab-bar-navigation.md` — The persistent bottom navigation bar that gives users access to the top-level sections of the app
- **In-App Notifications** `mobile-in-app-notifications.md` — The in-app feed of alerts, updates, and messages the user has received — distinct from system push notifications.
- **Camera** `mobile-camera-media-capture.md` — Capturing photos, video, or documents as well as reviewing and customising the capture experience for accessing the phone camera within an app.
- **Login** `mobile-login.md` — Everything a returning user needs to authenticate quickly and securely.
- **Account** `mobile-account.md` — Private account settings like credentials, linked accounts, notifications, and destructive actions.
- **Invite** `mobile-invite.md` — The flow for adding collaborators or members to a shared space with role assignment and pending invite management.

## Web app

- **Settings** `web-app-settings.md` — A screen that gives users control over their account, preferences, and application behaviour
- **Single Item Detail** `web-app-single-item-detail.md` — A screen that displays the full details of a single record — a user, order, document, or any other entity — after selecting it from a list.
- **Empty State** `web-app-empty-state.md` — The state of a screen or component when there is no data to display, whether it's because a user is new, has cleared their content, or a search returned no results.
- **Notifications** `web-app-notifications.md` — An area that surfaces alerts, updates, and activity relevant to the user to help them stay informed
- **Onboarding** `web-app-onboarding.md` — A guided experience that introduces new users to the product and gets them to their first moment of value as quickly as possible
- **Account** `web-app-account.md` — Where users view and manage their personal information, preferences, and account-level details
- **Login** `web-app-login.md` — A login page is a critical component of many web applications, serving as the gateway for users to access personalized features, secure content, and their own data

_Bundled content: v3.2.1, 2026-08-20. Catalogue scoped to home_manager._
