import '../models/film_genre.dart';
import '../models/screening.dart';

List<Screening> buildSeedScreenings() {
  final DateTime now = DateTime.now();

  return <Screening>[
    // 1. Mandatory: Exactly 60-character title
    Screening(
      id: 'seed-1',
      title: 'Edge of Tomorrow: 35mm Midnight IMAX Restoration Screening!!',
      category: FilmGenre.sciFi,
      when: now.add(const Duration(days: 2, hours: 3)),
      place: 'Hall 1, Grand IMAX Cinema',
      limit: 25,
      audience: const <String>['Rita Vrataski', 'William Cage', 'Nance'],
      isStream: false,
      note: 'Includes a 15-minute intro on time-loop editing and sound design.',
      favourite: true,
    ),
    // 2. Mandatory: Item at its limit (FULL)
    Screening(
      id: 'seed-2',
      title: 'The Dark Knight: Gotham After Midnight',
      category: FilmGenre.crime,
      when: now.add(const Duration(days: 1, hours: 5)),
      place: 'Vault Screening Room B',
      limit: 5,
      audience: const <String>['Bruce', 'Alfred', 'Gordon', 'Rachel', 'Lucius'],
      isStream: false,
      note: '70mm print screening. Popcorn included.',
      favourite: true,
    ),
    // 3. Mandatory: Past item
    Screening(
      id: 'seed-3',
      title: 'Sherlock: A Scandal in Belgravia Special',
      category: FilmGenre.thriller,
      when: now.subtract(const Duration(days: 3, hours: 2)),
      place: '221B Lounge Theatre',
      limit: 20,
      audience: const <String>['John Watson', 'Molly Hooper', 'Lestrade'],
      isStream: false,
      note: 'Post-screening trivia session on deduction.',
    ),
    // 4. Mandatory: Item with mode (isStream) on
    Screening(
      id: 'seed-4',
      title: 'La La Land: Synchronized Jazz Watch Party',
      category: FilmGenre.musical,
      when: now.add(const Duration(days: 3, hours: 1)),
      place: 'https://teleparty.com/join/lalaland-jazz-club',
      limit: 50,
      audience: const <String>['Sebastian', 'Mia', 'Keith'],
      isStream: true,
      note: 'Bring your keyboard or piano for the intermission jam chat.',
    ),
    // 5. Mandatory: Item without the optional text (note: null)
    Screening(
      id: 'seed-5',
      title: 'Rush: 1976 Formula 1 Rivalry Documentary Cut',
      category: FilmGenre.action,
      when: now.add(const Duration(days: 4, hours: 4)),
      place: 'Pitlane Dolby Atmos Hall',
      limit: 8,
      audience: const <String>['Niki', 'James', 'Marlene', 'Suzy', 'Clay'],
      isStream: false,
      note: null,
    ),
    // 6. <= 5 seats left (shows "2 left" badge)
    Screening(
      id: 'seed-6',
      title: 'The Gentlemen: Savile Row Tailoring & Crime Night',
      category: FilmGenre.crime,
      when: now.add(const Duration(days: 5, hours: 2)),
      place: 'Mayfair VIP Screening Room',
      limit: 6,
      audience: const <String>['Mickey', 'Raymond', 'Fletcher', 'Rosalind'],
      isStream: false,
      note: 'Smart heritage dress code encouraged: tweed, blazers, or Oxfords.',
    ),
    // 7. Live / recently started item
    Screening(
      id: 'seed-7',
      title: 'Oceans Eleven: Casino Heist Commentary Stream',
      category: FilmGenre.crime,
      when: now.subtract(const Duration(minutes: 25)),
      place: 'https://watch.cinemaclub.org/oceans-eleven',
      limit: 40,
      audience: const <String>['Danny Ocean', 'Rusty Ryan', 'Linus Caldwell'],
      isStream: true,
      note: 'Live audio breakdown of Steven Soderbergh camera blocking.',
    ),
    // 8. Upcoming Sci-Fi
    Screening(
      id: 'seed-8',
      title: 'Fallout: Wasteland Marathon Episodes 1-3',
      category: FilmGenre.sciFi,
      when: now.add(const Duration(days: 6)),
      place: 'Vault 33 Underground Projection Room',
      limit: 30,
      audience: const <String>['Lucy MacLean', 'Maximus'],
      isStream: false,
      note: null,
    ),
    // 9. Upcoming Action
    Screening(
      id: 'seed-9',
      title: 'The Last Samurai: 35mm Archival Print',
      category: FilmGenre.action,
      when: now.add(const Duration(days: 7, hours: 2)),
      place: 'Studio 4 Classic Hall',
      limit: 35,
      audience: const <String>['Nathan Algren', 'Katsumoto'],
      isStream: false,
      note: 'Original Japanese and English audio with restored subtitles.',
    ),
    // 10. Upcoming Thriller Stream
    Screening(
      id: 'seed-10',
      title: 'Peaky Blinders: Finale Directors Cut Stream',
      category: FilmGenre.thriller,
      when: now.add(const Duration(days: 8)),
      place: 'https://stream.garrison-cinema.uk/peaky',
      limit: 100,
      audience: const <String>['Thomas Shelby', 'Arthur', 'Ada'],
      isStream: true,
      note: 'Live Q&A in chat after the credits roll.',
    ),
    // 11. Past Musical
    Screening(
      id: 'seed-11',
      title: 'Whiplash: Tempo & Jazz Rhythm Breakdown',
      category: FilmGenre.musical,
      when: now.subtract(const Duration(days: 1, hours: 6)),
      place: 'Conservatory Recital Cinema',
      limit: 15,
      audience: const <String>['Andrew Neiman', 'Terence Fletcher'],
      isStream: false,
      note: null,
    ),
    // 12. Upcoming Action with empty audience (tests empty audience tab)
    Screening(
      id: 'seed-12',
      title: 'Pirates of the Caribbean: Curse of the Black Pearl',
      category: FilmGenre.action,
      when: now.add(const Duration(days: 10)),
      place: 'Harbour Open-Air Screen',
      limit: 60,
      audience: const <String>[],
      isStream: false,
      note: 'Outdoor evening projection. Blankets provided at the entrance.',
    ),
  ];
}