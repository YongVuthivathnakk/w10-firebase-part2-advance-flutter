import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../view_model/library_item_data.dart';
import 'library_item_tile.dart';
import '../view_model/library_view_model.dart';

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    LibraryViewModel mv = context.watch<LibraryViewModel>();

    AsyncValue<List<LibraryItemData>> asyncValue = mv.data;

    Widget content;
    switch (asyncValue.state) {
      case AsyncValueState.loading:
        content = Center(child: CircularProgressIndicator());
        break;
      case AsyncValueState.error:
        content = Center(
          child: Text(
            'error = ${asyncValue.error!}',
            style: TextStyle(color: Colors.red),
          ),
        );
        break;
      case AsyncValueState.success:
        List<LibraryItemData> data = asyncValue.data!;
        content = RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            await mv.fetchSong(forceFetch: true);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => LibraryItemTile(
              data: data[index],
              isPlaying: mv.isSongPlaying(data[index].song),
              onTap: () {
                mv.start(data[index].song);
              },
              onLike: () =>
                  mv.likeSong(data[index].song.id, data[index].song.likes),
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          // Use the button to trigger instead because cannot pull up to down to refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Library", style: AppTextStyles.heading),
              SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _refreshIndicatorKey.currentState?.show();
                },
              ),
            ],
          ),
          SizedBox(height: 50),
          Expanded(child: content),
        ],
      ),
    );
  }
}
