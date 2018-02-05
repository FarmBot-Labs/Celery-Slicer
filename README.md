# Flattening Celery Script

This is a proof of concept for taking a tree of celery script nodes and flattening it so that every node in the tree has a numeric address, similar to pointers in some programming languages.

## Why?

 * :star: Makes it easier to resolve variables and closures.
 * Makes it easier to generate stack traces when execution halts (a tricky problem in the past).
 * Makes it easier to serialize state when execution resumes (eg: `Stopped at address 3`)
 * Makes it easier to pause the VM (references are stored as integers, making JSON generation trivial)

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
## After (JSON version)

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
    :__KIND__ => "NULL"
  },
  1 => %{
    :__KIND__     => "sequence",
    "is_outdated" => false,
    "label"       => "Move Relative Test",
    "version"     => 6,
    "🔗body"      => 2,
    "🔗locals"    => 6,
    "🔗parent"    => 0
  },
  2 => %{
    :__KIND__  => "move_relative",
    "speed"    => 100,
    "x"        => 0,
    "y"        => 100,
    "z"        => 0,
    "🔗parent" => 1
  },
  3 => %{
    :__KIND__  => "move_relative",
    "speed"    => 100,
    "x"        => 0,
    "y"        => -100,
    "z"        => 0,
    "🔗parent" => 2
  },
  4 => %{
    :__KIND__      => "send_message",
    "message"      => "Move Relative test complete",
    "message_type" => "success",
    "🔗body"       => 5,
    "🔗parent"     => 3
  },
  5 => %{
    :__KIND__      => "channel",
    "channel_name" => "toast",
    "🔗parent"     => 4
  },
  6 => %{
    :__KIND__  => "scope_declaration",
    "🔗parent" => 1
  }
}
```


## Syntax Notes:

 * `$parent`, `$body`, and other `$vars`: Sometimes a number is more than just a number. Anytime we serialize a reference (pointer), we prepend a `$` to the arg name.
 * `__KIND__`: Same as `kind` in `CeleryScript`. It's `__SCREAMING__` so you remember that it is not an arg.
 * Location 0: Always `nothing`. Can be used as a null pointer.

## Try It (JS)

Reference implementation is in `2_typescript_version/try_it.ts`

```
yarn install
npm start
```

## Try It (IEx)

```
iex -S mix
{:ok, ok} = Slicer.test_things
```

## Try It (Ruby)

```
ruby 3_ruby_version/demo.rb
```
