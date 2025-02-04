import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class _Args {
  final SonarrSeries series;

  _Args({
    required this.series,
  });
}

class SonarrAddSeriesDetailsRouter extends SonarrPageRouter {
  SonarrAddSeriesDetailsRouter() : super('/sonarr/addseries/details');

  @override
  _Widget widget() => _Widget();

  @override
  Future<void> navigateTo(
    BuildContext context, [
    SonarrSeries? series,
  ]) {
    assert(series != null);
    return LunaRouter.router.navigateTo(
      context,
      route(),
      routeSettings: RouteSettings(
        arguments: _Args(
          series: series!,
        ),
      ),
    );
  }

  @override
  void defineRoute(FluroRouter router) {
    super.noParameterRouteDefinition(router);
  }
}

class _Widget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<_Widget>
    with LunaLoadCallbackMixin, LunaScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Future<void> loadCallback() async {
    context.read<SonarrState>().fetchRootFolders();
    context.read<SonarrState>().fetchTags();
    context.read<SonarrState>().fetchQualityProfiles();
    context.read<SonarrState>().fetchLanguageProfiles();
  }

  @override
  Widget build(BuildContext context) {
    _Args? arguments = ModalRoute.of(context)!.settings.arguments as _Args?;
    if (arguments == null) {
      return LunaInvalidRoute(
        title: 'sonarr.AddSeries'.tr(),
        message: 'sonarr.NoSeriesFound'.tr(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => SonarrSeriesAddDetailsState(
        series: arguments.series,
      ),
      builder: (context, _) => LunaScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
        bottomNavigationBar: const SonarrAddSeriesDetailsActionBar(),
      ),
    );
  }

  Widget _appBar() {
    return LunaAppBar(
      title: 'sonarr.AddSeries'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(
        [
          context.watch<SonarrState>().rootFolders!,
          context.watch<SonarrState>().tags!,
          context.watch<SonarrState>().qualityProfiles!,
          context.watch<SonarrState>().languageProfiles!,
        ],
      ),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.hasError) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            LunaLogger().error(
              'Unable to fetch Sonarr add series data',
              snapshot.error,
              snapshot.stackTrace,
            );
          }
          return LunaMessage.error(onTap: _refreshKey.currentState!.show);
        }
        if (snapshot.hasData) {
          return _content(
            context,
            rootFolders: snapshot.data![0] as List<SonarrRootFolder>,
            tags: snapshot.data![1] as List<SonarrTag>,
            qualityProfiles: snapshot.data![2] as List<SonarrQualityProfile>,
            languageProfiles: snapshot.data![3] as List<SonarrLanguageProfile>,
          );
        }
        return const LunaLoader();
      },
    );
  }

  Widget _content(
    BuildContext context, {
    required List<SonarrRootFolder> rootFolders,
    required List<SonarrQualityProfile> qualityProfiles,
    required List<SonarrLanguageProfile> languageProfiles,
    required List<SonarrTag> tags,
  }) {
    context.read<SonarrSeriesAddDetailsState>().initializeMonitored();
    context.read<SonarrSeriesAddDetailsState>().initializeUseSeasonFolders();
    context.read<SonarrSeriesAddDetailsState>().initializeSeriesType();
    context.read<SonarrSeriesAddDetailsState>().initializeMonitorType();
    context
        .read<SonarrSeriesAddDetailsState>()
        .initializeRootFolder(rootFolders);
    context
        .read<SonarrSeriesAddDetailsState>()
        .initializeQualityProfile(qualityProfiles);
    context
        .read<SonarrSeriesAddDetailsState>()
        .initializeLanguageProfile(languageProfiles);
    context.read<SonarrSeriesAddDetailsState>().initializeTags(tags);
    context.read<SonarrSeriesAddDetailsState>().canExecuteAction = true;
    return LunaListView(
      controller: scrollController,
      children: [
        SonarrSeriesAddSearchResultTile(
          series: context.read<SonarrSeriesAddDetailsState>().series,
          onTapShowOverview: true,
          exists: false,
          isExcluded: false,
        ),
        const SonarrSeriesAddDetailsRootFolderTile(),
        const SonarrSeriesAddDetailsMonitorTile(),
        const SonarrSeriesAddDetailsQualityProfileTile(),
        const SonarrSeriesAddDetailsLanguageProfileTile(),
        const SonarrSeriesAddDetailsSeriesTypeTile(),
        const SonarrSeriesAddDetailsUseSeasonFoldersTile(),
        const SonarrSeriesAddDetailsTagsTile(),
      ],
    );
  }
}
