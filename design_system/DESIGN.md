---
name: Mausam Precision
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#454652'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#767683'
  outline-variant: '#c6c5d4'
  surface-tint: '#4c56af'
  primary: '#000666'
  on-primary: '#ffffff'
  primary-container: '#1a237e'
  on-primary-container: '#8690ee'
  inverse-primary: '#bdc2ff'
  secondary: '#00639a'
  on-secondary: '#ffffff'
  secondary-container: '#51b2fe'
  on-secondary-container: '#00436a'
  tertiary: '#002104'
  on-tertiary: '#ffffff'
  tertiary-container: '#00390a'
  on-tertiary-container: '#48ab4d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#343d96'
  secondary-fixed: '#cee5ff'
  secondary-fixed-dim: '#96ccff'
  on-secondary-fixed: '#001d32'
  on-secondary-fixed-variant: '#004a75'
  tertiary-fixed: '#94f990'
  tertiary-fixed-dim: '#78dc77'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-temp:
    fontFamily: Inter
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 72px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin: 20px
  widget-gap: 12px
  internal-padding: 16px
---

## Brand & Style

The design system is engineered for the India Meteorological Department (IMD) to provide authoritative, life-saving weather data with absolute clarity. The brand personality is **Institutional, Vigilant, and Accessible**. It balances the gravity of government-grade reporting with the modern efficiency of a high-performance utility.

The visual style is **Corporate Modern** with a focus on high-density information architecture. It utilizes a structured hierarchy where data is prioritized through modularity. The emotional response is one of trust and reliability, ensuring users—from rural farmers to urban commuters—can interpret complex meteorological shifts at a glance.

## Colors

The palette is anchored by **Deep IMD Blue**, signaling authority and the vastness of the atmosphere. 

- **Primary (#1A237E):** Reserved for headers, primary actions, and institutional branding.
- **Marine Blue (#0288D1):** Used for interactive elements, links, and water-related data visualizations.
- **Functional Accents:** Success Green, Warning Orange, and Caution Yellow are used strictly for status-driven data (e.g., severe weather alerts, air quality indices).
- **Surface:** A Pure White base is used for maximum contrast, supported by a light neutral grey for background layering and secondary card containers.

## Typography

This design system utilizes **Inter** for its exceptional legibility and neutral, systematic tone. The type scale is optimized for high-density data legibility across a wide age demographic.

- **Numerical Priority:** Large temperature readings use `display-temp` with slight negative letter-spacing to ensure the primary data point is unavoidable.
- **Clarity:** Use `body-lg` for critical weather descriptions and `label-caps` for secondary data categories (e.g., "HUMIDITY", "WIND SPEED").
- **Accessibility:** Line heights are generous to prevent visual crowding in data-heavy widgets.

## Layout & Spacing

This design system employs a **Fluid Grid** model optimized for mobile-first consumption. 

- **Grid Model:** A 4-column grid for mobile, scaling to 8-columns for tablets. 
- **Rhythm:** An 8px base unit governs all spatial relationships. 
- **Safe Zones:** A 20px horizontal margin ensures content does not touch device edges. 
- **Modularity:** Content is organized into "Widgets" that occupy 100% or 50% of the available width, allowing for a flexible, dashboard-like reflow on larger screens.

## Elevation & Depth

Depth is used sparingly to maintain a clean, professional appearance. 

- **Tonal Layers:** The primary background is `#F5F5F5`. Elevated content sits on Pure White cards.
- **Shadows:** Use extra-diffused, low-opacity shadows (e.g., `box-shadow: 0 4px 12px rgba(26, 35, 126, 0.08)`) to create soft separation without adding visual weight.
- **Interactive States:** Buttons and cards use a subtle "lift" effect (increased shadow) when active, providing tactile feedback for touch interactions.

## Shapes

The shape language is defined by **Rounded (0.5rem / 8px)** corners for standard UI components like buttons and inputs. 

- **Cards:** For modular data widgets, use `rounded-lg` (16px) or `rounded-xl` (24px) to soften the information-heavy layout and create a modern, friendly container feel.
- **Consistency:** All stroke-based icons should use rounded terminals to match the container geometry.

## Components

- **Buttons:** Primary buttons use the Deep IMD Blue with white text. Floating Action Buttons (FABs) for "Report Weather" use the Marine Blue.
- **Weather Cards:** Large-format cards (24px radius) containing current conditions. Secondary cards for 7-day forecasts should use a 16px radius.
- **Alert Chips:** High-contrast status indicators. Severe weather alerts use `Warning Orange` backgrounds with black text for maximum visibility.
- **Input Fields:** Outlined style with 1px borders in a soft neutral grey. On focus, the border transitions to Deep IMD Blue.
- **Data Widgets:** Modular units containing a line-icon, a label, and a data point (e.g., "Visibility | 5km").
- **Iconography:** Thin-to-medium weight line icons. Use `Marine Blue` for standard weather icons and `Warning Orange` for hazardous weather icons.