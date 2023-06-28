import 'package:codefactory_bloc_todos/flutter_bloc/bloc/todo_bloc.dart';
import 'package:codefactory_bloc_todos/flutter_bloc/bloc/todo_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/todo_cubit.dart';
import '../bloc/todo_state.dart';
import '../repository/todo_repository.dart';

class BlocHomeScreen extends StatefulWidget {
  const BlocHomeScreen({super.key});

  @override
  State<BlocHomeScreen> createState() => _BlocHomeScreenState();
}

class _BlocHomeScreenState extends State<BlocHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(repository: TodoRepository()),
      child: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String title = '';
  @override
  void initState() {
    super.initState();
    // ListTodosEvent
    // BlocProvider.of<TodoCubit>(context).listTodo();
    BlocProvider.of<TodoBloc>(context).add(ListTodosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BloC'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          title.isNotEmpty
              ? context.read<TodoBloc>().add(CreateTodoEvent(title: title))
              : ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('내용을 입력해 주세요'),
                  ),
                );
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
              child: BlocBuilder<TodoBloc, TodoState>(
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
                                BlocProvider.of<TodoBloc>(context).add(DeleteTodoEvent(todo: item));
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
