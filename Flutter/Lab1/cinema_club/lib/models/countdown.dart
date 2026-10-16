sealed class Countdown {
  const Countdown();

  factory Countdown.from(DateTime when, DateTime now) {
    if (now.isBefore(when)) {
      return Upcoming(when.difference(now));
    }
    final Duration elapsed = now.difference(when);
    if (elapsed < const Duration(hours: 2)) {
      return Started(elapsed);
    }
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

String formatCountdown(Countdown countdown) => switch (countdown) {
      Upcoming(:final remaining) => remaining.inDays > 0
          ? 'In ${remaining.inDays}d ${remaining.inHours % 24}h'
          : 'In ${remaining.inHours}h ${remaining.inMinutes % 60}m',
      Started(:final elapsed) => 'Live (${elapsed.inMinutes}m in)',
      Ended() => 'Ended',
    };