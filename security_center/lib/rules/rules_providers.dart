import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:security_center/services/snapd_rules_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'rules_providers.g.dart';

@riverpod
Future<List<SnapdRule>> rules(RulesRef ref) =>
    getService<RulesService>().getRules();

@riverpod
Future<List<String>> interfaces(InterfacesRef ref) async {
  final rules = await ref.watch(rulesProvider.future);
  return rules.map((rule) => rule.interface).toSet().toList();
}

@riverpod
Future<Map<String, int>> snapRuleCounts(
  SnapRuleCountsRef ref, {
  required String interface,
}) async {
  final rules = await ref.watch(rulesProvider.future);
  return rules.fold<Map<String, int>>(
    {},
    (counts, rule) {
      if (rule.interface == interface) {
        counts[rule.snap] = (counts[rule.snap] ?? 0) + 1;
      }
      return counts;
    },
  );
}

@riverpod
class SnapRulesModel extends _$SnapRulesModel {
  @override
  Future<List<SnapdRule>> build({
    required String snap,
    required String interface,
  }) async {
    final rules = await ref.watch(rulesProvider.future);
    return rules
        .where((rule) => rule.snap == snap && rule.interface == interface)
        .toList();
  }

  Future<void> removeRule(String id) async {
    final service = getService<RulesService>();
    await service.removeRule(id);
    ref.invalidate(rulesProvider);
  }

  Future<void> removeAll() async {
    final service = getService<RulesService>();
    await service.removeAllRules(
      snap: snap,
      interface: interface,
    );
    ref.invalidate(rulesProvider);
  }
}
