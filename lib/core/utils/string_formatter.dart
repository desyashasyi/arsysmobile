String capitalizeEachWord(String text) {
  if (text.isEmpty) {
    return text;
  }
  // Don't change strings that are already all uppercase (like acronyms)
  if (text == text.toUpperCase()) {
    return text;
  }
  return text.split(' ').map((word) {
    if (word.isEmpty) {
      return '';
    }
    // Handle cases like (Tesis)
    if (word.startsWith('(') && word.endsWith(')')) {
      return '(${capitalizeEachWord(word.substring(1, word.length - 1))})';
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
