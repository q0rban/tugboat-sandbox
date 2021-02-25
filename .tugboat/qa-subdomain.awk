{
  # Convert to lowercase.
  str = tolower($0);
  # Replace all special chars with hyphens.
  gsub(/[^a-z0-9]/, "-", str);
  # Deduplicate hyphens.
  gsub(/-+/, "-", str);
  # Remove leading / trailing hyphens.
  gsub(/(^-)|(-$)/, "", str);
  # Trim the string down to 25 characters and print.
  printf 'SetEnvIf Request_URI ".*" QA_SUBDOMAIN=%s\n', substr(str, 0, 25)
}
