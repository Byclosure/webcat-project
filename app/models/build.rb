require 'json'

class Build < ActiveRecord::Base

  TYPE_CI = 1
  TYPE_INDIVIDUAL = 2

  belongs_to :project
  has_one :build_stats
  has_many :test_issues
  has_many :step_screenshots

  attr_accessible :report, :successful, :number, 
          :build_type, :intent, :commit_id, :step_definitions, :step_definition_matches

  def successfuls
    Build.find_by successful: true
  end

  def faileds
    Build.find_by successful: false
  end

  def individual_build?
    build_type == TYPE_INDIVIDUAL
  end

  def ci_build?
    build_type == TYPE_CI
  end

  def successful?
    successful
  end

  def head
    commit_id
  end

  def pretty_name
    created_at.strftime('%d-%-m-%y %k:%M')
  end

  def features
    @features ||= scenarios.map { |s| s.feature }.uniq
  end

  def scenarios_by_feature(feature_name)
    scenarios.select{ |s| s.feature == feature_name }
  end

  def find_scenario_by_id(scenario_id)
    scenarios.select{|s| s.id == scenario_id}.first
  end

  def find_scenario_by_named_id(scenario_id)
    scenarios.select{|s| s.named_id == scenario_id}.first
  end

  def scenarios
    @scenarios_without_skipped ||= scenarios_unfiltered.select{ |s| !s.skipped? }
  end

  def skipped_scenarios
    @scenarios_skipped ||= scenarios_unfiltered.select{ |s| s.skipped? }
  end

  def scenarios_unfiltered
    if(@scenarios.nil?)
      @scenarios = []
      @all_steps = []

      current_scenario_id = 0

      parsed_report.each { |feature|

        feature_tags =
          if(feature['tags'].nil?)
            []
          else
            feature['tags'].map { |tag| tag['name'] }
          end

        feature['elements'].each {|scenario|
          if scenario['type'] == 'scenario_outline'
            next
          end

          scenario_tags =
            if(scenario['tags'].nil?)
               []
            else
              scenario['tags'].map { |tag| tag['name'] }
            end

          current_scenario_id += 1

          @scenarios << Scenario.new(
              id: current_scenario_id,
              named_id: scenario['id'],
              name: scenario['name'],
              steps: process_steps(scenario['id'], scenario['steps']),
              feature: feature['name'],
              build: self,
              uri: feature['uri'],
              keyword: scenario['keyword'],
              tags: (feature_tags.concat scenario_tags).map(&:downcase).uniq)
        }
      }
    end

    @scenarios
  end

  def failed_scenarios
    scenarios.select { |scenario| !scenario.passed? }
  end

  def steps
    scenarios_unfiltered
    @all_steps
  end

  private
  def process_steps(scenario_id, unprocessed_steps)
    steps = []

    unprocessed_steps.each_index { |index|
      step = unprocessed_steps[index]

      steps << Step.new(
        scenario_named_id: scenario_id,
        order: index,
        location: step['match']['location'],
        result: Step.map_result(step['result']['status']),
        name: step['name'],
        keyword: step['keyword'],
        shot: step['embeddings'],
        error: step['result']['error_message'],
        rows: step['rows'].nil? ? nil : step['rows'].map{|r| r['cells']},
        build: self)
    }

    @all_steps.concat steps
    steps
  end

  def parsed_json
    @parsed_json ||= JSON.parse json
  end

  def parsed_report
    @parsed_report ||= JSON.parse report
  end
end
