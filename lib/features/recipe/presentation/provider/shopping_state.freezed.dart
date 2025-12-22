// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ShoppingState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<ShoppingItemModel> get recipes => throw _privateConstructorUsedError;
  List<ShoppingIngredientModel> get ingredients =>
      throw _privateConstructorUsedError;
  ShoppingViewMode get viewMode => throw _privateConstructorUsedError;

  /// Create a copy of ShoppingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShoppingStateCopyWith<ShoppingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingStateCopyWith<$Res> {
  factory $ShoppingStateCopyWith(
    ShoppingState value,
    $Res Function(ShoppingState) then,
  ) = _$ShoppingStateCopyWithImpl<$Res, ShoppingState>;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<ShoppingItemModel> recipes,
    List<ShoppingIngredientModel> ingredients,
    ShoppingViewMode viewMode,
  });
}

/// @nodoc
class _$ShoppingStateCopyWithImpl<$Res, $Val extends ShoppingState>
    implements $ShoppingStateCopyWith<$Res> {
  _$ShoppingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShoppingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? recipes = null,
    Object? ingredients = null,
    Object? viewMode = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            recipes: null == recipes
                ? _value.recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                      as List<ShoppingItemModel>,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<ShoppingIngredientModel>,
            viewMode: null == viewMode
                ? _value.viewMode
                : viewMode // ignore: cast_nullable_to_non_nullable
                      as ShoppingViewMode,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShoppingStateImplCopyWith<$Res>
    implements $ShoppingStateCopyWith<$Res> {
  factory _$$ShoppingStateImplCopyWith(
    _$ShoppingStateImpl value,
    $Res Function(_$ShoppingStateImpl) then,
  ) = __$$ShoppingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<ShoppingItemModel> recipes,
    List<ShoppingIngredientModel> ingredients,
    ShoppingViewMode viewMode,
  });
}

/// @nodoc
class __$$ShoppingStateImplCopyWithImpl<$Res>
    extends _$ShoppingStateCopyWithImpl<$Res, _$ShoppingStateImpl>
    implements _$$ShoppingStateImplCopyWith<$Res> {
  __$$ShoppingStateImplCopyWithImpl(
    _$ShoppingStateImpl _value,
    $Res Function(_$ShoppingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShoppingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? recipes = null,
    Object? ingredients = null,
    Object? viewMode = null,
  }) {
    return _then(
      _$ShoppingStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        recipes: null == recipes
            ? _value._recipes
            : recipes // ignore: cast_nullable_to_non_nullable
                  as List<ShoppingItemModel>,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<ShoppingIngredientModel>,
        viewMode: null == viewMode
            ? _value.viewMode
            : viewMode // ignore: cast_nullable_to_non_nullable
                  as ShoppingViewMode,
      ),
    );
  }
}

/// @nodoc

class _$ShoppingStateImpl implements _ShoppingState {
  const _$ShoppingStateImpl({
    this.isLoading = false,
    this.error,
    final List<ShoppingItemModel> recipes = const <ShoppingItemModel>[],
    final List<ShoppingIngredientModel> ingredients =
        const <ShoppingIngredientModel>[],
    this.viewMode = ShoppingViewMode.byRecipe,
  }) : _recipes = recipes,
       _ingredients = ingredients;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<ShoppingItemModel> _recipes;
  @override
  @JsonKey()
  List<ShoppingItemModel> get recipes {
    if (_recipes is EqualUnmodifiableListView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipes);
  }

  final List<ShoppingIngredientModel> _ingredients;
  @override
  @JsonKey()
  List<ShoppingIngredientModel> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  @override
  @JsonKey()
  final ShoppingViewMode viewMode;

  @override
  String toString() {
    return 'ShoppingState(isLoading: $isLoading, error: $error, recipes: $recipes, ingredients: $ingredients, viewMode: $viewMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    const DeepCollectionEquality().hash(_recipes),
    const DeepCollectionEquality().hash(_ingredients),
    viewMode,
  );

  /// Create a copy of ShoppingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingStateImplCopyWith<_$ShoppingStateImpl> get copyWith =>
      __$$ShoppingStateImplCopyWithImpl<_$ShoppingStateImpl>(this, _$identity);
}

abstract class _ShoppingState implements ShoppingState {
  const factory _ShoppingState({
    final bool isLoading,
    final String? error,
    final List<ShoppingItemModel> recipes,
    final List<ShoppingIngredientModel> ingredients,
    final ShoppingViewMode viewMode,
  }) = _$ShoppingStateImpl;

  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<ShoppingItemModel> get recipes;
  @override
  List<ShoppingIngredientModel> get ingredients;
  @override
  ShoppingViewMode get viewMode;

  /// Create a copy of ShoppingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShoppingStateImplCopyWith<_$ShoppingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
