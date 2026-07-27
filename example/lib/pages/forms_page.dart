import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  static const _roles = [
    AppOption(value: 'admin', label: 'Administrator'),
    AppOption(value: 'editor', label: 'Editor'),
    AppOption(value: 'viewer', label: 'Viewer'),
  ];

  static final _roleSource = AppAsyncOptionSource<String>(
    loader: (query) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final normalized = query.toLowerCase();
      return _roles
          .where((option) => option.label.toLowerCase().contains(normalized))
          .toList();
    },
  );

  static final _pagedRoleSource = AppAsyncPagedOptionSource<String>(
    loader: (query, cursor) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final offset = cursor as int? ?? 0;
      final filtered = _roles
          .where(
            (option) =>
                option.label.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      final options = filtered.skip(offset).take(2).toList();
      final next = offset + options.length;
      return AppOptionPage(
        options: options,
        nextCursor: next < filtered.length ? next : null,
      );
    },
  );

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _formController = AppFormController(
    crossValidators: [
      (values) => values['password'] == values['confirmation']
          ? const {}
          : const {'confirmation': 'Passwords do not match.'},
    ],
  );
  late final AppAsyncAction<void> _submitAction = _formController
      .createSubmitAction(
        (values) async {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        },
        loadingDelay: const Duration(milliseconds: 120),
        minimumLoadingDuration: const Duration(milliseconds: 250),
      );

  @override
  void dispose() {
    _submitAction.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Forms',
      description: 'Native Form-compatible fields with concise defaults.',
      sections: [
        ComponentSection(
          title: 'Text fields',
          child: AppTextFormField.email(
            label: 'Email',
            description: 'Validation starts after user interaction.',
            required: true,
            hintText: 'name@example.com',
          ),
        ),
        const ComponentSection(
          title: 'Select',
          child: AppSelectFormField<String>(
            label: 'Role',
            options: FormsPage._roles,
            required: true,
          ),
        ),
        ComponentSection(
          title: 'Async autocomplete',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAutoCompleteFormField<String>.source(
                label: 'Assignee',
                optionSource: FormsPage._roleSource,
              ),
              const Gap(12),
              AppAutoCompleteFormField<String>.paged(
                label: 'Paged assignee',
                pagedOptionSource: FormsPage._pagedRoleSource,
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Boolean and choice controls',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCheckboxFormField(
                controlLabel: const Text('Accept terms'),
                validator: (value) => value == true ? null : 'Required.',
              ),
              const Gap(8),
              AppSwitchFormField(
                controlLabel: const Text('Enable notifications'),
              ),
              const Gap(8),
              AppRadioGroupFormField<String>(
                label: 'Density',
                direction: Axis.horizontal,
                options: const [
                  AppOption(value: 'compact', label: 'Compact'),
                  AppOption(value: 'standard', label: 'Standard'),
                  AppOption(value: 'comfortable', label: 'Comfortable'),
                ],
              ),
              const Gap(8),
              AppSliderFormField(
                label: 'Volume',
                initialValue: const SliderValue.single(0.6),
                valueIndicatorBuilder: (context, value) =>
                    SliderValueIndicator(value: value),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Specialized inputs',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextAreaFormField(
                label: 'Notes',
                hintText: 'Add context for the request',
              ),
              const Gap(12),
              AppInputOtpFormField(
                label: 'Verification code',
                length: 6,
                separatorEvery: 3,
                validator: AppValidators.exactLength(6),
              ),
              const Gap(12),
              AppPhoneInputFormField(
                label: 'Phone number',
                searchPlaceholder: const Text('Search country'),
              ),
              const Gap(12),
              AppChipInputFormField<String>(
                label: 'Tags',
                initialValue: const ['flutter', 'desktop'],
                placeholder: const Text('Type a tag and press Enter'),
                maxItems: 5,
              ),
              const Gap(12),
              AppStarRatingFormField(
                label: 'Experience rating',
                initialValue: 4,
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Date and time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDatePickerFormField(label: 'Start date'),
              const Gap(12),
              AppDateRangePickerFormField(label: 'Date range'),
              const Gap(12),
              AppTimePickerFormField(
                label: 'Start time',
                use24HourFormat: true,
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Formatted and visual choices',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormattedInputFormField(
                label: 'Reference code',
                initialValue: AppFormattedValue([
                  AppFormattedParts.fixed('APP-'),
                  AppFormattedParts.editable('', length: 4),
                  AppFormattedParts.fixed('-'),
                  AppFormattedParts.editable('', length: 2),
                ]),
              ),
              const Gap(12),
              AppColorInputFormField(
                label: 'Accent color',
                initialValue: AppColorDerivative.fromColor(
                  const Color(0xff4f46e5),
                ),
              ),
              const Gap(12),
              AppMultipleChoiceFormField<String>(
                label: 'Plan',
                initialValue: 'team',
                options: [
                  AppOption(value: 'personal', label: 'Personal'),
                  AppOption(value: 'team', label: 'Team'),
                  AppOption(value: 'business', label: 'Business'),
                ],
              ),
              const Gap(12),
              AppItemPickerFormField<String>(
                label: 'Workspace icon',
                placeholder: Text('Choose icon'),
                title: Text('Workspace icon'),
                options: [
                  AppOption(value: 'folder', label: 'Folder'),
                  AppOption(value: 'star', label: 'Star'),
                  AppOption(value: 'archive', label: 'Archive'),
                ],
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Media, sortable, and object inputs',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImageInputFormField<String>(
                label: 'Cover image',
                pick: () async => 'asset://workspace-cover',
                previewBuilder: (context, value) =>
                    AppCard(child: Center(child: Text(value))),
              ),
              const Gap(12),
              AppSortableInputFormField<String>(
                label: 'Section order',
                initialValue: const ['Overview', 'Activity', 'Settings'],
                itemBuilder: (context, index, item) => AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('${index + 1}. $item'),
                  ),
                ),
              ),
              const Gap(12),
              AppObjectInputFormField<String>(
                label: 'Short code',
                initialValue: 'APP',
                converter: AppObjectConverter(
                  (value) => [value],
                  (parts) => parts.first,
                ),
                parts: const [AppEditablePart(length: 3, width: 56)],
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Managed async validation',
          child: AppForm(
            controller: _formController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextFormField(
                  name: 'username',
                  label: 'Username',
                  required: true,
                  validator: AppValidators.required(),
                  asyncValidator: (value) async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 600),
                    );
                    return value?.toLowerCase() == 'admin'
                        ? 'This username is reserved.'
                        : null;
                  },
                ),
                const Gap(12),
                AppSelectFormField<String>(
                  name: 'role',
                  label: 'Role',
                  options: FormsPage._roles,
                  validator: (value) => value == null ? 'Choose a role.' : null,
                ),
                const Gap(12),
                AppTextFormField.password(name: 'password', label: 'Password'),
                const Gap(12),
                AppTextFormField.password(
                  name: 'confirmation',
                  label: 'Confirm password',
                ),
                const Gap(8),
                AppFormErrorSummary(controller: _formController),
                const Gap(8),
                AppButton.primary(
                  action: _submitAction,
                  loadingLabel: 'Submitting',
                  child: const Text('Submit form'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
