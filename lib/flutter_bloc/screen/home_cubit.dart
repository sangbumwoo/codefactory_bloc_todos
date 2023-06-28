import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/todo_cubit.dart';
import '../bloc/todo_state.dart';
import '../repository/todo_repository.dart';

class CubitHomeScreen extends StatefulWidget {
  const CubitHomeScreen({super.key});

  @override
  State<CubitHomeScreen> createState() => _CubitHomeScreenState();
}

class _CubitHomeScreenState extends State<CubitHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoCubit(repository: TodoRepository()),
      child: const CubitWidget(),
    );
  }
}

class BlocWidget extends StatefulWidget {
  const BlocWidget({super.key});

  @override
  State<BlocWidget> createState() => _BlocWidgetState();
}

class _BlocWidgetState extends State<BlocWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CubitWidget extends StatefulWidget {
  const CubitWidget({super.key});

  @override
  State<CubitWidget> createState() => _CubitWidgetState();
}

class _CubitWidgetState extends State<CubitWidget> {
  String title = '';

  @override
  void initState() {
    super.initState();

    // ListTodosEvent
    BlocProvider.of<TodoCubit>(context).listTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Cubit'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          title.isNotEmpty
              ? context.read<TodoCubit>().createTodo(title)
              : ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('내용을 입력해 주세요')));
        },
        child: const Icon(
          Icons.edit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) {
                title = val;
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: BlocBuilder<TodoCubit, TodoState>(
                builder: (_, state) {
                  if (state is Empty) {
                    return Container();
                  } else if (state is Error) {
                    return Text(state.message);
                  } else if (state is Loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is Loaded) {
                    final items = state.todos;
                    return ListView.separated(
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                BlocProvider.of<TodoCubit>(context).deleteTodo(
                                  item,
                                );
                              },
                              child: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, index) => const Divider(),
                      itemCount: items.length,
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
