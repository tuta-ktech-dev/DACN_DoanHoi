import 'package:doan_hoi_app/src/core/di/dependency_injection.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:doan_hoi_app/src/presentation/widgets/event_card.dart';
import 'package:doan_hoi_app/widgets/base_error.dart';
import 'package:doan_hoi_app/widgets/base_indicator.dart';
import 'package:doan_hoi_app/widgets/base_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListEventScreen extends StatelessWidget {
  const ListEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FetchEventCubit>()..fetchEvents(),
      child: const ListEventView(),
    );
  }
}

class ListEventView extends StatefulWidget {
  const ListEventView({super.key});

  @override
  State<ListEventView> createState() => _ListEventViewState();
}

class _ListEventViewState extends State<ListEventView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<FetchEventCubit>().fetchMoreEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchEventCubit, FetchEventState>(
      builder: (context, state) {
        if (state.errorMessage != null) {
          return BaseError(
              errorMessage: state.errorMessage!,
              onTryAgain: () {
                context.read<FetchEventCubit>().fetchEvents();
              });
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.events?.length ??
              0 + (state.status == FetchingStatus.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (state.status == FetchingStatus.loadingMore) {
              return const BaseIndicator();
            }
            return EventCard(
              event: state.events![index],
              key: Key(state.events![index].id.toString()),
              onRegister: () {},
            );
          },
        );
      },
    );
  }
}
