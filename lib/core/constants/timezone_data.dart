class TimezoneData {
  static const List<Map<String, String>> timezones = [
    // Indonesia
    {
      'id': 'Asia/Jakarta',
      'name': 'WIB',
      'city': 'Jakarta',
      'country': 'Indonesia',
      'flag': '🇮🇩',
      'offset': '+07:00',
    },
    {
      'id': 'Asia/Makassar',
      'name': 'WITA',
      'city': 'Makassar',
      'country': 'Indonesia',
      'flag': '🇮🇩',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Jayapura',
      'name': 'WIT',
      'city': 'Jayapura',
      'country': 'Indonesia',
      'flag': '🇮🇩',
      'offset': '+09:00',
    },

    // Asia
    {
      'id': 'Asia/Tokyo',
      'name': 'JST',
      'city': 'Tokyo',
      'country': 'Japan',
      'flag': '🇯🇵',
      'offset': '+09:00',
    },
    {
      'id': 'Asia/Seoul',
      'name': 'KST',
      'city': 'Seoul',
      'country': 'South Korea',
      'flag': '🇰🇷',
      'offset': '+09:00',
    },
    {
      'id': 'Asia/Shanghai',
      'name': 'CST',
      'city': 'Shanghai',
      'country': 'China',
      'flag': '🇨🇳',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Singapore',
      'name': 'SGT',
      'city': 'Singapore',
      'country': 'Singapore',
      'flag': '🇸🇬',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Kuala_Lumpur',
      'name': 'MYT',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'flag': '🇲🇾',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Bangkok',
      'name': 'ICT',
      'city': 'Bangkok',
      'country': 'Thailand',
      'flag': '🇹🇭',
      'offset': '+07:00',
    },
    {
      'id': 'Asia/Manila',
      'name': 'PHT',
      'city': 'Manila',
      'country': 'Philippines',
      'flag': '🇵🇭',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Dubai',
      'name': 'GST',
      'city': 'Dubai',
      'country': 'UAE',
      'flag': '🇦🇪',
      'offset': '+04:00',
    },
    {
      'id': 'Asia/Hong_Kong',
      'name': 'HKT',
      'city': 'Hong Kong',
      'country': 'Hong Kong',
      'flag': '🇭🇰',
      'offset': '+08:00',
    },
    {
      'id': 'Asia/Kolkata',
      'name': 'IST',
      'city': 'Mumbai',
      'country': 'India',
      'flag': '🇮🇳',
      'offset': '+05:30',
    },
    {
      'id': 'Asia/Riyadh',
      'name': 'AST',
      'city': 'Riyadh',
      'country': 'Saudi Arabia',
      'flag': '🇸🇦',
      'offset': '+03:00',
    },

    // Europe
    {
      'id': 'Europe/London',
      'name': 'GMT',
      'city': 'London',
      'country': 'United Kingdom',
      'flag': '🇬🇧',
      'offset': '+00:00',
    },
    {
      'id': 'Europe/Paris',
      'name': 'CET',
      'city': 'Paris',
      'country': 'France',
      'flag': '🇫🇷',
      'offset': '+01:00',
    },
    {
      'id': 'Europe/Berlin',
      'name': 'CET',
      'city': 'Berlin',
      'country': 'Germany',
      'flag': '🇩🇪',
      'offset': '+01:00',
    },
    {
      'id': 'Europe/Amsterdam',
      'name': 'CET',
      'city': 'Amsterdam',
      'country': 'Netherlands',
      'flag': '🇳🇱',
      'offset': '+01:00',
    },
    {
      'id': 'Europe/Rome',
      'name': 'CET',
      'city': 'Rome',
      'country': 'Italy',
      'flag': '🇮🇹',
      'offset': '+01:00',
    },

    // America
    {
      'id': 'America/New_York',
      'name': 'EST',
      'city': 'New York',
      'country': 'USA',
      'flag': '🇺🇸',
      'offset': '-05:00',
    },
    {
      'id': 'America/Los_Angeles',
      'name': 'PST',
      'city': 'Los Angeles',
      'country': 'USA',
      'flag': '🇺🇸',
      'offset': '-08:00',
    },
    {
      'id': 'America/Chicago',
      'name': 'CST',
      'city': 'Chicago',
      'country': 'USA',
      'flag': '🇺🇸',
      'offset': '-06:00',
    },
    {
      'id': 'America/Toronto',
      'name': 'EST',
      'city': 'Toronto',
      'country': 'Canada',
      'flag': '🇨🇦',
      'offset': '-05:00',
    },
    {
      'id': 'America/Mexico_City',
      'name': 'CST',
      'city': 'Mexico City',
      'country': 'Mexico',
      'flag': '🇲🇽',
      'offset': '-06:00',
    },
    {
      'id': 'America/Sao_Paulo',
      'name': 'BRT',
      'city': 'São Paulo',
      'country': 'Brazil',
      'flag': '🇧🇷',
      'offset': '-03:00',
    },

    // Australia
    {
      'id': 'Australia/Sydney',
      'name': 'AEDT',
      'city': 'Sydney',
      'country': 'Australia',
      'flag': '🇦🇺',
      'offset': '+11:00',
    },
    {
      'id': 'Pacific/Auckland',
      'name': 'NZDT',
      'city': 'Auckland',
      'country': 'New Zealand',
      'flag': '🇳🇿',
      'offset': '+13:00',
    },
  ];

  static Map<String, String>? getById(String id) {
    try {
      return timezones.firstWhere((t) => t['id'] == id);
    } catch (e) {
      return null;
    }
  }
}