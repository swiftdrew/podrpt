<div align="center">
  <h1>Podrpt</h1>
  <p><strong>A CLI tool 💎 for analyzing and reporting outdated CocoaPods dependencies directly to Slack.</strong></p>
  
  <p>
    <a href="https://rubygems.org/gems/podrpt"><img src="https://img.shields.io/gem/v/podrpt.svg?style=flat-square" alt="Gem Version"/></a>
  </p>
</div>

**Podrpt** is a command-line tool written in Ruby, focused on speed and automation. It parses your `Podfile.lock`, identifies outdated pods, and sends a clear, actionable report to Slack, making it perfect for Continuous Integration (CI/CD) pipelines.

## Table of Contents

- [✨ Key Features](#-key-features)
- [🚀 Getting Started](#-getting-started)
  - [1. Installation](#1-installation)
  - [2. Initial Setup](#2-initial-setup)
  - [3. Usage](#3-usage)
- [📜 License](#-license)
- [⚖️ Code of Conduct](#️-code-of-conduct)

---

## ✨ Key Features

* 🚀 **Fast Analysis**: Uses the native CocoaPods API for superior performance, avoiding slow shell-out commands.
* 📊 **Slack Reports**: Sends cleanly formatted notifications directly to a Slack channel, ideal for CI/CD pipelines.
* ⚠️ **Risk Assessment**: Assign custom risk scores and owner teams to each dependency via a `PodsRisk.yaml` file.
* 🎯 **Dependency Filtering**: Ignore transitive dependencies and focus only on the pods you directly manage with a `PodsAllowlist.yaml`.
* ⚙️ **Interactive Setup**: A simple `init` command generates all the necessary configuration files to get you started.
* 🤖 **CI/CD Focused**: Designed to run in automated environments without leaving behind unnecessary file artifacts.

---

## 🚀 Getting Started

Follow the three steps below to set up and run Podrpt in your project.

### 1. Installation

Add the gem to your project's `Gemfile`:
```ruby
gem 'podrpt', '~> 2.0.0'
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

## 📜 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## ⚖️ Code of Conduct

Everyone interacting in the Podrpt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/podrpt/blob/master/CODE_OF_CONDUCT.md).
