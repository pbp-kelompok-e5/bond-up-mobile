// Application constants
// Includes choices from Django backend (CITY_CHOICES, SPORT_CHOICES, SKILL_CHOICES)

class AppConstants {
  AppConstants._();

  /// City choices - must match Django CITY_CHOICES
  static const Map<String, String> cityChoices = {
    'ambon': 'Ambon',
    'banda_aceh': 'Banda Aceh',
    'bandar_lampung': 'Bandar Lampung',
    'bandung': 'Bandung',
    'banjar': 'Banjar',
    'banjarbaru': 'Banjarbaru',
    'banjarmasin': 'Banjarmasin',
    'batu': 'Batu',
    'batam': 'Batam',
    'baubau': 'Baubau',
    'bekasi': 'Bekasi',
    'bengkulu': 'Bengkulu',
    'bima': 'Bima',
    'binjai': 'Binjai',
    'bitung': 'Bitung',
    'blitar': 'Blitar',
    'bogor': 'Bogor',
    'bontang': 'Bontang',
    'bukittinggi': 'Bukittinggi',
    'cilegon': 'Cilegon',
    'cimahi': 'Cimahi',
    'cirebon': 'Cirebon',
    'denpasar': 'Denpasar',
    'depok': 'Depok',
    'dumai': 'Dumai',
    'gorontalo': 'Gorontalo',
    'gunungsitoli': 'Gunungsitoli',
    'jakarta_barat': 'Jakarta Barat',
    'jakarta_pusat': 'Jakarta Pusat',
    'jakarta_selatan': 'Jakarta Selatan',
    'jakarta_timur': 'Jakarta Timur',
    'jakarta_utara': 'Jakarta Utara',
    'jambi': 'Jambi',
    'jayapura': 'Jayapura',
    'kediri': 'Kediri',
    'kendari': 'Kendari',
    'kotamobagu': 'Kotamobagu',
    'kupang': 'Kupang',
    'langsa': 'Langsa',
    'lhokseumawe': 'Lhokseumawe',
    'lubuk_linggau': 'Lubuk Linggau',
    'madiun': 'Madiun',
    'magelang': 'Magelang',
    'makassar': 'Makassar',
    'malang': 'Malang',
    'manado': 'Manado',
    'mataram': 'Mataram',
    'medan': 'Medan',
    'metro': 'Metro',
    'mojokerto': 'Mojokerto',
    'nusantara': 'Nusantara',
    'padang': 'Padang',
    'padang_panjang': 'Padang Panjang',
    'padangsidimpuan': 'Padangsidimpuan',
    'pagar_alam': 'Pagar Alam',
    'palangka_raya': 'Palangka Raya',
    'palembang': 'Palembang',
    'palopo': 'Palopo',
    'palu': 'Palu',
    'pangkalpinang': 'Pangkalpinang',
    'pariaman': 'Pariaman',
    'parepare': 'Parepare',
    'pasuruan': 'Pasuruan',
    'payakumbuh': 'Payakumbuh',
    'pekalongan': 'Pekalongan',
    'pekanbaru': 'Pekanbaru',
    'pematangsiantar': 'Pematangsiantar',
    'pontianak': 'Pontianak',
    'prabumulih': 'Prabumulih',
    'probolinggo': 'Probolinggo',
    'sabang': 'Sabang',
    'salatiga': 'Salatiga',
    'samarinda': 'Samarinda',
    'sawahlunto': 'Sawahlunto',
    'semarang': 'Semarang',
    'serang': 'Serang',
    'sibolga': 'Sibolga',
    'singkawang': 'Singkawang',
    'solok': 'Solok',
    'sorong': 'Sorong',
    'subulussalam': 'Subulussalam',
    'sukabumi': 'Sukabumi',
    'sungai_penuh': 'Sungai Penuh',
    'surabaya': 'Surabaya',
    'surakarta': 'Surakarta',
    'tangerang': 'Tangerang',
    'tangerang_selatan': 'Tangerang Selatan',
    'tanjungbalai': 'Tanjungbalai',
    'tanjungpinang': 'Tanjungpinang',
    'tarakan': 'Tarakan',
    'tasikmalaya': 'Tasikmalaya',
    'tebing_tinggi': 'Tebing Tinggi',
    'tegal': 'Tegal',
    'ternate': 'Ternate',
    'tidore_kepulauan': 'Tidore Kepulauan',
    'tomohon': 'Tomohon',
    'tual': 'Tual',
    'yogyakarta': 'Yogyakarta',
  };

  /// Sport choices - must match Django SPORT_CHOICES
  static const Map<String, String> sportChoices = {
    'football': 'Football',
    'basketball': 'Basketball',
    'badminton': 'Badminton',
    'tennis': 'Tennis',
    'running': 'Running',
    'cycling': 'Cycling',
    'swimming': 'Swimming',
    'volleyball': 'Volleyball',
  };

  /// Skill level choices - must match Django SKILL_CHOICES
  static const Map<String, String> skillChoices = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  /// Get city display name from city code
  static String getCityDisplay(String cityCode) {
    return cityChoices[cityCode] ?? cityCode;
  }

  /// Get sport display name from sport code
  static String getSportDisplay(String sportCode) {
    return sportChoices[sportCode] ?? sportCode;
  }

  /// Get skill display name from skill code
  static String getSkillDisplay(String skillCode) {
    return skillChoices[skillCode] ?? skillCode;
  }

  /// Get sorted list of city entries for dropdown
  static List<MapEntry<String, String>> get sortedCities {
    final entries = cityChoices.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }

  /// Get sorted list of sport entries for dropdown
  static List<MapEntry<String, String>> get sortedSports {
    return sportChoices.entries.toList();
  }

  /// Get sorted list of skill entries for dropdown
  static List<MapEntry<String, String>> get sortedSkills {
    return skillChoices.entries.toList();
  }
}

