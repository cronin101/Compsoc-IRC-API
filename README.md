# COMPSOC IRC API
### A simple API for querying the #compsoc IRC logs

## Return Type
All requests will return __JSON__ with a description of the object alongside the returned object

## Paths
`GET /all_lines` will return all spoken lines since logging began.

`GET /all_lines/by/foo` will return all lines that a user __foo__ spoke.

`GET /all_lines/matching/bar` will return all lines matching the REGEX (or plain string) __bar__.

`GET /all_lines/by/foo/matching/bar` is a combination of the two above lines. Simples.
