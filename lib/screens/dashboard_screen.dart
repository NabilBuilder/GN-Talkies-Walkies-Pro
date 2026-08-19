import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/materiel.dart';
import '../models/site.dart';
import '../models/marche.dart';
import '../di/service_locator.dart';
import '../repositories/i_historique_transfert_repository.dart';
import '../repositories/i_marche_repository.dart';
import '../repositories/i_materiel_repository.dart';
import '../repositories/i_site_repository.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // DI: Injected via GetIt
  final ISiteRepository _siteRepository = getIt<ISiteRepository>();
  // DI: Injected via GetIt
  final IMarcheRepository _marcheRepository = getIt<IMarcheRepository>();
  // DI: Injected via GetIt
  final IMaterielRepository _materielRepository = getIt<IMaterielRepository>();
  // DI: Injected via GetIt
  final IHistoriqueTransfertRepository _transfertRepository = getIt<IHistoriqueTransfertRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Materiel>>(
        stream: _materielRepository.getMateriels(),
        builder: (context, materielSnapshot) {
          if (materielSnapshot.hasError || !materielSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final materiels = materielSnapshot.data!;

          return StreamBuilder<List<Site>>(
            stream: _siteRepository.getSites(),
            builder: (context, siteSnapshot) {
              final sites = siteSnapshot.data ?? [];

              return StreamBuilder<List<Marche>>(
                stream: _marcheRepository.getMarches(),
                builder: (context, marcheSnapshot) {
                  final marches = marcheSnapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),

                          _buildStatCards(materiels, sites, marches),
                          const SizedBox(height: 24),

                          _buildEtatChart(materiels),
                          const SizedBox(height: 24),

                          _buildSiteChart(materiels),
                          const SizedBox(height: 24),

                          _buildRecentTransferts(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dashboardTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.dashboardSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatCards(List<Materiel> materiels, List<Site> sites, List<Marche> marches) {
    final total = materiels.length;
    final actifCount = materiels.where((m) => m.etat == EtatMateriel.actif).length;
    final panneCount = materiels.where((m) => m.etat == EtatMateriel.enPanne).length;
    final perduCount = materiels.where((m) => m.etat == EtatMateriel.perdu).length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(
          title: AppLocalizations.of(context)!.totalEquipment,
          count: total,
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        _StatCard(
          title: AppLocalizations.of(context)!.operational,
          count: actifCount,
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _StatCard(
          title: AppLocalizations.of(context)!.inRepair,
          count: panneCount,
          icon: Icons.warning,
          color: Colors.orange,
        ),
        _StatCard(
          title: AppLocalizations.of(context)!.lost,
          count: perduCount,
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _StatCard(
          title: AppLocalizations.of(context)!.sites,
          count: sites.length,
          icon: Icons.location_city,
          color: Colors.indigo,
        ),
        _StatCard(
          title: AppLocalizations.of(context)!.markets,
          count: marches.length,
          icon: Icons.business,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildEtatChart(List<Materiel> materiels) {
    final actif = materiels.where((m) => m.etat == EtatMateriel.actif).length;
    final panne = materiels.where((m) => m.etat == EtatMateriel.enPanne).length;
    final perdu = materiels.where((m) => m.etat == EtatMateriel.perdu).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.statusDistribution,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {});
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _etatSections(actif, panne, perdu),
                    ),
                  ),
                  IgnorePointer(
                    child: Text(
                      '$actif',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _legendItem(AppLocalizations.of(context)!.statusActive, Colors.green, actif),
                _legendItem(AppLocalizations.of(context)!.statusInRepair, Colors.orange, panne),
                _legendItem(AppLocalizations.of(context)!.statusLost, Colors.red, perdu),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _etatSections(int actif, int panne, int perdu) {
    final total = actif + panne + perdu;
    if (total == 0) {
      return [
        PieChartSectionData(
          title: AppLocalizations.of(context)!.none,
          value: 1,
          color: Colors.grey,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ];
    }
    return [
      PieChartSectionData(
        title: '$actif',
        value: actif.toDouble(),
        color: Colors.green,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      PieChartSectionData(
        title: '$panne',
        value: panne.toDouble(),
        color: Colors.orange,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      PieChartSectionData(
        title: '$perdu',
        value: perdu.toDouble(),
        color: Colors.red,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ];
  }

  Widget _legendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildSiteChart(List<Materiel> materiels) {
    final counts = <String, int>{};
    for (final m in materiels) {
      final site = m.siteActuel.isEmpty ? AppLocalizations.of(context)!.undefined : m.siteActuel;
      counts[site] = (counts[site] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.noEquipmentToDisplay),
        ),
      );
    }

    final maxCount = sortedEntries.first.value > 0 ? sortedEntries.first.value : 1;
    final barWidth = 18.0;
    final chartHeight = 180.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.equipmentBySite,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {});
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = sortedEntries[group.x].key;
                        return BarTooltipItem(
                          '$label\n${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedEntries.length) {
                            return const SizedBox.shrink();
                          }
                          final label = sortedEntries[index].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 80,
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(
                    sortedEntries.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: sortedEntries[i].value.toDouble(),
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: _siteColor(i),
                        ),
                      ],
                    ),
                  ),
                  maxY: maxCount.toDouble() * 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _siteColor(int index) {
    const colors = [
      Color(0xFF1B5E20),
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFF44336),
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFE91E63),
    ];
    return colors[index % colors.length];
  }

  Widget _buildRecentTransferts() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.recentTransfers,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder(
              stream: _transfertRepository.getHistory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      AppLocalizations.of(context)!.noTransfersRecorded,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final transferts = snapshot.data!;
                final recent = transferts.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final t = recent[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.swap_horiz,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        t.materielDesignation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${t.siteOrigine} → ${t.siteDestination}\n${t.dateTransfert.day}/${t.dateTransfert.month}/${t.dateTransfert.year}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                      isThreeLine: false,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
