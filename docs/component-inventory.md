# shadcn_flutter 组件转换清单

基线版本：`shadcn_flutter 0.0.53`  
更新日期：2026-07-25

## 口径

该版本 README 声明“84 components”，但 Components Library 区域实际展示 57 项。
本项目将这 57 项与源码公开导出的 27 项补充能力合并为当前 84 项转换基线。升级时以
新版本公开导出和文档差异为准，不把 84 当作永久不变的数量。

状态：`完成` 表示已有 App 公共入口；`增强中` 表示已有可用入口但产品层能力仍需补齐；
`待转换` 表示尚未提供 App 公共入口。

## README 展示的 57 项

| 分类 | 上游组件 | App API | 状态 |
| --- | --- | --- | --- |
| Animation | AnimatedValueBuilder | AppAnimatedValueBuilder | 完成 |
| Animation | Number Ticker | AppNumberTicker | 完成 |
| Animation | RepeatedAnimationBuilder | AppRepeatedAnimationBuilder | 完成 |
| Disclosure | Accordion | AppAccordion | 完成 |
| Disclosure | Collapsible | AppCollapsible | 完成 |
| Feedback | Alert | AppAlert / AppAlert.destructive | 完成 |
| Feedback | Alert Dialog | AppAlertDialog / AppDialog.show | 完成 |
| Feedback | Circular Progress | AppCircularProgressIndicator | 完成 |
| Feedback | Progress Bar | AppProgress | 完成 |
| Feedback | Skeleton | AppSkeleton | 完成 |
| Feedback | Toast | AppToast.show/custom | 完成 |
| Forms | Button | AppButton.xxx / AppAsyncAction / AppButtonConfig | 完成 |
| Forms | Checkbox | AppCheckbox / AppCheckboxFormField | 完成 |
| Forms | Chip Input | AppChipInput / AppChipInputFormField | 完成 |
| Forms | Color Picker | AppColorPicker / AppColorInputFormField | 完成 |
| Forms | Date Picker | AppDatePicker / AppDatePicker.range / AppDatePickerFormField | 完成 |
| Forms | Form | AppForm / AppFormController / AppFormErrorSummary | 完成 |
| Forms | Input | AppInput / AppTextFormField | 完成 |
| Forms | Input OTP | AppInputOtp / AppInputOtpFormField | 完成 |
| Forms | Phone Input | AppPhoneInput / AppPhoneInputFormField | 完成 |
| Forms | Radio Group | AppRadioGroup / AppRadioGroupFormField | 完成 |
| Forms | Select | AppSelect / AppSelectFormField.async/source | 完成 |
| Forms | Slider | AppSlider / AppSliderFormField | 完成 |
| Forms | Star Rating | AppStarRating / AppStarRatingFormField | 完成 |
| Forms | Switch | AppSwitch / AppSwitchFormField | 完成 |
| Forms | Text Area | AppTextArea / AppTextAreaFormField | 完成 |
| Forms | Time Picker | AppTimePicker / AppTimePickerFormField | 完成 |
| Forms | Toggle | AppToggle / AppToggleFormField | 完成 |
| Layout | Card | AppCard | 完成 |
| Layout | Carousel | AppCarousel | 完成 |
| Layout | Divider | AppDivider | 完成 |
| Layout | Resizable | AppResizable / AppResizablePanel | 完成 |
| Layout | Stepper | AppStepper | 完成 |
| Layout | Steps | AppSteps | 完成 |
| Layout | Timeline | AppTimeline | 完成 |
| Navigation | Breadcrumb | AppBreadcrumb | 完成 |
| Navigation | Menubar | AppMenubar | 已完成 |
| Navigation | Navigation Menu | AppNavigationMenu | 已完成 |
| Navigation | Pagination | AppPagination | 完成 |
| Navigation | Tabs | AppTabs | 完成 |
| Navigation | Tab List | AppTabList | 完成 |
| Navigation | Tree | AppTree | 完成 |
| Surfaces | Dialog | AppDialog.show | 完成 |
| Surfaces | Drawer | AppDrawer.show | 完成 |
| Surfaces | Hover Card | AppHoverCard | 完成 |
| Surfaces | Popover | AppPopover.show | 完成 |
| Surfaces | Sheet | AppSheet.show | 完成 |
| Surfaces | Tooltip | AppTooltip | 完成 |
| Data Display | Avatar | AppAvatar | 完成 |
| Data Display | Avatar Group | AppAvatarGroup | 完成 |
| Data Display | Code Snippet | AppCodeSnippet | 完成 |
| Data Display | Tracker | AppTracker | 完成 |
| Utilities | Badge | AppBadge.xxx | 完成 |
| Utilities | Calendar | AppCalendar | 完成 |
| Utilities | Command | AppCommand | 已完成 |
| Utilities | Context Menu | AppContextMenu | 已完成 |
| Utilities | Dropdown Menu | AppDropdownMenu | 已完成 |

## 源码公开导出的 27 项补充能力

| 上游组件 | App API | 状态 |
| --- | --- | --- |
| Async | AppAsyncView | 已完成 |
| Chat | AppChat | 已完成 |
| Chip | AppChip / AppChipButton | 完成 |
| Dot Indicator | AppDotIndicator | 完成 |
| Keyboard Shortcut | AppKeyboardDisplay | 完成 |
| Linear Progress | AppLinearProgressIndicator | 完成 |
| Pinned Sheet | AppPinnedSheet | 已完成 |
| AutoComplete | AppAutoCompleteFormField.async/source/paged | 完成 |
| Formatted Input | AppFormattedInput / AppFormattedInputFormField | 完成 |
| Image Input | AppImageInput / AppImageInputFormField | 完成 |
| Sortable Input | AppSortableInput / AppSortableInputFormField | 完成 |
| Object Input | AppObjectInput / AppObjectInputFormField | 完成 |
| Item Picker | AppItemPicker / AppItemPickerFormField | 完成 |
| Multiple Choice | AppMultipleChoice / AppMultipleChoiceFormField | 完成 |
| Text Field | AppTextFormField / AppTextFormField.email/password | 完成 |
| Backdrop Transform | AppBackdropTransform / AppScaleBackdropTransform | 完成 |
| Refresh Trigger | AppRefreshTrigger | 完成 |
| Swiper | AppSwiper | 完成 |
| Navigation Bar | AppNavigationBar | 已完成 |
| Switcher | AppSwitcher | 完成 |
| Window | AppWindow | 已完成 |
| Table | AppTable | 完成 |
| Scaffold | AppScaffold | 完成 |
| Overflow Marquee | AppOverflowMarquee | 完成 |
| Scrollbar | AppScrollbar / AppScrollbarView | 完成 |
| Selectable Text | AppSelectableText | 完成 |
| Color Input | AppColorInput / AppColorInputFormField | 完成 |
