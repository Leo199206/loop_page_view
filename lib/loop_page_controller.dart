part of 'loop_page_view.dart';

/// A [PageController] extension to handle [LoopPageView] indefinitely scrollable list.
class LoopPageController extends PageController {
  static const int _initialShiftedPage = 100000;

  // ignore: prefer_final_fields
  int _currentShiftedPage;

  // ignore: prefer_final_fields
  int _itemCount;

  // ignore: prefer_final_fields
  int _initialIndexShift;

  final int _initialPage;

  LoopPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _currentShiftedPage = _initialShiftedPage,
        _itemCount = 0,
        _initialIndexShift = 0,
        _initialPage = initialPage,
        super(
          initialPage: initialPage + _initialShiftedPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
        );

  /// The current page displayed in the controlled [LoopPageView].
  ///
  /// There are circumstances that this [LoopPageController] can't know the current
  /// page. Reading [page] will throw an [AssertionError] in the following cases:
  ///
  /// 1. No [LoopPageView] is currently using this [LoopPageController]. Once a
  /// [LoopPageView] starts using this [LoopPageController], the new [page]
  /// position will be derived:
  ///
  ///   * First, based on the attached [LoopPageView]'s [BuildContext] and the
  ///     position saved at that context's [PageStorage] if [keepPage] is true.
  ///   * Second, from the [LoopPageController]'s [initialPage].
  ///
  /// 2. More than one [LoopPageView] using the same [LoopPageController].
  ///
  /// The [hasClients] property can be used to check if a [LoopPageView] is attached
  /// prior to accessing [page].
  ///
  @override
  double get page =>
      _notShiftedIndex(super.page.floor()).toDouble() +
      (super.page - super.page.truncate());

  // @override
  // double get page => super.page;

  /// Animates the controlled [LoopPageView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  @override
  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    return super
        .animateToPage(_shiftPage(page), duration: duration, curve: curve);
  }

  /// Changes which page is displayed in the controlled [LoopPageView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation.
  @override
  void jumpToPage(int page) {
    super.jumpToPage(_shiftPage(page));
  }

  /// Animates the controlled [LoopPageView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  @override
  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(_shiftPage(page.round()) + 1,
        duration: duration, curve: curve);
  }

  /// Animates the controlled [LoopPageView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  @override
  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(_shiftPage(page.round()) - 1,
        duration: duration, curve: curve);
  }

  int _notShiftedIndex(int index) {
    final int currentIndexShift = index % _itemCount;

    final int difference = currentIndexShift - _initialIndexShift;

    if (difference < 0) return difference + _itemCount;
    return difference;
  }

  int _shiftPage(int page) {
    final modPage = (page % _itemCount);

    final int instantCurrentShiftedPage = _currentShiftedPage;

    final int currentNotShiftedPage =
        _notShiftedIndex(instantCurrentShiftedPage);

    if (currentNotShiftedPage == modPage) return instantCurrentShiftedPage;

    final int distance = modPage - currentNotShiftedPage;

    final int oppositeDistance = distance > 0
        ? (-1 * currentNotShiftedPage) - (_itemCount - modPage)
        : distance == 0 ? 0 : distance + _itemCount;

    final int shiftedPage = distance.abs() <= oppositeDistance.abs()
        ? instantCurrentShiftedPage + distance
        : instantCurrentShiftedPage + oppositeDistance;
    return shiftedPage;
  }

  //Should be called only once.
  void _updateItemCount(int itemCount) {
    _itemCount = itemCount;
    _initialIndexShift = _initialShiftedPage % _itemCount;
    _currentShiftedPage = _initialShiftedPage + _initialPage;
  }
}
