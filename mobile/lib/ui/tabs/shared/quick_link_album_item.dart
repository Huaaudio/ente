import "package:flutter/material.dart";
import "package:photos/generated/l10n.dart";
import 'package:photos/models/collection/collection.dart';
import 'package:photos/models/collection/collection_items.dart';
import 'package:photos/models/file/file.dart';
import "package:photos/services/collections_service.dart";
import "package:photos/theme/ente_theme.dart";
import "package:photos/ui/common/loading_widget.dart";
import "package:photos/ui/components/buttons/icon_button_widget.dart";
import "package:photos/ui/viewer/file/no_thumbnail_widget.dart";
import "package:photos/ui/viewer/file/thumbnail_widget.dart";
import "package:photos/ui/viewer/gallery/collection_page.dart";
import "package:photos/utils/navigation_util.dart";

class QuickLinkAlbumItem extends StatelessWidget {
  final Collection c;
  static const heroTagPrefix = "outgoing_collection";

  const QuickLinkAlbumItem({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final colorScheme = getEnteColorScheme(context);
    final textTheme = getEnteTextTheme(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.strokeFainter),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 6,
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: FutureBuilder<EnteFile?>(
                      future: CollectionsService.instance.getCover(c),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final String heroTag =
                              heroTagPrefix + snapshot.data!.tag;
                          return Hero(
                            tag: heroTag,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(2),
                              ),
                              child: ThumbnailWidget(
                                snapshot.data!,
                                key: ValueKey(heroTag),
                              ),
                            ),
                          );
                        } else {
                          return const NoThumbnailWidget();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          FutureBuilder<int>(
                            future: CollectionsService.instance.getFileCount(c),
                            builder: (context, snapshot) {
                              if (!snapshot.hasError) {
                                if (!snapshot.hasData) {
                                  return Row(
                                    children: [
                                      EnteLoadingWidget(
                                        size: 10,
                                        color: colorScheme.strokeMuted,
                                      ),
                                    ],
                                  );
                                }
                                final noOfMemories = snapshot.data;

                                return Row(
                                  children: [
                                    Text(
                                      noOfMemories.toString() + "  \u2022  ",
                                      style: textTheme.smallMuted,
                                    ),
                                    c.hasLink
                                        ? (c.publicURLs!.first!.isExpired
                                            ? Icon(
                                                Icons.link_outlined,
                                                color: colorScheme.warning500,
                                                size: 22,
                                              )
                                            : Icon(
                                                Icons.link_outlined,
                                                color: colorScheme.strokeMuted,
                                                size: 22,
                                              ))
                                        : const SizedBox.shrink(),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text(S.of(context).somethingWentWrong);
                              } else {
                                return const EnteLoadingWidget(size: 10);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Flexible(
              flex: 1,
              child: IconButtonWidget(
                icon: Icons.chevron_right_outlined,
                iconButtonType: IconButtonType.secondary,
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        final thumbnail = await CollectionsService.instance.getCover(c);
        final page = CollectionPage(
          CollectionWithThumbnail(
            c,
            thumbnail,
          ),
          tagPrefix: heroTagPrefix,
        );
        // ignore: unawaited_futures
        routeToPage(context, page);
      },
    );
  }
}
