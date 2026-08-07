import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Chinese (`zh`) strings for shadcn_flutter calendar / form / menus.
///
/// Upstream only ships English; place this delegate *before*
/// [ShadcnLocalizations.delegate] so `zh` resolves here.
class AppLocalizationsZh extends ShadcnLocalizations {
  AppLocalizationsZh([super.locale = 'zh']);

  static const LocalizationsDelegate<ShadcnLocalizations> delegate =
      _AppLocalizationsZhDelegate();

  @override
  String get formNotEmpty => '此字段不能为空';

  @override
  String get invalidValue => '无效的值';

  @override
  String get invalidEmail => '无效的邮箱';

  @override
  String get invalidURL => '无效的网址';

  @override
  String formLessThan(double value) => '必须小于 $value';

  @override
  String formGreaterThan(double value) => '必须大于 $value';

  @override
  String formLessThanOrEqualTo(double value) => '必须小于或等于 $value';

  @override
  String get formPhoneNumberInvalid => '电话号码无效';

  @override
  String get formPhoneNumberEmpty => '请输入电话号码';

  @override
  String formGreaterThanOrEqualTo(double value) => '必须大于或等于 $value';

  @override
  String formBetweenInclusively(double min, double max) =>
      '必须在 $min 到 $max 之间（含边界）';

  @override
  String formBetweenExclusively(double min, double max) =>
      '必须在 $min 到 $max 之间（不含边界）';

  @override
  String formLengthLessThan(int value) => '至少需要 $value 个字符';

  @override
  String formLengthGreaterThan(int value) => '最多 $value 个字符';

  @override
  String get formPasswordDigits => '必须包含至少一个数字';

  @override
  String get formPasswordLowercase => '必须包含至少一个小写字母';

  @override
  String get formPasswordUppercase => '必须包含至少一个大写字母';

  @override
  String get formPasswordSpecial => '必须包含至少一个特殊字符';

  @override
  String get commandSearch => '输入命令或搜索…';

  @override
  String get commandEmpty => '未找到结果';

  @override
  String get datePickerSelectYear => '选择年份';

  @override
  String get abbreviatedMonday => '一';

  @override
  String get abbreviatedTuesday => '二';

  @override
  String get abbreviatedWednesday => '三';

  @override
  String get abbreviatedThursday => '四';

  @override
  String get abbreviatedFriday => '五';

  @override
  String get abbreviatedSaturday => '六';

  @override
  String get abbreviatedSunday => '日';

  @override
  String get monthJanuary => '1月';

  @override
  String get monthFebruary => '2月';

  @override
  String get monthMarch => '3月';

  @override
  String get monthApril => '4月';

  @override
  String get monthMay => '5月';

  @override
  String get monthJune => '6月';

  @override
  String get monthJuly => '7月';

  @override
  String get monthAugust => '8月';

  @override
  String get monthSeptember => '9月';

  @override
  String get monthOctober => '10月';

  @override
  String get monthNovember => '11月';

  @override
  String get monthDecember => '12月';

  @override
  String get abbreviatedJanuary => '1月';

  @override
  String get abbreviatedFebruary => '2月';

  @override
  String get abbreviatedMarch => '3月';

  @override
  String get abbreviatedApril => '4月';

  @override
  String get abbreviatedMay => '5月';

  @override
  String get abbreviatedJune => '6月';

  @override
  String get abbreviatedJuly => '7月';

  @override
  String get abbreviatedAugust => '8月';

  @override
  String get abbreviatedSeptember => '9月';

  @override
  String get abbreviatedOctober => '10月';

  @override
  String get abbreviatedNovember => '11月';

  @override
  String get abbreviatedDecember => '12月';

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonSave => '保存';

  @override
  String get timeHour => '时';

  @override
  String get timeMinute => '分';

  @override
  String get timeSecond => '秒';

  @override
  String get timeAM => '上午';

  @override
  String get timePM => '下午';

  @override
  String get colorRed => '红';

  @override
  String get colorGreen => '绿';

  @override
  String get colorBlue => '蓝';

  @override
  String get colorAlpha => '透明';

  @override
  String get colorHue => '色相';

  @override
  String get colorSaturation => '饱和';

  @override
  String get colorValue => '明度';

  @override
  String get colorLightness => '亮度';

  @override
  String get menuCut => '剪切';

  @override
  String get menuCopy => '复制';

  @override
  String get menuPaste => '粘贴';

  @override
  String get menuSelectAll => '全选';

  @override
  String get menuUndo => '撤销';

  @override
  String get menuRedo => '重做';

  @override
  String get menuDelete => '删除';

  @override
  String get menuShare => '分享';

  @override
  String get menuSearchWeb => '联网搜索';

  @override
  String get menuLiveTextInput => '实时文本输入';

  @override
  String get placeholderDatePicker => '请选择日期';

  @override
  String get placeholderTimePicker => '请选择时间';

  @override
  String get placeholderColorPicker => '请选择颜色';

  @override
  String get buttonPrevious => '上一页';

  @override
  String get buttonNext => '下一页';

  @override
  String get refreshTriggerPull => '下拉刷新';

  @override
  String get refreshTriggerRelease => '松开刷新';

  @override
  String get refreshTriggerRefreshing => '正在刷新…';

  @override
  String get refreshTriggerComplete => '刷新完成';

  @override
  String get colorPickerTabRecent => '最近';

  @override
  String get colorPickerTabRGB => 'RGB';

  @override
  String get colorPickerTabHSV => 'HSV';

  @override
  String get colorPickerTabHSL => 'HSL';

  @override
  String get colorPickerTabHEX => 'HEX';

  @override
  String get commandMoveUp => '上移';

  @override
  String get commandMoveDown => '下移';

  @override
  String get commandActivate => '选择';

  @override
  String dataTableSelectedRows(int count, int total) => '已选择 $count / $total 行';

  @override
  String get dataTableNext => '下一页';

  @override
  String get dataTablePrevious => '上一页';

  @override
  String get dataTableColumns => '列';

  @override
  String get timeDaysAbbreviation => '天';

  @override
  String get timeHoursAbbreviation => '时';

  @override
  String get timeMinutesAbbreviation => '分';

  @override
  String get timeSecondsAbbreviation => '秒';

  @override
  String get placeholderDurationPicker => '请选择时长';

  @override
  String get durationDay => '天';

  @override
  String get durationHour => '小时';

  @override
  String get durationMinute => '分钟';

  @override
  String get durationSecond => '秒';
}

class _AppLocalizationsZhDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const _AppLocalizationsZhDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'zh';

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    return SynchronousFuture<ShadcnLocalizations>(AppLocalizationsZh());
  }

  @override
  bool shouldReload(_AppLocalizationsZhDelegate old) => false;
}
