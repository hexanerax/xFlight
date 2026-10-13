import Foundation

enum AirportTimezones {
    /// Returns the IANA timezone identifier for the given IATA code.
    /// Prefers the API-provided string; falls back to the built-in table.
    static func resolve(iata: String?, apiTimezone: String?) -> TimeZone {
        if let id = apiTimezone, let tz = TimeZone(identifier: id) { return tz }
        if let iata, let id = table[iata], let tz = TimeZone(identifier: id) { return tz }
        return .current
    }

    // MARK: - Lookup table

    private static let table: [String: String] = [

        // ── North America – USA East ──────────────────────────────────────
        "JFK": "America/New_York", "EWR": "America/New_York", "LGA": "America/New_York",
        "BOS": "America/New_York", "PHL": "America/New_York", "BWI": "America/New_York",
        "DCA": "America/New_York", "IAD": "America/New_York", "CLT": "America/New_York",
        "ATL": "America/New_York", "MIA": "America/New_York", "FLL": "America/New_York",
        "MCO": "America/New_York", "TPA": "America/New_York", "PIT": "America/New_York",
        "BDL": "America/New_York", "RDU": "America/New_York", "JAX": "America/New_York",
        "CHS": "America/New_York", "SAV": "America/New_York", "RIC": "America/New_York",
        "ORF": "America/New_York", "SYR": "America/New_York", "ALB": "America/New_York",
        "DTW": "America/Detroit",  "CLE": "America/New_York", "CMH": "America/New_York",
        "CVG": "America/New_York", "IND": "America/Indiana/Indianapolis",
        "BNA": "America/Chicago",  "SDF": "America/Kentucky/Louisville",

        // ── North America – USA Central ───────────────────────────────────
        "ORD": "America/Chicago",  "MDW": "America/Chicago",  "MSP": "America/Chicago",
        "MKE": "America/Chicago",  "STL": "America/Chicago",  "MCI": "America/Chicago",
        "DSM": "America/Chicago",  "OMA": "America/Chicago",  "MSY": "America/Chicago",
        "MEM": "America/Chicago",  "LIT": "America/Chicago",  "TUL": "America/Chicago",
        "OKC": "America/Chicago",  "AUS": "America/Chicago",  "SAT": "America/Chicago",
        "HOU": "America/Chicago",  "IAH": "America/Chicago",  "DFW": "America/Chicago",
        "DAL": "America/Chicago",

        // ── North America – USA Mountain ──────────────────────────────────
        "DEN": "America/Denver",   "SLC": "America/Denver",   "ABQ": "America/Denver",
        "ELP": "America/Denver",   "BOI": "America/Denver",   "PHX": "America/Phoenix",
        "TUS": "America/Phoenix",

        // ── North America – USA Pacific ───────────────────────────────────
        "LAX": "America/Los_Angeles", "SFO": "America/Los_Angeles", "SJC": "America/Los_Angeles",
        "OAK": "America/Los_Angeles", "SAN": "America/Los_Angeles", "SEA": "America/Los_Angeles",
        "PDX": "America/Los_Angeles", "LAS": "America/Los_Angeles", "SMF": "America/Los_Angeles",
        "BUR": "America/Los_Angeles", "LGB": "America/Los_Angeles", "ONT": "America/Los_Angeles",
        "SNA": "America/Los_Angeles", "RNO": "America/Los_Angeles", "FAT": "America/Los_Angeles",
        "GEG": "America/Los_Angeles",

        // ── North America – Alaska & Hawaii ───────────────────────────────
        "ANC": "America/Anchorage", "FAI": "America/Anchorage",
        "HNL": "Pacific/Honolulu",  "OGG": "Pacific/Honolulu",
        "KOA": "Pacific/Honolulu",  "LIH": "Pacific/Honolulu",

        // ── Canada ────────────────────────────────────────────────────────
        "YYZ": "America/Toronto",   "YOW": "America/Toronto",   "YUL": "America/Toronto",
        "YQB": "America/Toronto",   "YHZ": "America/Halifax",   "YVR": "America/Vancouver",
        "YYJ": "America/Vancouver", "YEG": "America/Edmonton",  "YYC": "America/Edmonton",
        "YWG": "America/Winnipeg",  "YXE": "America/Regina",

        // ── Mexico & Central America ──────────────────────────────────────
        "MEX": "America/Mexico_City", "CUN": "America/Cancun",
        "GDL": "America/Mexico_City", "MTY": "America/Monterrey",
        "TIJ": "America/Tijuana",     "PVR": "America/Mexico_City",
        "SJD": "America/Mazatlan",    "MZT": "America/Mazatlan",
        "HMO": "America/Hermosillo",  "BJX": "America/Mexico_City",
        "PTY": "America/Panama",      "SAL": "America/El_Salvador",
        "GUA": "America/Guatemala",   "TGU": "America/Tegucigalpa",
        "MGA": "America/Managua",     "SJO": "America/Costa_Rica",

        // ── Caribbean ─────────────────────────────────────────────────────
        "NAS": "America/Nassau",      "MBJ": "America/Jamaica",
        "KIN": "America/Jamaica",     "SJU": "America/Puerto_Rico",
        "BGI": "America/Barbados",    "POS": "America/Port_of_Spain",
        "PTP": "America/Guadeloupe",  "FDF": "America/Martinique",
        "HAV": "America/Havana",      "SDQ": "America/Santo_Domingo",
        "PAP": "America/Port-au-Prince",

        // ── South America ─────────────────────────────────────────────────
        "GRU": "America/Sao_Paulo",   "GIG": "America/Sao_Paulo",
        "BSB": "America/Sao_Paulo",   "FOR": "America/Fortaleza",
        "SSA": "America/Bahia",       "REC": "America/Recife",
        "BEL": "America/Belem",       "MAO": "America/Manaus",
        "POA": "America/Sao_Paulo",   "CWB": "America/Sao_Paulo",
        "EZE": "America/Argentina/Buenos_Aires",
        "AEP": "America/Argentina/Buenos_Aires",
        "COR": "America/Argentina/Cordoba",
        "SCL": "America/Santiago",    "BOG": "America/Bogota",
        "MDE": "America/Bogota",      "LIM": "America/Lima",
        "UIO": "America/Guayaquil",   "GYE": "America/Guayaquil",
        "MVD": "America/Montevideo",  "ASU": "America/Asuncion",
        "LPB": "America/La_Paz",      "CCS": "America/Caracas",

        // ── UK & Ireland ──────────────────────────────────────────────────
        "LHR": "Europe/London", "LGW": "Europe/London", "LTN": "Europe/London",
        "STN": "Europe/London", "LCY": "Europe/London", "MAN": "Europe/London",
        "BHX": "Europe/London", "EDI": "Europe/London", "GLA": "Europe/London",
        "BRS": "Europe/London", "NCL": "Europe/London", "LBA": "Europe/London",
        "ABZ": "Europe/London", "BFS": "Europe/London",
        "DUB": "Europe/Dublin", "ORK": "Europe/Dublin", "SNN": "Europe/Dublin",

        // ── France ────────────────────────────────────────────────────────
        "CDG": "Europe/Paris", "ORY": "Europe/Paris", "NCE": "Europe/Paris",
        "LYS": "Europe/Paris", "MRS": "Europe/Paris", "TLS": "Europe/Paris",
        "BOD": "Europe/Paris", "NTE": "Europe/Paris",

        // ── Benelux ───────────────────────────────────────────────────────
        "AMS": "Europe/Amsterdam", "EIN": "Europe/Amsterdam",
        "BRU": "Europe/Brussels",  "LUX": "Europe/Luxembourg",

        // ── Germany & Austria & Switzerland ───────────────────────────────
        "FRA": "Europe/Berlin", "MUC": "Europe/Berlin", "BER": "Europe/Berlin",
        "DUS": "Europe/Berlin", "HAM": "Europe/Berlin", "STR": "Europe/Berlin",
        "CGN": "Europe/Berlin", "NUE": "Europe/Berlin", "HAJ": "Europe/Berlin",
        "LEJ": "Europe/Berlin", "DRS": "Europe/Berlin",
        "VIE": "Europe/Vienna", "GRZ": "Europe/Vienna",
        "ZRH": "Europe/Zurich", "GVA": "Europe/Zurich", "BSL": "Europe/Zurich",

        // ── Iberia ────────────────────────────────────────────────────────
        "MAD": "Europe/Madrid", "BCN": "Europe/Madrid", "PMI": "Europe/Madrid",
        "AGP": "Europe/Madrid", "VLC": "Europe/Madrid", "SVQ": "Europe/Madrid",
        "BIO": "Europe/Madrid", "ZAZ": "Europe/Madrid",
        "ACE": "Atlantic/Canary", "TFS": "Atlantic/Canary",
        "LPA": "Atlantic/Canary", "TFN": "Atlantic/Canary",
        "LIS": "Europe/Lisbon",  "OPO": "Europe/Lisbon", "FAO": "Europe/Lisbon",
        "FNC": "Atlantic/Madeira", "PDL": "Atlantic/Azores",

        // ── Italy ─────────────────────────────────────────────────────────
        "FCO": "Europe/Rome", "MXP": "Europe/Rome", "LIN": "Europe/Rome",
        "VCE": "Europe/Rome", "NAP": "Europe/Rome", "CTA": "Europe/Rome",
        "PMO": "Europe/Rome", "BLQ": "Europe/Rome", "BGY": "Europe/Rome",
        "TRN": "Europe/Rome", "PSA": "Europe/Rome", "BRI": "Europe/Rome",

        // ── Nordic ────────────────────────────────────────────────────────
        "ARN": "Europe/Stockholm", "GOT": "Europe/Stockholm",
        "CPH": "Europe/Copenhagen", "AAL": "Europe/Copenhagen",
        "OSL": "Europe/Oslo",      "BGO": "Europe/Oslo",
        "HEL": "Europe/Helsinki",  "TMP": "Europe/Helsinki",
        "TLL": "Europe/Tallinn",   "RIX": "Europe/Riga",
        "VNO": "Europe/Vilnius",   "REK": "Atlantic/Reykjavik",

        // ── Eastern Europe ────────────────────────────────────────────────
        "WAW": "Europe/Warsaw",    "KRK": "Europe/Warsaw",
        "PRG": "Europe/Prague",    "BUD": "Europe/Budapest",
        "OTP": "Europe/Bucharest", "SOF": "Europe/Sofia",
        "ATH": "Europe/Athens",    "SKG": "Europe/Athens",
        "HER": "Europe/Athens",    "RHO": "Europe/Athens",
        "IST": "Europe/Istanbul",  "SAW": "Europe/Istanbul",
        "ADB": "Europe/Istanbul",  "AYT": "Europe/Istanbul",
        "ESB": "Europe/Istanbul",
        "BEG": "Europe/Belgrade",  "ZAG": "Europe/Zagreb",
        "SKP": "Europe/Skopje",    "TIA": "Europe/Tirane",
        "DBV": "Europe/Zagreb",    "LJU": "Europe/Ljubljana",
        "KIV": "Europe/Chisinau",  "KBP": "Europe/Kiev",
        "MSQ": "Europe/Minsk",

        // ── Russia ────────────────────────────────────────────────────────
        "LED": "Europe/Moscow",    "SVO": "Europe/Moscow",
        "DME": "Europe/Moscow",    "VKO": "Europe/Moscow",
        "KZN": "Europe/Moscow",    "KRR": "Europe/Moscow",
        "ROV": "Europe/Moscow",    "GOJ": "Europe/Moscow",
        "SVX": "Asia/Yekaterinburg", "OVB": "Asia/Novosibirsk",
        "IKT": "Asia/Irkutsk",    "KHV": "Asia/Vladivostok",
        "VVO": "Asia/Vladivostok",

        // ── Middle East ───────────────────────────────────────────────────
        "DXB": "Asia/Dubai",   "AUH": "Asia/Dubai",   "SHJ": "Asia/Dubai",
        "DOH": "Asia/Qatar",   "KWI": "Asia/Kuwait",  "BAH": "Asia/Bahrain",
        "MCT": "Asia/Muscat",  "RUH": "Asia/Riyadh",  "JED": "Asia/Riyadh",
        "DMM": "Asia/Riyadh",  "MED": "Asia/Riyadh",
        "AMM": "Asia/Amman",   "BEY": "Asia/Beirut",  "DAM": "Asia/Damascus",
        "BGW": "Asia/Baghdad", "EBL": "Asia/Baghdad",
        "TLV": "Asia/Jerusalem",
        "CAI": "Africa/Cairo", "LXR": "Africa/Cairo", "HRG": "Africa/Cairo",
        "SSH": "Africa/Cairo", "ASW": "Africa/Cairo",
        "KHI": "Asia/Karachi", "LHE": "Asia/Karachi", "ISB": "Asia/Karachi",
        "PEW": "Asia/Karachi",

        // ── South Asia ────────────────────────────────────────────────────
        "DEL": "Asia/Kolkata", "BOM": "Asia/Kolkata", "MAA": "Asia/Kolkata",
        "BLR": "Asia/Kolkata", "HYD": "Asia/Kolkata", "CCU": "Asia/Kolkata",
        "AMD": "Asia/Kolkata", "PNQ": "Asia/Kolkata", "COK": "Asia/Kolkata",
        "TRV": "Asia/Kolkata", "IXC": "Asia/Kolkata", "LKO": "Asia/Kolkata",
        "JAI": "Asia/Kolkata", "GOI": "Asia/Kolkata", "BBI": "Asia/Kolkata",
        "NAG": "Asia/Kolkata", "PAT": "Asia/Kolkata",
        "CMB": "Asia/Colombo",
        "KTM": "Asia/Kathmandu",
        "DAC": "Asia/Dhaka",   "CGP": "Asia/Dhaka",
        "MLE": "Indian/Maldives",
        "KBL": "Asia/Kabul",

        // ── Southeast Asia ────────────────────────────────────────────────
        "BKK": "Asia/Bangkok",  "DMK": "Asia/Bangkok", "HKT": "Asia/Bangkok",
        "CNX": "Asia/Bangkok",
        "SIN": "Asia/Singapore",
        "KUL": "Asia/Kuala_Lumpur", "PEN": "Asia/Kuala_Lumpur",
        "BKI": "Asia/Kuching",      "MYY": "Asia/Kuching",
        "MNL": "Asia/Manila",       "CEB": "Asia/Manila",  "DVO": "Asia/Manila",
        "CGK": "Asia/Jakarta",      "SUB": "Asia/Jakarta", "BDO": "Asia/Jakarta",
        "DPS": "Asia/Makassar",     "UPG": "Asia/Makassar",
        "HAN": "Asia/Ho_Chi_Minh",  "SGN": "Asia/Ho_Chi_Minh",
        "DAD": "Asia/Ho_Chi_Minh",
        "PNH": "Asia/Phnom_Penh",   "REP": "Asia/Phnom_Penh",
        "VTE": "Asia/Vientiane",    "RGN": "Asia/Rangoon",
        "BWN": "Asia/Brunei",

        // ── East Asia ─────────────────────────────────────────────────────
        "HKG": "Asia/Hong_Kong",  "MFM": "Asia/Macau",
        "TPE": "Asia/Taipei",     "KHH": "Asia/Taipei",
        "PVG": "Asia/Shanghai",   "SHA": "Asia/Shanghai",
        "PEK": "Asia/Shanghai",   "PKX": "Asia/Shanghai",
        "CAN": "Asia/Shanghai",   "SZX": "Asia/Shanghai",
        "CTU": "Asia/Shanghai",   "WUH": "Asia/Shanghai",
        "XIY": "Asia/Shanghai",   "NKG": "Asia/Shanghai",
        "HGH": "Asia/Shanghai",   "XMN": "Asia/Shanghai",
        "CKG": "Asia/Shanghai",   "KMG": "Asia/Shanghai",
        "CGO": "Asia/Shanghai",   "CSX": "Asia/Shanghai",
        "TAO": "Asia/Shanghai",   "TNA": "Asia/Shanghai",
        "SHE": "Asia/Shanghai",   "CGQ": "Asia/Shanghai",
        "HRB": "Asia/Shanghai",   "DLC": "Asia/Shanghai",
        "TSN": "Asia/Shanghai",   "TYN": "Asia/Shanghai",
        "HAK": "Asia/Shanghai",   "SYX": "Asia/Shanghai",
        "URC": "Asia/Urumqi",     "KHG": "Asia/Urumqi",
        "ICN": "Asia/Seoul",      "GMP": "Asia/Seoul",
        "PUS": "Asia/Seoul",      "CJU": "Asia/Seoul",
        "NRT": "Asia/Tokyo",      "HND": "Asia/Tokyo",
        "KIX": "Asia/Tokyo",      "NGO": "Asia/Tokyo",
        "FUK": "Asia/Tokyo",      "CTS": "Asia/Tokyo",
        "OKA": "Asia/Tokyo",      "HIJ": "Asia/Tokyo",

        // ── Central Asia & Caucasus ───────────────────────────────────────
        "ALA": "Asia/Almaty",   "TSE": "Asia/Almaty",
        "TAS": "Asia/Tashkent", "FRU": "Asia/Bishkek",
        "ASB": "Asia/Ashgabat", "GYD": "Asia/Baku",
        "TBS": "Asia/Tbilisi",  "EVN": "Asia/Yerevan",
        "DYU": "Asia/Dushanbe",

        // ── Africa ────────────────────────────────────────────────────────
        "JNB": "Africa/Johannesburg", "CPT": "Africa/Johannesburg",
        "DUR": "Africa/Johannesburg", "PLZ": "Africa/Johannesburg",
        "NBO": "Africa/Nairobi",      "MBA": "Africa/Nairobi",
        "EBB": "Africa/Kampala",      "ADD": "Africa/Addis_Ababa",
        "DAR": "Africa/Dar_es_Salaam","ZNZ": "Africa/Dar_es_Salaam",
        "JRO": "Africa/Dar_es_Salaam","HRE": "Africa/Harare",
        "LUN": "Africa/Lusaka",       "GBE": "Africa/Gaborone",
        "LOS": "Africa/Lagos",        "ABV": "Africa/Lagos",
        "PHC": "Africa/Lagos",        "KAN": "Africa/Lagos",
        "ACC": "Africa/Accra",        "DKR": "Africa/Dakar",
        "ABJ": "Africa/Abidjan",      "CMN": "Africa/Casablanca",
        "RAK": "Africa/Casablanca",   "TNG": "Africa/Casablanca",
        "ALG": "Africa/Algiers",      "ORN": "Africa/Algiers",
        "TUN": "Africa/Tunis",        "MIR": "Africa/Tunis",
        "TRI": "Africa/Tripoli",      "BEN": "Africa/Tripoli",
        "KRT": "Africa/Khartoum",
        "RUN": "Indian/Reunion",      "MRU": "Indian/Mauritius",
        "MPM": "Africa/Maputo",       "WDH": "Africa/Windhoek",
        "LAD": "Africa/Luanda",       "TNR": "Indian/Antananarivo",
        "FIH": "Africa/Kinshasa",     "LBV": "Africa/Libreville",
        "BZV": "Africa/Brazzaville",  "BKO": "Africa/Bamako",
        "OUA": "Africa/Ouagadougou",  "NIM": "Africa/Niamey",
        "LFW": "Africa/Lome",

        // ── Australia & New Zealand ───────────────────────────────────────
        "SYD": "Australia/Sydney",   "MEL": "Australia/Melbourne",
        "BNE": "Australia/Brisbane", "ADL": "Australia/Adelaide",
        "PER": "Australia/Perth",    "CBR": "Australia/Sydney",
        "HBA": "Australia/Hobart",   "TSV": "Australia/Brisbane",
        "CNS": "Australia/Brisbane", "OOL": "Australia/Brisbane",
        "DRW": "Australia/Darwin",
        "AKL": "Pacific/Auckland",   "WLG": "Pacific/Auckland",
        "CHC": "Pacific/Auckland",   "ZQN": "Pacific/Auckland",

        // ── Pacific Islands ───────────────────────────────────────────────
        "NAN": "Pacific/Fiji",       "SUV": "Pacific/Fiji",
        "PPT": "Pacific/Tahiti",     "GUM": "Pacific/Guam",
        "APW": "Pacific/Apia",       "TBU": "Pacific/Tongatapu",
        "HIR": "Pacific/Guadalcanal","VLI": "Pacific/Efate",
        "NOU": "Pacific/Noumea",     "ROR": "Pacific/Palau",
    ]
}
