![rsense](https://cloud.githubusercontent.com/assets/1395968/2978144/51565ee2-dbb5-11e3-9b94-e97a37739d03.png)

# Rsense Can See All

[![Gitter chat](https://badges.gitter.im/rsense/rsense.png)](https://gitter.im/rsense/rsense)

RSense is a tool for doing static analysis of Ruby source code. Rsense is used in conjunction with an editor plugin.

RSense is currently under heavy development and ready for testing.  Currently we need to improve the homepage and develop plugins for code_completion.  In the near future we'll also be ready to implement some of the other basic features like `find-definition`. After that, there's plenty to do in the long term.  See the waffle link below to find out where you can pitch in. It would be awesome if you helped get things done.

[![Stories in Ready](https://badge.waffle.io/rsense/rsense.png?label=ready&title=Ready)](https://waffle.io/rsense/rsense)


## Installation
RSense is installed via RubyGems. Be sure to install it with the proper version of Ruby (whichever ruby you are using for your project).

Or install it yourself as:

    $ gem install rsense

## Usage

Install one of these plugins:
-  [rsense/atom-rsense](https://atom.io/packages/rsense)
-  [rsense/SublimeRsense](https://github.com/rsense/SublimeRsense)
-  [rsense/rsense.tmbundle](https://github.com/rsense/rsense.tmbundle)

Start RSense via the commandline with `rsense start`.  Rsense can take two options, in case of a port conflict, you can set the port with `rsense start --port 12345`.  It can also take a project path, like `rsense start --path /path/to/my/project`.  When passed a project path, rsense attempts to preload the project's dependencies based on the `Gemfile.lock`.

## Troubleshooting

You can view rsense's logs at /tmp/rsense.log. Sometimes I like to tail them, like so:

```bash
$ less +F /tmp/rsense.log
```

If you have trouble getting started with RSense, try [rsense/sample](https://github.com/rsense/sample) . It's a known working example, with startup instructions, that should let you test RSense and figure out if it is something you were doing, or more likely, an rsense bug.

Otherwise, come by our gitter chat: [![Gitter chat](https://badges.gitter.im/rsense/rsense.png)](https://gitter.im/rsense/rsense) or create an issue.

## Plugin Authors

Rsense plugins are easy to implement.  First your plugin will need to ensure the Rsense server has been started.  It can do this by shelling out to the command line with `rsense start`.  The server can optionally take a port number like this: `rsense start --port 12345`. The default port is `47367`. It also takes a project path, in case the user has a `.rsense` config file there.  For now, this config file is not very useful, but it may become so in the future.

The rsense server will be running at `http://localhost:47367` (or an alternate port if you specify one).  It communicates via json.  You need to send it json like the following example, via POST:

```json
{
    "command": "code_completion",
    "project": "/home/myprojects/test_gem",
    "file": "/home/myprojects/test_gem/lib/sample.rb",
    "code": "require \"sample/version\"\n\nmodule Sample\n  class Sample\n    attr_accessor :simple\n\n    def initialize\n      @simple = \"simple\"\n    end\n\n    def another\n      \"another\"\n    end\n  end\nend\n\nsample = Sample::Sample.new\nsample",
    "location": {
        "row": 18,
        "column": 7
    }
}
```

For now, `code_completion` is the only command available, but this will change in the future. 

Use absolute paths for both paths as there's no way to be sure where the user may have rsense installed. Project is the root dir of the user's project. This is needed for finding information about project dependencies. Rsense uses project path to get information from RubyGems and Bundler about your dependencies so it can do accurate type inference. RSense uses the filepath for tracking SourcePosition. This is only slightly important for code-completion and most completions will work without it. HOWEVER, when we begin looking into source-rewriting for refactorings, or even exposing the already written Find Definition tool, it will be necessary. 

`code` is the text from the file where a completion is being triggered. We send it with the command because it is unlikely the user will have saved the file.  Many tools which act on source code resolve this by writing to a tempfile, but I find this to be a hacky, and unnecessary solution. Rsense takes the code directly.

Location is tricky. Editor's measure cursor position in different ways. Rsense expects 1-based numbers here, with the first row, and first column being (1, 1). With each editor I've worked with, I've found it necessary to play around until it works. But you can examine `spec/fixtures/test_gem/lib/sample.rb` for the file being from which the above json was generated for use as a test-case.

Rsense will return json that looks like the below:

```json
{
  "completions":
  [
    {
      "name":"taint",
      "qualified_name":"Object#taint",
      "base_name":"Object",
      "kind":"METHOD"
    },
    {
      "name":"methods",
      "qualified_name":"Object#methods",
      "base_name":"Object",
      "kind":"METHOD"
    }
  ]
}

```
Rsense now comes with a secondary executable- `_rsense_commandline.rb`. If forming json and sending commands via http is difficult from your editor, `_rsense_commandline.rb` can do it for you.  Just shell out to it with the needed info, like this:

```bash
_rsense_commandline.rb  --project=/home/projects/myproject  --filepath=/home/projects/myproject/lib/test_case.rb  --text='class TestCase
  def junk
    "Hello"
  end
end

tt = TestCase.new
tt.
'  --location='7:3'
```

## Contributing

Contributions can only be accepted if they include tests.

1. Fork it ( https://github.com/[my-github-username]/rsense/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

RSense is distributed under the term of
[GPLv3+](http://gplv3.fsf.org/).

## Credits

Rsense was originally designed and implemented by [Matsuyama Tomohiro(@m2ym)](https://github.com/m2ym/), and his hard work is still at the core of rsense today.  All of the algorithms for type-detection were implemented by him, with inspiration from multiple places.  You can read about his original version at [Rsense: A Ruby Development tools for Emacs, Vim and Others](http://rsense.github.io/)

In 2013, a major undertaking by @edubkendo to bring it current and improve its usefullness to rubyists was sponsored by the @jruby organization as a Google Summer of Code project.

Special thanks belongs to [Tom Enebo (@enebo)](https://github.com/enebo) who provided excellent mentorship, code, architectural suggestions and more throughout the course of the update.
