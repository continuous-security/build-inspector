# Build Profiler

## Requirements
If you don't have `brew cask` installed, run this:
```
brew tap phinze/homebrew-cask && brew install brew-cask
```

If you don't have `vagrant` installed, run this:
```
brew cask install vagrant
```

This tool also makes use of the `sahara` plugin for snapshots. Install with this:
```
vagrant plugin install sahara
```

## Running
First, clone this repo and move inside the repo directory. Since this tool does not manage vagrant for you, yet, you'll have to do it yourself. This step will take a while the first time, but won't be necessary again. Eventually, this step will be eliminated. Start vagrant and build the image:
```
vagrant up
```

Once vagrant is started, save a snapshot with:
```
vagrant sandbox on
```

Until this can be automated, you must run this after **each** run of this tool:
```
vagrant sandbox rollback
```

## Usage
```
Usage profiler.rb [options] <git repo URL> <build command>
    -h, --help                       Display this screen
    -d, --duration #                 Wait this long after building before stopping, in minutes, default=15
```

### Gradle Example

```
ruby profiler.rb https://github.com/CalebFenton/TotallyLegitApp.git "./gradlew build; ./gradlew backdoor"
```

The above project has a task called `backdoor` that adds a reverse connect shell to `~/.bashrc`.

After running, you'll have a file called `evidence.zip` which has all network activity, file system changes, and any new processes. The guest OS is still running at this point, so you can inspect things further.

### Bundler Example

```
ruby profiler.rb https://github.com/jsyeo/harmless-project.git "bundle install"
```

This sinata project uses a malicious gem that uploads your machine's environment variables to firebase. After running, you should see an output printed to stdout showing a list of outgoing connections. It should show that the `bundle install` step connected to firebase.

## Development
When you want to experiment, just do `vagrant sandbox on`. Make all the changes you want to the image. If you'd like to keep them do `vagrant sandbox commit` and if you don't do `vagrant sandbox rollback`.
