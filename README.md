# COMPSOC IRC API
### A simple API for querying the #compsoc IRC logs
###### Disclaimer: This API is probably an insult to all reasonable conventions. Deal with it.

## JSON Goodness
All requests will return __JSON__ with a description of the object (and its size) alongside the returned object.

## Paths
### Returning many lines

The URL pattern for multi-line queries is `GET /all_lines(/by/foo)?(/matching/bar)?(/to/baz)?`.

`GET /all_lines` will return all spoken lines since logging began.

`GET /all_lines/to/baz` will return all spoken lines addressed to __baz__ (For example the line `< foo> baz: Hi!`)

`GET /all_lines/by/foo` will return all lines that a user __foo__ spoke.

`GET /all_lines/matching/bar` will return all lines matching the REGEX (or plain string) __bar__.

`GET /all_lines/by/foo/matching/bar` is a combination of the two above lines. Simples.

#### Example Usage
##### Request
    GET /all_lines/by/batman/matching/WHERE/to/joker
##### Response
The object returned when expecting a many-line response is an array of IRC lines (sometimes an array with one or no elements).

    {
      "description": "all lines spoken on #compsoc by batman, matching 'WHERE' and to joker",
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

##### Request
    GET /all_lines/by/dog
##### Response
    {
      "description": "all lines spoken on #compsoc by dog",
      "size": 3,
      "object": [
        {
          "username": "dog",
          "text": "HELLO?",
          "time": "23:52",
          "target_name": null
        },
        {
          "username": "dog",
          "text": "HELLO??!!?",
          "time": "23:52",
          "target_name": null
        },
        {
          "username": "dog",
          "text": "YES THIS IS DOG",
          "time": "23:52",
          "target_name": null
        }
      ]
    }
### Returning just one line
All one-line queries will short circuit on a match and are therefore generally faster than multi-line queries.

    TODO: Complete short circuiting versions of all of the multi-line features

`GET /first_line` will return the first line ever spoken (since the logging was actually turned on)!

`GET /first_line/by/foo` will return the first line that __foo__ spoke since logging began.

`GET /last_line` will return the last line spoken.

`GET /last_line/by/foo` will return the last line spoken by __foo__.

#### Example Usage
##### Request
    GET /first_line/by/alfred
##### Response    
    {
      "description": "first line spoken on #compsoc by alfred",
      "size": 1,
      "object": {
        "username": "alfred",
        "text": "Evening, Master Wayne.",
        "time": "18:52",
        "target_name": "batman"
      }
    }
