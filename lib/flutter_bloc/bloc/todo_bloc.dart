import 'dart:async';

import 'package:codefactory_bloc_todos/flutter_bloc/bloc/todo_event.dart';
import 'package:codefactory_bloc_todos/flutter_bloc/bloc/todo_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/todo.dart';
import '../repository/todo_repository.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc({
    required this.repository,
  }) : super(Empty()) {
    on<ListTodosEvent>(listTodoEvent);
    on<CreateTodoEvent>(createTodoEvent);
    on<DeleteTodoEvent>(deleteTodEvent);
  }

  Future<FutureOr<void>> listTodoEvent(
      ListTodosEvent event, Emitter<TodoState> emit) async {
    try {
      emit(Loading());
      final resp = await repository.listTodo();
      final todos = resp
          .map<Todo>(
            (e) => Todo.fromJson(e),
          )
          .toList();
      emit(Loaded(todos: todos));
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }

  Future<FutureOr<void>> createTodoEvent(
      CreateTodoEvent event, Emitter<TodoState> emit) async {
    try {
      if (state is Loaded) {
        final parsedState = (state as Loaded);

        final newTodo = Todo(
          id: parsedState.todos.isNotEmpty
              ? parsedState.todos[parsedState.todos.length - 1].id + 1
              : 1,
          title: event.title,
          createdAt: DateTime.now().toString(),
        );

        final prevTodos = [
          ...parsedState.todos,
        ];

        final newTodos = [
          newTodo,
          ...prevTodos,
        ];

        emit(Loaded(todos: newTodos));

        final resp = await repository.createTodo(newTodo);

        emit(Loaded(
          todos: [
            Todo.fromJson(resp),
            ...prevTodos,
          ],
        ));
      }
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }

  Future<FutureOr<void>> deleteTodEvent(
      DeleteTodoEvent event, Emitter<TodoState> emit) async {
    try {
      if (state is Loaded) {
        final newTodos = (state as Loaded)
            .todos
            .where((todo) => todo.id != event.todo.id)
            .toList();

        emit(Loaded(todos: newTodos));

        await repository.deleteTodo(event.todo);
      }
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }

}
