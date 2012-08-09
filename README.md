# COMPSOC IRC API
### A simple API for querying the #compsoc IRC logs

## JSON Goodness
All requests will return __JSON__ with a description of the object (and its size) alongside the returned object.

## Paths
### Returning many lines
`GET /all_lines` will return all spoken lines since logging began.

`GET /all_lines/by/foo` will return all lines that a user __foo__ spoke.

`GET /all_lines/matching/bar` will return all lines matching the REGEX (or plain string) __bar__.

`GET /all_lines/by/foo/matching/bar` is a combination of the two above lines. Simples.

#### Example Usage
##### Request
    GET /all_lines/by/batman/matching/WHERE
##### Response
    {
      "description": "all lines spoken on #compsoc by batman",
      "filter": "WHERE",
      "size": 1,
      "object": [
        {
          "username": "batman",
          "text": "WHERE IS SHE??!?",
          "time": "22:31",
          "target_name": "joker"
        }
      ]
    }    
