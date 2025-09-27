# Podrpt

Podrpt is a command-line tool written in Ruby to analyze and report outdated CocoaPods dependencies in iOS projects. It's designed to be fast, flexible, and CI/CD-friendly, providing clear, actionable reports directly to Slack.

It leverages the native CocoaPods API for high-performance analysis, avoiding slow external process calls for version fetching.

**Features**
- **Fast Analysis**: Uses the native CocoaPods gem API instead of shelling out to pod search.

- **Outdated Pod Detection**: Compares versions in your **Podfile.lock** against the latest public releases.

- **Risk Assessment**: Assign custom risk scores and owner teams to dependencies via a PodsRisk.yaml file.

- **Dependency Filtering**: Use an PodsAllowlist.yaml file to filter out transitive dependencies and focus only on the pods you directly manage.

- **Slack Notifications**: Delivers a clean, formatted report directly to a Slack channel, perfect for CI/CD pipelines.

- **CI/CD Focused**: Designed to run in automated environments without leaving behind unnecessary file artifacts.

- Interactive Setup: A simple init command to generate all necessary configuration files.- 

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'podrpt', '~> 0.1.0'
```

And then execute:
```sh
bundle install
```

## Setup
After installing the gem, you need to generate the configuration files in your project's root directory. Navigate to your iOS project's root folder and run the interactive setup command:

And then execute:
```sh
bundle exec podrpt init
```

This command will:

1 Create a sample **PodsRisk.yaml** file for defining risk scores.
```yaml
default:
  risk: 500
  owners: []
pods:
  XPTO:
    risk: 100
    owners: ['core-team']
```

2 Create a sample **PodsAllowlist.yaml** file for filtering dependencies.
3 Prompt you for your Slack Incoming Webhook URL and save it securely in a .podrpt.yml file (which should be added to your .gitignore).

After running init, customize the generated .yaml files to fit your project's needs.

## Usage
To run an analysis and send a report to Slack, simply execute the run command:

And then execute:
```sh
bundle exec podrpt run
```

If you want to see what will be sent and what URL is configured, use this command:

```sh
bundle exec podrpt run --dry-run
```

The report will only include outdated pods by default.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Podrpt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/podrpt/blob/master/CODE_OF_CONDUCT.md).
