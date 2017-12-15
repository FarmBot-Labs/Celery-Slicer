# Flattening Celery Script

This is a proof of concept for taking a tree of celery script nodes and flattening it so that every nodoe in the tree has a numeric address, similar to pointers in some programming languages.

## Why?

 * :star: Makes it easier to resolve variables and closures.
 * Makes it easier to generate stack traces when execution halts.
 * Makes it easier to serialize stat when execution resumes (eg: `Stopped at address 3`)
 * Makes it easier to pause the VM (references needs to be converted to JSON links)

## Before

```
{
  "kind": "sequence",
  "args": {
    "locals": {
      "kind": "scope_declaration",
      "args": {},
      "body": []
    },
    "version": 6,
    "is_outdated": false,
    "label": "Subsequence"
  },
  "body": [
    {
      "kind": "send_message",
      "args": {
        "message": "subsequence is executing",
        "message_type": "success"
      },
      "body": [
        {
          "kind": "channel",
          "args": {
            "channel_name": "toast"
          }
        }
      ]
    }
  ]
}
```
## After

```
{
	"0": { "__KIND__": "NULL" },
	"1": {
		"__KIND__": "sequence",
		"$parent": "0",
		"$body": "2",
		"$locals": "4",
		"version": "6",
		"is_outdated": "false",
		"label": "\"Subsequence\""
	},
	"2": {
		"__KIND__": "send_message",
		"$parent": "1",
		"$body": "3",
		"message": "\"subsequence is executing\"",
		"message_type": "\"success\""
	},
	"3": {
		"__KIND__": "channel",
		"$parent": "2",
		"channel_name": "\"toast\""
	},
	"4": {
		"__KIND__": "scope_declaration",
		"$parent": "1"
	}
}
```

## Elixir Flavored Output

```
%{
  0 => %{
    __KIND__: "NULL"},
  1 => %{
      :__KIND__     => "sequence",
      "$body"       => 2,
      "$locals"     => 6,
      "$parent"     => 0,
      "is_outdated" => false,
      "label"       => "Move Relative Test",
      "version"     => 6
    },
  2 => %{
    :__KIND__ => "move_relative",
    "$parent" => 1,
    "speed"   => 100,
    "x"       => 0,
    "y"       => 100,
    "z"       => 0
  },
  3 => %{
    :__KIND__ => "move_relative",
    "$parent" => 2,
    "speed"   => 100,
    "x"       => 0,
    "y"       => -100,
    "z"       => 0
  },
  4 => %{
    :__KIND__      => "send_message",
    "$body"        => 5,
    "$parent"      => 3,
    "message"      => "Move Relative test complete",
    "message_type" => "success"
  },
  5 => %{
    :__KIND__      => "channel",
    "$parent"      => 4,
    "channel_name" => "toast"
  },
  6 => %{
    :__KIND__ => "scope_declaration",
    "$parent" => 1
  }
}
```

## Syntax Notes:

 * `$parent`, `$body`, and othe `$vars`: Sometimes a number is more than just a number. Anytime we serialize a reference (pointer), we prepend a `$` to the arg name.
 * `__KIND__`: Same as `kind` in `CeleryScript`. It's `__SCREAMING__` so you remember that it is not an arg.
 * Location 0: Always `nothing`. Can be used as a null pointer.

## Try It

Reference implementation is in `2_typescript_version/try_it.ts`

```
yarn install
npm start
```
