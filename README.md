# SQLite FTS5 Arabic Phonetic Fuzzy Trigram Tokenizer

A custom SQLite FTS5 tokenizer designed for Arabic and Latin text with diacritics support, phonetic matching, and fuzzy search capabilities.

## Features

### Arabic Text Support
- **Diacritic-insensitive search**: Matches Arabic text with or without diacritics (tashkeel)
    - `الحمد` matches `ٱلْحَمْدُ`
- **Character normalization**: Normalizes variant Arabic characters
    - Alif variants (أ إ آ ٱ) → ا
    - Yeh variants → ى
    - Teh marbuta handling
- **Unicode-aware trigrams**: Enables substring matching within Arabic words
    - `حمد` matches `الحمد`

### Latin/Transliteration Support
- **Latin diacritic normalization**: Removes diacritics from Latin characters
    - `ṣalāh` → `salah`
- **Phonetic hashing**: Fuzzy matching for Latin text using phonetic patterns
    - `salah` matches `salaah`
    - `quran` matches `kuran`
- **Byte-based trigrams**: Partial/fuzzy matching for Latin words

### Search Capabilities
- **Prefix search**: `الح*` matches `الحمد`
- **Exact match**: Direct token matching
- **Fuzzy match**: Phonetic similarity for Latin text
- **Substring match**: Via trigram tokens

## Usage

It can be used anywhere where sqlite with fts5 is supported.

### Sample using terminal

```
sqlite> .open /Users/gtal/quran.db
sqlite> select load_extension('/Users/gtal/arabic-phonetic-fuzzy-trigram/dist/sqlite3-arabic-phonetic-fuzzy-trigram');
sqlite> CREATE VIRTUAL TABLE docs USING fts5(content, tokenize='arabic_phonetic_fuzzy_trigram');
sqlite> INSERT INTO docs VALUES ('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ');
sqlite> INSERT INTO docs VALUES ('ṣalāh is important صلاة');
sqlite> SELECT * FROM docs WHERE content MATCH 'الحمد';
ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
sqlite> SELECT * FROM docs WHERE content MATCH 'ٱلْحَمْدُ';
ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
sqlite> SELECT * FROM docs WHERE content MATCH 'الح*';
ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
sqlite> SELECT * FROM docs WHERE content MATCH 'حمد';
ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
sqlite> SELECT * FROM docs WHERE content MATCH 'alhamdu';
ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ
sqlite> SELECT * FROM docs WHERE content MATCH 'salah';
ṣalāh is important صلاة
sqlite> SELECT * FROM docs WHERE content MATCH 'salaah';
ṣalāh is important صلاة
sqlite> SELECT * FROM docs WHERE content MATCH 'sal*';
ṣalāh is important صلاة
sqlite> INSERT INTO docs VALUES ('The Quran was first revealed to Prophet Muhammad ﷺ  during the month of Ramadan');
sqlite> SELECT * FROM docs WHERE content MATCH 'kuran';
The Quran was first revealed to Prophet Muhammad ﷺ  during the month of Ramadan
sqlite>
```

## Configuration Options

```sql
CREATE VIRTUAL TABLE docs USING fts5(
    content, 
    tokenize='arabic_phonetic_fuzzy_trigram remove_diacritics 1 generate_trigrams 1 transliterate 1'
);
```

| Option | Default | Description |
|--------|---------|-------------|
| `remove_diacritics` | 1 | Remove Arabic diacritics (tashkeel) |
| `generate_trigrams` | 1 | Generate trigram tokens for fuzzy matching |
| `transliterate` | 1 | Generate transliterated tokens for Arabic text |

## How It Works

### Token Generation Pipeline

For Arabic words:
1. **Primary token**: Clean text (diacritics removed) with `flags=0`
2. **Trigrams**: Unicode-aware 3-character chunks with `flags=1`
3. **Transliteration**: Latin equivalent (if diacritics present) with `flags=1`

For Latin words:
1. **Primary token**: Phonetic hash with `flags=0`
2. **Transliteration**: Diacritic-normalized text with `flags=1`
3. **Phonetic hash**: Of transliterated text with `flags=1`
4. **Trigrams**: 3-byte chunks with `flags=1`

### FTS5 Colocated Tokens

The tokenizer uses `FTS5_TOKEN_COLOCATED` (flags=1) for synonym tokens at the same position, allowing multiple representations of the same word to match.

## Dependencies

- SQLite 3.x with FTS5 enabled
- Standard C library

## Credits

Based on:
- [GreentechApps/sqlite3-arabic-tokenizer](https://github.com/GreentechApps/sqlite3-arabic-tokenizer)
- [streetwriters/sqlite-better-trigram](https://github.com/streetwriters/sqlite-better-trigram)
- [nalgeon/sqlean](https://github.com/nalgeon/sqlean) (translit/phonetic hash)
- SQLite spellfix extension (phonetic hash algorithm)
